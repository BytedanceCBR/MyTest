//
//  FHHouseFindHelpViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpViewModel.h"
#import "FHHouseFindHelpSubmitCell.h"
#import "FHHouseFindHeaderView.h"
#import "FHHouseFindHelpRegionCell.h"
#import "FHHouseFindPriceCell.h"
#import "FHHouseFindTextItemCell.h"
#import "FHHouseFindHelpContactCell.h"
#import <FHHouseBase/FHEnvContext.h>
#import "FHHouseFindSelectModel.h"
#import <FHHouseBase/FHHouseType.h>
#import <TTNewsAccountBusiness/TTAccountManager+AccountInterfaceTask.h>
#import <FHCommonUI/ToastManager.h>
#import <TTReachability/TTReachability.h>
#import "FHHouseFindHelpRegionSheet.h"
#import <TTAccountSDK/TTAccount.h>
#import "FHHouseFindRecommendModel.h"
#import "FHHouseFindHelpMainViewModel.h"
#import "FHMainApi+HouseFind.h"

#define HELP_HEADER_ID @"header_id"
#define HELP_ITEM_HOR_MARGIN 20
#define HELP_MAIN_CELL_ID @"main_cell_id"
#define HELP_REGION_CELL_ID @"region_cell_id"
#define HELP_PRICE_CELL_ID @"price_cell_id"
#define HELP_NORMAL_CELL_ID @"normal_cell_id"
#define HELP_CONTACT_CELL_ID @"contact_cell_id"
#define HELP_SUBMIT_CELL_ID @"submit_cell_id"

#define ROOM_MAX_COUNT 2
#define REGION_MAX_COUNT 3


extern NSString *const kFHPhoneNumberCacheKey;

@interface FHHouseFindHelpViewModel ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource, UITableViewDelegate, FHHouseFindPriceCellDelegate>

@property(nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *secondFilter;
@property (nonatomic , strong) NSArray<NSString *> *titlesArray;
@property (nonatomic , strong) RACDisposable *configDisposable;
@property (nonatomic , assign) BOOL available;
@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) NSMutableDictionary *selectMap; // housetype : FHHouseFindSelectModel
@property (nonatomic , strong) FHSearchFilterConfigItem *regionConfigItem;
@property (nonatomic , strong) FHSearchFilterConfigItem *priceConfigItem;
@property (nonatomic , strong) FHSearchFilterConfigItem *roomConfigItem;

@property (nonatomic , strong) FHHouseFindSelectItemModel *selectRegionItem;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;

@property (nonatomic , weak) FHHouseFindHelpContactCell *contactCell;
@property(nonatomic , assign) BOOL isRequestingSMS;
@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , assign) NSInteger verifyCodeRetryTime;
//是否重新是重新发送验证码
@property(nonatomic , assign) BOOL isVerifyCodeRetry;
@property(nonatomic , assign) CGFloat lastY;

@end

@implementation FHHouseFindHelpViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView recommendModel:(FHHouseFindRecommendDataModel *)recommendModel
{
    self = [super init];
    if (self) {
        
        _houseType = FHHouseTypeSecondHandHouse;
        _selectMap = [NSMutableDictionary new];
        FHHouseFindSelectItemModel *selectItem = [FHHouseFindSelectItemModel new];
        selectItem.tabId = FHSearchTabIdTypeRegion;
        _selectRegionItem = selectItem;
        _recommendModel = recommendModel;
        
        _collectionView = collectionView;
        [self registerCell:collectionView];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        _collectionView.allowsMultipleSelection = YES;

        [self setupHouseContent:nil];

//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:self.recommendModel.openUrl]];
        [self refreshHouseFindItems:routeParamObj.queryParams];
//        RACDisposable *disposable = [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(FHConfigDataModel * _Nullable x) {
//            if (x) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [wself setupHouseContent:x];
//                });
//            }
//        }];
//        self.configDisposable = disposable;
        
    }
    return self;
}

- (void)resetBtnDidClick
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    for (FHHouseFindSelectItemModel *itemModel in model.items) {
        [itemModel.selectIndexes removeAllObjects];
    }
    [self.collectionView reloadData];
}

