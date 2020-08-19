//
//  FHMapAreaHouseListViewModel.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import "FHMapAreaHouseListViewModel.h"
#import <FHHouseBase/FHSingleImageInfoCellModel.h>
//#import <FHHouseBase/FHHouseBaseItemCell.h>
#import <FHHouseBase/FHHouseBaseSmallItemCell.h>
//#import <FHHouseBase/FHPlaceHolderCell.h>
#import <FHHouseBase/FHHomePlaceHolderCell.h>
#import <MJRefresh/MJRefresh.h>
#import <FHCommonUI/ToastManager.h>
#import <FHHouseBase/FHHouseTypeManager.h>
#import <FHHouseBase/FHUserTracker.h>
#import <TTUIWidget/UIViewController+Track.h>
#import <FHHouseBase/FHHouseSearcher.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/FHMainManager.h>
#import <FHHouseBase/FHHouseFilterBridge.h>
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <FHHouseBase/FHMainApi.h>
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <FHHouseBase/FHCommonDefines.h>

#import "FHMapAreaHouseListViewController.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import <FHHouseBase/FHSearchChannelTypes.h>

#define kPlaceholderCellId @"placeholder_cell_id"
#define kSingleImageCellId @"single_image_cell_id"

@interface FHMapAreaHouseListViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , weak)   FHMapAreaHouseListViewController *listController;
@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHSearchHouseDataModel *currentHouseModel;
@property(nonatomic , strong) FHHouseRentDataModel *currentRentModel;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) NSString *originSearchId;
@property(nonatomic , strong) NSMutableDictionary * houseShowTracerDic; // 埋点key记录
@property(nonatomic , strong) TTHttpTask *requestTask;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
//@property(nonatomic , copy)   NSString *filterCondition;
@property(nonatomic , assign) BOOL hasEnterCategory;
@property(nonatomic , copy)   NSString *currentFilter;

/*
 * 多边形，经纬度用","分割，不同点之间用";"分割。
 * 116.44417238014412,39.89371509137617;116.42774785086281,39.893496613309466
 */
@property(nonatomic , copy) NSString *coordinateEnclosure;
/*
 * 小区id
 * [123,345,567,789]
 */
@property(nonatomic , copy) NSString *neighborhoodIds;

@end

@implementation FHMapAreaHouseListViewModel


-(instancetype)initWithWithController:(FHMapAreaHouseListViewController *)viewController tableView:(UITableView *)table userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        
        _houseShowTracerDic = [NSMutableDictionary new];
        _houseList = [NSMutableArray new];
        self.listController = viewController;
        self.tableView = table;
        
        [self configTableView];
        
        self.houseType = [userInfo[@"house_type"] integerValue];
        self.coordinateEnclosure = userInfo[COORDINATE_ENCLOSURE];
        self.neighborhoodIds = userInfo[NEIGHBORHOOD_IDS];
        
        NSString *filter = userInfo[@"filter"];
        if (!IS_EMPTY_STRING(filter)) {
            self.currentFilter = filter;
        }
        
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[FHHouseBaseSmallItemCell class] forCellReuseIdentifier:kSingleImageCellId];
    [_tableView registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:kPlaceholderCellId];
    
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [_refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
    
    _refreshFooter.hidden = YES;
    
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (!hasMore) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}


-(void)jump2DetailPage:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.houseList.count) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    if (cellModel) {
//        NSString *origin_from = self.listController.tracerDict[@"origin_from"];
//        NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
//        NSString *page_type = self.listController.tracerDict[@"category_name"];
        NSString *urlStr = NULL;
        if (self.houseType == FHHouseTypeSecondHandHouse) {
            // 二手房
            FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
            if (theModel) {
                urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid];
            }
        } else if (self.houseType == FHHouseTypeRentHouse) {
            // 租房
            FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
            if (theModel) {
                urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];
            }
        } else {
            urlStr = @"";
        }
        if (urlStr.length > 0) {
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"enter_from"] = self.listController.tracerModel.categoryName ? : UT_BE_NULL;
            traceParam[@"element_from"] = self.listController.tracerModel.elementFrom?:UT_BE_NULL;
            traceParam[@"log_pb"] = [cellModel logPb];
            traceParam[@"origin_from"] = self.listController.tracerModel.elementFrom ? : UT_BE_NULL;
            traceParam[@"origin_search_id"] = self.listController.tracerModel.originSearchId ? : UT_BE_NULL;
            traceParam[@"search_id"] = self.searchId;
            traceParam[@"rank"] = @(indexPath.row);
            
            NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                                   @"tracer": traceParam
                                   };
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

