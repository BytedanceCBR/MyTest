//
//  FHBaseMainListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHBaseMainListViewModel.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHConditionFilterViewModel.h"
#import <FHHouseBase/FHConfigModel.h>
#import <TTNetworkManager/TTHttpTask.h>
#import <FHHouseBase/FHSearchFilterOpenUrlModel.h>
#import <FHHouseBase/FHPlaceHolderCell.h>
#import <TTRoute/TTRoute.h>
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/FHMainManager+Toast.h>
#import <FHHouseBase/FHMainApi.h>
#import <TTUIWidget/UIScrollView+Refresh.h>
#import "FHBaseMainListViewController.h"
#import <FHHouseBase/FHTracerModel.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <TTUIWidget/UIViewController+Track.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHSearchHouseModel.h>
#import <FHHouseBase/FHRecommendSecondhandHouseTitleModel.h>
//#import <FHHouseBase/FHSingleImageInfoCellModel.h>
#import <FHHouseBase/FHRecommendSecondhandHouseTitleCell.h>
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import <FHHouseBase/FHHomePlaceHolderCell.h>
#import <FHHouseBase/FHMapSearchOpenUrlDelegate.h>

#import "FHMainListTopView.h"
#import "FHMainRentTopView.h"
#import "FHMainOldTopView.h"

#import <FHHouseBase/FHHouseRentFilterType.h>
#import <BDWebImage/BDWebImage.h>
#import "FHBaseMainListViewModel+Internal.h"
#import "FHBaseMainListViewModel+Old.h"
#import "FHBaseMainListViewModel+Rent.h"

#import "FHSugSubscribeModel.h"
#import "FHSuggestionSubscribCell.h"
#import "FHHouseListAPI.h"
#import "FHCommuteManager.h"
#import "FHSuggestionRealHouseTopCell.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import "FHHouseListAgencyInfoCell.h"
#import <FHCommonUI/ToastManager.h>
#import <FHHouseBase/FHUtils.h>
#import "FHHouseListNoHouseCell.h"
#import "FHHouseOpenURLUtil.h"
#import "FHEnvContext.h"
#import "FHMessageManager.h"
#import "FHMainOldTopTagsView.h"
#import "SSCommonLogic.h"
#import "FHListBaseCell.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHHouseListRecommendTipCell.h"
#import "FHNeighbourhoodAgencyCardCell.h"
#import <FHHouseDetail/FHDetailBaseModel.h>
#import "FHHouseListRedirectTipCell.h"
#import "FHCommuteManager.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <FHHouseBase/FHRelevantDurationTracker.h>
#import "FHHouseListBaseItemCell.h"
#import "UIDevice+BTDAdditions.h"
#import "FHHouseAgentCardCell.h"
#import "FHHousReserveAdviserCell.h"
#import "FHMainListTableView.h"
#import "FHFindHouseHelperCell.h"

#define kPlaceCellId @"placeholder_cell_id"
#define kSingleCellId @"single_cell_id"
#define kSubscribMainPage @"kFHHouseListSubscribCellId"
#define kRealHouseMainPage @"kRealHouseMainPageCellId"
#define kSugCellId @"sug_cell_id"
#define kAgencyInfoCellId @"kAgencyInfoCellId"
#define kNoHousePlaceHolderCellId @"no_house_cell_id"


#define kFilterBarHeight 44
#define kFilterTagsViewHeight 40
#define MAX_ICON_COUNT 4
#define ICON_HEADER_HEIGHT ([FHMainRentTopView totalHeight])

#define OLD_ICON_HEADER_HEIGHT ([FHMainOldTopView totalHeight])

extern NSString *const INSTANT_DATA_KEY;

@interface FHBaseMainListViewModel ()

@property(nonatomic , strong) UIView *bottomLine;
@property (nonatomic, strong) NSMutableDictionary *showCache;
//预约以后的状态暂存
@property (nonatomic, strong) NSMutableDictionary *subscribeCache;

@end


@implementation FHBaseMainListViewModel

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
    }
    return _bottomLine;
}

-(instancetype)initWithTableView:(UITableView *)tableView houseType:(FHHouseType)houseType  routeParam:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        
        _houseList = [NSMutableArray new];
        _sugesstHouseList = [NSMutableArray new];
        _showHouseDict = [NSMutableDictionary new];
        _showCache = [NSMutableDictionary new];
        _subscribeCache = [NSMutableDictionary new];
        _currentRecommendHouseDataModel = nil;
        _houseDataModel = nil;
        
        self.tableView = tableView;
        self.houseType = houseType;
        self.isShowSubscribeCell = NO;

        tableView.delegate = self;
        tableView.dataSource = self;
        
        [self registerCellClasses];

        __weak typeof(self) wself = self;
        FHRefreshCustomFooter *footer = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [wself requestData:NO];
        }];
        _tableView.mj_footer = footer;
        [footer setUpNoMoreDataText:@"没有更多信息了"];
        footer.hidden = YES;
        
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        [self initTopBanner];
        [self initFilter];
        
        _mainListPage =  [paramObj.sourceURL.host hasSuffix:@"main"];
        if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
            self.tracerModel.originFrom = @"renting";
        }
        
        [self setupTopTagsView];
        
        _isFirstLoad = YES;
        _canChangeHouseSearchDic = YES;
        _showPlaceHolder = YES;
    }
    return self;
}

- (NSArray *)cellIdArray
{
    if (!_cellIdArray) {
        _cellIdArray = @[NSStringFromClass([FHSuggestionSubscribCell class]),
                         NSStringFromClass([FHSuggestionRealHouseTopCell class]),
                         NSStringFromClass([FHRecommendSecondhandHouseTitleCell class]),
                         NSStringFromClass([FHHouseListRecommendTipCell class]),
                         NSStringFromClass([FHPlaceHolderCell class]),
                         NSStringFromClass([FHHouseListAgencyInfoCell class]),
                         NSStringFromClass([FHHouseListNoHouseCell class]),
                         NSStringFromClass([FHPlaceHolderCell class]),
                         NSStringFromClass([FHHomePlaceHolderCell class]),
                         NSStringFromClass([FHHouseListRedirectTipCell class]),
                         NSStringFromClass([FHNeighbourhoodAgencyCardCell class]),
                         NSStringFromClass([FHHousReserveAdviserCell class])
                         ];
    }
    return _cellIdArray;
}

// 注册cell类型
- (void)registerCellClasses
{
    [_tableView registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:kPlaceCellId];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHouseBaseItemCellList"];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeSecondHandHouse]];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeRentHouse]];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeNeighborhood]];
     [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeNewHouse]];
     [_tableView registerClass:[FHHouseListBaseItemCell class] forCellReuseIdentifier:@"FHListSynchysisNewHouseCell"];
    [_tableView registerClass:[FHHouseAgentCardCell class] forCellReuseIdentifier:NSStringFromClass([FHHouseAgentCardCell class])];
    [_tableView registerClass:[FHFindHouseHelperCell class] forCellReuseIdentifier:@"FHFindHouseHelperCell"];
    for (NSString *className in self.cellIdArray) {
        [self registerCellClassBy:className];
    }
}

- (void)registerCellClassBy:(NSString *)className
{
    [_tableView registerClass:NSClassFromString(className) forCellReuseIdentifier:className];
}
// cell class
- (Class)cellClassForEntity:(id)model {

    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *houseModel = (FHSearchHouseItemModel *)model;
            
        if (houseModel.cardType == FHSearchCardTypeAgentCard) {
            return [FHHouseAgentCardCell class];
        }
        
        if(houseModel.houseType.integerValue == FHHouseTypeNewHouse) {
            if (houseModel.cellStyles ==6) {
               return [FHHouseListBaseItemCell class];
            }
        }
        return [FHHouseBaseItemCell class];
    }else if ([model isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        return [FHSuggestionSubscribCell class];
    }else if ([model isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
        return [FHHouseListAgencyInfoCell class];
    }else if ([model isKindOfClass:[FHSearchGuessYouWantTipsModel class]]) {
        return [FHHouseListRecommendTipCell class];
    }else if ([model isKindOfClass:[FHSearchGuessYouWantContentModel class]]) {
        return [FHRecommendSecondhandHouseTitleCell class];
    }else if ([model isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
        return [FHNeighbourhoodAgencyCardCell class];
    }
    else if ([model isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        return [FHSuggestionRealHouseTopCell class];
    }
    
    else if ([model isKindOfClass:[FHHomePlaceHolderCellModel class]]) {
        return [FHHomePlaceHolderCell class];
    }else if ([model isKindOfClass:[FHHouseListNoHouseCellModel class]]) {
        return [FHHouseListNoHouseCell class];
    }else if ([model isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        return [FHHouseListRedirectTipCell class];
    }else if ([model isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        return [FHHousReserveAdviserCell class];
    }else if ([model isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        return [FHFindHouseHelperCell class];
    }
    return [FHListBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    if ([model isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        FHSearchFindHouseHelperModel *helperModel = (FHSearchFindHouseHelperModel *)model;
        if (helperModel.cardType == FHSearchCardTypeFindHouseHelper) {
            return @"FHFindHouseHelperCell";
        }
    }
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *houseModel = (FHSearchHouseItemModel *)model;
        if(houseModel.houseType.integerValue == FHHouseTypeNewHouse && houseModel.cellStyles == 6){
               return @"FHListSynchysisNewHouseCell";
        }
        if(houseModel.cardType == FHSearchCardTypeAgentCard){
               return NSStringFromClass([FHHouseAgentCardCell class]);
        }
        return [FHSearchHouseItemModel cellIdentifierByHouseType:houseModel.houseType.integerValue];
    }
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)addNotiWithNaviBar:(FHFakeInputNavbar *)naviBar {
    self.navbar = naviBar;
    if ((_mainListPage && _houseType == FHHouseTypeSecondHandHouse) || _houseType == FHHouseTypeRentHouse || _houseType == FHHouseTypeNewHouse) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessageDot) name:@"kFHMessageUnreadChangedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessageDot) name:@"kFHChatMessageUnreadChangedNotification" object:nil];
        [self refreshMessageDot];
    }
}

- (void)refreshMessageDot {
      if ([[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount]) {
        [self.navbar displayMessageDot:[[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount]];
    } else {
        [self.navbar displayMessageDot:0];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:_houseType showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    self.houseFilterViewModel.delegate = self;

    self.filterPanel.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, kFilterBarHeight);
    [self.filterBgControl addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
}


-(void)initTopBanner
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (_houseType == FHHouseTypeRentHouse) {
        FHConfigDataRentOpDataModel *rentModel = dataModel.rentOpData;
        if (rentModel.items.count > 0) {
            FHMainRentTopView *topView = [[FHMainRentTopView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , ICON_HEADER_HEIGHT) banner:dataModel.rentBanner];
            [topView updateWithConfigData:dataModel];
            topView.delegate = self;
            self.topBannerView = topView;
        }else {
            UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [FHFakeInputNavbar perferredHeight])];
            topView.backgroundColor = [UIColor whiteColor];
            self.topBannerView = topView;
        }
    }else if (_houseType == FHHouseTypeSecondHandHouse){
        if (dataModel.houseOpData2.items.count > 0) {
            FHMainOldTopView *topView = [[FHMainOldTopView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, OLD_ICON_HEADER_HEIGHT)];
            topView.delegate = self;
            self.topBannerView = topView;
            NSMutableDictionary *tracerDict = @{}.mutableCopy;
            if ([self baseLogParam]) {
                [tracerDict addEntriesFromDictionary:[self baseLogParam]];
            }
            tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
            [topView updateWithConfigData:dataModel tracerDict:tracerDict];
            for (FHConfigDataOpData2ItemsModel *item in dataModel.houseOpData.items ) {
                [self addOperationShowLog:item.logPb];
            }
            [self.showCache removeAllObjects];
        }else {
            UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [FHFakeInputNavbar perferredHeight])];
            topView.backgroundColor = [UIColor whiteColor];
            self.topBannerView = topView;
        }
    }else {
        UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [FHFakeInputNavbar perferredHeight])];
        topView.backgroundColor = [UIColor whiteColor];
        self.topBannerView = topView;
    }
    
}

- (void)setupTopTagsView
{
    if (self.mainListPage) {
        self.topTagsView = [[FHMainOldTopTagsView alloc] init];
        BOOL hasTagData = [self.topTagsView hasTagData];
        CGFloat tagHeight = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? kFilterTagsViewHeight : 0;
        self.topTagsView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, tagHeight);
        self.topTagsView.hidden = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? NO : YES;
        __weak typeof(self) weakSelf = self;
        self.topTagsView.itemClickBlk = ^{
            __block NSString *value_id = nil;
            NSArray *temp = weakSelf.topTagsView.lastConditionDic[@"tags%5B%5D"];
            if ([temp isKindOfClass:[NSArray class]] && temp.count > 0) {
                [temp enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (value_id.length > 0) {
                        value_id = [NSString stringWithFormat:@"%@,%@",value_id,obj];
                    } else {
                        value_id = obj;
                    }
                }];
            } else {
                value_id = nil;//
            }
            [weakSelf.houseFilterBridge setFilterConditions:weakSelf.topTagsView.lastConditionDic];
            [weakSelf.houseFilterViewModel trigerConditionChanged];
            [weakSelf addTagsViewClick:value_id];
        };
    }
}

