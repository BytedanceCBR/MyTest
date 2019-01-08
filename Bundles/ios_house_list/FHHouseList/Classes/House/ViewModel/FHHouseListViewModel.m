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
@interface FHHouseListViewModel () <UITableViewDelegate, UITableViewDataSource, FHMapSearchOpenUrlDelegate, FHHouseSuggestionDelegate>

@property(nonatomic , strong) FHErrorView *maskView;

@property(nonatomic, weak) UITableView *tableView;

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property (nonatomic , copy, nullable) NSString *searchId;
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

// log
@property (nonatomic , assign) BOOL isFirstLoad;

@end


@implementation FHHouseListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh];
    };
}

-(instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj {

    self = [super init];
    if (self) {

        _canChangeHouseSearchDic = YES;
        self.houseList = [NSMutableArray array];
        self.showPlaceHolder = YES;
        self.isRefresh = YES;
        self.isEnterCategory = YES;
        self.isFirstLoad = YES;
        self.tableView = tableView;
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;

        self.houseSearchDic = paramObj.userInfo.allInfo[@"houseSearch"];
        NSDictionary *tracerDict = paramObj.allParams[@"tracer"];
        if (tracerDict) {
            self.tracerModel = [[FHTracerModel alloc]initWithDictionary:tracerDict error:nil];
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
        [wself loadData:wself.isRefresh];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    
    [self.tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kFHHouseListCellId];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];

}

#pragma mark - 网络请求
-(void)loadData:(BOOL)isRefresh
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
    }else {
        offset = self.houseList.count;
    }
    
    NSString *searchId = self.searchId;

    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            
            [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
        case FHHouseTypeSecondHandHouse:
            
            [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId];
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


-(void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    
    if (error) {
        
        [self processError:error];
        return;
    }
    
    if (self.isRefresh) {
        [self.houseList removeAllObjects];
        [self.tableView.mj_footer endRefreshing];
    }
    
    if (model) {
        
        
        NSString *searchId;
        NSString *houseListOpenUrl;
        NSString *mapFindHouseOpenUrl;
        NSArray *itemArray = @[];
        BOOL hasMore = NO;
        NSString *refreshTip;

        if ([model isKindOfClass:[FHSearchHouseModel class]]) {

            FHSearchHouseDataModel *houseModel = ((FHSearchHouseModel *)model).data;
            searchId = houseModel.searchId;
            houseListOpenUrl = houseModel.houseListOpenUrl;
            mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;

        }else if ([model isKindOfClass:[FHNewHouseListResponseModel class]]) {
            
            FHNewHouseListDataModel *houseModel = ((FHNewHouseListResponseModel *)model).data;
            searchId = houseModel.searchId;
            houseListOpenUrl = houseModel.houseListOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;

        }else if ([model isKindOfClass:[FHHouseRentModel class]]) {

            FHHouseRentDataModel *houseModel = ((FHHouseRentModel *)model).data;
            searchId = houseModel.searchId;
            houseListOpenUrl = houseModel.houseListOpenUrl;
            mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;

        } else if ([model isKindOfClass:[FHHouseNeighborModel class]]) {

            FHHouseNeighborDataModel *houseModel = ((FHHouseNeighborModel *)model).data;
            searchId = houseModel.searchId;
            houseListOpenUrl = houseModel.houseListOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;

        }
        
        self.searchId = searchId;
        
        if (self.isFirstLoad) {
            self.originSearchId = searchId;
            self.isFirstLoad = NO;
            if (searchId.length > 0 ) {
                SETTRACERKV(UT_ORIGIN_SEARCH_ID, searchId);
            }
        }
        self.showPlaceHolder = NO;
        if (self.isEnterCategory) {
            [self addEnterCategoryLog];
            self.isEnterCategory = NO;
            
        }
        if (self.isRefresh) {
            [self addHouseSearchLog];
            [self refreshHouseListUrlCallback:houseListOpenUrl];
        }else {
            [self addCategoryRefreshLog];
        }
        self.houseListOpenUrl = houseListOpenUrl;
        self.mapFindHouseOpenUrl = mapFindHouseOpenUrl;
        
        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            if (cellModel) {
                
                [self.houseList addObject:cellModel];
            }

        }];
        [self.tableView reloadData];
        [self updateTableViewWithMoreData:hasMore];
        
        if (self.isRefresh && self.viewModelDelegate) {
            [self.viewModelDelegate showNotify:refreshTip inViewModel:self];
        }
        
        if (self.houseList.count == 0) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
            
        }else{
            [self showMaskView:NO];
        }
    }else {
        
        [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
    
    
    if (self.isRefresh && self.houseList.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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

    if ([self.condition isEqualToString:allQuery]) {
        return;
    }
    self.condition = allQuery;
    [self.filterOpenUrlMdodel overwriteFliter:self.condition];

    self.isRefresh = YES;
    [self.tableView triggerPullDown];
    [self loadData:self.isRefresh];
    
}

#pragma mark filter将要显示
-(void)onConditionWillPanelDisplay
{
    NSLog(@"onConditionWillPanelDisplay");

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
        param[@"click_type"] = @"list";
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
            [query appendString:[NSString stringWithFormat:@"&enter_from=%@",self.tracerModel.enterFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"enter_type"]) {
            [query appendString:[NSString stringWithFormat:@"&enter_type=%@",self.tracerModel.enterType ? : @"be_null"]];
            
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !self.showPlaceHolder ? self.houseList.count : 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {

        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListCellId];
        BOOL isFirstCell = (indexPath.row == 0);
        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);

        if (indexPath.row < self.houseList.count) {
            
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            [cell updateWithHouseCellModel:cellModel];
            [cell refreshTopMargin: 20];
            [cell refreshBottomMargin:isLastCell ? 20 : 0];
        }
        return cell;
        
    }else {
        
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
        return cell;

    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.houseList.count) {

        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
        if (cellModel.groupId.length > 0 && ![self.houseShowCache.allKeys containsObject:cellModel.groupId]) {
            
            [self addHouseShowLog:indexPath];
            self.houseShowCache[cellModel.groupId] = @"1";
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {

        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
        if (indexPath.row < self.houseList.count) {

            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
            if (height < 1) {
                
                height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHSingleImageInfoCell *cell) {
                    
                    [cell updateWithHouseCellModel:cellModel];
                    [cell refreshTopMargin: 20];
                    [cell refreshBottomMargin:isLastCell ? 20 : 0];
                    
                }];
            }
            
            return height;
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

    if (indexPath.row < self.houseList.count) {
        
        if (indexPath.row < self.houseList.count) {
            
            [self jump2HouseDetailPage:indexPath];
        }
        
    }
}

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(NSIndexPath *)indexPath {

    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"card_type"] = @"left_pic";
    traceParam[@"enter_from"] = [self pageTypeString];
    traceParam[@"element_from"] = [self elementTypeString];
    traceParam[@"log_pb"] = [cellModel logPb];
    traceParam[@"origin_from"] = self.originFrom;
    traceParam[@"origin_search_id"] = self.originSearchId;
    traceParam[@"search_id"] = self.searchId;
    traceParam[@"rank"] = @(indexPath.row);
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr;

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

-(NSString *)elementTypeString {
    
    return @"be_null";

}

#pragma mark house_show log
-(void)addHouseShowLog:(NSIndexPath *)indexPath {
    
    if (self.houseList.count < 1 || indexPath.row >= self.houseList.count) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];

    if (!cellModel) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = [self houseTypeString] ? : @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = [self pageTypeString];
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"group_id"] = [cellModel groupId] ? : @"be_null";
    tracerDict[@"impr_id"] = [cellModel imprId] ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"";
    tracerDict[@"rank"] = @(indexPath.row);
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
    params[@"page_type"] = [self pageTypeString];
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
