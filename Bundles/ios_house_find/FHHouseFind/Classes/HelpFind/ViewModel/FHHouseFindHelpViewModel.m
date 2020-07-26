
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
#import <FHHouseBase/FHBaseViewController.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <FHHouseBase/FHUserTracker.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHHouseMine/FHLoginDefine.h>
#import "FHFindHouseAreaSelectionPanel.h"
#import "FHFilterModelParser.h"
#import "AreaSelectionTableViewVM.h"

#define HELP_HEADER_ID @"header_id"
#define HELP_ITEM_HOR_MARGIN 20
#define HELP_ITEM_HOR_INSET 13

#define HELP_MAIN_CELL_ID @"main_cell_id"
#define HELP_REGION_CELL_ID @"region_cell_id"
#define HELP_PRICE_CELL_ID @"price_cell_id"
#define HELP_NORMAL_CELL_ID @"normal_cell_id"
#define HELP_CONTACT_CELL_ID @"contact_cell_id"
#define HELP_SUBMIT_CELL_ID @"submit_cell_id"

#define ROOM_MAX_COUNT 2
#define REGION_MAX_COUNT 3


extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;

@interface FHHouseFindHelpViewModel ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource, UITableViewDelegate, FHHouseFindPriceCellDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

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
@property (nonatomic , strong) FHHouseFindHelpRegionSheet *regionSheet;

@property (nonatomic , weak) FHHouseFindHelpContactCell *contactCell;
@property (nonatomic , weak) FHHouseFindHelpSubmitCell *commitCell;
@property (nonatomic , weak) UITextField *activeTextField;

//1.0.1版本帮我找房优化需求去掉了验证码逻辑
//@property(nonatomic , assign) BOOL isRequestingSMS;
//@property(nonatomic , strong) NSTimer *timer;
//@property(nonatomic , assign) NSInteger verifyCodeRetryTime;
////是否重新是重新发送验证码
//@property(nonatomic , assign) BOOL isVerifyCodeRetry;
@property(nonatomic , assign) CGPoint lastContentOffset;
@property(nonatomic , assign) BOOL isKeyboardShow;

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
        
        _collectionView = collectionView;
        [self registerCell:collectionView];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        _collectionView.allowsMultipleSelection = YES;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
//        tapGesture.delegate = self;
//        tapGesture.cancelsTouchesInView = NO;
//        [_collectionView addGestureRecognizer:tapGesture];
        
        [self setupHouseContent:nil];
        self.recommendModel = recommendModel;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        
    }
    return self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setRecommendModel:(FHHouseFindRecommendDataModel *)recommendModel
{
    _recommendModel = recommendModel;
    if (recommendModel.openUrl.length > 0) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:recommendModel.openUrl]];
        [self refreshHouseFindItems:routeParamObj.queryParams];
    }else {
        [self selectDefaultItems];
    }
}

-(void)onTap
{
    [self.collectionView endEditing:YES];
}

- (void)resetBtnDidClick
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    for (FHHouseFindSelectItemModel *itemModel in model.items) {
        [itemModel.selectIndexes removeAllObjects];
    }
    [self selectDefaultItems];
    [self.collectionView reloadData];
    [self addClickLogWithEvent:@"click_options" position:@"reset"];
}