- (void)addTagsViewClick:(NSString *)value_id {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self categoryName] ? : @"be_null";
    param[UT_ELEMENT_TYPE] = @"select_options";
    param[UT_SEARCH_ID] = self.searchId ? : @"be_null";
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ? : @"be_null";
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
    param[@"value_id"] = value_id ?: @"be_null";
    TRACK_EVENT(@"click_options", param);
}

-(NSString *)originFrom
{
    return self.viewController.tracerModel.originFrom;
}

-(NSString *)originSearchId
{
    return self.viewController.tracerModel.originSearchId;
}

-(FHTracerModel *)tracerModel
{
    return self.viewController.tracerModel;
}

-(void)setErrorMaskView:(FHErrorView *)errorMaskView
{
    _errorMaskView = errorMaskView;
    __weak typeof(self) wself = self;
    _errorMaskView.retryBlock = ^{
        [wself requestData:YES];
    };
    _errorMaskView.hidden = YES;
    
}

-(void)showErrorMask:(BOOL)show tip:(FHEmptyMaskViewType )type enableTap:(BOOL)enableTap
{
    if (show) {
        [self.tableView reloadData];
        [_errorMaskView showEmptyWithType:type];
        _errorMaskView.retryButton.enabled = enableTap;
        CGFloat top = _topView.height; //self.tableView.contentOffset.y;
        
        if(self.errorMaskView.superview){
            [_errorMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.mas_equalTo(self.viewController.containerView);
                make.top.mas_equalTo(top);
            }];
        }
        self.tableView.contentOffset = CGPointMake(0, -top);
        self.tableView.scrollEnabled = NO;
    }
    self.errorMaskView.hidden = !show;
    if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
        self.topTagsView.hidden = show;
    }
}

- (void)requestAddSubScribe:(NSString *)text
{
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    NSDictionary *paramsDict = nil;
    if (_houseType) {
        paramsDict = @{@"house_type":@(_houseType)};
    }
    
    TTHttpTask *task = [FHHouseListAPI requestAddSugSubscribe:_subScribeQuery params:paramsDict offset:_subScribeOffset searchId:_subScribeSearchId sugParam:nil class:[FHSugSubscribeModel class] completion:^(id<FHBaseModelProtocol>  _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[FHSugSubscribeModel class]]) {
            FHSugSubscribeModel *infoModel = (FHSugSubscribeModel *)model;
            if ([infoModel.data.items.firstObject isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
                FHSugSubscribeDataDataItemsModel *subModel = (FHSugSubscribeDataDataItemsModel *)infoModel.data.items.firstObject;
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setValue:text forKey:@"text"];
                [dict setValue:@"1" forKey:@"status"];
                [dict setValue:subModel.subscribeId forKey:@"subId"];

                [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
                
                NSMutableDictionary *uiDict = [NSMutableDictionary new];
                [uiDict setValue:@(YES) forKey:@"subscribe_state"];
                [uiDict setValue:subModel.subscribeId forKey:@"subscribe_id"];
                [uiDict setValue:subModel forKey:@"subscribe_item"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
                
                NSMutableDictionary *dictClickParams = [NSMutableDictionary new];
                
                if (self.subScribeShowDict) {
                    [dictClickParams addEntriesFromDictionary:self.subScribeShowDict];
                }
                
                if (subModel.subscribeId) {
                    [dictClickParams setValue:subModel.subscribeId forKey:@"subscribe_id"];
                }
                
                if (subModel.title) {
                    [dictClickParams setValue:subModel.title forKey:@"title"];
                }else
                {
                    [dictClickParams setValue:@"be_null" forKey:@"title"];
                }
                
                if (subModel.text) {
                    [dictClickParams setValue:subModel.text forKey:@"text"];
                }else
                {
                    [dictClickParams setValue:@"be_null" forKey:@"text"];
                }
                
                if (dictClickParams) {
                    self.subScribeShowDict = [NSDictionary dictionaryWithDictionary:dictClickParams];
                }
                
                if (wself.subScribeShowDict) {
                    if (wself.subScribeShowDict) {
                        [dictClickParams setValue:@"confirm" forKey:@"click_type"];
                        TRACK_EVENT(@"subscribe_click",dictClickParams);
                    }
                }
            }
        }
        
    }];
    
    self.requestTask = task;
}

- (void)requestDeleteSubScribe:(NSString *)subscribeId andText:(NSString *)text
{
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI requestDeleteSugSubscribe:subscribeId class:nil completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (text.length > 0) {
                [dict setValue:text forKey:@"text"];
            }
            [dict setValue:@"0" forKey:@"status"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
            
            NSMutableDictionary *uiDict = [NSMutableDictionary new];
            [uiDict setValue:@(NO) forKey:@"subscribe_state"];
            [uiDict setValue:subscribeId forKey:@"subscribe_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
            
            if (wself.subScribeShowDict) {
                NSMutableDictionary *traceParams = [NSMutableDictionary dictionaryWithDictionary:self.subScribeShowDict];
                [traceParams setValue:@"cancel" forKey:@"click_type"];
                TRACK_EVENT(@"subscribe_click",traceParams);
            }
        }
    }];
    
    self.requestTask = task;
}


-(void)requestData:(BOOL)isHead
{
    [_requestTask cancel];
    
    NSString *query = self.allQuery;
    if (self.originFrom.length > 0) {
        if ([query isKindOfClass:[NSString class]] && query.length > 0) {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&origin_from=%@",self.originFrom]];
        }else{
            query = [NSString stringWithFormat:@"origin_from=%@",self.originFrom];
        }
    }
    NSString *originSearchId = self.originSearchId ? : @"be_null";
    if ([query isKindOfClass:[NSString class]] && query.length > 0) {
        query = [query stringByAppendingString:[NSString stringWithFormat:@"&origin_search_id=%@",originSearchId]];
    }else{
        query = [NSString stringWithFormat:@"origin_search_id=%@",originSearchId];
    }
    NSString *enterFrom = [self pageTypeString];
    if ([query isKindOfClass:[NSString class]] && query.length > 0) {
        query = [query stringByAppendingString:[NSString stringWithFormat:@"&enter_from=%@",enterFrom]];
    }else{
        query = [NSString stringWithFormat:@"enter_from=%@",enterFrom];
    }
    NSString *queryType = self.houseSearchDic[@"query_type"] ? : @"filter";
    if (queryType.length > 0) {
        if ([query isKindOfClass:[NSString class]] && query.length > 0) {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&query_type=%@",queryType]];
        }else{
            query = [NSString stringWithFormat:@"query_type=%@",queryType];
        }
    }
    NSInteger offset = 0;
    if (!isHead) {
        offset = _houseList.count;
    }
    
    if (offset == 0) {
        self.showRealHouseTop = NO;
    }
    
    if (isHead) {
        self.showPlaceHolder = YES;
    }
    
    if (![TTReachability isNetworkConnected]) {
        if (isHead) {
            self.showPlaceHolder = NO;
            [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoNetWorkAndRefresh enableTap:YES ];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    __weak typeof(self) wself = self;
    if (_mainListPage && self.houseType == FHHouseTypeRentHouse) {
        
        self.requestTask = [self requestRentData:isHead query:query completion:^(FHListSearchHouseModel * _Nullable model, NSError * _Nullable error) {
            [wself processData:model error:error isRefresh:isHead isRecommendSearch:NO];
        }];
        
    }else{
        NSString *channelId = _mainListPage ? CHANNEL_ID_SEARCH_HOUSE_WITH_BANNER : CHANNEL_ID_SEARCH_HOUSE;
        if (self.fromRecommend) {
            channelId = CHANNEL_ID_RECOMMEND_SEARCH;
        }
        if ([query isKindOfClass:[NSString class]] && query.length > 0) {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",CHANNEL_ID,channelId]];
        }else{
            query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,channelId];
        }
        self.requestTask = [self loadData:isHead fromRecommend:self.fromRecommend query:query completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
            [wself processData:model error:error isRefresh:isHead isRecommendSearch:self.fromRecommend];
        }];
    }
    
}

-(void)processError:(NSError *)error  isRefresh:(BOOL)isRefresh
{
    if (error.code != NSURLErrorCancelled) {
        //不是主动取消
        if (!isRefresh) {
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
        }else {
            FHEmptyMaskViewType tip = FHEmptyMaskViewTypeNoData;
            if (![TTReachability isNetworkConnected]) {
                tip = FHEmptyMaskViewTypeNoNetWorkAndRefresh;
            }
            [self showErrorMask:YES tip:tip enableTap:NO ];
        }
    }
    [self.tableView.mj_footer endRefreshing];
    
}

