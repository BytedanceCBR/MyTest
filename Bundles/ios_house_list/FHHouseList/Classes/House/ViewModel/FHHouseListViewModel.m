//
//  FHHouseListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewModel.h"
#import "MJRefresh.h"
#import "FHRefreshCustomFooter.h"
#import "TTHttpTask.h"
#import "FHHouseListAPI.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"

#import "FHHomePlaceHolderCell.h"
#import "FHPlaceHolderCell.h"
#import "TTReachability.h"
#import "FHMainManager+Toast.h"
#import "UIScrollView+Refresh.h"
#import "FHSearchFilterOpenUrlModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FHMapSearchOpenUrlDelegate.h"
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import "Masonry.h"
#import "FHEnvContext.h"
#import "FHRecommendSecondhandHouseTitleCell.h"
#import "FHRecommendSecondhandHouseTitleModel.h"
#import "FHHouseBridgeManager.h"
#import "FHCityListViewModel.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "HMDTTMonitor.h"
#import "FHSugSubscribeModel.h"
#import "FHSuggestionSubscribCell.h"
#import <FHCommonUI/ToastManager.h>
#import "FHCommutePOISearchViewController.h"
#import "FHCommuteManager.h"
#import <FHHouseBase/FHEnvContext.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <BDALog/BDAgileLog.h>
#import "FHSuggestionRealHouseTopCell.h"
#import <TTBaseLib/NSString+URLEncoding.h>
#import <FHHouseBase/FHSearchChannelTypes.h>
#import "FHHouseListAgencyInfoCell.h"
#import <FHHouseBase/FHUtils.h>
#import "FHHouseListNoHouseCell.h"
#import "FHHouseOpenURLUtil.h"
#import "FHFakeInputNavbar.h"
#import "FHEnvContext.h"
#import "FHMessageManager.h"
#import "FHNeighbourhoodAgencyCardCell.h"
#import "FHHousReserveAdviserCell.h"
#import <FHHouseDetail/FHDetailBaseModel.h>
#import "FHHouseListRecommendTipCell.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "FHMainOldTopTagsView.h"
#import "FHHouseListRedirectTipCell.h"
#import <FHHouseBase/FHRelevantDurationTracker.h>
#import "FHHouseListBaseItemCell.h"
#import "FHFindHouseHelperCell.h"
#import "FHHouseSearchSecondHouseCell.h"
#import "FHHouseSearchNewHouseCell.h"
#import "FHDynamicLynxCell.h"
#import "NSDictionary+BTDAdditions.h"
#import "NSArray+BTDAdditions.h"
#import "UITableView+FHHouseCard.h"
#import "FHHouseCardUtils.h"
#import "NSObject+FHTracker.h"
#import "FHHouseListRentCell.h"
#import "FHHouseTableView.h"
#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardCellViewModelProtocol.h"
#import "FHSuggestionDefines.h"
#import "SSCommonLogic.h"
#import "FHHouseCardStatusManager.h"

extern NSString *const INSTANT_DATA_KEY;

#define NO_HOUSE_CELL_ID @"no_house_cell"


@interface FHHouseListViewModel(FHHouseTableView)<FHHouseTableViewDataSource, FHHouseNewComponentViewModelDelegate>

- (NSObject *)getEntityFromModel:(id)model;

@end

@interface FHHouseListViewModel () <UITableViewDelegate, UITableViewDataSource, FHMapSearchOpenUrlDelegate, FHHouseSuggestionDelegate,FHCommutePOISearchDelegate>

@property(nonatomic , weak) FHErrorView *maskView;

@property(nonatomic, weak) UITableView *tableView;

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) NSMutableArray *sugesstHouseList;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property (nonatomic , copy, nullable) NSString *searchId;
@property (nonatomic , copy, nullable) NSString *recommendSearchId;
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , strong) NSDictionary *houseSearchDic;
@property(nonatomic , assign) BOOL canChangeHouseSearchDic;// houseSearchDic[@"query_type"] = @"filter"

@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;

@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , assign) BOOL showRealHouseTop;
@property(nonatomic , assign) BOOL showFakeHouseTop;
@property(nonatomic , assign) BOOL lastHasMore;
@property(nonatomic , assign) BOOL isHasFilterCondition;


@property (nonatomic , assign) BOOL isRefresh;
@property (nonatomic , assign) BOOL isFirstHavetip;
@property (nonatomic , copy) NSString *query;
@property (nonatomic , copy) NSString *condition;

@property (nonatomic, copy) NSString *mapFindHouseOpenUrl;
@property(nonatomic , strong) NSMutableDictionary *houseShowCache;
@property(nonatomic , strong) FHTracerModel *tracerModel;
// log
@property (nonatomic , assign) BOOL isFirstLoad;
@property (nonatomic , assign) BOOL fromRecommend;

//subscribe
@property (nonatomic , assign) NSInteger subScribeOffset;
@property (nonatomic , strong) NSString * subScribeSearchId;
@property (nonatomic , strong) NSString * queryStr;
@property (nonatomic , strong) NSString * subScribeQuery;
@property (nonatomic , strong) NSDictionary * subScribeShowDict;
@property (nonatomic , assign) BOOL isShowSubscribeCell;

@property (nonatomic, strong) JSONModel *currentRecommendHouseDataModel;
@property (nonatomic, strong) JSONModel *houseDataModel;

@property (nonatomic, weak)     FHFakeInputNavbar       *navbar;
@property(nonatomic , weak) FHMainOldTopTagsView *topTagsView;
@property(nonatomic , strong) NSArray *cellIdArray;
//预约以后的状态暂存
@property (nonatomic, strong) NSMutableDictionary *subscribeCache;

@property (nonatomic, assign) NSTimeInterval startMonitorTime;

@end


@implementation FHHouseListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh];
    };
}

- (void)setTopTagsView:(FHMainOldTopTagsView *)topTagsView
{
    _topTagsView = topTagsView;
}

-(void)clickRedirectTip:(NSString *)openUrl
{
    if (openUrl.length > 0) {

        [FHEnvContext sharedInstance].refreshConfigRequestType = @"switch_house";

        [FHEnvContext openSwitchCityURL:openUrl completion:^(BOOL isSuccess) {
            // 进历史
            if (isSuccess) {
                [[[FHHouseBridgeManager sharedInstance] cityListModelBridge] switchCityByOpenUrlSuccess];
            }
        }];
        NSDictionary *params = @{@"click_type":@"switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_click" params:params];
    }
}

-(instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj {

    self = [super init];
    if (self) {
        _canChangeHouseSearchDic = YES;
        self.houseList = [NSMutableArray array];
        self.sugesstHouseList = [NSMutableArray array];
        self.subscribeCache = [NSMutableDictionary dictionary];
        self.showPlaceHolder = YES;
        self.isRefresh = YES;
        self.isEnterCategory = YES;
        self.isFirstLoad = YES;
        self.isFirstHavetip = YES;
        self.tableView = tableView;
        self.isShowSubscribeCell = NO;
        //prehousetype表示从sug页面所在的housetype
        //jumphousetype表示sug页面网络请求期待跳向的housetype,该housetype不一定开通
        self.preHouseType = [paramObj.allParams[@"pre_house_type"] intValue];
        self.jumpHouseType = [paramObj.allParams[@"jump_house_type"] intValue];
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        _startMonitorTime = [[NSDate date] timeIntervalSince1970];

        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;

        if ([paramObj.sourceURL.host rangeOfString:@"commute_list"].location != NSNotFound) {
            self.houseType = FHHouseTypeRentHouse;
            self.commute = YES;
        }
        if ([paramObj.host isEqualToString:@"neighborhood_deal_list"]) { //和冯康确认过，这个功能已经下线了
            self.houseType = FHHouseTypeNeighborhood;
            self.searchType = FHHouseListSearchTypeNeighborhoodDeal;
        }
        self.houseSearchDic = paramObj.userInfo.allInfo[@"houseSearch"];
        

        [self configTableView];
    }
    return self;
}

- (void)updateTracerDict:(NSDictionary *)tracerDict {
    if (tracerDict && tracerDict.count) {
        self.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDict];
        self.originFrom = self.tracerModel.originFrom;
    }
}