- (void)confirmBtnDidClick
{
//    [self.collectionView endEditing:YES];
    __weak typeof(self) wself = self;
    [self addClickLogWithEvent:@"click_confirm" position:nil];
    
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
    if (selectItem.higherPrice.length < 1 && selectItem.lowerPrice.length < 1 && selectItem.selectIndexes.count < 1) {
        [[ToastManager manager] showToast:@"请选择您的购房预算"];
        return;
    }
    selectItem = [model selectItemWithTabId:FHSearchTabIdTypeRoom];
    if (selectItem.selectIndexes.count < 1) {
        [[ToastManager manager] showToast:@"请选择您想购买的户型"];
        return;
    }
    selectItem = [model selectItemWithTabId:FHSearchTabIdTypeRegion];
    if (selectItem.selectIndexes.count < 1) {
        [[ToastManager manager] showToast:@"请选择您想购买的区域"];
        return;
    }
    
    NSString *phoneNumber = self.contactCell.phoneInput.text;
    //包含*说明没有编辑过电话号码，直接取真实的手机号
    if ([phoneNumber containsString:@"*"]) {
        phoneNumber = self.contactCell.phoneNum;
    }
    if (phoneNumber.length < 1 || ![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]) {
        [[ToastManager manager] showToast:@"请输入正确的手机号"];
        return;
    }
    [self storePhoneNumber:phoneNumber];
    
    if (![self submitActionWithPhoneNumber:phoneNumber]) {
        [[ToastManager manager] showToast:@"请输入正确的手机号"];
        return;
    }
    
//    if([TTAccount sharedAccount].isLogin){
//        [self submitAction];
//        return;
//    }
//    [self addClickLoginLog];

//    NSString *phoneNumber = self.contactCell.phoneInput.text;
//    NSString *smsCode = self.contactCell.varifyCodeInput.text;
    
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络错误"];
//        return;
//    }
//    if(smsCode.length == 0){
//        [[ToastManager manager] showToast:@"验证码为空"];
//        return;
//    }
    
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络异常"];
//        return;
//    }
//    //添加抖音 submit 埋点
//    NSMutableDictionary *trackerDict = [self.viewController tracerDict].mutableCopy;
//    trackerDict[@"enter_from"] = @"driving_find_house";
//    trackerDict[@"login_method"] = @"phone_sms";
//    trackerDict[@"enter_method"] = @"click";
//    [FHLoginTrackHelper loginSubmit:trackerDict];
//    [self requestQuickLogin:phoneNumber smsCode:smsCode completion:^(UIImage * _Nonnull captchaImage, NSNumber * _Nonnull newUser, NSError * _Nonnull error) {
//        //添加抖音 result 埋点
//        [FHLoginTrackHelper loginResult:trackerDict error:error];
//        if(!error){
//            //记录上一次登录成功的行为
//            [[NSUserDefaults standardUserDefaults] setObject:@"phone_sms" forKey:FHLoginTrackLastLoginMethodKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
////            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPhoneNumberCacheKey];
//            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPLoginhoneNumberCacheKey];
//            [wself submitAction];
//        }else{
//            NSString *errorMessage = [wself errorMessageByErrorCode:error];
//            [[ToastManager manager] showToast:errorMessage];
//        }
//    }];
}
#pragma mark 提交选项
- (BOOL)submitActionWithPhoneNumber:(NSString *)phoneNumber
{
    if (phoneNumber.length < 1) {
        return NO;
    }
    
    __weak typeof(self)wself = self;
    FHHouseType ht = _houseType;
    FHHouseFindSelectModel *selectModel = [self selectModelWithType:ht];
    NSMutableString *query = [NSMutableString new];
    if (selectModel.items.count > 0) {
        for (FHHouseFindSelectItemModel *item in selectModel.items ) {
            NSString *q = [item selectQueryForFindingHouse];
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
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return YES;
    }
    [FHMainApi saveHFHelpFindByHouseType:[NSString stringWithFormat:@"%ld",_houseType] query:query phoneNum:phoneNumber completion:^(FHHouseFindRecommendModel * _Nonnull model, NSError * _Nonnull error) {
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
    
    return YES;
}

- (void)jump2HouseFindResultPage:(NSDictionary *)recommendDict
{
    if ([self.viewController.parentViewController respondsToSelector:@selector(jump2HouseFindResultVC)]) {
        [self.viewController.parentViewController performSelector:@selector(jump2HouseFindResultVC)];
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
    __block NSInteger regionIndex = 0;
    [model.items enumerateObjectsUsingBlock:^(FHHouseFindSelectItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tabId == FHSearchTabIdTypeRegion) {
            regionIndex = idx;
            *stop = YES;
        }
    }];
    NSArray<FHFilterNodeModel*> *configs = [self.class convertConfigItemsToModel:@[model.items[regionIndex].configOption]];
    __weak typeof(self)wself = self;
    frame.size.height = REGION_CONTENT_HEIGHT + bottomHeight;
    _regionSheet = [[FHHouseFindHelpRegionSheet alloc]initWithFrame:frame];
    if (selectItem.selectIndexes.count > 0) {
        [_regionSheet setSelectedNodes:configs selectedIndexes:selectItem.selectIndexes];
    } else {
        [_regionSheet setNodes:configs];
    }
    [_regionSheet showWithCompleteBlock:^{
        [wself updateRegionItem:section];
    } cancelBlock:^{

    }];
}

+ (NSArray<FHFilterNodeModel *> *)convertConfigItemsToModel:(NSArray<FHSearchFilterConfigOption *> *)items {
    NSMutableArray<FHFilterNodeModel*>* result = [[NSMutableArray alloc] initWithCapacity:[items count]];
    [items enumerateObjectsUsingBlock:^(FHSearchFilterConfigOption * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFilterNodeModel* model = [self convertConfigItemToModel:obj];
        [result addObject:model];
    }];
    return result;
}

+ (FHFilterNodeModel *)convertConfigItemToModel:(FHSearchFilterConfigOption *)item {
    FHFilterNodeModel* model = [[FHFilterNodeModel alloc] init];
    model.label = item.text;
    model.isSupportMulti = item.supportMulti;
    if ([item.options count] > 0) {
        model.children = [self convertConfigOptionsToModel:item.options
                                              supportMutli:item.supportMulti
                                                withParent:model];
    } else {
        model.children = nil;
    }
    return model;
}


+ (NSArray<FHFilterNodeModel *> *)convertConfigOptionsToModel:(NSArray<FHSearchFilterConfigOption *> *)options
                                                 supportMutli:(NSNumber*)supportNutli
                                                   withParent:(FHFilterNodeModel*)model {
    NSMutableArray<FHFilterNodeModel*>* result = [[NSMutableArray alloc] init];
    [options enumerateObjectsUsingBlock:^(FHSearchFilterConfigOption * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFilterNodeModel* mm = [self convertConfigOptionToModel:obj
                                                    supportMutli:supportNutli ? supportNutli : obj.supportMulti
                                                      withParent:model];
        [result addObject:mm];
    }];
    return result;
}

+ (FHFilterNodeModel *)convertConfigOptionToModel:(FHSearchFilterConfigOption *)option
                                     supportMutli:(NSNumber*)supportNutli
                                       withParent:(FHFilterNodeModel*)model {
    FHFilterNodeModel* result = [[FHFilterNodeModel alloc] init];
    result.label = option.text;
    result.rankType = option.rankType;
    result.isEmpty = [option.isEmpty integerValue];
    result.isNoLimit = [option.isNoLimit integerValue];
    result.value = option.value;
    result.key = option.type;
    result.parent = model;
    result.rate = model.rate;
    result.isSupportMulti = supportNutli ? [supportNutli boolValue] : [option.supportMulti boolValue];
    result.children = [self convertConfigOptionsToModel:option.options supportMutli:supportNutli withParent:result];
    return result;
}

- (NSString*)getFilterLabelForSelectedNodes:(NSArray<FHFilterNodeModel*>*)nodes {
    if (nodes == nil || [nodes count] == 0) {
        return nil;
    } else if ([nodes count] == 1) {
        return [nodes firstObject].label;
    }
    
    return nil;
}

- (void)updateRegionItem:(NSInteger)section
{
    NSArray *VMs = self.regionSheet.areaPanel.selectionViewModels;
    [_selectRegionItem.selectIndexes removeAllObjects];
    [VMs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AreaSelectionTableViewVM *viewModel = (AreaSelectionTableViewVM *)obj;
        if (viewModel.selectedIndexPath.count > 0) {
            //区域选择控件不支持多选，所以indexPath取数组中的第一个就可以
            NSIndexPath *indexPath = [viewModel.selectedIndexPath allObjects].firstObject;
            [_selectRegionItem.selectIndexes addObject:@(indexPath.row)];
        }
    }];
    
    //重置后只选择未选择“行政区”以及“区域”
   if (_selectRegionItem.selectIndexes.count == 2) {
       NSNumber *index0 = _selectRegionItem.selectIndexes[0];
       NSNumber *index1 = _selectRegionItem.selectIndexes[1];
       if (index0.integerValue == 0 && index1.integerValue == 0) {
           [[ToastManager manager] showToast:@"请选择意向区域"];
           return;
       }
   }
    
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
    NSMutableArray *optionTypes = [NSMutableArray array];  //帮我找房多级区域选择
    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
    if (!selectItem) {
        selectItem = [model makeItemWithTabId:item.tabId.integerValue];
    }
    if (!selectItem.configOption) {
        selectItem.configOption = [item.options firstObject];
    }
    if (item.tabId.integerValue == FHSearchTabIdTypeRegion && options.options.count > 0) {
//        for (FHSearchFilterConfigOption *subOptions in options.options) {
//            if (![subOptions.type isEqualToString:@"empty"]) {
//                optionType = subOptions.type;
//                break;
//            }
//        }
        //1.0.1版本帮我找房优化需求，此处为支持多级区域选择改动较大，逻辑独立处理
        [self configAreaMultiSelectionWithOptionTypes:optionTypes
                                              options:options
                                                model:model
                                               params:params
                                                 item:item
                                           selectItem:selectItem];
        return;
    }
    
    __block id priceItem = nil;
    __block NSNumber *rate = nil;
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *keyStr = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([keyStr hasPrefix:optionType]) {
            
            if (item.tabId.integerValue == FHSearchTabIdTypePrice) {
                priceItem = obj;
                rate = item.rate;
            }
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
    if (item.tabId.integerValue == FHSearchTabIdTypePrice && selectItem.selectIndexes.count < 1 && priceItem) {
        
        [self fillPriceItem:item selectItem:selectItem priceItem:priceItem rate:rate];
        //        NSLog(@"zjing %@",selectItem);
    }
}

- (void)configAreaMultiSelectionWithOptionTypes:(NSMutableArray *)optionTypes
                                        options:(FHSearchFilterConfigOption *)options
                                          model:(FHHouseFindSelectModel *)model
                                         params:(NSDictionary *)params
                                           item:(FHSearchFilterConfigItem *)item
                                     selectItem:(FHHouseFindSelectItemModel *)selectItem {
    //加入region级type（区域）
    [optionTypes addObject:options.type];
    
    //遍历disrict级type（行政区）
    [options.options enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHSearchFilterConfigOption *currentOption = (FHSearchFilterConfigOption *)obj;
        if ([currentOption.type isEqualToString:@"empty"] || [optionTypes containsObject:currentOption.type]) {
            return;
        }
        
        //加入不存在的type
        if (![optionTypes containsObject:currentOption.type]) {
            [optionTypes addObject:currentOption.type];
        }
        
        //遍历area级type（商圈）
        [currentOption.options enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHSearchFilterConfigOption *currentOption = (FHSearchFilterConfigOption *)obj;
            if ([currentOption.type isEqualToString:@"empty"] || [optionTypes containsObject:currentOption.type]) {
                return;
            }
            
            //加入不存在的type
            if (![optionTypes containsObject:currentOption.type]) {
                [optionTypes addObject:currentOption.type];
            }
        }];
    }];
    
    //把region写死，默认插到第一个位置
    [model addSelecteItem:selectItem withIndex:0];
    
    //帮我找房区域选择支持多级，因此需要重新实现逻辑
    __block NSArray *currentOptions = options.options;
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id _Nonnull obj, BOOL * _Nonnull stop) {
        if (![self isValidKey:key inTypes:optionTypes]) {
            return;
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray* items = (NSArray*)obj;
            
            [items enumerateObjectsUsingBlock:^(NSString *it, NSUInteger idx, BOOL * _Nonnull stop) {
                //遍历area
                for (NSInteger index = 0; index < currentOptions.count; index++) {
                    FHSearchFilterConfigOption *option = currentOptions[index];
                    if (![it isEqualToString:option.value]) {
                        continue;
                    }
                    if (item.tabId.integerValue == FHSearchTabIdTypeRegion) {
                        FHSearchFilterConfigOption *op = nil;
                        if (item.options.count > 0) {
                            op = [item.options firstObject];
                        }
                        if ([op.supportMulti boolValue]) {
                            [model addSelecteItem:selectItem withIndex:index];
                            currentOptions = option.options;
                            *stop = YES;
                        }
                    }
                }
            }];
        }
    }];
    
    //如果selectIndexes只有两个值，说明没有包含商圈area，此处添加一个0代表“不限”选项
    if (selectItem.selectIndexes.count == 2) {
        [model addSelecteItem:selectItem withIndex:0];
    }
}