- (void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error isRefresh:(BOOL)isRefresh isRecommendSearch:(BOOL)isRecommendSearch
{
    if (error) {
        [self processError:error isRefresh:isRefresh];
        return;
    }
    
    if (isRefresh) {
        [self.houseList removeAllObjects];
        [self.sugesstHouseList removeAllObjects];
        [self.tableView.mj_footer endRefreshing];
        [self.showHouseDict removeAllObjects];
        
        self.showRealHouseTop = NO;
    }

    if (model) {
        
        NSMutableArray *items = @[].mutableCopy;
        NSArray *recommendItems = nil;
        BOOL hasMore = NO;
        NSString *refreshTip = nil;
        FHSearchHouseDataRedirectTipsModel *redirectTips = nil;
        FHListSearchHouseDataModel *recommendHouseDataModel = nil;
        BOOL fromRecommend = NO;

        if ([model isKindOfClass:[FHListSearchHouseModel class]]) { // 列表页
            
            if (isRecommendSearch) {
                recommendHouseDataModel = ((FHListSearchHouseModel *)model).data;
                self.recommendSearchId = recommendHouseDataModel.searchId;
                hasMore = recommendHouseDataModel.hasMore;
                recommendItems = recommendHouseDataModel.searchItems;
                self.currentRecommendHouseDataModel = recommendHouseDataModel;
                fromRecommend = YES;
            } else {
                FHListSearchHouseDataModel *houseModel = ((FHListSearchHouseModel *)model).data;
                self.houseListOpenUrl = houseModel.houseListOpenUrl;
                self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
                self.houseDataModel = houseModel;
                hasMore = houseModel.hasMore;
                refreshTip = houseModel.refreshTip;
                if (houseModel.searchItems.count > 0) {
                    [items addObjectsFromArray:houseModel.searchItems];
                }
                redirectTips = houseModel.redirectTips;
                recommendHouseDataModel = houseModel.recommendSearchModel;
                recommendItems = recommendHouseDataModel.searchItems;
                self.searchId = houseModel.searchId;
                if (recommendItems.count > 0) {
                    self.recommendSearchId = recommendHouseDataModel.searchId;
                    if (!hasMore) {
                        hasMore = recommendHouseDataModel.hasMore;
                    }
                    self.currentRecommendHouseDataModel = houseModel.recommendSearchModel;
                    fromRecommend = YES;
                }
            }
        }
        self.fromRecommend = fromRecommend;

        self.viewController.tracerModel.searchId = self.searchId;
        if (self.isFirstLoad) {
            self.viewController.tracerModel.originSearchId = self.searchId;
            self.isFirstLoad = NO;
            if (self.searchId.length > 0 ) {
                SETTRACERKV(UT_ORIGIN_SEARCH_ID, self.searchId);
            }
            [self tryAddCommuteShowLog];
        }
        
        self.showPlaceHolder = NO;
        if (!self.addEnterCategory) {
            [self addEnterLog];
            self.addEnterCategory = YES;
        }
        if (isRefresh) {
            [self addHouseSearchLog];
            [self addHouseRankLog];
            [self handleRefreshHouseOpenUrl:self.houseListOpenUrl];            
        } else {
            [self addLoadMoreRefreshLog];
        }
        __weak typeof(self)wself = self;
        __block id lastObj = nil;
        __block BOOL hideRefreshTip = NO;
        
        NSMutableDictionary *traceDictParams = [NSMutableDictionary new];
        if ([self.viewController.tracerModel logDict]) {
            [traceDictParams addEntriesFromDictionary:[self.viewController.tracerModel logDict]];
        }
        [items enumerateObjectsUsingBlock:^(id  _Nonnull theItemModel, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([itemDict isKindOfClass:[NSDictionary class]]) {
//                id theItemModel = [[self class] searchItemModelByDict:itemDict];
            if (idx == 0 && [theItemModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
                hideRefreshTip = YES;
            }
                if ([theItemModel isKindOfClass:[FHSearchHouseItemModel class]]) {
                    FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel*)theItemModel;
//                    itemModel.isLastCell = (idx == items.count - 1);
                    if ([lastObj isKindOfClass:[FHHouseNeighborAgencyModel class]] || [lastObj isKindOfClass:[FHHouseReserveAdviserModel class]]) {
                        itemModel.topMargin = 0;
                    }
                    if ((itemModel.houseType.integerValue == FHHouseTypeRentHouse || itemModel.houseType.integerValue == FHHouseTypeNeighborhood) && idx == 0) {
                        itemModel.topMargin = 10;
                    }
                    theItemModel = itemModel;
                }else if ([theItemModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
                    FHSearchRealHouseAgencyInfo *agencyInfoModel = (FHSearchRealHouseAgencyInfo *)theItemModel;
                    if (agencyInfoModel.agencyTotal.integerValue != 0 && agencyInfoModel.houseTotal.integerValue != 0) {
                        if (isRefresh) {
                            // 展示经纪人信息
                            wself.showRealHouseTop = YES;
                        }
                    }else {
                        theItemModel = nil;
                    }
                }else if ([theItemModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]] && isRefresh) {
                    // 展示搜索订阅卡片
                    wself.isShowSubscribeCell = YES;
                }else if ([theItemModel isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {

                    FHSugListRealHouseTopInfoModel *infoModel = theItemModel;
                    infoModel.searchId = wself.searchId;
                    infoModel.tracerDict = traceDictParams;
                    infoModel.searchQuery = wself.subScribeQuery;
                    theItemModel = infoModel;
                    if (!isRefresh) {
                        wself.showFakeHouseTop = YES;
                    }
                }else if ([theItemModel isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
                    FHHouseNeighborAgencyModel *agencyModel = theItemModel;
                    NSMutableDictionary *traceParam = [NSMutableDictionary new];
                    traceParam[@"card_type"] = @"left_pic";
                    traceParam[@"enter_from"] = traceDictParams[@"enter_from"];
                    traceParam[@"element_from"] = traceDictParams[@"element_from"];
                    traceParam[@"page_type"] = [wself pageTypeString];
                    traceParam[@"search_id"] = wself.searchId;
                    traceParam[@"log_pb"] = agencyModel.logPb;
                    traceParam[@"origin_from"] = wself.originFrom;
                    traceParam[@"origin_search_id"] = wself.originSearchId;
                    traceParam[@"rank"] = @(0);
                    agencyModel.tracerDict = traceParam;
                    agencyModel.belongsVC = wself.viewController;
                    theItemModel = agencyModel;
                }else if ([theItemModel isKindOfClass:[FHHouseReserveAdviserModel class]]) {
                    FHHouseReserveAdviserModel *model = theItemModel;
                    NSMutableDictionary *traceParam = [NSMutableDictionary new];
                    traceParam[@"card_type"] = @"left_pic";
                    traceParam[@"enter_from"] = traceDictParams[@"enter_from"];
                    traceParam[@"element_from"] = traceDictParams[@"element_from"];
                    traceParam[@"page_type"] = [self pageTypeString];
                    traceParam[@"search_id"] = wself.searchId;
                    traceParam[@"log_pb"] = model.logPb;
                    traceParam[@"origin_from"] = wself.originFrom;
                    traceParam[@"origin_search_id"] = wself.originSearchId;
                    traceParam[@"rank"] = @(0);
                    if(self.houseType == FHHouseTypeNeighborhood){
                        traceParam[@"element_type"] = @"neighborhood_expert_card";
                    }else{
                        traceParam[@"element_type"] = @"area_expert_card";
                    }
                    model.tracerDict = traceParam;
                    model.belongsVC = wself.viewController;
                    model.subscribeCache = wself.subscribeCache;
                    model.tableView = wself.tableView;
                    theItemModel = model;
                }else if ([theItemModel isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
                    FHSearchHouseDataRedirectTipsModel *tipModel = theItemModel;
                    tipModel.clickRightBlock = ^(NSString *openUrl){
                        [wself clickRedirectTip:openUrl];
                    };
                    theItemModel = tipModel;
                }
                if (theItemModel) {
                    [wself.houseList addObject:theItemModel];
                }
                if (theItemModel) {
                    lastObj = theItemModel;
                }
//            }
        }];
        
        [recommendItems enumerateObjectsUsingBlock:^(id  _Nonnull theItemModel, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([itemDict isKindOfClass:[NSDictionary class]]) {
//                id theItemModel = [[wself class] searchItemModelByDict:itemDict];
                if ([theItemModel isKindOfClass:[FHSearchHouseItemModel class]]) {
                    FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)theItemModel;
                    itemModel.isRecommendCell = YES;
                    itemModel.isLastCell = (idx == items.count - 1);
                    theItemModel = itemModel;
                }

                if ([theItemModel isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
                    FHSugListRealHouseTopInfoModel *infoModel = theItemModel;
                    infoModel.searchId = wself.searchId;
                    infoModel.tracerDict = traceDictParams;
                    infoModel.searchQuery = wself.subScribeQuery;
                    theItemModel = infoModel;
                }else if ([theItemModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
                    FHSearchRealHouseAgencyInfo *agencyInfoModel = (FHSearchRealHouseAgencyInfo *)theItemModel;
                    if (agencyInfoModel.agencyTotal.integerValue == 0 || agencyInfoModel.houseTotal.integerValue == 0) {
                        theItemModel = nil;
                    }
                }else if ([theItemModel isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
                    FHHouseNeighborAgencyModel *agencyModel = theItemModel;
                    NSMutableDictionary *traceParam = [NSMutableDictionary new];
                    traceParam[@"card_type"] = @"left_pic";
                    traceParam[@"enter_from"] = [self pageTypeString];
                    traceParam[@"element_from"] = [self elementTypeString];
                    traceParam[@"search_id"] = self.searchId;
                    traceParam[@"log_pb"] = agencyModel.logPb;
                    traceParam[@"origin_from"] = self.originFrom;
                    traceParam[@"origin_search_id"] = self.originSearchId;
                    traceParam[@"rank"] = @(0);
                    agencyModel.tracerDict = traceParam;
                    agencyModel.belongsVC = wself.viewController;
                    theItemModel = agencyModel;
                }else if ([theItemModel isKindOfClass:[FHHouseReserveAdviserModel class]]) {
                    FHHouseReserveAdviserModel *model = theItemModel;
                    NSMutableDictionary *traceParam = [NSMutableDictionary new];
                    traceParam[@"card_type"] = @"left_pic";
                    traceParam[@"enter_from"] = traceDictParams[@"enter_from"];
                    traceParam[@"element_from"] = traceDictParams[@"element_from"];
                    traceParam[@"page_type"] = [self pageTypeString];
                    traceParam[@"search_id"] = wself.searchId;
                    traceParam[@"log_pb"] = model.logPb;
                    traceParam[@"origin_from"] = wself.originFrom;
                    traceParam[@"origin_search_id"] = wself.originSearchId;
                    traceParam[@"rank"] = @(0);
                    if(self.houseType == FHHouseTypeNeighborhood){
                        traceParam[@"element_type"] = @"neighborhood_expert_card";
                    }else{
                        traceParam[@"element_type"] = @"area_expert_card";
                    }
                    model.tracerDict = traceParam;
                    model.belongsVC = wself.viewController;
                    model.tableView = wself.tableView;
                    model.subscribeCache = wself.subscribeCache;
                    theItemModel = model;
                }
            
                if (theItemModel) {
                    [wself.sugesstHouseList addObject:theItemModel];
                }
//            }
        }];
        
        if(self.houseList.count == 1 && self.sugesstHouseList.count == 0){
            //只有一个筛选提示时 增加无数据提示
            if ([self.houseList.firstObject isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                //add place holder
                FHHouseListNoHouseCellModel *cellModel = [[FHHouseListNoHouseCellModel alloc] init];
                cellModel.cellHeight = self.tableView.height - self.topView.height - 121;
                [self.houseList addObject:cellModel];
            }
        }
        
        [self.tableView reloadData];
        
        if (self.houseList.count > 10 || self.sugesstHouseList.count > 10) {
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }

        if (hasMore == NO) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
        
//        if (isRefresh && (items.count > 0 || recommendItems.count > 0) && !_showFilter && _showRealHouseTop) {
//            self.tableView.contentOffset = CGPointMake(0, -self.topView.height);
//        }
        
        if (isRefresh && (items.count > 0 || recommendItems.count > 0)) {
            if (!_showFilter && !hideRefreshTip) {
                [self showNotifyMessage:refreshTip];
            }else {
                [self showNotifyMessage:nil];
            }
        }
                
        if (self.houseList.count == 0 && self.sugesstHouseList.count == 0) {
            [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoDataForCondition enableTap:NO ];
        } else {
            [self showErrorMask:NO tip:FHEmptyMaskViewTypeNoData enableTap:NO ];
            self.tableView.scrollEnabled = YES;
        }
    } else {
        [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoData enableTap:YES ];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        [[FHRelevantDurationTracker sharedTracker] sendRelevantDuration];
    }
}

-(void)showInputSearch
{
    [self addClickSearchLog];
    [self.houseFilterViewModel closeConditionFilterPanel];
    
    //house_search
    NSObject *sugDelegateTable = WRAP_WEAK(self);
    
    NSInteger fromHome = 3;//list
    NSMutableDictionary *traceParam = [self baseLogParam];
    if (_mainListPage) {
        
        if ( _houseType == FHHouseTypeRentHouse) {
            //租房大类页要重新设置originfrom
            NSString *originFrom = @"renting_search";
            SETTRACERKV(UT_ORIGIN_FROM,originFrom);
            id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
            [envBridge setTraceValue:originFrom forKey:UT_ORIGIN_FROM];
            fromHome = 4;//rent
            traceParam[UT_ELEMENT_FROM] = originFrom;
            traceParam[UT_PAGE_TYPE] = @"renting";
            traceParam[UT_ORIGIN_FROM] = originFrom;
        }else if (_houseType == FHHouseTypeSecondHandHouse){
            fromHome = 5; // list main
            sugDelegateTable = nil;
        }
        
    }
    traceParam[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
    
    NSMutableDictionary *dict = @{@"house_type":@(_houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(fromHome)
                           }.mutableCopy;
    if (sugDelegateTable) {
        dict[@"sug_delegate"] = sugDelegateTable;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://house_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)showMapSearch
{
    if (_houseType == FHHouseTypeRentHouse && _mainListPage && self.mapFindHouseOpenUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:self.mapFindHouseOpenUrl];
        NSDictionary *dict = @{@"enter_from_list":@"1"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }else{
        [self showOldMapSearch];
    }
}

- (void)showMessageList {
    [self.houseFilterViewModel closeConditionFilterPanel];
    // 二手房大类页
    if ((_mainListPage && _houseType == FHHouseTypeSecondHandHouse) || _houseType == FHHouseTypeRentHouse || _houseType == FHHouseTypeNewHouse) {

        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_PAGE_TYPE] = [self categoryName] ? : @"be_null";
        param[UT_ENTER_FROM] = self.tracerModel.enterFrom ? : @"be_null";
        param[UT_ENTER_TYPE] = self.tracerModel.enterType ? : @"be_null";
        param[UT_ELEMENT_FROM] = self.tracerModel.elementFrom ? : @"be_null";
        param[UT_SEARCH_ID] = self.searchId ? : @"be_null";
        param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ? : @"be_null";
        param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
        [param setValue: [[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount] >0?@"1":@"0" forKey:@"with_tips"];
        TRACK_EVENT(@"click_im_message", param);
        
        NSString *messageSchema = @"sslocal://message_conversation_list";
        NSURL *openUrl = [NSURL URLWithString:messageSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ENTER_FROM] = [self categoryName] ? : @"be_null";
        dict[@"tracer"] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

#pragma mark 地图找房
-(void)showOldMapSearch
{
    /*
     1. event_type：house_app2c_v2
     2. click_type: 点击类型,{'地图找房': 'map', '房源列表': 'list'}
     3. category_name：category名,{'二手房列表页': 'old_list'}
     4. enter_from：category入口,{'首页': 'maintab', '找房tab': 'findtab'}
     5. enter_type：进入category方式,{'点击': 'click'}
     6. element_from：组件入口,{'首页搜索': 'maintab_search', '首页icon': 'maintab_icon', '找房tab开始找房': 'findtab_find', '找房tab搜索': 'findtab_search'}
     7. search_id
     8. origin_from
     9. origin_search_id
     */
    
    if (self.mapFindHouseOpenUrl.length > 0) {
        
        NSMutableString *openUrl = self.mapFindHouseOpenUrl;
        
        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_CATEGORY_NAME] = [self categoryName] ? : @"be_null";
        param[UT_ENTER_FROM] = self.tracerModel.enterFrom ? : @"be_null";
        param[UT_ENTER_TYPE] = self.tracerModel.enterType ? : @"be_null";
        param[UT_ELEMENT_FROM] = self.tracerModel.elementFrom ? : @"be_null";
        param[UT_SEARCH_ID] = self.searchId ? : @"be_null";
        param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ? : @"be_null";
        param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
        
        param[@"click_type"] = @"map";
        param[UT_ENTER_TYPE] = @"click";
        TRACK_EVENT(@"click_switch_mapfind", param);
        
        NSMutableString *query = @"".mutableCopy;
        if (![self.mapFindHouseOpenUrl containsString:@"enter_category"]) {
            [query appendString:[NSString stringWithFormat:@"enter_category=%@",[self categoryName]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ORIGIN_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&origin_from=%@",self.tracerModel.originFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ORIGIN_SEARCH_ID]) {
            [query appendString:[NSString stringWithFormat:@"&origin_search_id=%@",self.originSearchId ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ENTER_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&enter_from=%@",[self pageTypeString]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ELEMENT_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&element_from=%@",self.tracerModel.elementFrom ? : @"be_null"]];
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_SEARCH_ID]) {
            [query appendString:[NSString stringWithFormat:@"&search_id=%@",self.searchId ? : @"be_null"]];
        }
        
        if (![self.mapFindHouseOpenUrl containsString:UT_ORIGIN_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&%@=%@", UT_ORIGIN_FROM ,self.tracerModel.originFrom?:UT_BE_NULL]];
        }
        
        [query appendFormat:@"&enter_from_list=1"];
        
        if (query.length > 0) {
            
            openUrl = [NSString stringWithFormat:@"%@&%@",openUrl,query];
        }
        
        //需要重置非过滤器条件，以及热词placeholder
        [self.houseFilterBridge closeConditionFilterPanel];
        
        NSURL *url = [NSURL URLWithString:openUrl];
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        NSHashTable *hashMap = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [hashMap addObject:self];
        dict[OPENURL_CALLBAK] = hashMap;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
}


-(void)handleRefreshHouseOpenUrl:(NSString *)openUrl
{
    if (openUrl.length < 1) {
        return;
    }
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
    
    NSString *placeholder = nil;
    NSString *fullText = paramObj.queryParams[@"full_text"];
    NSString *displayText = paramObj.queryParams[@"display_text"];
    
    if (fullText.length > 0) {
        placeholder = fullText;
    }else if (displayText.length > 0) {
        placeholder = displayText;
    }
    
    if (placeholder.length == 0) {
        placeholder =  [self navbarPlaceholder];
    }
    
    self.navbar.placeHolder = placeholder;
    
    [self.houseFilterBridge setFilterConditions:paramObj.queryParams];
    
    if (self.topTagsView && paramObj.queryParams) {
        self.topTagsView.lastConditionDic = [NSMutableDictionary dictionaryWithDictionary:paramObj.queryParams];
    }
}

-(NSString *)navbarPlaceholder
{
    switch (_houseType) {
            case FHHouseTypeNewHouse:
                return @"请输入楼盘名/地址";
            case FHHouseTypeSecondHandHouse:
                return @"请输入小区/商圈/地铁";
            case FHHouseTypeNeighborhood:
                return @"请输入小区/商圈/地铁";
            case FHHouseTypeRentHouse:
                return @"请输入小区/商圈/地铁";
        default:
            return @"";
            break;
    }
        
}

-(void)handleHouseListCallback:(NSString *)openUrl {
    
    if ([FHHouseOpenURLUtil isSameURL:self.houseListOpenUrl and:openUrl]) {
        return;
    }
    if (self.houseListOpenUrl && openUrl) {
        NSString *deOpenUrl = [openUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *deOrigin = [self.houseListOpenUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([deOpenUrl isEqualToString:deOrigin]) {
            return;
        }
    }
    
    [self handleRefreshHouseOpenUrl:openUrl];
    [self.houseFilterViewModel trigerConditionChanged];
}

#pragma mark - top banner rent delegate
-(void)selecteRentItem:(FHConfigDataOpDataItemsModel *)model
{
    NSMutableString *openUrl = [[NSMutableString alloc] initWithString:model.openUrl];// model.openUrl;
    if (![openUrl containsString:@"house_type"]) {
        [openUrl appendFormat:@"&house_type=%ld",FHHouseTypeRentHouse];        
    }
    if (![openUrl containsString:UT_SEARCH_ID]) {
        [openUrl appendFormat:@"&search_id=%@",self.searchId?:@"be_null"];
    }
    TTRouteUserInfo *userInfo = nil;
    NSURL *url = nil;
    FHHouseRentFilterType filterType = [self rentFilterType:model.openUrl];
    
    NSString *originFrom = model.logPb[UT_ORIGIN_FROM];
    
    if (filterType == FHHouseRentFilterTypeMap){
        
        //王然说点击不爆切换埋点
        //        [self addMapsearchLog];
        
        //        if (self.mapFindHouseOpenUrl.length > 0) {
        //            //使用跳转
        //            openUrl = self.mapFindHouseOpenUrl;
        //        }
        if (originFrom.length == 0) {
            originFrom = @"renting_mapfind";
        }
        
        if (![openUrl containsString:UT_ENTER_FROM]) {
            [openUrl appendString:@"&enter_from=renting"];
        }
        if (![openUrl containsString:UT_ORIGIN_FROM]) {
            [openUrl appendFormat:@"&origin_from=%@",originFrom];
        }
        
        SETTRACERKV(UT_ORIGIN_FROM, originFrom);
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict] ];
        
        params[UT_ENTER_FROM] = @"renting";
        params[UT_ORIGIN_FROM] = originFrom;
        params[UT_ORIGIN_SEARCH_ID] = nil;//remove origin_search_id
        
        NSDictionary *infoDict = @{@"tracer":params};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
        url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }else{
        NSMutableDictionary *infoDict = @{}.mutableCopy;
        NSDictionary *param = [self addEnterHouseListLog:model.openUrl];
        if (param) {
            infoDict[@"tracer"] = param;
            userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
            if (originFrom.length == 0) {
                originFrom = param[UT_ORIGIN_FROM];
            }
            
            if (originFrom) {
                SETTRACERKV(UT_ORIGIN_FROM, originFrom);
            }
        }
        if ([model.openUrl isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:model.openUrl];
            if ([model.openUrl containsString:@"://commute_list"]){
                //通勤找房
                [[FHCommuteManager sharedInstance] tryEnterCommutePage:model.openUrl logParam:infoDict];
            }else{
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            }
        }
    }
}

-(void)tapRentBanner
{
    NSString *destLocation = [[FHCommuteManager sharedInstance] destLocation];
    NSString *cityId = [[FHCommuteManager sharedInstance] cityId];
    NSString *currentCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if (cityId.length == 0 || ![cityId isEqualToString:currentCityId] || destLocation.length == 0) {
        [[FHCommuteManager sharedInstance] clear];
        [self showCommuteConfigPage];
    }else{
        [self gotoCommuteList:nil];
    }
}

-(void)selecteOldItem:(FHConfigDataOpDataItemsModel *)model
{
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:model.openUrl]];
    NSMutableDictionary *queryP = [NSMutableDictionary new];
    [queryP addEntriesFromDictionary:paramObj.allParams];
    NSDictionary *baseParams = [self baseLogParam];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_ENTER_FROM] = baseParams[UT_ENTER_FROM] ? : @"be_null";
    dict[UT_ELEMENT_FROM] = baseParams[UT_ELEMENT_FROM] ? : @"be_null";
    dict[UT_ORIGIN_FROM] = baseParams[UT_ORIGIN_FROM] ? : @"be_null";
    dict[UT_LOG_PB] = model.logPb ? : @"be_null";
    dict[UT_SEARCH_ID] = baseParams[UT_SEARCH_ID] ? : @"be_null";
    dict[UT_ORIGIN_SEARCH_ID] = baseParams[UT_ORIGIN_SEARCH_ID] ? : @"be_null";
    
    NSDictionary *userInfoDict = @{@"tracer":dict};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    
    if ([model.openUrl isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:model.openUrl];
        if ([model.openUrl containsString:@"://commute_list"]){
            //通勤找房
            [[FHCommuteManager sharedInstance] tryEnterCommutePage:model.openUrl logParam:dict];
        }else{
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
    
    NSDictionary *logpbDict = model.logPb;
//    [self addOperationClickLog:logpbDict[@"operation_name"]];
    [self addClickIconLog:model.logPb];
}

- (void)showBannerItem:(FHConfigDataRentOpDataItemsModel *)item withIndex:(NSInteger)index
{
    FHConfigDataRentOpDataItemsModel *opData = item;
    if (!opData) {
        return;
    }
    // banner show 唯一性判断(地址)
    NSString *tracerKey = [NSString stringWithFormat:@"_%p_",opData];
    if (tracerKey.length > 0) {
        if (self.showCache[tracerKey]) {
            return;
        }
        self.showCache[tracerKey] = @(1);
    }
    NSString *opId = opData.id;
    if (opId.length > 0) {
    } else {
        opId = @"be_null";
    }
    // 添加埋点
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary *baseParams = [self baseLogParam];
    params[UT_ENTER_FROM] = baseParams[UT_ENTER_FROM];
    params[UT_ELEMENT_FROM] = @"banner";
    params[@"rank"] = @(index);
    params[UT_PAGE_TYPE] = [self pageTypeString];
    params[@"item_title"] = opData.title.length > 0 ? opData.title : @"be_null";
    params[@"item_id"] = opId;
    params[@"description"] = opData.descriptionStr.length > 0 ? opData.descriptionStr : @"be_null";
    NSString *origin_from = @"be_null";
    if (opData.logPb && [opData.logPb isKindOfClass:[NSDictionary class]]) {
        origin_from = opData.logPb[@"origin_from"];
    }
    params[@"origin_from"] = origin_from;
    params[UT_LOG_PB] = opData.logPb ? : @"be_null";
    [FHUserTracker writeEvent:@"banner_show" params:params];
}

- (void)clickBannerItem:(FHConfigDataRentOpDataItemsModel *)opData withIndex:(NSInteger)index
{
    NSString *opId = opData.id;
    if (opId.length > 0) {
    } else {
        opId = @"be_null";
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary *baseParams = [self baseLogParam];
    params[UT_ENTER_FROM] = baseParams[UT_ENTER_FROM];
    params[UT_ELEMENT_FROM] = @"banner";
    params[@"rank"] = @(index);
    params[UT_PAGE_TYPE] = [self pageTypeString];
    params[@"item_title"] = opData.title.length > 0 ? opData.title : @"be_null";
    params[@"item_id"] = opId;
    params[@"description"] = opData.descriptionStr.length > 0 ? opData.descriptionStr : @"be_null";
    NSString *origin_from = @"be_null";
    if (opData.logPb && [opData.logPb isKindOfClass:[NSDictionary class]]) {
        origin_from = opData.logPb[@"origin_from"];
    }
    params[@"origin_from"] = origin_from;
    params[UT_LOG_PB] = opData.logPb ? : @"be_null";
    [FHUserTracker writeEvent:@"banner_click" params:params];
    
    // 页面跳转，origin_from：服务端下方，如果进入到房源相关页面需要透传
    if (opData.openUrl.length > 0) {
        NSMutableDictionary *trace_params = [NSMutableDictionary new];
        trace_params[@"origin_from"] = origin_from;
        trace_params[@"enter_from"] = baseParams[UT_ENTER_FROM];
        
        NSDictionary *infoDict = @{@"tracer":trace_params};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        NSMutableString *openUrl = [[NSMutableString alloc] initWithString:opData.openUrl];
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)willChangeTopViewBackgroundColor:(UIColor *)bgColor
{
    self.navbar.backgroundColor = bgColor;
}

//-(void)rentBannerLoaded:(UIView *)bannerView
//{
//    self.showNotifyDoneBlock = ^{
//        //banner图片加载成功
//        CGFloat bannerHeight = bannerView.height;
//        self.topBannerView.frame = CGRectMake(0, 0,SCREEN_WIDTH , ICON_HEADER_HEIGHT + bannerHeight);
//        
//        CGRect frame = [self.topView relayout];
//        UIEdgeInsets insets = self.tableView.contentInset;
//        
//        BOOL scrolled = fabs(self.tableView.contentOffset.y + insets.top) > 1;
//        
//        insets.top = CGRectGetHeight(frame);
//        self.tableView.contentInset = insets;
//        
//        if (self.topView.superview == self.topContainerView) {
//            [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(self.topView.height - [self.topView filterTop]);
//            }];
//            self.topView.top = -[self.topView filterTop];
//        }else{
//            self.topView.top = -frame.size.height;
//            if (!scrolled) {
//                self.tableView.contentOffset = CGPointMake(0, -insets.top);
//            }
//        }
//    };
//    
//    if (self.animateShowNotify) {        
//        return;
//    }
//    
//    self.showNotifyDoneBlock();
//    self.showNotifyDoneBlock = nil;
//    
//
//}

- (NSString *)getEvaluateWebParams:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
    if (data && !error) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        temp = [temp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return temp;
    }
    return nil;
}

-(void)gotoCommuteList:(UIViewController *)popController
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHConfigDataRentBannerItemsModel *item = [dataModel.rentBanner.items firstObject];
    NSURL *url = [NSURL URLWithString:item.openUrl];
    
    NSMutableDictionary *param = [[self baseLogParam]mutableCopy];
    param[UT_ENTER_TYPE] = @"click";
    param[UT_ENTER_FROM] = popController? @"commuter_detail" :@"rent_list";
    param[UT_ELEMENT_FROM] = UT_BE_NULL;
    param[UT_SEARCH_ID] = self.searchId;
    
    param[UT_ORIGIN_FROM] = UT_OF_COMMUTE;
    if (!param[UT_ORIGIN_SEARCH_ID]) {
        param[UT_ORIGIN_SEARCH_ID] = @"be_null";
    }
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary new];
    userInfoDict[TRACER_KEY] = param;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:userInfoDict];
    if (popController) {
        __weak typeof(self) wself = self;
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
            NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:nav.viewControllers];
            [controllers removeObject:popController];
            [controllers addObject:routeObj.instance];
            [nav setViewControllers:controllers animated:YES];
        }];
    }else{
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}


#pragma mark - filter delegate

-(void)onConditionChanged:(NSString *)condition
{
    if ([self.conditionFilter isEqualToString:condition]) {
        return;
    }
    self.fromRecommend = NO;

    self.conditionFilter = condition;
    NSString *allQuery = [self.houseFilterBridge getAllQueryString];
    self.allQuery = allQuery;
    if (self.topTagsView) {
        NSMutableDictionary *filterDict = @{}.mutableCopy;
        NSDictionary *queryDict = [self.filterOpenUrlMdodel queryDictBy:allQuery];
        if (queryDict) {
            [filterDict addEntriesFromDictionary:queryDict];
        }
        self.topTagsView.lastConditionDic = filterDict;
        self.topTagsView.condition = allQuery;
    }
    
    [self.tableView triggerPullDown];
    self.fromRecommend = NO;
    [self requestData:YES];
}

-(void)onConditionPanelWillDisplay
{
    if (self.topView.superview != self.topContainerView){
        //筛选器不在顶部时 才上移
        self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] - self.topView.height);
    }
    
    //只显示筛选器
    [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.topView filterBottom] - [self.topView filterTop]);
    }];
    [self scrollViewDidScroll:self.tableView];
    self.showFilter = YES;
}

-(void)onConditionPanelWillDisappear
{
    self.showFilter = NO;
    if (!self.errorMaskView.isHidden) {
        //显示无网或者无结果view
        self.tableView.contentOffset = CGPointMake(0, -self.topView.height);
    }
    [self scrollViewDidScroll:self.tableView];
}

-(UIImage *)placeHolderImage
{
    if (!_placeHolderImage) {
        _placeHolderImage = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolderImage;
}

#pragma mark - tableview delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sugesstHouseList.count > 0) {
        return 2;
    }
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_showPlaceHolder) {
        return  10;
    }
    
    return section == 0 ? self.houseList.count : self.sugesstHouseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (_showPlaceHolder) {
        FHHomePlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaceCellId];
        cell.topOffset = 20;
        return cell;
    }else{
        BOOL isLastCell = NO;
        BOOL isFirstCell = NO;
        
        NSString *identifier = @"";
        id data = nil;
        if (indexPath.section == 0) {
            data = self.self.houseList[indexPath.row];
            
        } else {
            isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
            if (indexPath.row < self.sugesstHouseList.count) {
                data = self.sugesstHouseList[indexPath.row];
            }
        }
        isFirstCell = (indexPath.row == 0);
        if (data) {
            identifier = [self cellIdentifierForEntity:data];
        }
        
        __weak typeof(self)wself = self;
        if (identifier.length > 0) {
             FHListBaseCell *cell = (FHListBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
                FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)data;
                if (item.houseType.integerValue == FHHouseTypeNewHouse && item.cellStyles == 6) {
                    FHHouseListBaseItemCell *newHousecell = (FHHouseListBaseItemCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                    [newHousecell updateSynchysisNewHouseCellWithSearchHouseModel:item];
                    return newHousecell;
                }
            }
            
            if ([cell isKindOfClass:[FHHouseAgentCardCell class]]) {
                FHHouseAgentCardCell *agentCardCell = (FHHouseAgentCardCell *)cell;
                NSMutableDictionary *traceDict = [NSMutableDictionary new];
                traceDict[@"origin_from"] = @"old";
                traceDict[@"element_type"] = @"be_null";
                traceDict[@"page_type"] = @"old_kind_list";
                traceDict[@"rank"] = @"0";
                traceDict[@"search_id"] = self.searchId;
                traceDict[@"origin_search_id"] = self.originSearchId;
                traceDict[@"realtor_position"] = @"realtor_card";
                agentCardCell.traceParams = traceDict;
                agentCardCell.currentWeakVC = self.viewController;
            }
            
            if ([cell isKindOfClass:[FHFindHouseHelperCell class]]) {
                FHFindHouseHelperCell *helperCell = (FHFindHouseHelperCell *) cell;
                helperCell.cellTapAction = ^(NSString *url){
                    [wself jump2HouseFindPageWithUrl:url];
                };
            }
            
               [cell refreshWithData:data];
            if ([cell isKindOfClass:[FHHouseListAgencyInfoCell class]]) {
                FHHouseListAgencyInfoCell *agencyInfoCell = (FHHouseListAgencyInfoCell *)cell;
                if (!agencyInfoCell.btnClickBlock) {
                    agencyInfoCell.btnClickBlock = ^{
                        [wself jump2Webview:data];
                    };
                }
            }else if ([cell isKindOfClass:[FHSuggestionSubscribCell class]]) {
                FHSuggestionSubscribCell *subscribeCell = (FHSuggestionSubscribCell *)cell;
                subscribeCell.addSubscribeAction = ^(NSString * _Nonnull subscribeText) {
                    [wself requestAddSubScribe:subscribeText];
                };
                NSString *subscribeText = nil;
                if ([data isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                    FHSugSubscribeDataDataSubscribeInfoModel *subscribModel = (FHSugSubscribeDataDataSubscribeInfoModel *)data;
                    subscribeText = subscribModel.text;
                }
                subscribeCell.deleteSubscribeAction = ^(NSString * _Nonnull subscribeId) {
                    [wself requestDeleteSubScribe:subscribeId andText:subscribeText];
                };
            }else if ([cell isKindOfClass:[FHHousReserveAdviserCell class]]) {
                FHHousReserveAdviserCell *adCell = (FHHousReserveAdviserCell *)cell;
                WeakSelf;
                adCell.textFieldShouldBegin = ^{
                    if([wself.tableView isKindOfClass:[FHMainListTableView class]]){
                        FHMainListTableView *tableView = (FHMainListTableView *)wself.tableView;
                        tableView.forbiddenScrollRectToVisible = YES;
                    }
                };
                adCell.textFieldDidEnd = ^{
                    if([wself.tableView isKindOfClass:[FHMainListTableView class]]){
                        FHMainListTableView *tableView = (FHMainListTableView *)wself.tableView;
                        tableView.forbiddenScrollRectToVisible = NO;
                    }
                };
            }
            return cell;
        }
        
    }
    return [[FHListBaseCell alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder) {
        return 88;
    }
    BOOL isFirstCell = NO;
    BOOL isLastCell = NO;
    id data = nil;
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            data = self.houseList[indexPath.row];
            if (indexPath.row == self.houseList.count - 1) {
                isLastCell = YES;
            }
            if (indexPath.row == 0) {
                isFirstCell = YES;
            }
        }
    } else {
        if (indexPath.row < self.sugesstHouseList.count) {
            data = self.sugesstHouseList[indexPath.row];
            if (indexPath.row == self.sugesstHouseList.count - 1) {
                isLastCell = YES;
            }
            if (indexPath.row == 0) {
                isFirstCell = YES;
            }
        }
    }
    if (data) {
        id cellClass = [self cellClassForEntity:data];
        if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)data;
            item.isLastCell = isLastCell;
            if ((item.houseType.integerValue == FHHouseTypeRentHouse || item.houseType.integerValue == FHHouseTypeNeighborhood) && isFirstCell) {
                item.topMargin = 10;
            }else {
                item.topMargin = 0;
            }
            data = item;
        }
        if ([[cellClass class]respondsToSelector:@selector(heightForData:)]) {
            return [[cellClass class] heightForData:data];
        }
    }
    return 88;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_showPlaceHolder) {
        FHSearchBaseItemModel *cellModel = nil;
        NSString *hashString = @"";
        if (indexPath.section == 0) {
            if (indexPath.row < self.houseList.count) {
                cellModel = self.houseList[indexPath.row];
            }
        } else {
            if (indexPath.row < self.sugesstHouseList.count) {
                cellModel = self.sugesstHouseList[indexPath.row];
            }
        }
        if (![cellModel isKindOfClass:[FHSearchBaseItemModel class]]) {
            return;
        }
        
        if (cellModel.cardType == FHSearchCardTypeAgentCard) {
           return;
        }
        
        if ([cellModel respondsToSelector:@selector(hash)]) {
            hashString = [NSString stringWithFormat:@"%ld",[cellModel hash]];
        }
        if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)cellModel;
            hashString = item.id;
        }
        if (hashString.length < 1) {
            return;
        }
        
        NSString *hasShow = self.showHouseDict[hashString];
        if ([hasShow isEqualToString:@"1"]) {
            return;
        }
        [self addHouseShowLog:cellModel withRank:indexPath.row];
        self.showHouseDict[hashString] = @"1";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder) {
        return;
    }
    
    id cellModel = nil;
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            cellModel = self.houseList[indexPath.row];
        }
    } else {
        if (indexPath.row < self.sugesstHouseList.count) {
            cellModel = self.sugesstHouseList[indexPath.row];           
        }
    }
    
    if ([cellModel isKindOfClass:[FHSearchBaseItemModel class]] && ((FHSearchBaseItemModel *)cellModel).cardType == FHSearchCardTypeAgentCard) {
        return;
    }
    
    if([cellModel isKindOfClass:[FHHouseReserveAdviserModel class]] || [cellModel isKindOfClass:[FHHouseNeighborAgencyModel class]]){
        return;
    }
    
    [self showHouseDetail:cellModel atIndexPath:indexPath];
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        if (model.houseType.integerValue != FHHouseTypeNewHouse) {
              if (self.houseType == FHHouseTypeSecondHandHouse) {
                      [[FHRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
                  }
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.showFilter) {
        //正在展示筛选器
        return;
    }
    BOOL shouldInTable = (scrollView.contentOffset.y + scrollView.contentInset.top <  [self.topView filterTop]);
    [self moveToTableView:shouldInTable];
    [self.viewController refreshContentOffset:scrollView.contentOffset];

}


-(void)moveToTableView:(BOOL)toTableView
{
    if (toTableView) {
        
        [self.topView showFilterCorner:YES];
        if (!self.topBannerView) {
            return;
        }
        if (self.topView.superview == self.tableView) {
            return;
        }
        
        self.topView.top = -self.topView.height;
        [self.tableView addSubview:self.topView];
        [self.tableView sendSubviewToBack:self.topView];
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
    }else{
        
        [self.topView showFilterCorner:NO];
        if (self.topView.superview == self.topContainerView){
            return;
        }
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topView.height - [self.topView filterTop]);
        }];
        
        [self.topContainerView addSubview:self.topView];
        self.topView.top = -[self.topView filterTop];
    }
}