- (void)confirmBtnDidClick
{
    [self.collectionView endEditing:YES];
    __weak typeof(self) wself = self;
    
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
    if (selectItem.higherPrice.length < 1 && selectItem.lowerPrice.length < 1 && selectItem.selectIndexes.count < 1) {
        [[ToastManager manager] showToast:@"请选择购房预算"];
        return;
    }
    selectItem = [model selectItemWithTabId:FHSearchTabIdTypeRoom];
    if (selectItem.selectIndexes.count < 1) {
        [[ToastManager manager] showToast:@"请选择户型"];
        return;
    }
    selectItem = [model selectItemWithTabId:FHSearchTabIdTypeRegion];
    if (selectItem.selectIndexes.count < 1) {
        [[ToastManager manager] showToast:@"请选择区域"];
        return;
    }
    
    if([TTAccount sharedAccount].isLogin){
        [self submitAction];
        return;
    }
    
    NSString *phoneNumber = self.contactCell.phoneInput.text;
    NSString *smsCode = self.contactCell.varifyCodeInput.text;

    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    if(smsCode.length == 0){
        [[ToastManager manager] showToast:@"验证码为空"];
        return;
    }
    [self requestQuickLogin:phoneNumber smsCode:smsCode completion:^(UIImage * _Nonnull captchaImage, NSNumber * _Nonnull newUser, NSError * _Nonnull error) {
        if(!error){
//            [[ToastManager manager] showToast:@"登录成功"];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPhoneNumberCacheKey];
            [wself reloadCollectionViewSection:[wself.collectionView indexPathForCell:wself.contactCell].section];
            [wself submitAction];
        }else{
            NSString *errorMessage = [wself errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
        }
    }];
}
#pragma mark 提交选项
- (void)submitAction
{
    __weak typeof(self)wself = self;
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *selectModel = [self selectModelWithType:ht];
    NSMutableString *query = [NSMutableString new];
    if (selectModel.items.count > 0) {
        for (FHHouseFindSelectItemModel *item in selectModel.items ) {
            NSString *q = [item selectQuery];
            if (!q) {
#if DEBUG
                NSLog(@"WARNING select query is nil for item : %@",item);
#endif
                continue;
            }
            if (query.length > 0) {
                [query appendString:@"&"];
            }
            [query appendString:q];
        }
    }
    NSLog(@"zjing query : %@",query);
    [FHMainApi saveHFHelpFindByHouseType:[NSString stringWithFormat:@"%ld",_houseType] query:query phoneNum:@"" completion:^(FHHouseFindRecommendModel * _Nonnull model, NSError * _Nonnull error) {
        if (model && error == NULL) {
            if (model.data) {
                wself.recommendModel = model.data;
                [wself jump2HouseFindResultPage:[model toDictionary]];
            }
        } else {
            NSString *message = error.localizedDescription ? : @"请求失败，请稍后重试";
            [[ToastManager manager]showToast:message];
        }
    }];
}

- (void)jump2HouseFindResultPage:(NSDictionary *)recommendDict
{
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (recommendDict) {
        infoDict[@"recommend_house"] = recommendDict;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://house_find"];
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)setupHouseContent:(FHConfigDataModel *)configData
{
    if (!configData) {
        configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    }
    
    self.secondFilter = nil;
    
    if (!configData) {
        //show no data
        if (self.showNoDataBlock) {
            self.showNoDataBlock(YES,NO);
        }
    }else{
        
        BOOL avaiable = configData.cityAvailability.enable.boolValue;
        if (self.showNoDataBlock) {
            self.showNoDataBlock(NO,avaiable);
        }
        self.available = avaiable;
        
        if (!avaiable) {
            return;
        }
        
        NSMutableArray *titles = @[].mutableCopy;
        NSMutableArray *filterArray = @[].mutableCopy;
        FHSearchFilterConfigItem *priceItem = nil;
        FHSearchFilterConfigItem *roomItem = nil;
        FHSearchFilterConfigItem *regionItem = nil;
        NSInteger sectionNum = 1;

        for (NSInteger index = 0; index < configData.filter.count; index++) {
            FHSearchFilterConfigItem *configItem = configData.filter[index];
            if ([configItem.tabId integerValue] == FHSearchTabIdTypeRegion) {
                regionItem = configItem;
            }else if ([configItem.tabId integerValue] == FHSearchTabIdTypePrice) {
                priceItem = configItem;
            }else if ([configItem.tabId integerValue] == FHSearchTabIdTypeRoom) {
                roomItem = configItem;
            }
        }
        if (priceItem) {
            [filterArray addObject:priceItem];
            [titles addObject:@"您的购房预算是多少？"];
        }
        if (roomItem) {
            [filterArray addObject:roomItem];
            [titles addObject:@"您想买的户型是？"];
        }
        if (regionItem) {
            [filterArray addObject:regionItem];
            [titles addObject:@"您想买的区域是？"];
        }
        self.priceConfigItem = priceItem;
        self.regionConfigItem = regionItem;
        self.roomConfigItem = roomItem;

        self.secondFilter = filterArray;
        self.titlesArray = titles;
        [self.collectionView reloadData];
    }
}

- (NSArray<FHSearchFilterConfigItem *> *)filterOfHouseType:(FHHouseType) ht
{
    switch (ht) {
        case FHHouseTypeSecondHandHouse:
            return _secondFilter;
        default:
            break;
    }
    return nil;
}

- (FHHouseFindSelectModel *)selectModelWithType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = self.selectMap[@(ht)];
    if (!model) {
        model = [[FHHouseFindSelectModel alloc] init];
        self.selectMap[@(ht)] = model;
    }
    return model;
}

- (void)showRegionSheet:(FHHouseFindSelectItemModel *)selectItem section:(NSInteger)section
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    [_selectRegionItem.selectIndexes removeAllObjects];
    if (selectItem.selectIndexes.count > 0) {
        [_selectRegionItem.selectIndexes addObjectsFromArray:selectItem.selectIndexes];
    }
    CGRect frame = [UIScreen mainScreen].bounds;
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    __weak typeof(self)wself = self;
    frame.size.height = REGION_CONTENT_HEIGHT + bottomHeight;
    FHHouseFindHelpRegionSheet *sheet = [[FHHouseFindHelpRegionSheet alloc]initWithFrame:frame];
    sheet.tableViewDelegate = self;
    [sheet showWithCompleteBlock:^{
        [wself updateRegionItem:section];
    } cancelBlock:^{
        
    }];
}