- (BOOL)isValidKey:(NSString *)key inTypes:(NSArray *)types {
    __block BOOL hasThisKey = NO;
    [types enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([key hasPrefix:obj]) {
            hasThisKey = YES;
            *stop = YES;
        }
    }];
    
    return hasThisKey;
}

- (void)selectDefaultItems
{
    FHHouseType ht = _houseType;
    NSArray *filter = [self filterOfHouseType:ht];
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    FHSearchFilterConfigItem *item = self.priceConfigItem;
    FHSearchFilterConfigOption *options = [item.options firstObject];
    FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
    if (!selectItem) {
        selectItem = [model makeItemWithTabId:item.tabId.integerValue];
    }
    if (!selectItem.configOption) {
        selectItem.configOption = [item.options firstObject];
    }
    selectItem.lowerPrice = nil;
    selectItem.higherPrice = nil;
    [model clearAddSelecteItem:selectItem withIndex:3];
    
    item = self.roomConfigItem;
    options = [item.options firstObject];
    selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
    if (!selectItem) {
        selectItem = [model makeItemWithTabId:item.tabId.integerValue];
    }
    if (!selectItem.configOption) {
        selectItem.configOption = [item.options firstObject];
    }
    FHSearchFilterConfigOption *option = nil;
    if (item.options.count > 0) {
        option = [item.options firstObject];
    }
    if ([option.supportMulti boolValue]) {
        [model addSelecteItem:selectItem withIndex:1];
    }else {
        [model clearAddSelecteItem:selectItem withIndex:1];
    }
}