-(void)showNotifyMessage:(NSString *)message
{
    self.animateShowNotify = YES;
    __weak typeof(self) wself = self;
    CGFloat height =  [_topView showNotify:message willCompletion:^{
        wself.tableView.scrollEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            [wself configNotifyInfo:[wself.topView filterBottom] isShow:NO];
            
        } completion:^(BOOL finished) {
            wself.tableView.scrollEnabled = YES;
            if (wself.showNotifyDoneBlock) {
                wself.showNotifyDoneBlock();
                wself.showNotifyDoneBlock = nil;
            }
            wself.animateShowNotify = NO;
        }];
    }];
    
    [self configNotifyInfo:height isShow:YES];
    
}

-(void)configNotifyInfo:(CGFloat)topViewHeight isShow:(BOOL)isShow
{
    UIEdgeInsets insets = self.tableView.contentInset;
    BOOL isTop = (fabs(self.tableView.contentOffset.y) < 0.1) || fabs(self.tableView.contentOffset.y + self.tableView.contentInset.top) < 0.1; //首次进入情况
    insets.top = topViewHeight;
    self.tableView.contentInset = insets;
    _topView.frame = CGRectMake(0, -topViewHeight, _topView.width, topViewHeight);
    
    if (isShow) {
        if (isTop) {
            [self.tableView setContentOffset:CGPointMake(0, -topViewHeight) animated:NO];
        }else{
            self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] -topViewHeight);
        }
    }else{
        if (isTop) {
            [self.tableView setContentOffset:CGPointMake(0, -topViewHeight) animated:NO];
        } else {
            if (self.tableView.contentOffset.y >= -[self.topView filterBottom]) {
                if (self.tableView.contentOffset.y < ([self.topView filterTop] - topViewHeight - [self.topView notifyHeight])) {
                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + [self.topView notifyHeight]);
                } else if (self.tableView.contentOffset.y < self.tableView.height){
                    
                    if (!self.tableView.isDragging || (self.tableView.contentOffset.y < ([self.topView filterTop] - topViewHeight))) {
                        //小于一屏再进行设置
                        self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] - topViewHeight);
                        
                    }
                }
            }
        }
    }
    
    if (_topView.superview == self.topContainerView) {
        self.topView.top = -[self.topView filterTop];
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topView.height - [self.topView filterTop]);
        }];
    }
}