- (void)addTagsViewClick:(NSString *)value_id
{
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self categoryName] ? : @"be_null";
    param[UT_ELEMENT_TYPE] = @"select_options";
    param[UT_SEARCH_ID] = self.searchId ? : @"be_null";
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ? : @"be_null";
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
    param[@"value_id"] = value_id ?: @"be_null";
    TRACK_EVENT(@"click_options", param);
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        [[FHRelevantDurationTracker sharedTracker] sendRelevantDuration];
    }
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
    for (NSString *className in self.cellIdArray) {
        [self registerCellClassBy:className];
    }
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeRentHouse]];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeNeighborhood]];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHouseBaseItemCellList"];
    [_tableView registerClass:[FHFindHouseHelperCell class] forCellReuseIdentifier:@"FHFindHouseHelperCell"];
    [_tableView registerClass:[FHHouseSearchSecondHouseCell class] forCellReuseIdentifier:@"FHHouseSearchSecondHouseCell"];
    [_tableView registerClass:[FHHouseSearchNewHouseCell class] forCellReuseIdentifier:@"FHHouseSearchNewHouseCell"];
    [_tableView registerClass:[FHDynamicLynxCell class] forCellReuseIdentifier:@"FHDynamicLynxCell"];
    [_tableView registerClass:[FHHouseListRentCell class] forCellReuseIdentifier:NSStringFromClass([FHHouseListRentCell class])];
    if(self.commute){
        [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];
    }else{
        [self.tableView registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];
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
        if ([FHEnvContext isDisplayNewCardType]) {
            if (houseModel.houseType.integerValue == FHHouseTypeRentHouse) {
                return [FHHouseListRentCell class];
            }
        }
        if (self.commute) {
            return [FHHouseBaseItemCell class];
        }else if(houseModel.houseType.integerValue == FHHouseTypeNewHouse) {
            return [FHHouseSearchNewHouseCell class];
        }else {
            if (houseModel.houseType.integerValue == FHHouseTypeSecondHandHouse) {
                return [FHHouseSearchSecondHouseCell class];
            }
            return [FHHouseBaseItemCell class];
        }
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
    }else if ([model isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        return [FHSuggestionRealHouseTopCell class];
    }else if ([model isKindOfClass:[FHHomePlaceHolderCellModel class]]) {
        if (self.commute) {
            return [FHPlaceHolderCell class];
        }else {
            return [FHHomePlaceHolderCell class];
        }
    }else if ([model isKindOfClass:[FHHouseListNoHouseCellModel class]]) {
        return [FHHouseListNoHouseCell class];
    }else if ([model isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        return [FHHouseListRedirectTipCell class];
    }else if ([model isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        return [FHHousReserveAdviserCell class];
    }else if ([model isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        return [FHFindHouseHelperCell class];
    }else if ([model isKindOfClass:[FHDynamicLynxCellModel class]]) {
        return [FHDynamicLynxCell class];
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
        if ([FHEnvContext isDisplayNewCardType]) {
            if (houseModel.houseType.integerValue == FHHouseTypeRentHouse) {
                return NSStringFromClass([FHHouseListRentCell class]);
            }
        }
        if(houseModel.houseType.integerValue == FHHouseTypeNewHouse) {
            return NSStringFromClass([FHHouseSearchNewHouseCell class]);
        }
        if (houseModel.houseType.integerValue == FHHouseTypeSecondHandHouse) {
            return NSStringFromClass([FHHouseSearchSecondHouseCell class]);
        }
        return [FHSearchHouseItemModel cellIdentifierByHouseType:houseModel.houseType.integerValue];
    }
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)addNotiWithNaviBar:(FHFakeInputNavbar *)naviBar {
    self.navbar = naviBar;
    if (_houseType == FHHouseTypeSecondHandHouse || _houseType == FHHouseTypeNewHouse || _houseType == FHHouseTypeRentHouse) {
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

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

-(void)configTableView
{
    if ([FHEnvContext isHouseListComponentEnable]) {
        [(FHHouseTableView *)self.tableView setFhHouse_dataSource:self];
        [(FHHouseTableView *)self.tableView registerCellStyles];
    } else {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView fhHouseCard_registerCellStyles];
        [self registerCellClasses];
    }
    
    __weak typeof(self)wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        [wself loadData:wself.isRefresh];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    
    if ([self isNeighborhoodList]) {
        self.tableView.backgroundColor = [UIColor themeGray7];
    }
}

- (BOOL)isNeighborhoodList {
    return (self.houseType == FHHouseTypeNeighborhood && self.searchType != FHHouseListSearchTypeNeighborhoodDeal);
}

-(void)loadData:(BOOL)isRefresh {
    [self loadData:isRefresh fromRecommend:self.fromRecommend];
}

#pragma mark - 网络请求
-(void)loadData:(BOOL)isRefresh fromRecommend:(BOOL)isFromRecommend
{
    if (isRefresh) {
        self.maskView.hidden = YES;
        self.showPlaceHolder = YES;
        [self.tableView reloadData];
    }
    if (![TTReachability isNetworkConnected]) {
        if (isRefresh) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            [self showMaskView:YES];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    NSString *query = self.condition;
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
    NSInteger offset = 0;

    if (isRefresh) {
        if (!_isFirstLoad && _canChangeHouseSearchDic) {
            if (self.houseSearchDic.count <= 0) {
                // pageType 默认就是 [self pageTypeString]
                self.houseSearchDic = @{
                                        @"enter_query":@"be_null",
                                        @"search_query":@"be_null",
                                        @"page_type": [self pageTypeString],
                                        @"query_type":@"filter"
                                        };
            } else {
                NSMutableDictionary *dic = [self.houseSearchDic mutableCopy];
                dic[@"query_type"] = @"filter";
                self.houseSearchDic = dic;
            }
        }else if (self.isCommute && self.houseSearchDic.count <= 0){
            self.houseSearchDic = @{@"query_type":@"mutiple",UT_PAGE_TYPE:[self pageTypeString]};
        }
        self.tableView.mj_footer.hidden = YES;
        [self.houseShowCache removeAllObjects];
        self.searchId = nil;
    } else {
        if (isFromRecommend) {
            offset = [FHHouseListViewModel searchOffsetByhouseModel:self.currentRecommendHouseDataModel];
        } else {
            offset = [FHHouseListViewModel searchOffsetByhouseModel:self.houseDataModel];
        }
    }
    NSString *queryType = self.houseSearchDic[@"query_type"];
    if (queryType.length > 0) {
        if ([query isKindOfClass:[NSString class]] && query.length > 0) {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&query_type=%@",queryType]];
        }else{
            query = [NSString stringWithFormat:@"query_type=%@",queryType];
        }
    }
    NSString *searchId = self.searchId;

    if(self.preHouseType){
        query = [query stringByAppendingFormat:@"&pre_house_type=%ld",self.preHouseType];
    }
    if(self.jumpHouseType){
        query = [query stringByAppendingFormat:@"&jump_house_type=%ld",(long)self.jumpHouseType];
    }
    if (self.isCommute) {
        [self requestCommute:isRefresh query:query offset:offset searchId:searchId];
        return;
    }
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            if (isFromRecommend) {
                [self requestRecommendNewHouseListData:isRefresh query:query offset:offset searchId:self.recommendSearchId];
            } else {
                [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId];
            }
            break;
        case FHHouseTypeSecondHandHouse:
            if (isFromRecommend) {
                [self requestRecommendErshouHouseListData:isRefresh query:query offset:offset searchId:self.recommendSearchId];
            } else {
                if ([query isKindOfClass:[NSString class]] && query.length > 0) {
                    query = [query stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",CHANNEL_ID,CHANNEL_ID_SEARCH_HOUSE]];
                }else{
                    query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_SEARCH_HOUSE];
                }
                self.query = query;
                [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId];
            }
            break;
            
        case FHHouseTypeRentHouse:
            if ([query isKindOfClass:[NSString class]] && query.length > 0) {
                query = [query stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",CHANNEL_ID,CHANNEL_ID_SEARCH_RENT]];
            }else{
                query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_SEARCH_RENT];
            }
            self.query = query;
            [self requestRentHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
            
        case FHHouseTypeNeighborhood:
            
            if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
                [self requestNeiborhoodDealListData:isRefresh query:query offset:offset searchId:searchId];
            }else {
                [self requestNeiborhoodHouseListData:isRefresh query:query offset:offset searchId:searchId];
            }
            break;
            
        default:
            break;
    }
    
    
}

+ (NSInteger)searchOffsetByhouseModel:(JSONModel *)houseModel
{
    if ([houseModel isKindOfClass:[FHListSearchHouseDataModel class]]) {
        FHListSearchHouseDataModel *model = (FHListSearchHouseDataModel *)houseModel;
        return model.offset;
    }
    return 0;
}

-(void)requestNewHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];

    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchNewHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }

        [wself processData:model error:error isRecommendSearch:NO];
    }];
    
    self.requestTask = task;
}

-(void)requestNeiborhoodHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;

    TTHttpTask *task = [FHHouseListAPI searchNeighborhoodList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }

        [wself processData:model error:error isRecommendSearch:NO];
    }];
    
    self.requestTask = task;
}

#pragma mark 查成交
-(void)requestNeiborhoodDealListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId
{
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchNeighborhoodDealList:query searchType:[self searchTypeString] offset:offset searchId:searchId class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        
        [wself processData:model error:error isRecommendSearch:NO];
    }];
    
    self.requestTask = task;
}

- (NSString *)searchTypeString
{
    switch (self.searchType) {
        case FHHouseListSearchTypeNeighborhoodDeal:
            return @"neighborhood_deal";
            break;
            
        default:
            break;
    }
    return nil;
}


-(void)requestRentHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchRent:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error isRecommendSearch:NO];

    }];
    
    self.requestTask = task;
}


-(void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    if (self.isRefresh) {
        if (query) {
            self.subScribeQuery = [NSString stringWithString:query];
        }
        self.subScribeOffset = offset;
        if (searchId) {
            self.subScribeSearchId = [NSString stringWithString:searchId];
        }
    }
    
    if (offset == 0) {
       _showRealHouseTop = NO;
        _showFakeHouseTop = NO;
    }
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error isRecommendSearch:NO];

    }];
    
    self.requestTask = task;
}

-(void)requestCommute:(BOOL)isRefresh query:(NSString *)query offset:(NSInteger)offset searchId:(NSString *)searchId {
    
    [_requestTask cancel];
    
    if (isRefresh) {
        self.isRefresh = isRefresh;
    }
    
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(manager.latitude, manager.longitude);
    CGFloat duration = manager.duration.floatValue*60;
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"page_type"] = @"rent_list";
    if (searchId.length > 0) {
        param[@"search_id"] = searchId;
    }
    param[CHANNEL_ID] = CHANNEL_ID_RENT_COMMUTING;
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI requestCommute:cityId query:query location:location houseType:_houseType duration:duration type:manager.commuteType param:param offset:offset completion:^(FHListSearchHouseModel * _Nullable model, NSError * _Nullable error) {
        if (!wself) {
            return ;
        }
        [wself processData:model error:error isRecommendSearch:NO];
    }];
    
    _requestTask = task;
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
                    [dictClickParams setValue:@"confirm" forKey:@"click_type"];
                    TRACK_EVENT(@"subscribe_click",dictClickParams);
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