- (void)updateRegionItem:(NSInteger)section
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:FHSearchTabIdTypeRegion];
    if (!selectItem) {
        selectItem = [model makeItemWithTabId:FHSearchTabIdTypeRegion];
    }
    [selectItem.selectIndexes removeAllObjects];
    if (_selectRegionItem.selectIndexes.count > 0) {
        [selectItem.selectIndexes addObjectsFromArray:_selectRegionItem.selectIndexes];
    }

    [self reloadCollectionViewSection:section];
}

- (void)refreshHouseFindItems:(NSDictionary *)params
{
    if (self.priceConfigItem) {
        
        [self selectItemWithConfigItem:self.priceConfigItem withParams:params];
    }
    if (self.roomConfigItem) {
        
        [self selectItemWithConfigItem:self.roomConfigItem withParams:params];
    }
    if (self.regionConfigItem) {
        
        [self selectItemWithConfigItem:self.regionConfigItem withParams:params];
    }
}

- (void)selectItemWithConfigItem:(FHSearchFilterConfigItem *)item withParams:(NSDictionary *)params
{
    if (!item) {
        return;
    }
    FHHouseType ht = _houseType;
    NSArray *filter = [self filterOfHouseType:ht];
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];

    FHSearchFilterConfigOption *options = [item.options firstObject];
    NSString *optionType = options.type;
    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
    if (!selectItem) {
        selectItem = [model makeItemWithTabId:item.tabId.integerValue];
    }
    if (!selectItem.configOption) {
        selectItem.configOption = [item.options firstObject];
    }
    if (item.tabId.integerValue == FHSearchTabIdTypeRegion && options.options.count > 0) {
        for (FHSearchFilterConfigOption *subOptions in options.options) {
            if (![subOptions.type isEqualToString:@"empty"]) {
                optionType = subOptions.type;
                break;
            }
        }
    }
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        
        NSString *keyStr = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([keyStr hasPrefix:optionType]) {
            
            if ([obj isKindOfClass:[NSArray class]]) {
                NSArray* items = (NSArray*)obj;
                
                [items enumerateObjectsUsingBlock:^(NSString *it, NSUInteger idx, BOOL * _Nonnull stop) {
                    for (NSInteger index = 0; index < options.options.count; index++) {
                        FHSearchFilterConfigOption *option = options.options[index];
                        if (![it isEqualToString:option.value]) {
                            continue;
                        }
                        if (item.tabId.integerValue == FHSearchTabIdTypePrice) {
                            
                            [model clearAddSelecteItem:selectItem withIndex:index];
                        }else {
                            FHSearchFilterConfigOption *option = nil;
                            if (item.options.count > 0) {
                                option = [item.options firstObject];
                            }
                            if ([option.supportMulti boolValue]) {
                                [model addSelecteItem:selectItem withIndex:index];
                            }else {
                                [model clearAddSelecteItem:selectItem withIndex:index];
                            }
                        }
                    }
                }];
            }else {
                for (NSInteger index = 0; index < options.options.count; index++) {
                    FHSearchFilterConfigOption *option = options.options[index];
                    if ([obj isEqualToString:option.value]) {
                        [model clearAddSelecteItem:selectItem withIndex:index];
                    }
                }
            }
        }
    }];
}