-(void)refreshWithFilter:(NSString *)filter
{
    if([_currentFilter isEqualToString:filter]){
        return;
    }
    self.currentFilter = filter;
    [self requestData:YES];
}

#pragma mark - Request

-(void)loadData
{
    [self requestData:YES];
}

-(void)requestData:(BOOL)isHead
{
    if (self.requestTask.state == TTHttpTaskStateRunning) {
        [self.requestTask cancel];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSMutableString *query = [[NSMutableString alloc] init];//
    
    if (self.currentFilter) {
        [query appendString:self.currentFilter];
    }
        
    if (query.length > 0 && ![query hasSuffix:@"&"]) {
        [query appendString:@"&"];
    }
    [query appendFormat:@"%@=%@",HOUSE_TYPE_KEY,@(self.houseType)];
    
    if (self.searchId) {
        [query appendFormat:@"&search_id=%@",self.searchId];
    }

    if (self.coordinateEnclosure.length > 0) {
        param[COORDINATE_ENCLOSURE] = self.coordinateEnclosure;
    }
    if (self.neighborhoodIds.length > 0) {
        param[NEIGHBORHOOD_IDS] = self.neighborhoodIds;
    }
        
    if (![TTReachability isNetworkConnected]) {
        if (isHead) {
            [self.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }else{
            SHOW_TOAST(@"网络异常");
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    if(self.houseType == FHHouseTypeSecondHandHouse){
        param[CHANNEL_ID] = CHANNEL_ID_CIRCEL_SEARCH;
        if (query.length > 0) {
            query = [NSString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_CIRCEL_SEARCH];
        }else {
            query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_CIRCEL_SEARCH];
        }
        self.requestTask = [self requsetSecondHouse:query param:param isHead:isHead];
    }else if (self.houseType == FHHouseTypeRentHouse){
        if (query.length > 0) {
            query = [NSString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_MAP_FIND_RENT];
        }else {
            query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_MAP_FIND_RENT];
        }
        self.requestTask = [self requsetRentHouse:query param:param isHead:isHead];
    }
    if (!isHead) {
        [self addCategoryRefreshLog];
    }
}

-(TTHttpTask *)requsetSecondHouse:(NSString *)query param:(NSDictionary *)param isHead:(BOOL)isHead
{
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher houseSearchWithQuery:query param:param offset:isHead?0:self.currentHouseModel.offset class:[FHSearchHouseModel class] needCommonParams:YES callback:^(NSError * _Nullable error,FHSearchHouseModel * _Nullable houseModel) {
        if (!wself) {
            return ;
        }
        [wself processQueryData:houseModel.data error:error isHead:isHead];
        
    }];
    return task;
}

-(TTHttpTask *)requsetRentHouse:(NSString *)query param:(NSDictionary *)param isHead:(BOOL)isHead
{
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHMainApi searchRent:query params:param offset:isHead?0:self.currentRentModel.offset searchId:self.searchId sugParam:nil class:[FHHouseRentModel class] completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (!wself) {
            return ;
        }
        
        [wself processQueryData:model.data error:error isHead:isHead];
    }];
    return task;
}