-(void)requestRecommendErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI recommendErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error isRecommendSearch:YES];
        
        
    }];
    
    self.requestTask = task;
}

-(void)requestRecommendNewHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [self.requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI recommendNewHouseList:query params:nil offset:offset searchId:searchId class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error isRecommendSearch:YES];
    }];
    
    self.requestTask = task;
}

- (void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error isRecommendSearch:(BOOL)isRecommendSearch
{    
    if (error) {
        
        [self processError:error];
        return;
    }
    
    if (self.isRefresh) {
        [self.houseList removeAllObjects];
        self.isFirstHavetip = YES;
        [self.sugesstHouseList removeAllObjects];
        [self.tableView.mj_footer endRefreshing];
    }
    
    if (model) {

//        NSString *searchId;
//        NSString *houseListOpenUrl;
//        NSString *mapFindHouseOpenUrl;
        NSMutableArray *itemArray = [NSMutableArray new];
        NSMutableArray *recommendItemArray = @[].mutableCopy;
        self.tableView.scrollEnabled = YES;
        if (self.houseType == FHHouseTypeNewHouse || self.houseType == FHHouseTypeSecondHandHouse) {
            self.tableView.backgroundColor = [UIColor themeGray7];
        }
        BOOL hasMore = NO;
        NSString *refreshTip;
        FHSearchHouseDataRedirectTipsModel *redirectTips;
        FHListSearchHouseDataModel *recommendHouseDataModel = nil;
        BOOL fromRecommend = NO;

        if ([model isKindOfClass:[FHListSearchHouseModel class]]) {

            if (isRecommendSearch) {
                recommendHouseDataModel = ((FHListSearchHouseModel *)model).data;
                self.recommendSearchId = recommendHouseDataModel.searchId;
                hasMore = recommendHouseDataModel.hasMore;
                if (recommendHouseDataModel.searchItems) {
                    [recommendItemArray addObjectsFromArray:recommendHouseDataModel.searchItems];
                }
                self.currentRecommendHouseDataModel = recommendHouseDataModel;
                fromRecommend = YES;
            }else {
                FHListSearchHouseDataModel *houseModel = ((FHListSearchHouseModel *)model).data;
                self.houseDataModel = houseModel;
                self.houseListOpenUrl = houseModel.houseListOpenUrl;
                self.searchPageOpenUrl = houseModel.searchHistoryOpenUrl;
                self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
                hasMore = houseModel.hasMore;
                refreshTip = houseModel.refreshTip;
                if(houseModel.realBussinessSearch && houseModel.realBussinessSearch.content && self.isFirstHavetip){
                    self.isFirstHavetip = NO;
                    [itemArray addObject:houseModel.realBussinessSearch];
                }
                if (houseModel.searchItems.count > 0) {
                    [itemArray addObjectsFromArray:houseModel.searchItems];
                }
                redirectTips = houseModel.redirectTips;
                recommendHouseDataModel = houseModel.recommendSearchModel;
                if (recommendHouseDataModel.searchItems) {
                    [recommendItemArray addObjectsFromArray:recommendHouseDataModel.searchItems];
                }
                self.searchId = houseModel.searchId;
                
                if (recommendItemArray.count > 0) {
                    self.recommendSearchId = recommendHouseDataModel.searchId;
                    if (!hasMore) {
                        hasMore = recommendHouseDataModel.hasMore;
                    }
                    self.currentRecommendHouseDataModel = recommendHouseDataModel;
                    fromRecommend = YES;
                }
            }

        }

        if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
            redirectTips = nil;
        }
        self.fromRecommend = fromRecommend;
        BOOL isFirstLoadCopy = self.isFirstLoad;

        if (self.isFirstLoad) {
            self.originSearchId = self.searchId;
   
            self.isFirstLoad = NO;
            if (self.searchId.length > 0 ) {
                SETTRACERKV(UT_ORIGIN_SEARCH_ID, self.searchId);
            }
        }
        self.showPlaceHolder = NO;
        if (self.isEnterCategory) {
            [self addEnterCategoryLog];
//            self.isEnterCategory = NO;
        }
        if (self.isRefresh) {
            [self addHouseSearchLog];
            [self addHouseRankLog];
            [self refreshHouseListUrlCallback:self.houseListOpenUrl];
        } else {
            [self addCategoryRefreshLog];
        }
        __weak typeof(self)wself = self;
        NSMutableDictionary *traceDictParams = [NSMutableDictionary new];
        if ([wself categoryLogDict]) {
            [traceDictParams addEntriesFromDictionary:[wself categoryLogDict]];
        }
        __block id lastObj = nil;
        __block BOOL hideRefreshTip = NO;
        
        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull theItemModel, NSUInteger idx, BOOL * _Nonnull stop) {
            //            if ([itemDict isKindOfClass:[NSDictionary class]]) {
            //                id theItemModel = [[wself class] searchItemModelByDict:itemDict];
            
            if (idx == 0 && [theItemModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
                hideRefreshTip = YES;
            }
            
            if ([FHEnvContext isHouseListComponentEnable]) {
                if (lastObj == nil && self.houseList.count > 0) {
                    lastObj = [self.houseList lastObject];
                }
                
                NSObject *entity = [self getEntityFromModel:theItemModel];
                if (entity) {
                    if ([entity conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)] && [entity respondsToSelector:@selector(adjustIfNeedWithPreviousViewModel:)]) {
                        NSObject<FHHouseCardCellViewModelProtocol> *viewModel = (NSObject<FHHouseCardCellViewModelProtocol> *)entity;
                        [viewModel adjustIfNeedWithPreviousViewModel:lastObj];
                    }
                    
                    [self.houseList addObject:entity];
                    lastObj = entity;
                }
                
                return;
            }
            
            NSObject *entity = [FHHouseCardUtils getEntityFromModel:theItemModel];
            if (entity) {
                
                FHTracerModel *tracerModel = [[FHTracerModel alloc] init];
                tracerModel.originSearchId = self.originSearchId;
                tracerModel.searchId = self.searchId;
                tracerModel.originFrom = self.tracerModel.originFrom;
                tracerModel.enterFrom = self.tracerModel.enterFrom;
                tracerModel.elementFrom = self.tracerModel.elementFrom;
                tracerModel.elementType = self.tracerModel.elementType;
                tracerModel.pageType = [self pageTypeString];
                tracerModel.categoryName = [self categoryName];
                if ([entity conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    dict[@"search_type"] = @(self.searchType);
                    dict[@"house_type"] = @(self.houseType);
                    dict[@"rank_offset"] = @(!self.isFirstHavetip ? -1 : 0);
                    NSObject<FHHouseNewComponentViewModelProtocol> *viewModel = (NSObject<FHHouseNewComponentViewModelProtocol> *)entity;
                    viewModel.context = dict;
                }
                if ([theItemModel isKindOfClass:[FHSearchHouseItemModel class]]) {
                    FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)theItemModel;
                    if ([wself.houseList count] == 0) {
                        model.topMargin = 10;
                    } else {
                        model.topMargin = 5;
                    }
                    if (model.houseType.integerValue == FHHouseTypeNewHouse || model.houseType.integerValue == FHHouseTypeSecondHandHouse) {
                        tracerModel.elementType = @"be_null";
                    }
                }
                
                entity.fh_trackModel = tracerModel;
                theItemModel = entity;
            } else if ([theItemModel isKindOfClass:[FHSearchHouseItemModel class]]) {
                FHSearchHouseItemModel *itemModel = theItemModel;
                itemModel.isLastCell = (idx == itemArray.count - 1);
                if ([lastObj isKindOfClass:[FHHouseNeighborAgencyModel class]] || [lastObj isKindOfClass:[FHHouseReserveAdviserModel class]]) {
                    itemModel.topMargin = 0;
                }
                if ((itemModel.houseType.integerValue == FHHouseTypeRentHouse || itemModel.houseType.integerValue == FHHouseTypeNeighborhood) && idx == 0) {
                    itemModel.topMargin = 10;
                }
                theItemModel = itemModel;
            }else if ([theItemModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) { //废弃
                FHSearchRealHouseAgencyInfo *agencyInfoModel = (FHSearchRealHouseAgencyInfo *)theItemModel;
                if (agencyInfoModel.agencyTotal.integerValue != 0 && agencyInfoModel.houseTotal.integerValue != 0) {
                    if (wself.isRefresh) {
                        // 展示经纪人信息
                        wself.showRealHouseTop = YES;
                    }
                }else {
                    theItemModel = nil;
                }
            }else if ([theItemModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]] && wself.isRefresh) {
                // 展示搜索订阅卡片
                wself.isShowSubscribeCell = YES;
            }else if ([theItemModel isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) { //废弃
                
                FHSugListRealHouseTopInfoModel *infoModel = theItemModel;
                infoModel.searchId = wself.searchId;
                infoModel.tracerDict = traceDictParams;
                infoModel.searchQuery = wself.subScribeQuery;
                theItemModel = infoModel;
                if (!wself.isRefresh) {
                    wself.showFakeHouseTop = YES;
                }
            }else if ([theItemModel isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
                FHHouseNeighborAgencyModel *agencyModel = theItemModel;
                NSMutableDictionary *traceParam = [NSMutableDictionary new];
                traceParam[@"card_type"] = @"left_pic";
                traceParam[@"enter_from"] = traceDictParams[@"enter_from"];
                traceParam[@"element_from"] = traceDictParams[@"element_from"];
                traceParam[@"page_type"] = [self pageTypeString];
                traceParam[@"search_id"] = wself.searchId;
                traceParam[@"log_pb"] = agencyModel.logPb;
                traceParam[@"origin_from"] = wself.originFrom;
                traceParam[@"origin_search_id"] = wself.originSearchId;
                traceParam[@"rank"] = @(0);
                if(self.houseType == FHHouseTypeNeighborhood){
                    traceParam[@"realtor_position"] = @"neighborhood_expert_card";
                }else{
                    traceParam[@"realtor_position"] = @"area_expert_card";
                }
                agencyModel.tracerDict = traceParam;
                agencyModel.belongsVC = wself.listVC;
                theItemModel = agencyModel;
            }else if ([theItemModel isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
                FHSearchHouseDataRedirectTipsModel *tipModel = theItemModel;
                tipModel.clickRightBlock = ^(NSString *openUrl){
                    [wself clickRedirectTip:openUrl];
                };
                theItemModel = tipModel;
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
                model.belongsVC = wself.listVC;
                model.tableView = wself.tableView;
                model.subscribeCache = wself.subscribeCache;
                theItemModel = model;
            }
            
            if (theItemModel) {
                [wself.houseList addObject:theItemModel];
            }
            if (theItemModel) {
                lastObj = theItemModel;
            }
            //            }
        }];
        
        [recommendItemArray enumerateObjectsUsingBlock:^(id  _Nonnull theItemModel, NSUInteger idx, BOOL * _Nonnull stop) {
            //            if ([itemDict isKindOfClass:[NSDictionary class]]) {
            //                id theItemModel = [[self class] searchItemModelByDict:itemDict];
            
            if ([FHEnvContext isHouseListComponentEnable]) {
                NSObject *entity = [self getEntityFromModel:theItemModel];
                if (entity) {
                    entity.fh_trackModel.searchId = self.recommendSearchId;
                    entity.fh_trackModel.elementType = @"search_related";
                    [self.sugesstHouseList addObject:entity];
                }
                
                return;
            }
            
            if ([theItemModel isKindOfClass:[FHSearchHouseItemModel class]]) {
                FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)theItemModel;
                itemModel.isRecommendCell = YES;
                itemModel.isLastCell = (idx == itemArray.count - 1);
                theItemModel = itemModel;
                NSObject *entity = [FHHouseCardUtils getEntityFromModel:theItemModel];
                if (entity) {
                    if ([wself.sugesstHouseList count] == 0) {
                        itemModel.topMargin = 10;
                    } else {
                        itemModel.topMargin = 5;
                    }
                    FHTracerModel *tracerModel = [[FHTracerModel alloc] init];
                    tracerModel.originSearchId = self.originSearchId;
                    tracerModel.searchId = self.searchId;
                    tracerModel.originFrom = self.tracerModel.originFrom;
                    tracerModel.enterFrom = self.tracerModel.enterFrom;
                    tracerModel.elementFrom = self.tracerModel.elementFrom;
                    tracerModel.elementType = self.tracerModel.elementType;
                    tracerModel.pageType = [self pageTypeString];
                    tracerModel.categoryName = [self categoryName];
                        if (itemModel.houseType.integerValue == FHHouseTypeNewHouse || itemModel.houseType.integerValue == FHHouseTypeSecondHandHouse) {
                            tracerModel.elementType = @"search_related";
                            tracerModel.searchId = self.recommendSearchId ? : @"be_null";
                        }

                    if ([entity conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        dict[@"search_type"] = @(self.searchType);
                        dict[@"house_type"] = @(self.houseType);
                        dict[@"rank_offset"] = @(!self.isFirstHavetip ? -1 : 0);
                        NSObject<FHHouseNewComponentViewModelProtocol> *viewModel = (NSObject<FHHouseNewComponentViewModelProtocol> *)entity;
                        viewModel.context = dict;
                    }
                    entity.fh_trackModel = tracerModel;
                    theItemModel = entity;
                }
                
            }
            if ([theItemModel isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) { //废弃
                FHSugListRealHouseTopInfoModel *infoModel = theItemModel;
                infoModel.searchId = wself.searchId;
                infoModel.tracerDict = traceDictParams;
                infoModel.searchQuery = wself.subScribeQuery;
                theItemModel = infoModel;
            }else if ([theItemModel isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) { //废弃
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
                agencyModel.belongsVC = wself.listVC;
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
                model.belongsVC = wself.listVC;
                model.tableView = wself.tableView;
                model.subscribeCache = wself.subscribeCache;
                theItemModel = model;
            }
            
            if (theItemModel) {
                [wself.sugesstHouseList addObject:theItemModel];
            }
            //            }
        }];

        BOOL addNoHouseCell = NO;
        if(self.houseList.count == 1 && self.sugesstHouseList.count == 0){
            if ([FHEnvContext isHouseListComponentEnable]) {
                id existModel = self.houseList.firstObject;
                id noResultViewModel = [FHHouseCardUtils getNoResultViewModelWithExistModel:existModel containerHeight:self.tableView.height];
                if (noResultViewModel) {
                    [self.houseList addObject:noResultViewModel];
                    addNoHouseCell = YES;
                }
            } else {
                //只有一个筛选提示时 增加无数据提示
                if ([self.houseList.firstObject isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                    //add place holder
                    FHHouseListNoHouseCellModel *cellModel = [[FHHouseListNoHouseCellModel alloc] init];
                    cellModel.cellHeight = self.tableView.height - 64 - 121;
                    [self.houseList addObject:cellModel];
                    addNoHouseCell = YES;
                }
            }
        }
        [self.tableView reloadData];
        if (isFirstLoadCopy) {
            [FHMainApi addUserOpenVCDurationLog:@"pss_house_list" resultType:FHNetworkMonitorTypeSuccess duration:[[NSDate date] timeIntervalSince1970] - _startMonitorTime];
        }
        if(addNoHouseCell){
            self.tableView.mj_footer.hidden = YES;
        }else{
            [self updateTableViewWithMoreData:hasMore];
        }
        ///TODO: 确认一下新房列表底部展示“没有更多信息了”文案是否正确？
        if (self.houseType != FHHouseTypeSecondHandHouse && self.houseType != FHHouseTypeNewHouse) {
            if (!hasMore && self.houseList.count < 10) {
                self.refreshFooter.hidden = YES;
            }
        }

        if (self.isRefresh && itemArray.count > 0 && _showRealHouseTop) {
            self.tableView.contentOffset = CGPointMake(0, 0);
        }
        
        if (self.isRefresh && self.viewModelDelegate && (itemArray.count > 0 || recommendItemArray.count > 0) && !hideRefreshTip) {
            [self.viewModelDelegate showNotify:refreshTip inViewModel:self];
        }
        if (self.houseList.count == 0 && self.sugesstHouseList.count == 0) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
        } else {
            [self showMaskView:NO];
        }
        
        // 刷新请求的时候将列表滑动在最顶部
        if (self.isRefresh) {
            if (self.houseList.count > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } else if (self.sugesstHouseList.count > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    } else {
        [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
}

//-(FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
//
//    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
//
//    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
//
//        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
//        cellModel.secondModel = obj;
//
//    }else if ([obj isKindOfClass:[FHNewHouseItemModel class]]) {
//
//        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
//        cellModel.houseModel = obj;
//
//    }else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
//
//        FHHouseRentDataItemsModel *item = (FHHouseRentDataItemsModel *)obj;
//        cellModel.rentModel = obj;
//
//    } else if ([obj isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {
//
//        FHHouseNeighborDataItemsModel *item = (FHHouseNeighborDataItemsModel *)obj;
//        cellModel.neighborModel = obj;
//
//    }else if ([obj isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
//
//        cellModel.subscribModel = obj;
//        cellModel.isSubscribCell = YES;
//    }else if ([obj isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
//
//        cellModel.realHouseTopModel = obj;
//        cellModel.isRealHouseTopCell = YES;
//    }else if ([obj isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
//
//        cellModel.agencyInfoModel = obj;
//        cellModel.isAgencyInfoCell = YES;
//    }
//    return cellModel;
//
//}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    
    ///与大类页逻辑保持一致
    if (self.houseList.count > 10 || self.sugesstHouseList.count > 10) {
        self.tableView.mj_footer.hidden = NO;
    }else{
        self.tableView.mj_footer.hidden = YES;
    }
    self.lastHasMore = hasMore;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"已加载全部" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

-(void)processError:(NSError *)error {

    //add error toast
    if (error.code != NSURLErrorCancelled) {
        //不是主动取消
        if (!self.isRefresh) {
            
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self showMaskView:NO];
            
        }else {
            if (![TTReachability isNetworkConnected]) {
                
                [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
            }else {
                
                [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        }
    }
    [self.tableView.mj_footer endRefreshing];
    
}


-(void)showMaskView:(BOOL)show
{
    self.maskView.hidden = !show;
}


#pragma mark - filter delegate

#pragma mark filter条件改变
-(void)onConditionChanged:(NSString *)condition
{
    NSString *allQuery = @"";
    if (self.getAllQueryString) {
        
        allQuery = self.getAllQueryString();
    }
    
    if (condition.length > 0) {
        self.isHasFilterCondition = YES;
    }else{
        self.isHasFilterCondition = NO;
    }

//    if ([self.condition isEqualToString:allQuery]) {
//        return;
//    }
    self.condition = allQuery;
    if (self.topTagsView) {
        NSMutableDictionary *filterDict = @{}.mutableCopy;
        NSDictionary *queryDict = [self.filterOpenUrlMdodel queryDictBy:allQuery];
        if (queryDict) {
            [filterDict addEntriesFromDictionary:queryDict];
        }
        self.topTagsView.lastConditionDic = filterDict;
        self.topTagsView.condition = allQuery;
    }
    self.isRefresh = YES;
    [self.tableView triggerPullDown];
    self.fromRecommend = NO;
    [self loadData:self.isRefresh];
    
}

#pragma mark filter将要显示
-(void)onConditionWillPanelDisplay
{
//    NSLog(@"onConditionWillPanelDisplay");

}

#pragma mark filter将要消失
-(void)onConditionPanelWillDisappear
{

}

#pragma mark filter被点击
-(void)onConditionPanelClickedWithContent:(NSString *)content
{
    [self reportClickOptionsWithPosition:content];
}

-(void)reportClickOptionsWithPosition:(NSString *)position
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
    tracerDict[UT_ELEMENT_TYPE] = @"filter";
    tracerDict[UT_CLICK_POSITION] = position ?: @"be_null";
    tracerDict[UT_HOUSE_TYPE] = [self houseTypeString];
    [FHUserTracker writeEvent:@"click_options" params:tracerDict];
}

#pragma mark - nav 点击事件
-(void)showInputSearch {
    if (self.closeConditionFilter) {
        self.closeConditionFilter();
    }
    
    [self addClickHouseSearchLog];
    
    if (self.isCommute) {
        [self showPoiSearch];
        return;
    }

    NSMutableDictionary *traceParam = [NSMutableDictionary dictionary];
    [traceParam addEntriesFromDictionary:[self.tracerModel toDictionary] ? : @{}];
    traceParam[UT_FROM_PAGE_TYPE] = [self pageTypeString];
    //house_search
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(FHEnterSuggestionTypeList), // list
                           @"sug_delegate":sugDelegateTable
                           };
    NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (self.listVC) {
        NSHashTable *tempTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [tempTable addObject:self.listVC];
        dictInfo[@"need_back_vc"] = tempTable;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dictInfo];
    NSString *urlStr = nil;
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        urlStr = [NSString stringWithFormat:@"sslocal://house_search_deal_neighborhood"];
    }else {
        if (self.searchPageOpenUrl) {
           //以本地的house_type为准
            urlStr = self.searchPageOpenUrl;
        } else {
            urlStr = @"sslocal://house_search";
        }
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)showPoiSearch {
    
    //commute_poi
    
    NSURL *url = [NSURL URLWithString:@"sslocal://commute_poi"];
    
    NSHashTable *delegate = WRAP_WEAK(self);
    NSDictionary *param = @{COMMUTE_POI_DELEGATE_KEY:delegate};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:param];
    
    [[TTRoute sharedRoute]openURLByViewController:url userInfo:userInfo];
    
}

#pragma mark - poi search delegate

-(void)userChoosePoi:(AMapAOI *)poi inViewController:(UIViewController *)viewController
{
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    manager.latitude = poi.location.latitude;
    manager.longitude = poi.location.longitude;
    manager.destLocation = poi.name;
    [manager sync];
    
    if (self.commuteSugSelectBlock) {
        self.commuteSugSelectBlock(poi.name);
        self.commutePoi = poi.name;
    }
    [viewController.navigationController popViewControllerAnimated:YES];
    
    [self loadData:YES fromRecommend:NO];
    
}

-(void)userChooseLocation:( CLLocation * )location geoCode:(AMapLocationReGeocode *)geoCode inViewController:(UIViewController *)viewController
{
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    manager.latitude = location.coordinate.latitude;
    manager.longitude = location.coordinate.longitude;
    manager.destLocation = geoCode.AOIName;
    [manager sync];
    
    if (self.commuteSugSelectBlock) {
        self.commuteSugSelectBlock(geoCode.AOIName);
        self.commutePoi = geoCode.AOIName;
    }
    [viewController.navigationController popViewControllerAnimated:YES];
    
    [self loadData:YES fromRecommend:NO];
}

-(void)userCanced:(UIViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}


#pragma mark 地图找房
-(void)showMapSearch {
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

        NSString *openUrl = self.mapFindHouseOpenUrl;
        NSMutableDictionary *param = [self categoryLogDict].mutableCopy;
        param[@"click_type"] = @"map";
        param[@"enter_type"] = @"click";
        TRACK_EVENT(@"click_switch_mapfind", param);
        
        NSMutableString *query = @"".mutableCopy;
        if (![self.mapFindHouseOpenUrl containsString:@"enter_category"]) {
            [query appendString:[NSString stringWithFormat:@"enter_category=%@",[self categoryName]]];

        }
        if (![self.mapFindHouseOpenUrl containsString:@"origin_from"]) {
            [query appendString:[NSString stringWithFormat:@"&origin_from=%@",self.tracerModel.originFrom ? : @"be_null"]];

        }
        if (![self.mapFindHouseOpenUrl containsString:@"origin_search_id"]) {
            [query appendString:[NSString stringWithFormat:@"&origin_search_id=%@",self.originSearchId ? : @"be_null"]];

        }
        if (![self.mapFindHouseOpenUrl containsString:@"enter_from"]) {
            [query appendString:[NSString stringWithFormat:@"&enter_from=%@",[self pageTypeString]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"element_from"]) {
            [query appendString:[NSString stringWithFormat:@"&element_from=%@",self.tracerModel.elementFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"search_id"]) {
            [query appendString:[NSString stringWithFormat:@"&search_id=%@",self.searchId ? : @"be_null"]];
            
        }
        
        [query appendFormat:@"&enter_from_list=1"];
        
        if (query.length > 0) {
            
            openUrl = [NSString stringWithFormat:@"%@&%@",openUrl,query];
        }
        
        //需要重置非过滤器条件，以及热词placeholder
        self.closeConditionFilter();

        NSURL *url = [NSURL URLWithString:openUrl];
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        NSHashTable *hashMap = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [hashMap addObject:self];
        dict[OPENURL_CALLBAK] = hashMap;
        dict[@"tracer"] = @{
            UT_FROM_PAGE_TYPE: [self pageTypeString],
            UT_ORIGIN_FROM: self.tracerModel.originFrom ? : @"be_null",
        };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

}

#pragma mark 消息列表
- (void)showMessageList {
    // 二手列表页
//    if (_houseType == FHHouseTypeSecondHandHouse || _houseType == FHHouseTypeRentHouse || _houseType == FHHouseTypeNewHouse || ) {
        if (self.closeConditionFilter) {
            self.closeConditionFilter();
        }
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
//    }
}

-(void)refreshHouseListUrlCallback:(NSString *)openUrl {

    if (openUrl.length < 1) {
        return;
    }
    if (self.houseListOpenUrlUpdateBlock) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
        self.houseListOpenUrlUpdateBlock(routeParamObj, NO);
    }
}

// findTab过来的houseSearch需要单独处理下埋点数据
-(void)updateHouseSearchDict:(NSDictionary *)houseSearchDic {

    self.houseSearchDic = houseSearchDic;
    self.canChangeHouseSearchDic = NO; // 禁止修改house_search埋点数据
}

#pragma mark - map url delegate
-(void)handleHouseListCallback:(NSString *)openUrl {
    
    if ([FHHouseOpenURLUtil isSameURL:self.houseListOpenUrl and:openUrl]) {
        return;
    }
    
    if (self.houseListOpenUrlUpdateBlock) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
        self.houseListOpenUrlUpdateBlock(routeParamObj, YES);
    }
    
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject {
    
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    if (allInfo[@"houseSearch"]) {
        self.houseSearchDic = allInfo[@"houseSearch"];
        self.canChangeHouseSearchDic = NO; // 禁止修改house_search埋点数据
    }
    
    NSString *houseTypeStr = routeObject.paramObj.allParams[@"house_type"];
    if(allInfo[@"tracer"]){
        [self updateTracerDict:allInfo[@"tracer"]];
    }
    self.isFirstHavetip = YES;
    self.houseType = houseTypeStr.integerValue;
    self.preHouseType = [routeObject.paramObj.allParams[@"pre_house_type"] intValue];
    self.jumpHouseType = [routeObject.paramObj.allParams[@"jump_house_type"] intValue];
    if (self.sugSelectBlock) {
        self.sugSelectBlock(routeObject.paramObj);
    }
}


#pragma mark -

-(void)resetCondition {
    //    self.resetConditionBlock(nil);
}

-(void)backAction:(UIViewController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sugesstHouseList.count > 0 ? 2 : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showPlaceHolder) {
        return 10;
    }
    return section == 0 ? self.houseList.count : self.sugesstHouseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder) {
        if (self.houseType == FHHouseTypeNewHouse) {
            FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
            return cell;
        }

        if(self.commute){
            FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
            return cell;
        }else{
            FHHomePlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
            cell.topOffset = 20;
            return cell;
        }
    }
    BOOL isLastCell = NO;
    BOOL isFirstCell = NO;
    if (indexPath.row == 0) {
        isFirstCell = YES;
    }

    NSString *identifier = @"";
    id data = nil;
    if (indexPath.section == 0) {
        data = self.houseList[indexPath.row];
    } else {
        isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
        if (indexPath.row < self.sugesstHouseList.count) {
            data = self.sugesstHouseList[indexPath.row];
            
        }
    }
    if (data) {
        identifier = [self cellIdentifierForEntity:data];
        
        UITableViewCell *cell = [tableView fhHouseCard_cellForEntity:data atIndexPath:indexPath];
        if (cell) return cell;
    }
    __weak typeof(self)wself = self;
    if (identifier.length > 0) {
        if (self.houseType == FHHouseTypeRentHouse) {
            if ([identifier isEqualToString:NSStringFromClass([FHHouseListRentCell class])]) {
                FHHouseBaseCell *cell = (FHHouseBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                [cell refreshWithData:data];
                return cell;
            }
            FHListBaseCell *cell = (FHListBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)data;
            if([cell isKindOfClass:[FHHouseListRecommendTipCell class]] && model.realSearchOpenUrl){
                WeakSelf;
                ((FHHouseListRecommendTipCell *)cell).channelSwitchBlock = ^{
                    StrongSelf;
                    NSMutableDictionary *infos = [NSMutableDictionary new];
                    NSMutableDictionary *tracer = [NSMutableDictionary new];
                    tracer[@"element_from"] = [self channelSwitchElementFromNameByhouseType:self.preHouseType];
                    tracer[@"enter_from"] = [self categoryName];
                    tracer[@"enter_type"] = @"click";
                    tracer[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
                    infos[@"tracer"] = tracer;
                    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
                    if(model.realSearchOpenUrl){
                        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:model.realSearchOpenUrl] userInfo:userInfo];
                    }
                };
            }
            [cell refreshWithData:data];
            if (self.houseList.count == 1 && self.sugesstHouseList.count == 0 && [self.houseList[0] isKindOfClass:[FHSearchGuessYouWantTipsModel class]]){
                    self.tableView.scrollEnabled = NO;
                    self.tableView.backgroundColor = [UIColor whiteColor];
                    [((FHHouseListRecommendTipCell *)cell) showErrorView];
            }
            return cell;
        }

        FHListBaseCell *cell = (FHListBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (self.houseType != FHHouseTypeRentHouse) {
            cell.backgroundColor = [UIColor themeGray7];
        }
        if ([cell isKindOfClass:[FHFindHouseHelperCell class]]) {
            FHFindHouseHelperCell *helperCell = (FHFindHouseHelperCell *) cell;
            helperCell.cellTapAction = ^(NSString *url){
                [wself jump2HouseFindPageWithUrl:url];
            };
        }
        if ([cell isKindOfClass:[FHHouseSearchSecondHouseCell class]]) {
            FHHouseSearchSecondHouseCell *secondCell = (FHHouseSearchSecondHouseCell *)cell;
            [secondCell updateHeightByIsFirst:isFirstCell];
        } else if ([cell isKindOfClass:[FHHouseSearchNewHouseCell class]]) {
            FHHouseSearchNewHouseCell *newCell = (FHHouseSearchNewHouseCell *)cell;
            [newCell updateHeightByIsFirst:isFirstCell];
        }
        if ([cell isKindOfClass:[FHDynamicLynxCell class]]) {
            FHDynamicLynxCellModel *cellModel = data;
            if (cellModel && [cellModel isKindOfClass:[FHDynamicLynxCellModel class]]) {
                cellModel.cell = cell;
                [(FHDynamicLynxCell *)cell updateWithCellModel:cellModel];
            }
        }
        [cell refreshWithData:data];
        if([cell isKindOfClass:[FHNeighbourhoodAgencyCardCell class]]){
            [((FHNeighbourhoodAgencyCardCell *)cell) updateHeightByIsFirst:isFirstCell];
        }
        if([cell isKindOfClass:[FHHousReserveAdviserCell class]]){
            [((FHHousReserveAdviserCell *)cell) updateHeightByIsFirst:isFirstCell];
        }
        if([cell isKindOfClass:[FHHouseListRedirectTipCell class]]){
            [((FHHouseListRedirectTipCell *)cell) updateHeightByIsFirst:isFirstCell];
            [((FHHouseListRedirectTipCell *)cell) refreshWithHouseType:self.houseType];
            
        }
        if([cell isKindOfClass:[FHHouseListRecommendTipCell class]] && [data isKindOfClass:[FHSearchGuessYouWantTipsModel class]]){
            FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)data;
            if(self.houseList.count == 1 && self.sugesstHouseList.count == 0 && [self.houseList[0] isKindOfClass:[FHSearchGuessYouWantTipsModel class]]){
                self.tableView.scrollEnabled = NO;
                self.tableView.backgroundColor = [UIColor whiteColor];
                [((FHHouseListRecommendTipCell *)cell) showErrorView];
            }
            WeakSelf;
            ((FHHouseListRecommendTipCell *)cell).channelSwitchBlock = ^{
                StrongSelf;
                NSMutableDictionary *infos = [NSMutableDictionary new];
                NSMutableDictionary *tracer = [NSMutableDictionary new];
                tracer[@"element_from"] = [self channelSwitchElementFromNameByhouseType:self.preHouseType];
                tracer[@"enter_from"] = [self categoryName];
                tracer[@"enter_type"] = @"click";
                tracer[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
                infos[@"tracer"] = tracer;
                TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
                if(model.realSearchOpenUrl){
                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:model.realSearchOpenUrl] userInfo:userInfo];
                }
            };
        }
        if ([cell isKindOfClass:[FHHouseListAgencyInfoCell class]]) {
            FHHouseListAgencyInfoCell *agencyInfoCell = (FHHouseListAgencyInfoCell *)cell;
            if (!agencyInfoCell.btnClickBlock) {
                agencyInfoCell.btnClickBlock = ^{
                    [wself jump2Webview:data];
                };
            }
        }else if ([cell isKindOfClass:[FHSuggestionSubscribCell class]]) {
            FHSuggestionSubscribCell *subscribeCell = (FHSuggestionSubscribCell *)cell;
            [subscribeCell updateHeightByIsFirst: isFirstCell];
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
        }
        if (!cell) {
            return [[FHListBaseCell alloc]init];
        }
        return cell;
    }
    return [[FHListBaseCell alloc]init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView fhHouseCard_willShowCell:cell atIndexPath:indexPath]) return;
    
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        return;
    }
    
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
    NSString *hasShow = self.houseShowCache[hashString];
    if ([hasShow isEqualToString:@"1"]) {
        return;
    }
    [self addHouseShowLog:cellModel withRank:indexPath.row];
    self.houseShowCache[hashString] = @"1";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 88;
    if(self.commute){
        height = 105;
    }
    if (_showPlaceHolder) {
        if (self.houseType == FHHouseTypeNewHouse) {
            return 118;
        }
        return height;
    }
    BOOL isFirstCell = NO;
    BOOL isLastCell = NO;
    CGFloat normalHeight = height;
    
    if (self.isCommute && indexPath.row == 0) {
        normalHeight -= 10;//通勤找房第一个缩小间距
    }
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
        if(self.houseList.count == 1 && self.sugesstHouseList.count == 0 && [data isKindOfClass:[FHSearchGuessYouWantTipsModel class]]){
            return self.tableView.bounds.size.height;
        }
        CGFloat cellHeight = [tableView fhHouseCard_heightForEntity:data atIndexPath:indexPath];
        if (cellHeight > -0.001f) return cellHeight;
        
        id cellClass = [self cellClassForEntity:data];
        if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)data;
            item.isLastCell = isLastCell;
            if ((item.houseType.integerValue == FHHouseTypeRentHouse || item.houseType.integerValue == FHHouseTypeNeighborhood) && isFirstCell) {
                item.topMargin = 10;
            }else {
                item.topMargin = 0;
            }
            if (self.houseType == FHHouseTypeNewHouse || self.houseType == FHHouseTypeSecondHandHouse) {
                if (isFirstCell) {
                    item.topMargin = 5;
                } else {
                    item.topMargin = 0;
                }
            }
            data = item;
        }
        if ([[cellClass class]respondsToSelector:@selector(heightForData:)]) {
            return [[cellClass class] heightForData:data];
        }
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([tableView fhHouseCard_didClickCell:cell atIndexPath:indexPath]) {
        return;
    }
    
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        
        if (indexPath.row < self.houseList.count) {

            id cellModel = self.houseList[indexPath.row];
            [self addDealGoDetailLog:cellModel withRank:indexPath.row];
            [self jump2NeighborhoodDealPage:cellModel];
        }
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
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        [[FHHouseCardStatusManager sharedInstance] readHouseId:model.id withHouseType:[model.houseType integerValue]];
    }
    if ([cell conformsToProtocol:@protocol(FHHouseCardReadStateProtocol)]) {
        [((id<FHHouseCardReadStateProtocol>)cell) refreshOpacityWithData:cellModel];
    }
    if([cellModel isKindOfClass:[FHHouseReserveAdviserModel class]] || [cellModel isKindOfClass:[FHHouseNeighborAgencyModel class]]){
        return;
    }
    
    [self jump2HouseDetailPage:cellModel withRank:indexPath.row];
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        if (model.houseType.integerValue != FHHouseTypeNewHouse) {
              if (self.houseType == FHHouseTypeSecondHandHouse) {
                      [[FHRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
                  }
        }
    }
//    else {
//        if (self.houseType == FHHouseTypeSecondHandHouse && ![cellModel isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
//            [[FHRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
//        }
//    }
}