- (void)fillPriceItem:(FHSearchFilterConfigItem *)configItem selectItem:(FHHouseFindSelectItemModel *)selectItem priceItem:(id)priceItem rate:(NSNumber *)rate
{
    NSString *item = nil;
    if ([priceItem isKindOfClass:[NSArray class]]) {
        NSArray *items = (NSArray*)priceItem;
        if (items.count < 1) {
            return;
        }
        item = items.firstObject;
    }else {
        item = (NSString *)priceItem;
    }
    if ([item isKindOfClass:[NSString class]]) {
        if ([item hasPrefix:@"["]) {
            item = [item substringFromIndex:1];
        }
        if ([item hasSuffix:@"]"]) {
            item = [item substringToIndex:item.length - 1];
        }
        NSArray *array = [item componentsSeparatedByString:@","];
        if (array.count > 0) {
            if (rate != nil && rate.integerValue != 0) {
                NSInteger lowerPrice = [array.firstObject integerValue] / rate.integerValue;
                selectItem.lowerPrice = [NSString stringWithFormat:@"%ld",lowerPrice];
            }
        }
        if (array.count > 1) {
            NSInteger higherPrice = [array[1] integerValue] / rate.integerValue;
            selectItem.higherPrice = [NSString stringWithFormat:@"%ld",higherPrice];
        }
    }
}