#pragma mark - goto detail

- (void)jump2Webview:(FHSearchRealHouseAgencyInfo *)model
{
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    if (![model isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
        return;
    }
    if ([model isKindOfClass:[FHSearchRealHouseAgencyInfo class]] &&[model.openUrl isKindOfClass:[NSString class]]) {
        
        NSString *urlStr = model.openUrl;
        
        if ([urlStr isKindOfClass:[NSString class]]) {
            NSDictionary *info = @{@"url":urlStr,@"fhJSParams":@{},@"title":@" "};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"] userInfo:userInfo];
        }
    }
}

-(void)showHouseDetail:(id)cellModel atIndexPath:(NSIndexPath *)indexPath
{
    NSString *logPb = @"";
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        logPb = model.logPb;
    }
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    NSMutableDictionary *tracerParam = [NSMutableDictionary dictionary];
    NSString *urlStr = nil;
    tracerParam[@"card_type"] = @"left_pic";
    if (_mainListPage && self.houseType == FHHouseTypeRentHouse) {
        
        SETTRACERKV(UT_ORIGIN_FROM, @"renting_list");
        
        id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
        [envBridge setTraceValue:self.originSearchId forKey:UT_ORIGIN_SEARCH_ID];
        
        [tracerParam addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict]];        
        tracerParam[UT_ELEMENT_FROM] = @"be_null";
        tracerParam[UT_ENTER_FROM] = @"renting";
        tracerParam[UT_LOG_PB] = logPb;
        tracerParam[@"rank"] = @(indexPath.row);
        tracerParam[UT_ORIGIN_FROM] = @"renting_list";
        tracerParam[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
        if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
            urlStr = [NSString stringWithFormat:@"fschema://rent_detail?house_id=%@", model.id];
        }
    }else if (self.houseType == FHHouseTypeSecondHandHouse){
        
        NSInteger rank = indexPath.row;
        if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
            if (model.isRecommendCell) {
                tracerParam[UT_ELEMENT_FROM] = @"search_related";
                tracerParam[UT_SEARCH_ID] = self.recommendSearchId;
            } else {
                tracerParam[UT_ELEMENT_FROM] = [self elementTypeString];
                tracerParam[UT_SEARCH_ID] = self.searchId;
            }
            tracerParam[UT_ENTER_FROM] = [self pageTypeString];
        }

        tracerParam[UT_LOG_PB] = logPb;
        tracerParam[UT_ORIGIN_FROM] = self.originFrom;
        tracerParam[UT_ORIGIN_SEARCH_ID] = self.originSearchId ?:@"be_null";
        tracerParam[@"rank"] = @(rank);
        
        [contextBridge setTraceValue:self.originFrom forKey:UT_ORIGIN_FROM];
        [contextBridge setTraceValue:self.originSearchId forKey:UT_ORIGIN_SEARCH_ID];

        if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
            if (model.externalInfo.externalUrl &&  model.externalInfo.isExternalSite.boolValue) {
                NSMutableDictionary * dictRealWeb = [NSMutableDictionary new];
                [dictRealWeb setValue:@(model.houseType.integerValue) forKey:@"house_type"];
                tracerParam[@"group_id"] = model.id ? : @"be_null";
                tracerParam[@"impr_id"] = model.imprId ? : @"be_null";
                [dictRealWeb setValue:tracerParam forKey:@"tracer"];
                [dictRealWeb setValue:model.externalInfo.externalUrl forKey:@"url"];
                [dictRealWeb setValue:model.externalInfo.backUrl forKey:@"backUrl"];
                
                TTRouteUserInfo *userInfoReal = [[TTRouteUserInfo alloc] initWithInfo:dictRealWeb];
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://house_real_web"] userInfo:userInfoReal];
                return;
            }
            if (model.houseType.integerValue == FHHouseTypeNewHouse) {
                 urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",model.id];
//                tracerParam[UT_ORIGIN_FROM] = @"renting_list";
            }else {
                 urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",model.id];
            }
           
        }
    }
    
    if (urlStr) {
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict[@"tracer"] = tracerParam;
             dict[@"house_type"] = @(self.houseType);
            if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
                FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
                if (model.houseType.integerValue == FHHouseTypeNewHouse) {
                    dict[@"house_type"] = @(model.houseType.integerValue);
                }
            }
            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByViewController:url userInfo: userInfo];
        }
    }
}