#pragma mark - 详情页跳转

- (void)jump2NeighborhoodDealPage:(id)cellModel
{
    NSString *urlStr = nil;

    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        urlStr = model.dealOpenUrl;
        if (!model.dealStatus && self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
            [[ToastManager manager]showToast:@"成交数据暂缺"];
            return;
        }
    }
    if (urlStr.length < 1) {
        return;
    }
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"card_type"] = @"left_pic";
    traceParam[@"enter_from"] = [self pageTypeString];
    traceParam[@"element_from"] = [self elementTypeString];
    traceParam[@"search_id"] = self.searchId;
    traceParam[@"log_pb"] = [cellModel logPb];
    traceParam[@"origin_from"] = self.originFrom;
    traceParam[@"origin_search_id"] = self.originSearchId;

    NSDictionary *dict = @{@"tracer": traceParam};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];

    NSString *openUrl = [urlStr stringByRemovingPercentEncoding];
    if (openUrl.length > 0) {
        openUrl = [openUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSURL *theUrl = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:theUrl userInfo:userInfo];
    }
}

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

-(void)jump2HouseDetailPage:(id)cellModel withRank:(NSInteger)rank
{
    
    NSDictionary *logPb = @{};
    NSString *urlStr = nil;
    NSString *elementFrom = [self elementTypeString];
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    FHSearchHouseItemModel *theModel = nil;
    
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        theModel = (FHSearchHouseItemModel *)cellModel;
        logPb = theModel.logPbWithTags;
        if (theModel.isRecommendCell) {
            traceParam[@"search_id"] = self.recommendSearchId;
            elementFrom = @"search_related";
        }
    }
    if (!theModel) {
        return;
    }
    traceParam[@"card_type"] = @"left_pic";
    traceParam[@"enter_from"] = [self pageTypeString];
    traceParam[@"element_from"] = elementFrom;

    traceParam[@"log_pb"] = logPb;
    traceParam[@"origin_from"] = self.originFrom;
    traceParam[@"origin_search_id"] = self.originSearchId;
    NSInteger realrank = self.isFirstHavetip == NO ? rank - 1 :rank ;
    rank = realrank;
    traceParam[@"rank"] = @(rank);
    NSMutableDictionary *dict = @{@"house_type":@(theModel.houseType.integerValue) ,
                           @"tracer": traceParam
                           }.mutableCopy;
    
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:self.originFrom forKey:@"origin_from"];
    [contextBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];

    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.id];
            break;
        case FHHouseTypeSecondHandHouse:
            if (theModel.externalInfo.externalUrl && theModel.externalInfo.isExternalSite.boolValue) {
                NSMutableDictionary * dictRealWeb = [NSMutableDictionary new];
                [dictRealWeb setValue:@(self.houseType) forKey:@"house_type"];
                traceParam[@"group_id"] = theModel.id;
                traceParam[@"impr_id"] = theModel.imprId;
                
                [dictRealWeb setValue:traceParam forKey:@"tracer"];
                [dictRealWeb setValue:theModel.externalInfo.externalUrl forKey:@"url"];
                [dictRealWeb setValue:theModel.externalInfo.backUrl forKey:@"backUrl"];
                
                TTRouteUserInfo *userInfoReal = [[TTRouteUserInfo alloc] initWithInfo:dictRealWeb];
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://house_real_web"] userInfo:userInfoReal];
                return;
            }
            if (theModel.houseType.integerValue == FHHouseTypeNewHouse) {
                urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.id];
            }else {
                 urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.id];
            }
           
            break;
        case FHHouseTypeRentHouse:
            urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];
            break;
        case FHHouseTypeNeighborhood:
            if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
                urlStr = theModel.dealOpenUrl;
            }else {
                urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id];
            }
            break;
        default:
            break;
    }
    
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        dict[@"biz_trace"] = theModel.bizTrace;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