- (NSString *)encodingIfNeeded:(NSString *)queryCondition
{
    if (![queryCondition containsString:@"%"]) {
        return [[queryCondition stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    return queryCondition;
}

#pragma mark - price cell delegate
- (void)reloadCollectionViewSection:(NSInteger)section
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    [CATransaction commit];
}
-(void)updateLowerPrice:(NSString *)price inCell:(FHHouseFindPriceCell *)cell
{
    FHHouseType ht = cell.tag;
    FHHouseFindSelectItemModel *priceItem = [self priceItemWithHouseType:ht];
    priceItem.lowerPrice = price;
    [priceItem.selectIndexes removeAllObjects];
    [self reloadCollectionViewSection:[self.collectionView indexPathForCell:cell].section];
}

-(void)updateHigherPrice:(NSString *)price inCell:(FHHouseFindPriceCell *)cell
{
    FHHouseType ht = cell.tag;
    FHHouseFindSelectItemModel *priceItem = [self priceItemWithHouseType:ht];
    priceItem.higherPrice = price;
    [priceItem.selectIndexes removeAllObjects];
    [self reloadCollectionViewSection:[self.collectionView indexPathForCell:cell].section];
}
-(FHHouseFindSelectItemModel *)priceItemWithHouseType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    
    FHHouseFindSelectItemModel *priceItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
    if (!priceItem) {
        priceItem = [model makeItemWithTabId:FHSearchTabIdTypePrice];
    }
    priceItem.fromType = FHHouseFindPriceFromTypeHelp;
    return priceItem;
}

#pragma mark - UICollectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.titlesArray.count + 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *filter = [self filterOfHouseType:_houseType];
    if (filter.count > section) {
        FHSearchFilterConfigItem *item = filter[section];
        FHSearchFilterConfigOption *options = [item.options firstObject];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            return options.options.count;
        }else if ([item.tabId integerValue] == FHSearchTabIdTypeRegion) {
            return 1;
        }
        return options.options.count;
    }
    return 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    FHHouseType ht = _houseType;
    NSArray *filter = [self filterOfHouseType:ht];
    if (filter.count > section) {

        FHHouseFindSelectModel *model = [self selectModelWithType:ht];
        FHSearchFilterConfigItem *item = filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {

            if (indexPath.item == 0) {
                
                FHHouseFindPriceCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_PRICE_CELL_ID forIndexPath:indexPath];
                pcell.tag = ht;
                pcell.delegate = self;
                
                FHHouseFindSelectItemModel *priceItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
                if (!priceItem) {
                    priceItem = [model makeItemWithTabId:FHSearchTabIdTypePrice];
                    priceItem.rate = item.rate;
                    priceItem.configOption = [item.options firstObject];
                }else{
                    priceItem.rate = item.rate;
                    priceItem.configOption = [item.options firstObject];
                }
                priceItem.fromType = FHHouseFindPriceFromTypeHelp;
                if (priceItem) {
                    [pcell updateWithLowerPrice:priceItem.lowerPrice higherPrice:priceItem.higherPrice];
                }
                
                return pcell;
            }else {
                
                FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_NORMAL_CELL_ID forIndexPath:indexPath];
                NSString *text = nil;
                
                FHSearchFilterConfigOption *options = [item.options firstObject];
                if (options.options.count > indexPath.item) {
                    FHSearchFilterConfigOption *option = options.options[indexPath.item];
                    text = option.text;
                }
                BOOL selected = NO;
                if (model) {
                    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
                    selected = [model selecteItem:selectItem containIndex:indexPath.item];
                }
                
                [tcell updateWithTitle:text highlighted:selected];
                return tcell;
            }

        }else if ([item.tabId integerValue] == FHSearchTabIdTypeRegion) {
            
            FHHouseFindHelpRegionCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_REGION_CELL_ID forIndexPath:indexPath];
            FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
            FHSearchFilterConfigOption *options = [item.options firstObject];
            NSMutableString *titleString = [NSMutableString stringWithString:@""];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
            NSMutableArray *itemsArray = [selectItem.selectIndexes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            [itemsArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj.integerValue < options.options.count) {
                    FHSearchFilterConfigOption *itemOption = options.options[obj.integerValue];
                    if (idx == 0) {
                        [titleString appendString:itemOption.text];
                    }else {
                        [titleString appendString:[NSString stringWithFormat:@"/%@",itemOption.text]];
                    }
                }
            }];
            [pcell updateWithTitle:titleString];
            return pcell;
        }else {

            FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_NORMAL_CELL_ID forIndexPath:indexPath];
            NSString *text = nil;

            FHSearchFilterConfigOption *options = [item.options firstObject];
            if (options.options.count > indexPath.item) {
                FHSearchFilterConfigOption *option = options.options[indexPath.item];
                text = option.text;
            }else{
                text = options.text;
            }
            BOOL selected = NO;
            if (model) {
                FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
                selected = [model selecteItem:selectItem containIndex:indexPath.item];
            }
            [tcell updateWithTitle:text highlighted:selected];
            return tcell;
        }
    }
    
    if (indexPath.item == 0) {
        
        FHHouseFindHelpContactCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_CONTACT_CELL_ID forIndexPath:indexPath];
        pcell.delegate = self;
        self.contactCell = pcell;

        if([TTAccount sharedAccount].isLogin){
            
            TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
            pcell.phoneNum = userInfo.mobile;
        }else {
            pcell.phoneNum = nil;
        }
        return pcell;
    }
    FHHouseFindHelpSubmitCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_SUBMIT_CELL_ID forIndexPath:indexPath];
    __weak typeof(self)wself = self;
    pcell.resetBlock = ^{
        [wself resetBtnDidClick];
    };
    pcell.confirmBlock = ^{
        [wself confirmBtnDidClick];
    };
    return pcell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HELP_HEADER_ID forIndexPath:indexPath];
    NSInteger section = indexPath.section;
    if (self.titlesArray.count > section) {
        [headerView updateTitle:self.titlesArray[section] showDelete:NO];
    }else {
        [headerView updateTitle:@"您的联系方式？" showDelete:NO];
    }
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseType ht = _houseType;
    NSInteger section = indexPath.section;
    NSArray *filter = [self filterOfHouseType:ht];
    if (filter.count > section) {
        FHSearchFilterConfigItem *item =  filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            if (indexPath.item == 0) {
                return CGSizeMake(collectionView.frame.size.width - 2*HELP_ITEM_HOR_MARGIN, 36);
            }else {
                return CGSizeMake(74, 30);
            }
        }else if ([item.tabId integerValue] == FHSearchTabIdTypeRegion) {
            return CGSizeMake(collectionView.frame.size.width, 36);
        }else {
            return CGSizeMake(74, 30);
        }
    }
    if (indexPath.item == 0) {
        
        if([TTAccount sharedAccount].isLogin){
            return CGSizeMake(collectionView.frame.size.width, 90);
        }
        return CGSizeMake(collectionView.frame.size.width, 150);
    }
    return CGSizeMake(collectionView.frame.size.width, 60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];

    NSArray *filter = [self filterOfHouseType:ht];
    NSInteger section = indexPath.section;
    if (filter.count > section) {

        FHSearchFilterConfigItem *item = filter[section];

        FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
        if (!selectItem) {
            selectItem = [model makeItemWithTabId:item.tabId.integerValue];
        }
        if (!selectItem.configOption) {
            selectItem.configOption = [item.options firstObject];
        }
        if (item.tabId.integerValue == FHSearchTabIdTypeRegion) {
            
            _regionConfigItem = item;
            [self showRegionSheet:selectItem section:indexPath.section];
        }else {
            
            if([model selecteItem:selectItem containIndex:indexPath.item]){
                //反选
                [model delSelecteItem:selectItem withIndex:indexPath.item];
            }else{
                if (item.tabId.integerValue == FHSearchTabIdTypePrice) {
                    [model clearAddSelecteItem:selectItem withIndex:indexPath.item];
                    selectItem.lowerPrice = nil;
                    selectItem.higherPrice = nil;
                }else if (item.tabId.integerValue == FHSearchTabIdTypeRoom) {
                    if (selectItem.selectIndexes.count >= ROOM_MAX_COUNT) {
                        [[ToastManager manager]showToast:[NSString stringWithFormat:@"最多选择%ld个",ROOM_MAX_COUNT]];
                        return;
                    }
                }

                //添加选择
                FHSearchFilterConfigOption *option = nil;
                if (item.options.count > 0) {
                    option = [item.options firstObject];
                }
                if ([option.supportMulti boolValue]) {
                    [model addSelecteItem:selectItem withIndex:indexPath.item];
                }else{
                    [model clearAddSelecteItem:selectItem withIndex:indexPath.item];
                }
            }
        }

        [self reloadCollectionViewSection:indexPath.section];
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    
    NSArray *filter = [self filterOfHouseType:ht];
    if (filter.count > section) {
        return UIEdgeInsetsMake(0, 20, 0, 20);
    }
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = 68;
    if (section == 0) {
        height -= 10;
    }
    
    return CGSizeMake(collectionView.frame.size.width - 2*HELP_ITEM_HOR_MARGIN, height);
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.collectionView endEditing:YES];
//}