//跳转到帮我找房
- (void)jump2HouseFindPageWithUrl:(NSString *)url {
    if (url.length > 0) {
        NSDictionary *tracerInfo = @{
            @"element_from": @"driving_find_house_card",
            @"enter_from": @"old_list",
        };
        NSURL *openUrl = [NSURL URLWithString:url];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] init];
        userInfo.allInfo = @{@"tracer": tracerInfo};
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

#pragma mark - log

-(NSMutableDictionary *)baseLogParam
{
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    //    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    //    NSDictionary *houseParams = [envBridge homePageParamsMap];
    [param addEntriesFromDictionary:[self.viewController.tracerModel logDict]];
    //    [param addEntriesFromDictionary:houseParams];
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ?: @"be_null";
    param[UT_SEARCH_ID] = self.searchId ?: @"be_null";
    if (_mainListPage && self.houseType == FHHouseTypeRentHouse) {
        param[UT_ENTER_FROM] = @"renting";
    }
    
    return param;
}

-(NSString *)pageTypeString
{
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        return @"renting";
    }
    return @"old_kind_list";
}

-(NSString *)categoryName
{
    if (_mainListPage) {
        if (_houseType == FHHouseTypeRentHouse) {
            return @"renting";
        }
        return @"old_kind_list";
    }
    
    switch (self.houseType) {
            case FHHouseTypeNewHouse:
            return @"new_list";
            break;
            case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
            case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
            case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)houseTypeString
{
    switch (self.houseType) {
            case FHHouseTypeNewHouse:
            return @"new";
            break;
            case FHHouseTypeSecondHandHouse:
            return @"old";
            break;
            case FHHouseTypeRentHouse:
            return @"rent";
            break;
            case FHHouseTypeNeighborhood:
            return @"neighborhood";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)elementTypeString {
    
    return @"be_null";
    
}


-(void)addEnterLog
{
    /*
     enter_category
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     */
    
    if (self.viewController.tracerModel) {
        FHTracerModel *model = self.viewController.tracerModel;
        TRACK_MODEL(UT_ENTER_CATEOGRY,model);
        self.stayTraceDict = [model logDict];
    }
    
}

-(void)addClickSearchLog
{
    
    /*
     1. event_type：house_app2c_v2
     2. page_type（页面类型）：renting（租房大类页），rent_list（租房列表页），findtab_rent（租房）
     3. origin_from
     4. origin_search_id
     5. hot_word（搜索框轮播词，无轮播词记为be_null）
     */

    NSMutableDictionary *homeParams = [NSMutableDictionary new];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[UT_PAGE_TYPE] = [self pageTypeString];
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId?:@"be_null";
    params[@"hot_word"] = @"be_null";
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        params[UT_ORIGIN_FROM] = @"renting_search";
    }else{
        params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    }
    params[UT_ORIGIN_SEARCH_ID] = self.viewController.tracerModel.originSearchId;
    
    TRACK_EVENT(@"click_house_search",params);
}

- (void)addHouseSearchLog
{
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.houseSearchDic) {
        [params addEntriesFromDictionary:self.houseSearchDic];
    } else {
        // house_search 上报时机是通过搜索（搜索页面）进入的搜索列表页，而通过搜索点击tab进入的不上报当前埋点，过滤器重新选择后也上报
        return;
    }
    params[@"house_type"] = [self houseTypeString];
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[UT_SEARCH_ID] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom.length > 0 ? self.viewController.tracerModel.originFrom : @"be_null";
    params[@"growth_deepevent"] = @(1);
    TRACK_EVENT(@"house_search",params);
    self.canChangeHouseSearchDic = YES;
}