//跳转到帮我找房
- (void)jump2HouseFindPageWithUrl:(NSString *)url {
    //帮我找房埋点修正需要origin_from字段
    NSString *originFrom = self.tracerModel.originFrom ?: @"be_null";
    if (url.length > 0) {
        NSDictionary *tracerInfo = @{
            @"element_from": @"driving_find_house_card",
            @"enter_from": @"old_list",
            @"origin_from": originFrom,
        };
        NSURL *openUrl = [NSURL URLWithString:url];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] init];
        userInfo.allInfo = @{@"tracer": tracerInfo};
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

#pragma mark - commute
-(void)commuteFilterUpdated
{
    self.isRefresh = YES;
    [self loadData:YES fromRecommend:NO];
    [self addCommuteSearchLog];
}


#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache {
    
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
}
//仅仅适用于sug页面跳转不一致时的频道切换“点击查看xx房结果”
- (NSString *)channelSwitchElementFromNameByhouseType:(NSInteger)houseType{
    if(houseType == FHHouseTypeNewHouse){
        return @"channel_switch_new_result";
    }else if(houseType == FHHouseTypeSecondHandHouse){
        return @"channel_switch_old_result";
    }else if(houseType == FHHouseTypeRentHouse){
        return  @"channel_switch_renting_result";
    }else if(houseType == FHHouseTypeNeighborhood){
        return  @"channel_switch_neighborhood_result";
    }
    return @"be_null";
}