//手机号单独保存，不复用表单的缓存
- (NSString *)loadPhoneNumber {
    YYCache *findHousePhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig findHousePhoneNumberCache];
    id phoneCache = [findHousePhoneNumberCache objectForKey:kFHFindHousePhoneNumberCacheKey];
    
    NSString *phoneNum = nil;
    if ([phoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)phoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }
   
    return phoneNum;
}

- (BOOL)storePhoneNumber:(NSString *)phoneNumber {
    YYCache *findHousePhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig findHousePhoneNumberCache];
    [findHousePhoneNumberCache setObject:phoneNumber ?: @"" forKey:kFHFindHousePhoneNumberCacheKey];
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
    if (priceItem.selectIndexes.count < 1) {
        priceItem.lowerPrice = price;
    }
}

-(void)updateHigherPrice:(NSString *)price inCell:(FHHouseFindPriceCell *)cell
{
    FHHouseType ht = cell.tag;
    FHHouseFindSelectItemModel *priceItem = [self priceItemWithHouseType:ht];
    if (priceItem.selectIndexes.count < 1) {
        priceItem.higherPrice = price;
    }
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

- (void)resetPriceSelectItems
{
    FHHouseType ht = _houseType;
    FHHouseFindSelectItemModel *priceItem = [self priceItemWithHouseType:ht];
    [priceItem.selectIndexes removeAllObjects];
    NSMutableArray *indexPaths = @[].mutableCopy;
    for (NSInteger index = 1; index < priceItem.configOption.options.count; index++) {
        
        [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    [_collectionView reloadItemsAtIndexPaths:indexPaths];
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
                //                NSLog(@"[FIND] pcell is: %@ indexpath section: %ld item: %ld",pcell,indexPath.section,indexPath.item);
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
                    [pcell updateWithLowerPlaceholder:@"最低价 (万)" higherPlaceholder:@"最高价 (万)"];
                    [pcell updateWithLowerPrice:priceItem.lowerPrice higherPrice:priceItem.higherPrice];
                }
                
                return pcell;
            }else {
                
                FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_NORMAL_CELL_ID forIndexPath:indexPath];
                tcell.titleFont = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:12] : [UIFont themeFontRegular:10];
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
            NSArray<FHSearchFilterConfigOption *> *options = item.options;
            NSMutableString *titleString = [NSMutableString stringWithString:@""];
            __block NSArray<FHSearchFilterConfigOption *> *filterOptions = options;
            NSMutableArray *itemsArray = selectItem.selectIndexes.mutableCopy;
            [itemsArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (!filterOptions) {
                    *stop = YES;
                    return;
                }
                
                NSInteger optionIndex = obj.integerValue;
                if (optionIndex < filterOptions.count) {
                    FHSearchFilterConfigOption *itemOption = filterOptions[optionIndex];
                    if (idx == 0) {
                        [titleString appendString:itemOption.text];
                    }else {
                        [titleString appendString:[NSString stringWithFormat:@"/%@",itemOption.text]];
                    }
                    
                    filterOptions = filterOptions[optionIndex].options;
                }
            }];
            [pcell updateWithTitle:titleString];
            return pcell;
        }else {
            
            FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_NORMAL_CELL_ID forIndexPath:indexPath];
            tcell.titleFont = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:12] : [UIFont themeFontRegular:10];
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
        pcell.phoneInput.delegate = self;