- (void)addOperationShowLog:(NSDictionary *)logPb
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"operation_name"] = logPb[@"operation_name"] ? : @"be_null";
    tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
    tracerDict[UT_LOG_PB] = logPb ? : @"be_null";
    [FHUserTracker writeEvent:@"operation_show" params:tracerDict];
}

//- (void)addOperationClickLog:(NSDictionary *)logPb
//{
//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[@"operation_name"] = logPb[@"operation_name"] ? : @"be_null";
//    tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
//    tracerDict[UT_LOG_PB] = logPb ? : @"be_null";
//    [FHUserTracker writeEvent:@"operation_click" params:tracerDict];
//}

- (void)addClickIconLog:(NSDictionary *)logPb
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    NSDictionary *baseParams = [self baseLogParam];
    tracerDict[UT_ENTER_FROM] = baseParams[UT_ENTER_FROM] ? : @"be_null";
    tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
    tracerDict[UT_LOG_PB] = logPb ? : @"be_null";
    [FHUserTracker writeEvent:@"click_icon" params:tracerDict];
}

-(void)addStayLog:(NSTimeInterval)duration
{
    duration = duration * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
    self.stayTraceDict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",duration];
    self.stayTraceDict[UT_SEARCH_ID] = self.searchId;
    self.stayTraceDict[UT_ORIGIN_SEARCH_ID] = self.originSearchId;
    self.stayTraceDict[UT_ORIGIN_FROM] = self.originFrom;

    TRACK_EVENT(@"stay_category", self.stayTraceDict);
    [self.viewController tt_resetStayTime];
    
}


-(void)addLoadMoreRefreshLog
{
    NSMutableDictionary *param = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. refresh_type（刷新类型）：pre_load_more（滑动频道）"
     */
    
    //    param[UT_SEARCH_ID] = self.searchId;
    param[@"refresh_type"] = @"pre_load_more";
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom?:@"maintab";
    
    TRACK_EVENT(@"category_refresh", param);
}