-(NSString *)categoryName {
    
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
            if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
                return @"neighborhood_trade_list";
            }
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)houseTypeString {
    
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

-(NSString *)pageTypeString {
    
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
            if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
                return @"neighborhood_trade_list";
            }
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)pageTypeStringByFindTab {
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"findtab_new";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"findtab_old";
            break;
        case FHHouseTypeRentHouse:
            return @"findtab_rent";
            break;
        case FHHouseTypeNeighborhood:
            return @"findtab_neighborhood";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)elementTypeString {
    
    return @"be_null";

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
    tracerDict[@"is_call"] = cellModel.contactModel.enablePhone ? @(1) : @(0);
    tracerDict[@"is_report"] = @(0);
    tracerDict[@"is_online"] = cellModel.contactModel.unregistered ? @(0) : @(1);
    tracerDict[@"realtor_id"] = cellModel.id;
    if(self.houseType == FHHouseTypeNeighborhood){
        tracerDict[@"element_type"] = @"neighborhood_expert_card";
        tracerDict[@"realtor_position"] = @"neighborhood_expert_card";
        tracerDict[@"house_type"] = @"neighborhood";
    }else{
        if (self.isHasFilterCondition) {
            tracerDict[@"element_type"] = @"area_expert_card";
            tracerDict[@"realtor_position"] = @"area_expert_card";
            tracerDict[@"house_type"] = @"area";
        }else{
            tracerDict[@"element_type"] = @"neighborhood_expert_card";
            tracerDict[@"realtor_position"] = @"neighborhood_expert_card";
            tracerDict[@"house_type"] = @"neighborhood";
        }
    }
    
    [FHUserTracker writeEvent:@"realtor_show" params:tracerDict];
}