// 统一处理网络数据返回
- (void)processQueryData:(id)model error:(NSError *)error isHead:(BOOL)isHead
{
    if (model != NULL && error == NULL) {
        BOOL hasMore = NO;
        NSString *searchId = @"";
        NSArray *items = NULL;
        NSString *refreshTip = nil;
        NSString *openUrl = nil;
        if ([model isKindOfClass:[FHSearchHouseDataModel class]]) {
            FHSearchHouseDataModel *dataModel = (FHSearchHouseDataModel *)model;
            searchId = dataModel.searchId;
            hasMore = dataModel.hasMore;
            items = dataModel.items;
            refreshTip = dataModel.refreshTip;
            openUrl = dataModel.houseListOpenUrl;
            self.currentHouseModel = dataModel;
        }else if ([model isKindOfClass:[FHHouseRentDataModel class]]){
            FHHouseRentDataModel *dataModel = (FHHouseRentDataModel *)model;
            searchId = dataModel.searchId;
            hasMore = dataModel.hasMore;
            items = dataModel.items;
            refreshTip = dataModel.refreshTip;
            openUrl = dataModel.houseListOpenUrl;
            self.currentRentModel = dataModel;
        }
        
        if (searchId.length > 0) {
            self.searchId = searchId;
        }
        if (isHead) {
//            if (openUrl) {
//                [self overwriteFilter:openUrl];
//            }
            self.currentRentModel = nil;
            self.currentHouseModel = nil;
            [self.houseList removeAllObjects];
            [self.houseShowTracerDic removeAllObjects];
        }
        
        
        if (items.count > 0) {
            self.listController.hasValidateData = YES;
            [self.listController.emptyView hideEmptyView];
            // 转换模型类型
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
                if (cellModel) {
                    [self.houseList addObject:cellModel];
                }
            }];
            [self.tableView reloadData];
            [self updateTableViewWithMoreData:hasMore];
            
            if (isHead) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                });
            }
        } else {
            [self processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL isHead:isHead];
        }
        
        //enter category
        if (!self.hasEnterCategory) {
            [self addEnterCategoryLog];
            self.hasEnterCategory = YES;
        }
        
        if (!hasMore && self.houseList.count < 10) {
            self.tableView.mj_footer.hidden = YES;
        }
    } else {
        [self processError:FHEmptyMaskViewTypeNoNetWorkAndRefresh tips:@"网络异常" isHead:isHead];
    }
    
}

- (void)processError:(FHEmptyMaskViewType)maskViewType tips:(NSString *)tips isHead:(BOOL)isHead {
    // 此时需要看是否已经有有效数据，如果已经有的话只需要toast提示，不显示空页面
    if (self.houseList.count > 0 && !isHead) {
        self.listController.hasValidateData = YES;
        [self.listController.emptyView hideEmptyView];
        if (tips.length > 0) {
            // Toast
            [[ToastManager manager] showToast:tips];
        }
    } else {
        self.listController.hasValidateData = NO;
        [self.listController.emptyView showEmptyWithType:maskViewType];
        if (tips.length > 0) {
            // Toast
            [[ToastManager manager] showToast:tips];
        }
    }
}


-(void)overwriteFilter:(NSString *)openUrl
{
    if([self.delegate respondsToSelector:@selector(overwriteWithOpenUrl:andViewModel:)]){
        [self.delegate overwriteWithOpenUrl:openUrl andViewModel:self];
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listController.hasValidateData == YES) {
        return _houseList.count;
    } else {
        // PlaceholderCell Count
        return 10;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listController.hasValidateData == YES) {
        FHHouseBaseSmallItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleImageCellId];
        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
        [cell refreshTopMargin:10];
        [cell updateWithHouseCellModel:cellModel];
        return cell;
    } else {
        // PlaceholderCell
        FHHomePlaceHolderCell *cell = (FHHomePlaceHolderCell *)[tableView dequeueReusableCellWithIdentifier:kPlaceholderCellId];
        cell.topOffset = 20;
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listController.hasValidateData == YES && indexPath.row < self.houseList.count) {
        NSInteger rank = indexPath.row - 1;
        NSString *recordKey = [NSString stringWithFormat:@"%ld",rank];
        if (!self.houseShowTracerDic[recordKey]) {
            // 埋点
            self.houseShowTracerDic[recordKey] = @(YES);
            [self addHouseShowLog:indexPath];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listController.hasValidateData) {
        if (indexPath.row < self.houseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseSmallItemCell recommendReasonHeight] : 0;
            BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
            return (isLastCell ? 95 : 75)+reasonHeight;
        }
    }
    
    return 75;
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
    [self jump2DetailPage:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.scrollEnabled) {
        //不是用户主动滑动
        scrollView.contentOffset = CGPointZero;
        return;
    }
    
    CGFloat minTop =  [self.delegate areaListMinTop];
    if (self.listController.view.top - scrollView.contentOffset.y > minTop) {
        [UIView animateWithDuration:0.1 animations:^{
            self.listController.view.top -= scrollView.contentOffset.y;
        }];
        scrollView.contentOffset = CGPointZero;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self checkScrollMoveEffect:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self checkScrollMoveEffect:scrollView];
}