- (void)registerCell:(UICollectionView *)collectionview
{
    [collectionview registerClass:[FHHouseFindHelpRegionCell class] forCellWithReuseIdentifier:HELP_REGION_CELL_ID];
    [collectionview registerClass:[FHHouseFindPriceCell class] forCellWithReuseIdentifier:HELP_PRICE_CELL_ID];
    [collectionview registerClass:[FHHouseFindTextItemCell class] forCellWithReuseIdentifier:HELP_NORMAL_CELL_ID];
    [collectionview registerClass:[FHHouseFindHelpContactCell class] forCellWithReuseIdentifier:HELP_CONTACT_CELL_ID];
    [collectionview registerClass:[FHHouseFindHelpSubmitCell class] forCellWithReuseIdentifier:HELP_SUBMIT_CELL_ID];
    [collectionview registerClass:[FHHouseFindHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HELP_HEADER_ID];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_regionConfigItem.options.count < 1) {
        return 0;
    }
    FHSearchFilterConfigOption *configOption = [_regionConfigItem.options firstObject];
    return configOption.options.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_regionConfigItem.options.count < 1) {
        return 0;
    }
    FHSearchFilterConfigOption *configOption = [_regionConfigItem.options firstObject];
    NSInteger count = configOption.options.count;
    FHSearchFilterConfigOption *regionOption = [configOption.options firstObject];
    if ([regionOption.type isEqualToString:@"empty"]) {
        count -= 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseType ht = _houseType;
    FHHouseFindHelpRegionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:REGION_CELL_ID];
    FHSearchFilterConfigOption *configOption = [_regionConfigItem.options firstObject];
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    NSInteger count = configOption.options.count;
    NSInteger row = indexPath.row;
    FHSearchFilterConfigOption *regionOption = [configOption.options firstObject];
    if ([regionOption.type isEqualToString:@"empty"]) {
        row += 1;
    }
    if (row < count) {
        
        BOOL selected = NO;
        NSString *text = nil;
        if (model) {
            selected = [_selectRegionItem.selectIndexes containsObject:@(row)];
        }
        FHSearchFilterConfigOption *options = [_regionConfigItem.options firstObject];
        if (options.options.count > row) {
            FHSearchFilterConfigOption *option = options.options[row];
            text = option.text;
        }
        cell.regionLabel.text = text;
        cell.regionSelected = selected;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    FHHouseFindSelectItemModel *selectItem = _selectRegionItem;
    FHSearchFilterConfigOption *configOption = [_regionConfigItem.options firstObject];
    NSInteger count = configOption.options.count;
    NSInteger row = indexPath.row;
    FHSearchFilterConfigOption *regionOption = [configOption.options firstObject];
    if ([regionOption.type isEqualToString:@"empty"]) {
        row += 1;
    }
    if (row < count) {

        if ([selectItem.selectIndexes containsObject:@(row)]) {
            [selectItem.selectIndexes removeObject:@(row)];
        }else {
            //添加选择
            if (selectItem.selectIndexes.count >= REGION_MAX_COUNT) {
                [[ToastManager manager]showToast:[NSString stringWithFormat:@"最多选择%ld个",REGION_MAX_COUNT]];
                return;
            }
            [selectItem.selectIndexes addObject:@(row)];

            FHSearchFilterConfigOption *option = nil;
            if (_regionConfigItem.options.count > 0) {
                option = [_regionConfigItem.options firstObject];
            }
            if ([option.supportMulti boolValue]) {
                [selectItem.selectIndexes addObject:@(row)];
            }else{
                [selectItem.selectIndexes removeAllObjects];
                [selectItem.selectIndexes addObject:@(row)];
            }
        }
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [CATransaction commit];
}

#pragma mark - login相关
- (void)keyboardWillShowNotifiction:(NSNotification *)notification
{
    if(_isHideKeyBoard){
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    self.lastY = [self.collectionView convertPoint:self.contactCell.phoneInput.origin toView:self.viewController.view].y;
    NSLog(@"zjing self.contactCell:%@ lastY:%f,keyboard %@",self.contactCell,self.lastY,userInfo[UIKeyboardFrameEndUserInfoKey]);

    CGFloat offset = 0;
    if (keyBoardBounds.origin.y < [UIScreen mainScreen].bounds.size.height && (self.lastY + keyBoardBounds.size.height > [UIScreen mainScreen].bounds.size.height)) {
        offset = self.lastY + self.lastY + keyBoardBounds.size.height - [UIScreen mainScreen].bounds.size.height;
    }else {
        offset = self.lastY;
    }
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.collectionView.contentOffset = CGPointMake(0, offset);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.collectionView.contentOffset = CGPointMake(0, self.lastY);

    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardFrameWillChange:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    self.lastY = [self.collectionView convertPoint:self.contactCell.origin toView:self.viewController.view].y;
    
    NSLog(@"zjing self.contactCell:%@ lastY:%f,keyboard %@",self.contactCell,self.lastY,userInfo[UIKeyboardFrameEndUserInfoKey]);
    
    CGFloat contentViewHeight = self.contactCell.height;

    CGFloat tempOffset = [UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y;
    CGFloat offset = 0;

    BOOL isDismissing = CGRectGetMinY(keyBoardBounds) >= [[[UIApplication sharedApplication] delegate] window].bounds.size.height;
    if (isDismissing) {
//        offset = (keyBoardBounds.origin.y - contentViewHeight) / 2;
        offset = self.lastY;
    }else {
        
        if (keyBoardBounds.origin.y < [UIScreen mainScreen].bounds.size.height && (self.lastY + keyBoardBounds.size.height > [UIScreen mainScreen].bounds.size.height)) {
            offset = self.lastY + self.lastY + keyBoardBounds.size.height - [UIScreen mainScreen].bounds.size.height;
        }else {
            offset = self.lastY;
        }
//        if (tempOffset > 0) {
//            CGFloat offsetKeybord = 30;
//            offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) - offsetKeybord;
//        }else {
//            offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) / 2;
//        }
    }
    NSLog(@"zjing offset:%f ",offset);
    // add by zjing for test
//    offset = 800;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.collectionView.contentOffset = CGPointMake(0, offset);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField != self.contactCell.phoneInput && textField != self.contactCell.varifyCodeInput) {
        return;
    }
    NSString *text = textField.text;
    NSInteger limit = 0;
    if(textField == self.contactCell.phoneInput) {
        limit = 11;
        
        //设置登录和获取验证码是否可点击
        if(text.length > 0){
            [self setVerifyCodeButtonAndConfirmBtnEnabled:YES];
        }else{
            [self setVerifyCodeButtonAndConfirmBtnEnabled:NO];
        }
    }else if(textField == self.contactCell.varifyCodeInput) {
        limit = 6;
    }
    
    if(text.length > limit) {
        textField.text = [text substringToIndex:limit];
    }
}

- (void)sendVerifyCode
{
    [self.collectionView endEditing:YES];
    __weak typeof(self) weakSelf = self;
    NSString *phoneNumber = self.contactCell.phoneInput.text;

    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
    if(self.isRequestingSMS){
        return;
    }
    
    self.isRequestingSMS = YES;
    [[ToastManager manager] showToast:@"正在获取验证码"];
    
    __weak typeof(self)wself = self;
    [self requestSendVerifyCode:phoneNumber completion:^(NSNumber * _Nonnull retryTime, UIImage * _Nonnull captchaImage, NSError * _Nonnull error) {
        wself.isRequestingSMS = NO;
        if(!error){
            [wself blockRequestSendMessage:[retryTime integerValue]];
            [[ToastManager manager] showToast:@"短信验证码发送成功"];
            wself.isVerifyCodeRetry = YES;
        }else{
            NSString *errorMessage = [wself errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
        }
    }];
}

- (void)blockRequestSendMessage:(NSInteger)retryTime
{
    self.verifyCodeRetryTime = retryTime;
    [self startTimer];
}

- (void)setVerifyCodeButtonAndConfirmBtnEnabled:(BOOL)enabled
{
    [self.contactCell enableSendVerifyCodeBtn:(enabled && self.verifyCodeRetryTime <= 0)];
}

- (BOOL)isPureInt:(NSString *)str
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    int val = 0;
    return [scanner scanInt:&val] && scanner.isAtEnd;
}

- (void)requestSendVerifyCode:(NSString *)phoneNumber completion:(void(^_Nullable)(NSNumber *retryTime, UIImage *captchaImage, NSError *error))completion
{
    [TTAccountManager startSendCodeWithPhoneNumber:phoneNumber captcha:nil type:TTASMSCodeScenarioQuickLogin unbindExist:NO completion:completion];
}

- (void)requestQuickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode completion:(void(^_Nullable)(UIImage *captchaImage, NSNumber *newUser, NSError *error))completion
{
    [TTAccountManager startQuickLoginWithPhoneNumber:phoneNumber code:smsCode captcha:nil completion:completion];
}

- (NSString *)errorMessageByErrorCode:(NSError *)error {
    switch (error.code) {
        case -106:
            return @"网络异常";
            break;
            
        default:
            return error.localizedDescription;
            break;
    }
}

- (void)setVerifyCodeButtonCountDown
{
    if(self.verifyCodeRetryTime < 0){
        self.verifyCodeRetryTime = 0;
    }
    
    if(self.verifyCodeRetryTime == 0){
        [self stopTimer];
        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateHighlighted];
        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateDisabled];
        self.contactCell.sendVerifyCodeBtn.enabled = (self.contactCell.phoneInput.text.length > 0);
        self.isRequestingSMS = NO;
    }else{
        self.contactCell.sendVerifyCodeBtn.enabled = NO;
        [self.contactCell.sendVerifyCodeBtn setTitle:[NSString stringWithFormat:@"重新发送(%lis)",(long)self.verifyCodeRetryTime] forState:UIControlStateDisabled];
    }
    self.verifyCodeRetryTime--;
    
    // add by zjing for test
    NSLog(@"zjing verifyCodeRetryTime:%ld",self.verifyCodeRetryTime);
}

- (void)startTimer
{
    if(_timer){
        [self stopTimer];
    }
    [self.timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if(!_timer){
        _timer  =  [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

-(void)dealloc
{
    [self.configDisposable dispose];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
