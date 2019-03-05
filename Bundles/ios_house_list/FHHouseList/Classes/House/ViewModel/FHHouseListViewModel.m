//
//  FHHouseListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewModel.h"
#import <MJRefresh.h>
#import "FHRefreshCustomFooter.h"
#import "TTHttpTask.h"
#import "FHHouseListAPI.h"
#import "FHSearchHouseModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseRentModel.h"
#import "FHNewHouseItemModel.h"

#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHPlaceHolderCell.h"
#import "TTReachability.h"
#import "FHMainManager+Toast.h"
#import <UIScrollView+Refresh.h>
#import "FHSearchFilterOpenUrlModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FHMapSearchOpenUrlDelegate.h"
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseListRedirectTipView.h"
#import "Masonry.h"
#import "FHEnvContext.h"
#import "FHRecommendSecondhandHouseTitleCell.h"
#import "FHRecommendSecondhandHouseTitleModel.h"
#import "FHHouseBridgeManager.h"
#import "FHCityListViewModel.h"

@interface FHHouseListViewModel () <UITableViewDelegate, UITableViewDataSource, FHMapSearchOpenUrlDelegate, FHHouseSuggestionDelegate>

@property(nonatomic , weak) FHErrorView *maskView;
@property (nonatomic , weak) FHHouseListRedirectTipView *redirectTipView;

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
@property(nonatomic , assign) BOOL lastHasMore;

@property (nonatomic , assign) BOOL isRefresh;
@property (nonatomic , copy) NSString *query;
@property (nonatomic , copy) NSString *condition;

@property (nonatomic, copy) NSString *mapFindHouseOpenUrl;
@property(nonatomic , strong) NSMutableDictionary *houseShowCache;
@property(nonatomic , strong) FHTracerModel *tracerModel;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;

// log
@property (nonatomic , assign) BOOL isFirstLoad;
@property (nonatomic , assign) BOOL fromRecommend;

@end


@implementation FHHouseListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh];
    };
}

-(void)setRedirectTipView:(FHHouseListRedirectTipView *)redirectTipView
{
    __weak typeof(self)wself = self;
    _redirectTipView = redirectTipView;
    _redirectTipView.clickCloseBlock = ^{
        [wself closeRedirectTip];
    };
    _redirectTipView.clickRightBlock = ^{
        [wself clickRedirectTip];
    };
    
}

-(void)updateRedirectTipInfo {
    
    if (self.showRedirectTip && self.redirectTips) {
        
        self.redirectTipView.hidden = NO;
        self.redirectTipView.text = self.redirectTips.text;
        self.redirectTipView.text1 = self.redirectTips.text2;
        [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
        }];
        
        NSDictionary *params = @{@"page_type":@"city_switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_switch_show" params:params];

    }else {
        self.redirectTipView.hidden = YES;
        [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

-(void)closeRedirectTip {
    
    self.showRedirectTip = NO;
    self.redirectTipView.hidden = YES;
    [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    NSDictionary *params = @{@"click_type":@"cancel",
                             @"enter_from":@"search"};
    [FHUserTracker writeEvent:@"city_click" params:params];
}

-(void)clickRedirectTip {
    
    if (self.redirectTips.openUrl.length > 0) {

        [FHEnvContext openSwitchCityURL:self.redirectTips.openUrl completion:^(BOOL isSuccess) {
            // 进历史
            if (isSuccess) {
                FHCityListViewModel *cityListViewModel = [[FHCityListViewModel alloc] initWithController:nil tableView:nil];
                [cityListViewModel switchCityByOpenUrlSuccess];
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
        self.showPlaceHolder = YES;
        self.isRefresh = YES;
        self.isEnterCategory = YES;
        self.isFirstLoad = YES;
        self.tableView = tableView;
        self.showRedirectTip = YES;
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;

        self.houseSearchDic = paramObj.userInfo.allInfo[@"houseSearch"];
        NSDictionary *tracerDict = paramObj.allParams[@"tracer"];
        if (tracerDict) {
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDict];
            self.originFrom = self.tracerModel.originFrom;
        }
        [self configTableView];

    }
    return self;
}

-(void)configTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak typeof(self)wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        if (wself.sugesstHouseList.count > 0) {
            wself.fromRecommend = YES;
            [wself loadData:wself.isRefresh fromRecommend:YES];
        } else {
            wself.fromRecommend = NO;
            [wself loadData:wself.isRefresh];
        }
    }];
    self.tableView.mj_footer = self.refreshFooter;
    
    [self.tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kFHHouseListCellId];
    [self.tableView registerClass:[FHRecommendSecondhandHouseTitleCell class] forCellReuseIdentifier:kFHHouseListRecommendTitleCellId];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];

}


-(void)loadData:(BOOL)isRefresh {
    [self loadData:isRefresh fromRecommend:self.fromRecommend];
}

#pragma mark - 网络请求
-(void)loadData:(BOOL)isRefresh fromRecommend:(BOOL)isFromRecommend
{
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
    NSInteger offset = 0;
    NSMutableDictionary *param = [NSMutableDictionary new];

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
        }
        self.tableView.mj_footer.hidden = YES;
        [self.houseShowCache removeAllObjects];
        self.searchId = nil;
    } else {
        if (isFromRecommend) {
            offset = self.sugesstHouseList.count - 1;
        } else {
            offset = self.houseList.count;
        }
    }
    
    NSString *searchId = self.searchId;

    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            
            [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
        case FHHouseTypeSecondHandHouse:
            if (isFromRecommend) {
                [self requestRecommendErshouHouseListData:isRefresh query:query offset:offset searchId:self.recommendSearchId];
            } else {
                [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId];
            }
            break;
            
        case FHHouseTypeRentHouse:
            
            [self requestRentHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
            
        case FHHouseTypeNeighborhood:
            
            [self requestNeiborhoodHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
            
        default:
            break;
    }
    
    
}


-(void)requestNewHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];

    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchNewHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHNewHouseListResponseModel class] completion:^(FHNewHouseListResponseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }

        [wself processData:model error:error];
    }];
    
    self.requestTask = task;
}