//        pcell.varifyCodeInput.delegate = self;
        pcell.delegate = self;
        self.contactCell = pcell;
        pcell.phoneNum = [self loadPhoneNumber];
        [pcell showFullPhoneNum:NO];
        
//        if([TTAccount sharedAccount].isLogin){
//
//            TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
//            pcell.phoneNum = userInfo.mobile;
//        }else {
//            pcell.phoneNum = nil;
//        }
        return pcell;
    }
    FHHouseFindHelpSubmitCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_SUBMIT_CELL_ID forIndexPath:indexPath];
    self.commitCell = pcell;
    __weak typeof(self)wself = self;
    pcell.resetBlock = ^{
        [wself resetBtnDidClick];
    };
    pcell.confirmBlock = ^{
        [wself confirmBtnDidClick];
    };
    return pcell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HELP_HEADER_ID forIndexPath:indexPath];
    NSInteger section = indexPath.section;
    if (self.titlesArray.count > section) {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titlesArray[section] attributes:@{NSFontAttributeName:[UIFont themeFontMedium:18], NSForegroundColorAttributeName:[UIColor themeGray1]}];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"(必填)" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14], NSForegroundColorAttributeName:[UIColor themeGray4]}]];
        [headerView updateAttrTitle:attributedString showDelete:NO];
    }else {
        [headerView updateTitle:@"您的联系方式是？" showDelete:NO];
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
    CGFloat itemWidth = floor((collectionView.frame.size.width - 2 * HELP_ITEM_HOR_MARGIN - 3 * HELP_ITEM_HOR_INSET) / 4);
    
    if (filter.count > section) {
        FHSearchFilterConfigItem *item =  filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            if (indexPath.item == 0) {
                return CGSizeMake(collectionView.frame.size.width - 2 * HELP_ITEM_HOR_MARGIN, 36);
            }else {
                return CGSizeMake(itemWidth, 30);
            }
        }else if ([item.tabId integerValue] == FHSearchTabIdTypeRegion) {
            return CGSizeMake(collectionView.frame.size.width, 36);
        }else {
            return CGSizeMake(itemWidth, 30);
        }
    }
    if (indexPath.item == 0) {
        
        if([TTAccount sharedAccount].isLogin){
            return CGSizeMake(collectionView.frame.size.width, 90);
        }
        return CGSizeMake(collectionView.frame.size.width, 107);
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
                if (item.tabId.integerValue != FHSearchTabIdTypePrice) {
                    [model delSelecteItem:selectItem withIndex:indexPath.item];
                }
            }else{
                if (item.tabId.integerValue == FHSearchTabIdTypePrice) {
                    [model clearAddSelecteItem:selectItem withIndex:indexPath.item];
                    selectItem.lowerPrice = nil;
                    selectItem.higherPrice = nil;
                    
                }else if (item.tabId.integerValue == FHSearchTabIdTypeRoom) {
                    if (selectItem.selectIndexes.count >= ROOM_MAX_COUNT) {
                        [[ToastManager manager]showToast:[NSString stringWithFormat:@"最多选择%ld种户型",ROOM_MAX_COUNT]];
                        return;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"zjing scrollViewDidScroll bounds is: %@,isDragging %ld, decelerating %ld",NSStringFromCGRect(scrollView.bounds),scrollView.isDragging,scrollView.isDecelerating);

//    if (scrollView == self.collectionView && !_isKeyboardShow && (scrollView.isDragging || scrollView.isDecelerating)) {
    if (scrollView == self.collectionView && scrollView.isDragging) {

//        NSLog(@"zjing isDragging bounds is: %@",NSStringFromCGRect(scrollView.bounds));
        [self.collectionView endEditing:YES];
    }
}

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
                [[ToastManager manager]showToast:[NSString stringWithFormat:@"最多选择%ld个区域",REGION_MAX_COUNT]];
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
    
    if (!self.activeTextField) {
        return;
    }
    
    _lastContentOffset =  self.collectionView.contentOffset;
    _isKeyboardShow = YES;
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat screenY = [self.contactCell convertPoint:CGPointMake(0, self.contactCell.height + 60) toView:self.collectionView].y;
    CGFloat offset = 0;
    offset = screenY + keyBoardBounds.size.height - [UIScreen mainScreen].bounds.size.height;
    
    CGFloat keyboardTop = [self.viewController.view convertPoint:keyBoardBounds.origin fromView:self.viewController.view].y;
    CGFloat top = self.viewController.view.height - keyboardTop;
//    NSLog(@"zjing screenY:%f offset is : %f \n",screenY,offset);
//    NSLog(@"zjing top is: %f keyboardTop is: %f  _lastContentOffset is %@",top,keyboardTop,[NSValue valueWithCGPoint:_lastContentOffset]);
    self.collectionView.scrollEnabled = NO;
    if (offset > 0) {
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        CGFloat cheight =  keyboardTop - CGRectGetMinY(self.collectionView.frame);
        CGRect bounds = self.collectionView.bounds;

//        NSLog(@"zjing cheight:%f,bounds:%@, collectionView is : %@",cheight,[NSValue valueWithCGRect:bounds],self.collectionView);
        bounds.origin.y = self.collectionView.contentSize.height - cheight;
        BOOL shouldDelay = SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"11.0");
        if (shouldDelay) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCollectionViewBounds:bounds duration:duration curve:curve];
            });
        }else {
            [self updateCollectionViewBounds:bounds duration:duration curve:curve];
        }
    }
}