#pragma mark house_show log

-(void)addHouseShowLog:(FHSearchBaseItemModel *)cellModel withRank: (NSInteger) rank
{
    if (![cellModel isKindOfClass:[FHSearchBaseItemModel class]]) {
        return;
    }
    NSString *originFrom = self.originFrom ? : @"be_null";

    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    NSInteger realrank = self.isFirstHavetip == NO ? rank - 1 :rank ;
    rank = realrank;
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"origin_from"] = originFrom;
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";

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
        tracerDict[@"log_pb"] = houseModel.logPbWithTags ? : @"be_null";
        tracerDict[@"house_type"] = houseModel.houseType.integerValue == FHHouseTypeNewHouse?@"new":([self houseTypeString] ? : @"be_null");
        tracerDict[@"biz_trace"] = [houseModel bizTrace] ? : @"be_null";
        tracerDict[@"card_type"] = @"left_pic";
        
        if (self.tracerModel.elementFrom && ![self.tracerModel.elementFrom isEqualToString:@"be_null"]) {
            tracerDict[UT_ELEMENT_FROM] = self.tracerModel.elementFrom;
        }
        
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    } else if ([cellModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        
        FHSugSubscribeDataDataSubscribeInfoModel *cellSubModel = (FHSugSubscribeDataDataSubscribeInfoModel *)cellModel;
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
        
        if (self.tracerModel.elementFrom && ![self.tracerModel.elementFrom isEqualToString:@"be_null"]) {
            tracerDict[UT_ELEMENT_FROM] = self.tracerModel.elementFrom;
        }
        
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    }else if ([cellModel isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        NSDictionary *params = @{@"page_type":@"city_switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_switch_show" params:params];
    }else if ([cellModel isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        if (![SSCommonLogic isEnableVerifyFormAssociate]) {
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
        }
    }else if ([cellModel isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        NSDictionary *params = @{@"origin_from":originFrom,
                                 @"event_type":@"house_app2c_v2",
                                 @"page_type":@"old_list",
                                 @"search_id":self.searchId.length > 0 ? self.searchId : @"be_null",
                                 @"element_type":@"driving_find_house_card",
                                };
        [FHUserTracker writeEvent:@"element_show" params:params];
    }else if ([cellModel isKindOfClass:[FHDynamicLynxCellModel class]]) {
        FHDynamicLynxModel *model = ((FHDynamicLynxCellModel *)cellModel).model;
        NSDictionary *reportData = [((FHDynamicLynxModel *)model).lynxData objectForKey:@"report_params"];
        NSString *trackingID = @"be_null";
        if (self.houseType == FHHouseTypeSecondHandHouse) {
            trackingID = @"107653";
        } else if (self.houseType == FHHouseTypeNewHouse) {
            trackingID = @"110832";
        }
        if (reportData && [reportData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *params = @{@"origin_from":reportData[@"origin_from"] ?: @"be_null",
                                     @"enter_from":reportData[@"enter_from"] ?: @"be_null",
                                     @"event_type":@"house_app2c_v2",
                                     @"page_type":reportData[@"page_type"] ?: @"be_null",
                                     @"element_type":reportData[@"element_type"] ?: @"be_null",
                                     @"search_id":reportData[@"search_id"] ?: @"be_null",
                                     @"event_tracking_id":trackingID,
                                    };
            [FHUserTracker writeEvent:@"element_show" params:params];
        }
    }
}


#pragma mark category log
-(void)addEnterCategoryLog {
    NSMutableDictionary *logParams = [NSMutableDictionary dictionaryWithDictionary:[self categoryLogDict]];
    [FHUserTracker writeEvent:@"enter_category" params:logParams];
}

-(void)addCategoryRefreshLog {
    
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    [FHUserTracker writeEvent:@"category_refresh" params:tracerDict];
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        return;
    }
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];

}

- (void)addClickHouseSearchLog {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.fromFindTab) {
        params[@"page_type"] = [self pageTypeStringByFindTab];
    }else {
        params[@"page_type"] = [self pageTypeString];
    }
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";

    if (self.isCommute) {
        if (self.commutePoi.length == 0) {
            FHCommuteManager *manager = [FHCommuteManager sharedInstance];
            self.commutePoi = manager.destLocation;
        }
        params[@"selected_word"] = self.commutePoi?:UT_BE_NULL;
    }else{
        params[@"hot_word"] = @"be_null";
    }
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        params[@"selected_word"] = nil;
        params[@"hot_word"] = nil;
    }
    TRACK_EVENT(@"click_house_search",params);
}