-(void)requestNeiborhoodHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;

    TTHttpTask *task = [FHHouseListAPI searchNeighborhoodList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHHouseNeighborModel class] completion:^(FHHouseNeighborModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }

        [wself processData:model error:error];
    }];
    
    self.requestTask = task;
}


-(void)requestRentHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHMainApi searchRent:query params:nil offset:offset searchId:searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
    }];
    
    self.requestTask = task;
}


-(void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];

        
    }];
    
    self.requestTask = task;
}

-(void)requestRecommendErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI recommendErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHRecommendSecondhandHouseModel class] completion:^(FHRecommendSecondhandHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
        
    }];
    
    self.requestTask = task;
}



-(void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    
    if (error) {
        
        [self processError:error];
        return;
    }
    
    if (self.isRefresh) {
        [self.houseList removeAllObjects];
        [self.sugesstHouseList removeAllObjects];
        [self.tableView.mj_footer endRefreshing];
    }
    
    if (model) {

//        NSString *searchId;
//        NSString *houseListOpenUrl;
//        NSString *mapFindHouseOpenUrl;
        NSArray *itemArray = @[];
        NSArray *recommendItemArray = @[];
        BOOL hasMore = NO;
        NSString *refreshTip;
        FHSearchHouseDataRedirectTipsModel *redirectTips;
        FHRecommendSecondhandHouseDataModel *recommendHouseDataModel;

        if ([model isKindOfClass:[FHRecommendSecondhandHouseModel class]]) {
            recommendHouseDataModel = ((FHRecommendSecondhandHouseModel *)model).data;
            self.recommendSearchId = recommendHouseDataModel.searchId;
            hasMore = recommendHouseDataModel.hasMore;
            recommendItemArray = recommendHouseDataModel.items;
        } else if ([model isKindOfClass:[FHSearchHouseModel class]]) {

            FHSearchHouseDataModel *houseModel = ((FHSearchHouseModel *)model).data;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;
            recommendHouseDataModel = houseModel.recommendSearchModel;
            recommendItemArray = recommendHouseDataModel.items;
            self.searchId = houseModel.searchId;
            if (recommendItemArray.count > 0) {
                self.recommendSearchId = recommendHouseDataModel.searchId;
                if (!hasMore) {
                    hasMore = recommendHouseDataModel.hasMore;
                }
                FHRecommendSecondhandHouseTitleModel *recommendTitleModel = [[FHRecommendSecondhandHouseTitleModel alloc]init];
                recommendTitleModel.noDataTip = recommendHouseDataModel.searchHint;
                recommendTitleModel.title = recommendHouseDataModel.recommendTitle;
                [self.sugesstHouseList addObject:recommendTitleModel];
            }
        } else if ([model isKindOfClass:[FHNewHouseListResponseModel class]]) {
            
            FHNewHouseListDataModel *houseModel = ((FHNewHouseListResponseModel *)model).data;
            self.searchId = houseModel.searchId;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;

        } else if ([model isKindOfClass:[FHHouseRentModel class]]) {

            FHHouseRentDataModel *houseModel = ((FHHouseRentModel *)model).data;
            self.searchId = houseModel.searchId;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;

        } else if ([model isKindOfClass:[FHHouseNeighborModel class]]) {

            FHHouseNeighborDataModel *houseModel = ((FHHouseNeighborModel *)model).data;
            self.searchId = houseModel.searchId;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;

        }
        
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
            self.isEnterCategory = NO;
        }
        if (self.isRefresh) {
            [self addHouseSearchLog];
            [self addHouseRankLog];
            [self refreshHouseListUrlCallback:self.houseListOpenUrl];
        } else {
            [self addCategoryRefreshLog];
        }

        if (!self.fromRecommend) {
            
            self.redirectTips = redirectTips;
            [self updateRedirectTipInfo];
        }

        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            if (cellModel) {
                cellModel.isRecommendCell = NO;
                [self.houseList addObject:cellModel];
            }

        }];
        
        [recommendItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            if (cellModel) {
                cellModel.isRecommendCell = YES;
                [self.sugesstHouseList addObject:cellModel];
            }
            
        }];
        
        [self.tableView reloadData];
        [self updateTableViewWithMoreData:hasMore];
        
        if (self.isRefresh && self.viewModelDelegate && itemArray.count > 0) {
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

-(FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {

    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
    
    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.secondModel = obj;
        
    }else if ([obj isKindOfClass:[FHNewHouseItemModel class]]) {
        
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.houseModel = obj;
        
    }else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        
        FHHouseRentDataItemsModel *item = (FHHouseRentDataItemsModel *)obj;
        cellModel.rentModel = obj;
        
    } else if ([obj isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {
        
        FHHouseNeighborDataItemsModel *item = (FHHouseNeighborDataItemsModel *)obj;
        cellModel.neighborModel = obj;
        
    }
    return cellModel;
    
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    
    self.tableView.mj_footer.hidden = NO;
    self.lastHasMore = hasMore;
    if (hasMore == NO) {
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

//    if ([self.condition isEqualToString:allQuery]) {
//        return;
//    }
    self.condition = allQuery;
    [self.filterOpenUrlMdodel overwriteFliter:self.condition];

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

#pragma mark - nav 点击事件
-(void)showInputSearch {
    if (self.closeConditionFilter) {
        self.closeConditionFilter();
    }
    [self addClickHouseSearchLog];
    
    NSDictionary *traceParam = [self.tracerModel toDictionary] ? : @{};
    //sug_list
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(3), // list
                           @"sug_delegate":sugDelegateTable
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
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

        NSMutableString *openUrl = self.mapFindHouseOpenUrl;
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
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

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
    
    if ([self.houseListOpenUrl isEqualToString:openUrl]) {
        return;
    }
    
    if (self.houseListOpenUrlUpdateBlock) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
        self.houseListOpenUrlUpdateBlock(routeParamObj, YES);
    }
    
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject {
    
    self.showRedirectTip = YES;
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    if (allInfo[@"houseSearch"]) {
        self.houseSearchDic = allInfo[@"houseSearch"];
        self.canChangeHouseSearchDic = NO; // 禁止修改house_search埋点数据
    }
    
    NSString *houseTypeStr = routeObject.paramObj.allParams[@"house_type"];
    self.houseType = houseTypeStr.integerValue;
    
    if (self.sugSelectBlock) {
        self.sugSelectBlock(routeObject.paramObj);
    }
}

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
    if (!self.showPlaceHolder) {
        if (indexPath.section == 1 && indexPath.row == 0 && [self.sugesstHouseList[0] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
            FHRecommendSecondhandHouseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListRecommendTitleCellId];
            FHRecommendSecondhandHouseTitleModel *model = self.sugesstHouseList[0];
            [cell bindData:model];
            return cell;
        } else {
            if (indexPath.section == 0) {
                FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListCellId];
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
                
                if (indexPath.row < self.houseList.count) {
                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                    CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
                    [cell updateWithHouseCellModel:cellModel];
                    [cell refreshTopMargin: 20];
                    [cell refreshBottomMargin:(isLastCell ? 20 : 0)+reasonHeight];                    
                }
                return cell;
            } else {
                FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListCellId];
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                
                if (indexPath.row < self.sugesstHouseList.count) {
                    FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
                    [cell updateWithHouseCellModel:cellModel];
                    [cell refreshTopMargin: 20];
                    [cell refreshBottomMargin:isLastCell ? 20 : 0];
                }
                return cell;
            }
        }
    } else {
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            if (cellModel.groupId.length > 0 && ![self.houseShowCache.allKeys containsObject:cellModel.groupId]) {
                
                [self addHouseShowLog:cellModel withRank:indexPath.row];
                self.houseShowCache[cellModel.groupId] = @"1";
            }
        }
    } else {
        if (indexPath.row > 0 && indexPath.row < self.sugesstHouseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
            if (cellModel.groupId.length > 0 && ![self.houseShowCache.allKeys containsObject:cellModel.groupId]) {
        
                [self addHouseShowLog:cellModel withRank:(indexPath.row - 1)];
                self.houseShowCache[cellModel.groupId] = @"1";
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {
        if (indexPath.section == 1 && indexPath.row == 0 && [self.sugesstHouseList[0] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
            CGFloat height = 44.5;
            FHRecommendSecondhandHouseTitleModel *titleModel = self.sugesstHouseList[0];
            if (titleModel.noDataTip.length > 0) {
                height += 58;
            }
            return height;
        } else {
            if (indexPath.section == 0) {
                
                FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
                
                BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
                return (isLastCell ? 125 : 105)+reasonHeight;
//                if (indexPath.row < self.houseList.count) {
//
//                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//                    CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
//                    if (height < 1) {
//                        height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHSingleImageInfoCell *cell) {
//
//                            [cell updateWithHouseCellModel:cellModel];
//                            [cell refreshTopMargin: 20];
//                            [cell refreshBottomMargin:isLastCell ? 20 : 0];
//
//                        }];
//                    }
//                    return height;
//                }
            } else {
                BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                return isLastCell ? 125 : 105;

//                if (indexPath.row < self.sugesstHouseList.count) {
//
//                    FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
//                    CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
//                    if (height < 1) {
//                        height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHSingleImageInfoCell *cell) {
//                            [cell updateWithHouseCellModel:cellModel];
//                            [cell refreshTopMargin: 20];
//                            [cell refreshBottomMargin:isLastCell ? 20 : 0];
//                        }];
//                    }
//                    return height;
//                }
            }
        }
    }

    return 105;
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
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            if (cellModel) {
                [self jump2HouseDetailPage:cellModel withRank:indexPath.row];
            }
        }
    } else {
        if (indexPath.row > 0 && indexPath.row < self.sugesstHouseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
            if (cellModel) {
                [self jump2HouseDetailPage:cellModel withRank:(indexPath.row - 1)];
            }
        }
    }
}

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank  {
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"card_type"] = @"left_pic";
    if (cellModel.isRecommendCell) {
        traceParam[@"enter_from"] = @"search_related_list";
        traceParam[@"element_from"] = @"search_related";
        traceParam[@"search_id"] = self.recommendSearchId;
    } else {
        traceParam[@"enter_from"] = [self pageTypeString];
        traceParam[@"element_from"] = [self elementTypeString];
        traceParam[@"search_id"] = self.searchId;
    }
    traceParam[@"log_pb"] = [cellModel logPb];
    traceParam[@"origin_from"] = self.originFrom;
    traceParam[@"origin_search_id"] = self.originSearchId;
    traceParam[@"rank"] = @(rank);
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr;

    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:self.originFrom forKey:@"origin_from"];
    [contextBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];

    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            if (cellModel.houseModel) {
                
                FHNewHouseItemModel *theModel = cellModel.houseModel;
                urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.houseId];
            }
            break;
        case FHHouseTypeSecondHandHouse:
            if (cellModel.secondModel) {
                
                FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
                urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid];
            }
            break;
        case FHHouseTypeRentHouse:
            if (cellModel.rentModel) {
                
                FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
                urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];
            }
            break;
        case FHHouseTypeNeighborhood:
            if (cellModel.neighborModel) {
                
                FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
                urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id];
            }
            break;
        default:
            break;
    }
    
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
}

#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache {
    
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
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

#pragma mark house_show log
-(void)addHouseShowLog:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank {
    if (!cellModel) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = [self houseTypeString] ? : @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    if (cellModel.isRecommendCell) {
        tracerDict[@"page_type"] = @"search_related_list";
        tracerDict[@"element_type"] = @"search_related";
        tracerDict[@"search_id"] = self.recommendSearchId ? : @"be_null";
    } else {
        tracerDict[@"page_type"] = [self pageTypeString];
        tracerDict[@"element_type"] = @"be_null";
        tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    }
    tracerDict[@"group_id"] = [cellModel groupId] ? : @"be_null";
    tracerDict[@"impr_id"] = [cellModel imprId] ? : @"be_null";
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"origin_from"] = originFrom;
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";

    [FHUserTracker writeEvent:@"house_show" params:tracerDict];

}


#pragma mark category log
-(void)addEnterCategoryLog {

    [FHUserTracker writeEvent:@"enter_category" params:[self categoryLogDict]];
}

-(void)addCategoryRefreshLog {

    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    [FHUserTracker writeEvent:@"category_refresh" params:tracerDict];
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
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
    params[@"hot_word"] = @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    
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