-(void)checkScrollMoveEffect:(UIScrollView *)scrollview
{
    CGFloat minTop = [self.delegate areaListMinTop];
    if (self.listController.view.top < minTop + 50) {
        //back to top
        [UIView  animateWithDuration:0.3 animations:^{
            self.listController.view.top = minTop;
        }];
    }else{
        //dismiss
        [self handleDismiss:0.3];
    }

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.contentOffset.y < 1 && (self.listController.view.top > [self.delegate areaListMinTop]) && velocity.y < -2.5) {
        //quickly swipe done
        [self handleDismiss:0.1];
    }
    if (scrollView.contentOffset.y > 50 && velocity.y < -2) {
        *targetContentOffset =  CGPointMake(0, 0.5);
    }
}

-(void)handleDismiss:(CGFloat)duration
{
//    [UIView ];
    [self.delegate areaListDismissed:self];
}


-(FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
    
    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc] init];
    
    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        cellModel.secondModel = obj;
    } else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        cellModel.rentModel = obj;
    }
    return cellModel;
}

#pragma mark tracer

-(void)addHouseShowLog:(NSIndexPath *)indexPath {
    
    if (self.houseList.count < 1 || indexPath.row >= self.houseList.count) {
        return;
    }
    if (!self.listController.hasValidateData) {
        return;
    }
    FHSingleImageInfoCellModel * cellModel = self.houseList[indexPath.row];
    
    if (!cellModel) {
        return;
    }
    
    NSString *groupId = cellModel.groupId;
    NSString *imprId = cellModel.imprId;
    NSDictionary *logPb = cellModel.logPb;
    
    NSString *origin_from = self.listController.tracerDict[@"origin_from"];
    NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
    NSString *house_type = [[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType];
    NSString *page_type = self.listController.tracerDict[@"category_name"];
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = house_type ? : @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = page_type ? : @"be_null";
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"group_id"] = groupId ? : @"be_null";
    tracerDict[@"impr_id"] = imprId ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"";
    tracerDict[@"rank"] = @(indexPath.row);
    tracerDict[@"origin_from"] = origin_from ? : @"be_null";
    tracerDict[@"origin_search_id"] = origin_search_id ? : @"be_null";
    tracerDict[@"log_pb"] = logPb ? : @"be_null";
    tracerDict[@"tab_name"] = self.houseType == FHHouseTypeSecondHandHouse ? @"old_tab" : @"rent_tab";

    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [self addStayCategoryLog];
}

-(void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    [FHUserTracker writeEvent:@"enter_category" params:tracerDict];
}

-(void)addCategoryRefreshLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    [FHUserTracker writeEvent:@"category_refresh" params:tracerDict];
}

-(void)addStayCategoryLog {
    NSTimeInterval duration = self.listController.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    [self.listController tt_resetStayTime];
}

-(NSDictionary *)categoryLogDict {
    
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    FHTracerModel *model = self.listController.tracerModel;
    tracerDict[UT_ORIGIN_FROM] = model.originFrom?:UT_BE_NULL;
    tracerDict[UT_ORIGIN_SEARCH_ID] = model.originSearchId?:UT_BE_NULL;
    tracerDict[UT_SEARCH_ID] = IS_EMPTY_STRING(self.searchId) ? UT_BE_NULL:self.searchId;
    tracerDict[UT_ENTER_TYPE] = model.enterType?:UT_BE_NULL;
    tracerDict[UT_CATEGORY_NAME] = model.categoryName?:UT_BE_NULL;
    tracerDict[UT_ENTER_FROM] = model.enterFrom?:UT_BE_NULL;
    tracerDict[UT_ELEMENT_FROM] = model.elementFrom?:UT_BE_NULL;
    
    return tracerDict;
}

@end