-(void)addHouseShowLog:(FHSearchBaseItemModel *)cellModel withRank: (NSInteger) rank
{
    if (![cellModel isKindOfClass:[FHSearchBaseItemModel class]]) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    NSDictionary *baseParam = [self baseLogParam];

    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"rank"] = @(rank);
    tracerDict[UT_ORIGIN_FROM] = baseParam[UT_ORIGIN_FROM] ? : @"be_null";;
    tracerDict[UT_ORIGIN_SEARCH_ID] = self.viewController.tracerModel.originSearchId ? : @"be_null";
    tracerDict[UT_SEARCH_ID] = self.searchId;

    NSString *hashString = [NSString stringWithFormat:@"%ld",cellModel.hash];

    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *houseModel = (FHSearchHouseItemModel *)cellModel;
        if (houseModel.isRecommendCell) {
            tracerDict[@"page_type"] = [self pageTypeString];
            tracerDict[@"element_type"] = @"search_related";
            tracerDict[@"search_id"] = self.recommendSearchId ? : @"be_null";
        }else {
            tracerDict[@"page_type"] = [self pageTypeString];
            tracerDict[@"element_type"] = @"be_null";
            tracerDict[@"search_id"] = self.searchId ? : @"be_null";
        }
        tracerDict[@"group_id"] = houseModel.id ? : @"be_null";
        tracerDict[@"impr_id"] = houseModel.imprId ? : @"be_null";
        tracerDict[@"log_pb"] = houseModel.logPb ? : @"be_null";
        tracerDict[@"house_type"] = houseModel.houseType.integerValue == FHHouseTypeNewHouse?@"new": ([self houseTypeString] ? : @"be_null");
        tracerDict[@"card_type"] = @"left_pic";
        
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    } else if ([cellModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        
        FHSugSubscribeDataDataSubscribeInfoModel *cellSubModel = (FHSugSubscribeDataDataSubscribeInfoModel *)cellModel;
        cellSubModel.subscribeId = @{};
        if ([cellSubModel.subscribeId isKindOfClass:[NSString class]] && [cellSubModel.subscribeId integerValue] != 0) {
            tracerDict[@"subscribe_id"] = cellSubModel.subscribeId;
        }else {
            tracerDict[@"subscribe_id"] = @"be_null";
        }
        tracerDict[@"title"] = cellSubModel.title ? : @"be_null";
        tracerDict[@"text"] = cellSubModel.text ? : @"be_null";
        
        self.subScribeShowDict = tracerDict;
        [FHUserTracker writeEvent:@"subscribe_show" params:tracerDict];
    }else if([cellModel isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        
        [tracerDict setValue:@"be_null" forKey:@"element_from"];
        [tracerDict setValue:@"filter_false_tip" forKey:@"element_type"];
        [FHUserTracker writeEvent:@"filter_false_tip_show" params:tracerDict];
    }else if([cellModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
        
        [tracerDict setValue:@"be_null" forKey:@"element_from"];
        [tracerDict setValue:@"selection_preference_tip" forKey:@"element_type"];
        [FHUserTracker writeEvent:@"selection_preference_tip_show" params:tracerDict];
    }else if ([cellModel isKindOfClass:[FHHouseNeighborAgencyModel class]]) {

        FHHouseNeighborAgencyModel *agencyCM = (FHHouseNeighborAgencyModel *)cellModel;
        [self addLeadShowLog:agencyCM];
        tracerDict[@"page_type"] = [self pageTypeString];
        tracerDict[@"card_type"] = @"left_pic";
        if(self.houseType == FHHouseTypeNeighborhood){
            tracerDict[@"element_type"] = @"neighborhood_expert_card";
            tracerDict[@"house_type"] = @"neighborhood";
        }else{
            tracerDict[@"element_type"] = @"area_expert_card";
            tracerDict[@"house_type"] = @"area";
        }
        tracerDict[@"origin_from"] = originFrom;
        tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        tracerDict[@"log_pb"] = agencyCM.logPb ? : @"be_null";
        tracerDict[@"realtor_logpb"] = agencyCM.contactModel.realtorLogpb ? : @"be_null";
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    }else if ([cellModel isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        NSDictionary *params = @{@"page_type":@"city_switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_switch_show" params:params];
    }else if ([cellModel isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        FHHouseReserveAdviserModel *cm = (FHHouseReserveAdviserModel *)cellModel;
        tracerDict[@"page_type"] = [self pageTypeString];
        tracerDict[@"enter_from"] = self.tracerModel.enterFrom ? : @"be_null";
        tracerDict[@"element_from"] = self.tracerModel.elementFrom ? : @"be_null";
        if(self.houseType == FHHouseTypeNeighborhood){
            tracerDict[@"element_type"] = @"neighborhood_expert_card";
        }else{
            tracerDict[@"element_type"] = @"area_expert_card";
        }
        tracerDict[@"origin_from"] = originFrom;
        tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        tracerDict[@"log_pb"] = cm.logPb ? : @"be_null";
        [FHUserTracker writeEvent:@"inform_show" params:tracerDict];
    }else if ([cellModel isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        NSDictionary *params = @{@"origin_from":originFrom,
                                 @"event_type":@"house_app2c_v2",
                                 @"page_type":@"old_list",
                                 @"search_id":self.searchId.length > 0 ? self.searchId : @"be_null",
                                 @"element_type":@"driving_find_house_card",
                                };
        [FHUserTracker writeEvent:@"element_show" params:params];
    }
}

- (void)addLeadShowLog:(id)cm
{
    if (![cm isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
        return;
    }
    FHHouseNeighborAgencyModel *cellModel = (FHHouseNeighborAgencyModel *)cm;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"page_type"] = [self pageTypeString];
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"enter_from"] = self.tracerModel.enterFrom;
    tracerDict[@"element_from"] = self.tracerModel.elementFrom ? : @"be_null";
    tracerDict[@"rank"] = @(0);
    tracerDict[@"origin_from"] = self.originFrom;
    tracerDict[@"origin_search_id"] = self.originSearchId ? : UT_BE_NULL;
    tracerDict[@"log_pb"] = cellModel.logPb ? : UT_BE_NULL;
    
    tracerDict[@"is_im"] = cellModel.contactModel.imOpenUrl.length > 0 ? @(1) : @(0);
    tracerDict[@"is_call"] = cellModel.contactModel.phone.length < 1 ? @(0) : @(1);
    tracerDict[@"is_report"] = @(0);
    tracerDict[@"is_online"] = cellModel.contactModel.unregistered ? @(0) : @(1);
    
    if(self.houseType == FHHouseTypeNeighborhood){
        tracerDict[@"element_type"] = @"neighborhood_expert_card";
        tracerDict[@"house_type"] = @"neighborhood";
    }else{
        tracerDict[@"element_type"] = @"area_expert_card";
        tracerDict[@"house_type"] = @"area";
    }
    
    [FHUserTracker writeEvent:@"lead_show" params:tracerDict];
}

-(NSDictionary *)addEnterHouseListLog:(NSString *)openUrl
{
    /*
     "1. event_type：house_app2c_v2
     2. category_name（列表名）：rent_list（租房列表页）
     3. enter_from（列表入口）：renting（租房大类页），maintab（首页），findtab（找房tab）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：renting_icon（租房大类页icon），renting_search（租房大类页搜索），maintab_search（首页搜索）, findtab_find（找房tab开始找房）findtab_search（找房tab搜索）
     6. search_id
     7. origin_from：renting_all（租房大类页全部房源icon），renting_joint（租房大类页合租icon），renting_fully（租房大类页整租icon），renting_apartment（租房大类页公寓icon），maintab_search（首页搜索），findtab_find（找房tab开始找房），findtab_search（找房tab搜索）
     8. origin_search_id"
     
     enter_category
     */
    
    FHHouseRentFilterType filterType = [self rentFilterType:openUrl];
    if (filterType == FHHouseRentFilterTypeMap) {
        //        [self addMapsearchLog];
        return nil;
    }
    
    NSString *originFrom = [self originFromWithFilterType:filterType];
    if (!originFrom) {
        return nil ;
    }
    
    self.originFrom = originFrom;
    NSMutableDictionary *param = [[self baseLogParam]mutableCopy];
    param[UT_CATEGORY_NAME] = @"rent_list";
    param[UT_ENTER_TYPE] = @"click";
    param[UT_ELEMENT_FROM] = @"renting_icon";
    param[UT_SEARCH_ID] = self.searchId;
    
    param[UT_ORIGIN_FROM] = originFrom;
    if (!param[UT_ORIGIN_SEARCH_ID]) {
        param[UT_ORIGIN_SEARCH_ID] = @"be_null";
    }
    
    return param;
}

- (void)addHouseRankLog
{
    NSString *sortType = nil;
    if ([self.houseFilterViewModel isLastSearchBySort]) {
        sortType =  [self.houseFilterViewModel sortType] ? : @"default";
    }
    
    if (sortType.length < 1) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[UT_PAGE_TYPE] = [self pageTypeString];//@"renting";
    params[@"rank_type"] = sortType;
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[UT_SEARCH_ID] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[UT_ORIGIN_FROM] = self.originFrom ? : @"be_null";//
    TRACK_EVENT(@"house_rank",params);
}


#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject
{
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        //JUMP to cat list page
        
        NSMutableDictionary *tracerDict = [self baseLogParam];
        [tracerDict addEntriesFromDictionary:allInfo[@"houseSearch"]];
        tracerDict[UT_CATEGORY_NAME] = @"rent_list";
        tracerDict[UT_ELEMENT_FROM] = @"renting_search";
        tracerDict[UT_PAGE_TYPE] = @"renting";
        tracerDict[UT_ORIGIN_FROM] = allInfo[@"tracer"][UT_ORIGIN_FROM] ? allInfo[@"tracer"][UT_ORIGIN_FROM] : @"be_null";
        
        NSMutableDictionary *houseSearchDict = [[NSMutableDictionary alloc] initWithDictionary:allInfo[@"houseSearch"]];
        houseSearchDict[UT_PAGE_TYPE] = @"renting";
        allInfo[@"houseSearch"] = houseSearchDict;
        allInfo[@"tracer"] = tracerDict;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:allInfo];
        
        routeObject.paramObj.userInfo = userInfo;
        [[TTRoute sharedRoute] openURLByPushViewController:routeObject.paramObj.sourceURL userInfo:routeObject.paramObj.userInfo];
    }
    
}


#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        //有网络了，重新请求
        if (!self.errorMaskView.isHidden) {
            //只有在显示错误的时候才自动刷新
            [self requestData:YES];
        }
    }
}

+ (id)searchItemModelByDict:(NSDictionary *)itemDict
{
    NSInteger cardType = [itemDict tt_integerValueForKey:@"card_type"];
    id itemModel = nil;
    NSError *jerror = nil;

    switch (cardType) {
        case FHSearchCardTypeSecondHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNewHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeRentHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNeighborhood:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeSubscribe:
            itemModel = [[FHSugSubscribeDataDataSubscribeInfoModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNeighborExpert:
            itemModel = [[FHHouseNeighborAgencyModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeAgencyInfo:
            itemModel = [[FHSearchRealHouseAgencyInfo alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeFilterHouseTip:
            itemModel = [[FHSugListRealHouseTopInfoModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeGuessYouWantTip:
            itemModel = [[FHSearchGuessYouWantTipsModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeGuessYouWantContent:
            itemModel = [[FHSearchGuessYouWantContentModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeAgentCard:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        default:
            break;
    }
    return itemModel;
}


@end