- (void)addHouseSearchLog {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.houseSearchDic) {
        [params addEntriesFromDictionary:self.houseSearchDic];
    } else {
        // house_search 上报时机是通过搜索（搜索页面）进入的搜索列表页，而通过搜索点击tab进入的不上报当前埋点，过滤器重新选择后也上报
        return;
    }
    params[@"house_type"] = [self houseTypeString];
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"search_id"] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    // enter_query 判空
    NSString *enter_query = params[@"enter_query"];
    if (enter_query && [enter_query isKindOfClass:[NSString class]]) {
        if (enter_query.length <= 0) {
            params[@"enter_query"] = @"be_null";
        }
    } else {
         params[@"enter_query"] = @"be_null";
    }
    // search_query 判空
    NSString *search_query = params[@"search_query"];
    if (search_query && [search_query isKindOfClass:[NSString class]]) {
        if (search_query.length <= 0) {
            params[@"search_query"] = @"be_null";
        }
    } else {
         params[@"search_query"] = @"be_null";
    }
    params[@"growth_deepevent"] = @(1);
    TRACK_EVENT(@"house_search",params);
    self.canChangeHouseSearchDic = YES;
}

- (void)addHouseRankLog {
    
    NSString *sortType;
    if (self.getSortTypeString) {
        sortType = self.getSortTypeString();
    }
    if (sortType.length < 1) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"page_type"] = [self pageTypeString];
    params[@"rank_type"] = sortType;
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"search_id"] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    TRACK_EVENT(@"house_rank",params);
}

-(void)addModifyCommuteLog:(BOOL)isShow
{
    if (self.searchType == FHHouseListSearchTypeNeighborhoodDeal) {
        return;
    }
    if (isShow) {
        [self addCommuteGoDetailLog];
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    param[UT_ELEMENT_FROM] = UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ?: UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    
    TRACK_EVENT(isShow?@"click_modification":@"click_close", param);
}

-(void)addCommuteSearchLog
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = @"commuter_detail";
    param[UT_HOUSE_TYPE] = @"rent";
    param[UT_ENTER_FROM] = [self pageTypeString];
    param[UT_ELEMENT_FROM] = UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom?:UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = self.tracerModel.originSearchId?:UT_BE_NULL;
    
    TRACK_EVENT(@"start_commute", param);
    
}

-(void)addCommuteGoDetailLog
{
    /*
     "1.event_type:house_app2c_v2
     2.page_type:commuter_detail(通勤选项页）
     3.enter_from:renting(从租房icon进入),rent_list（从修改进入）
     4.element_from:commuter_info（从租房icon进入），be_null（从修改进入）
     5.origin_from:commuter（通勤找房）
     6. origin_search_id"
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = @"commuter_detail";
    param[UT_ENTER_FROM] = [self pageTypeString];
    param[UT_ELEMENT_FROM] = UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ?: UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    
    TRACK_EVENT(@"go_detail", param);
}

- (void)addDealGoDetailLog:(id)cellModel withRank: (NSInteger) rank
{
    /*
     "event_type": "house_app2c_v2",
     "group_id"
     "origin_from": "neighborhood_trade",
     "origin_search_id"
     "page_type": "neighborhood_trade_list",
     "rank":
     "search_id"
     "log_pb": "
     */
    NSInteger realrank = self.isFirstHavetip == NO ? rank - 1 :rank ;
    rank = realrank;
    FHSearchHouseItemModel *theModel = nil;
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        theModel = (FHSearchHouseItemModel *)cellModel;
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_GROUP_ID] = theModel.id ? : @"be_null";
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ?: UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_RANK] = @(rank);
    param[UT_SEARCH_ID] = theModel.searchId ? : @"be_null";
    param[UT_LOG_PB] = theModel.logPb ? : @"be_null";
    TRACK_EVENT(@"click_house_deal", param);
    
}

-(NSDictionary *)categoryLogDict {
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName] ? : @"be_null";
    tracerDict[@"enter_from"] = self.tracerModel.enterFrom ? : @"be_null";
    tracerDict[@"enter_type"] = self.tracerModel.enterType ? : @"be_null";
    tracerDict[@"element_from"] = self.tracerModel.elementFrom ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    tracerDict[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    return tracerDict;
}

-(NSString *)stayPageEvent {
    
    return @"enter_category";
}

-(NSDictionary *)stayPageParams {
    
    return [self categoryLogDict];
}


@end

@implementation FHHouseListViewModel(FHHouseTableView)

- (FHTracerModel *)getCurrentTracerModel {
    FHTracerModel *tracerModel = [[FHTracerModel alloc] init];
    tracerModel.originSearchId = self.originSearchId;
    tracerModel.searchId = self.searchId;
    tracerModel.originFrom = self.tracerModel.originFrom;
    tracerModel.enterFrom = self.tracerModel.enterFrom;
    tracerModel.elementFrom = self.tracerModel.elementFrom;
    tracerModel.elementType = [self elementTypeString];
    tracerModel.pageType = [self pageTypeString];
    tracerModel.categoryName = [self categoryName];
    return tracerModel;
}

- (NSDictionary *)getCurrentContext {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"search_type"] = @(self.searchType);
    dict[@"house_type"] = @(self.houseType);
    dict[@"pre_house_type"] = @(self.preHouseType);
    dict[@"rank_offset"] = @(!self.isFirstHavetip ? -1 : 0);
    if (self.subScribeQuery) {
        dict[@"subscribe_query"] = self.subScribeQuery;
    }
    dict[@"subscribe_offset"] = @(self.subScribeOffset);
    if (self.subScribeSearchId) {
        dict[@"subscribe_search_id"] = self.subScribeSearchId;
    }
    
    return dict;
}

- (NSObject *)getEntityFromModel:(id)model {
    NSObject *entity = [FHHouseCardUtils getEntityFromModel:model];
    if (entity) {
        entity.fh_trackModel = [self getCurrentTracerModel];
        
        if ([entity conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) {
            NSObject<FHHouseNewComponentViewModelProtocol> *viewModel = (NSObject<FHHouseNewComponentViewModelProtocol> *)entity;
            viewModel.delegate = self;
            viewModel.context = [self getCurrentContext];
        }
    }
    
    return entity;
}

#pragma mark - FHHouseTableViewDataSource
- (NSArray<NSArray<id<FHHouseNewComponentViewModelProtocol>> *> *)fhHouse_dataList {
    if (self.showPlaceHolder) {
        NSInteger count = 10;
        NSArray *placeholderViewModels = @[];
        if (self.houseType == FHHouseTypeNewHouse) {
            placeholderViewModels = [FHHouseCardUtils getPlaceholderModelsWithStyle:FHHousePlaceholderStyle1 count:count];
        } else {
            if (self.commute){
                placeholderViewModels = [FHHouseCardUtils getPlaceholderModelsWithStyle:FHHousePlaceholderStyle3 count:count];
            } else {
                placeholderViewModels = [FHHouseCardUtils getPlaceholderModelsWithStyle:FHHousePlaceholderStyle2 count:count];
            }
        }
        
        return @[placeholderViewModels];
    }
    
    return @[self.houseList.count ? self.houseList : @[],
        self.sugesstHouseList.count ? self.sugesstHouseList : @[]
    ];
}

- (NSDictionary<NSString *, NSString *> *)fhHouse_supportCellStyles {
    return [FHHouseCardUtils supportCellStyleMap];
}

#pragma mark - FHHouseReserveAdviserViewModelDelegate
- (NSMutableDictionary *)belongSubscribeCache {
    return self.subscribeCache;
}

- (UIViewController *)belongsVC {
    return self.listVC;
}

- (UITableView *)belongTableView {
    return self.tableView;
}

@end