- (void)updateCollectionViewBounds:(CGRect)bounds duration:(NSNumber *)duration curve:(NSNumber *)curve
{
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        
        self.collectionView.bounds = bounds;
//        NSLog(@"zjing after bounds:%@, collectionView is : %@",[NSValue valueWithCGRect:bounds],self.collectionView);
        
    } completion:^(BOOL finished) {
//        NSLog(@"zjing finished bounds:%@, collectionView is : %@",[NSValue valueWithCGRect:bounds],self.collectionView);
    }];
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification
{
    if (!self.activeTextField) {
        return;
    }
    _isKeyboardShow = NO;
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat offset = 0;
    self.collectionView.scrollEnabled = YES;
    offset = self.collectionView.contentSize.height - self.collectionView.height;
    if (offset < 0) {
        offset = 0;
    }
//    NSLog(@"zjing hide offset:%f",offset);
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{

        self.collectionView.contentOffset = CGPointMake(0, offset);
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;

    if (textField != self.contactCell.phoneInput/* && textField != self.contactCell.varifyCodeInput*/) {
        [self resetPriceSelectItems];
        return;
    }
    NSString *text = textField.text;
    NSInteger limit = 0;
    if(textField == self.contactCell.phoneInput) {
        limit = 11;
        
        //设置登录和获取验证码是否可点击
//        if(text.length > 0){
//            [self setVerifyCodeButtonAndConfirmBtnEnabled:YES];
//        }else{
//            [self setVerifyCodeButtonAndConfirmBtnEnabled:NO];
//        }
    }
//    else if(textField == self.contactCell.varifyCodeInput) {
//        limit = 6;
//    }
    
    if(text.length > limit) {
        textField.text = [text substringToIndex:limit];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.contactCell.phoneInput) {
        //明文展示或者内容为空时不用读缓存
        if (![self.contactCell.phoneInput.text containsString:@"*"]) {
            self.activeTextField = textField;
            return;
        }
        [self.contactCell showFullPhoneNum:YES];
    }
    
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

//- (void)sendVerifyCode
//{
//    [self.collectionView endEditing:YES];
//    __weak typeof(self) weakSelf = self;
//    NSString *phoneNumber = self.contactCell.phoneInput.text;
//
//    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
//        [[ToastManager manager] showToast:@"手机号错误"];
//        return;
//    }
//
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络错误"];
//        return;
//    }
//
//    if(self.isRequestingSMS){
//        return;
//    }
//
//    self.isRequestingSMS = YES;
//    [[ToastManager manager] showToast:@"正在获取验证码"];
//
//    __weak typeof(self)wself = self;
//    [self requestSendVerifyCode:phoneNumber completion:^(NSNumber * _Nonnull retryTime, UIImage * _Nonnull captchaImage, NSError * _Nonnull error) {
//        wself.isRequestingSMS = NO;
//        if(!error){
//            [wself blockRequestSendMessage:[retryTime integerValue]];
//            [[ToastManager manager] showToast:@"短信验证码发送成功"];
//            wself.isVerifyCodeRetry = YES;
//        }else{
//            NSString *errorMessage = [wself errorMessageByErrorCode:error];
//            [[ToastManager manager] showToast:errorMessage];
//        }
//    }];
//}

//- (void)blockRequestSendMessage:(NSInteger)retryTime
//{
//    self.verifyCodeRetryTime = retryTime;
//    [self startTimer];
//}

//- (void)setVerifyCodeButtonAndConfirmBtnEnabled:(BOOL)enabled
//{
//    [self.contactCell enableSendVerifyCodeBtn:(enabled && self.verifyCodeRetryTime <= 0)];
//}

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
    [TTAccount quickLoginWithPhone:phoneNumber SMSCode:smsCode captcha:nil jsonObjCompletion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error, id  _Nullable jsonObj) {
        if (completion) {
            completion(captchaImage, @([[TTAccount sharedAccount] user].newUser), error);
        }
    }];
//    [TTAccountManager startQuickLoginWithPhoneNumber:phoneNumber code:smsCode captcha:nil completion:completion];
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

//- (void)setVerifyCodeButtonCountDown
//{
//    if(self.verifyCodeRetryTime < 0){
//        self.verifyCodeRetryTime = 0;
//    }
//
//    if(self.verifyCodeRetryTime == 0){
//        [self stopTimer];
//        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
//        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateHighlighted];
//        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateDisabled];
//        self.contactCell.sendVerifyCodeBtn.enabled = (self.contactCell.phoneInput.text.length > 0);
//        self.isRequestingSMS = NO;
//    }else{
//        self.contactCell.sendVerifyCodeBtn.enabled = NO;
//        [self.contactCell.sendVerifyCodeBtn setTitle:[NSString stringWithFormat:@"重新发送(%lis)",(long)self.verifyCodeRetryTime] forState:UIControlStateDisabled];
//    }
//    self.verifyCodeRetryTime--;
//}

//- (void)startTimer
//{
//    if(_timer){
//        [self stopTimer];
//    }
//    [self.timer fire];
//}
//
//- (void)stopTimer {
//    [_timer invalidate];
//    _timer = nil;
//}
//
//- (NSTimer *)timer {
//    if(!_timer){
//        _timer  =  [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    }
//    return _timer;
//}

#pragma mark - 埋点相关

#pragma mark - 埋点
- (void)addGoDetailLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"page_type"] = [self pageTypeString];
    [FHUserTracker writeEvent:@"go_detail" params:params];
}

- (void)addClickLoginLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"enter_type"] = [self pageTypeString];
    [FHUserTracker writeEvent:@"click_login" params:params];
}

- (void)addClickLogWithEvent:(NSString *)event position:(NSString *)position
{
    NSString *eventStr = event ?: @"click_options";
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"page_type"] = [self pageTypeString];
    if (position.length > 0) {
        params[@"click_position"] = position;
    }
    
    [FHUserTracker writeEvent:event params:params];
}

- (NSString *)pageTypeString
{
    return @"driving_find_house";
}

-(void)dealloc
{
    [self.configDisposable dispose];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
