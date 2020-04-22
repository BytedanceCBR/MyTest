//
//  FHOldPriceComparisonListViewModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/9.
//

#import "FHOldPriceComparisonListViewModel.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseListAPI.h"
#import "FHNeighborListModel.h"
#import "FHHouseBridgeManager.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <FHCommonUI/ToastManager.h>
#import <FHHouseBase/FHUserTracker.h>
#import "FHHouseTypeManager.h"
#import <FHHouseBase/FHSingleImageInfoCellModel.h>
#import <TTUIWidget/UIViewController+Track.h>
#import "FHHouseDetailAPI.h"
#import <FHCommonUI/FHErrorView.h>
#import <TTReachability/TTReachability.h>
#import "ToastManager.h"
#import "FHOldPriceComparisonListController.h"
//#import "FHOldPriceComparisonCell.h"
#import "FHHouseListBaseItemCell.h"
#import "FHHouseListBaseItemModel.h"
#import "FHHomePlaceHolderCell.h"

#define kPlaceholderCellId @"placeholder_cell_id"
#define kSingleImageCellId @"single_image_cell_id"

@interface FHOldPriceComparisonListViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic ,strong) NSMutableArray *houseList;
@property(nonatomic ,copy) NSString *searchId;
@property(nonatomic ,assign) BOOL hasMore;
@property(nonatomic ,strong) NSMutableDictionary *houseShowTracerDic; // 埋点key记录
@property(nonatomic ,weak) UITableView *tableView;
@property(nonatomic ,weak) FHOldPriceComparisonListController *listController;
@property(nonatomic ,weak) TTHttpTask *requestTask;
@property(nonatomic ,assign) BOOL hasEnterCategory;
@property(nonatomic ,assign) BOOL isRefresh;
@property(nonatomic ,strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic ,weak) FHErrorView *maskView;
@property(nonatomic ,strong) FHSearchHouseDataModel *currentHouseModel;

@end

@implementation FHOldPriceComparisonListViewModel

- (void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        wself.isRefresh = YES;
        [wself requestErshouHouseListData:NO query:self.query offset:0 searchId:self.searchId];
    };
}

- (instancetype)initWithController:(FHOldPriceComparisonListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        _isRefresh = YES;
        self.listController = viewController;
        self.tableView = tableView;
        self.hasMore = NO;
        self.hasEnterCategory = NO;
        self.houseShowTracerDic = [NSMutableDictionary new];
        [self configTableView];
    }
    return self;
}

- (void)configTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        [wself loadMore];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    _refreshFooter.hidden = YES;
    [_tableView registerClass:[FHHouseListBaseItemCell class] forCellReuseIdentifier:kSingleImageCellId];
    [_tableView registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:kPlaceholderCellId];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    self.hasMore = hasMore;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)loadMore {
    [self addCategoryRefreshLog];
    [self requestErshouHouseListData:NO query:self.query offset:self.currentHouseModel.offset searchId:self.searchId];
}

- (void)requestErshouHouseListData:(BOOL)isRefresh query:(NSString *)query offset:(NSInteger)offset searchId:(nullable NSString *)searchId {
    
    if (![TTReachability isNetworkConnected]) {
        if (_isRefresh) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            self.maskView.hidden = NO;
        }else{
            [[ToastManager manager] showToast:@"网络异常"];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    
    NSDictionary *params = @{
                             @"page_type":@"price_analysis_list"
                             };
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:params offset:offset searchId:searchId sugParam:nil class:[FHListResultHouseModel class] completion:^(FHListResultHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
    }];
    
    self.requestTask = task;
}

- (void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    if (model != NULL && error == NULL) {
        FHHouseListDataModel *houseModel = ((FHListResultHouseModel *)model).data;
        self.currentHouseModel = houseModel;
        BOOL hasMore = houseModel.hasMore;
        self.searchId = houseModel.searchId;
        NSArray *items = houseModel.items;
        if (items.count > 0) {
            self.listController.hasValidateData = YES;
            self.maskView.hidden = YES;
            // 转换模型类型
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
                FHHouseListBaseItemModel *cellModel = (FHHouseListBaseItemModel *)obj;
                if (cellModel) {
                    cellModel.isRecommendCell = NO;
                    cellModel.isSubscribCell = NO;
                    [self.houseList addObject:cellModel];
                }
            }];
            [self.tableView reloadData];
            [self updateTableViewWithMoreData:hasMore];
            
            if (!hasMore && self.houseList.count < 10) {
                self.refreshFooter.hidden = YES;
            }
            
            NSString *refreshTip = houseModel.refreshTip;
            if (self.isRefresh && self.houseList.count > 0) {
                [self.listController showNotify:refreshTip];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
        } else {
            [self processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL];
        }
        // enter category
        if (!self.hasEnterCategory) {
            [self addEnterCategoryLog];
            self.hasEnterCategory = YES;
        }
    } else {
        [self processError:FHEmptyMaskViewTypeNoData tips:@"网络异常"];
    }
}

//- (FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
//    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc] init];
//    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
//        cellModel.secondModel = obj;
//    }
//    return cellModel;
//}

- (void)processError:(FHEmptyMaskViewType)maskViewType tips:(NSString *)tips {
    // 此时需要看是否已经有有效数据，如果已经有的话只需要toast提示，不显示空页面
    if (self.houseList.count > 0) {
        self.listController.hasValidateData = YES;
        self.maskView.hidden = YES;
        if (tips.length > 0) {
            // Toast
            [[ToastManager manager] showToast:tips];
        }
    } else {
        self.listController.hasValidateData = NO;
        [self.listController.emptyView showEmptyWithType:maskViewType];
        self.maskView.hidden = NO;
        if (tips.length > 0) {
            // Toast
            [[ToastManager manager] showToast:tips];
        }
    }
    [self updateTableViewWithMoreData:self.hasMore];
}

- (void)jump2DetailPage:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.houseList.count) {
        return;
    }
//    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    FHHouseListBaseItemModel *cellModel = self.houseList[indexPath.row];
    if (cellModel) {
        NSString *origin_from = self.listController.tracerDict[@"origin_from"];
        NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
        NSString *urlStr = NULL;
//        FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
//        if (theModel) {
            urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",cellModel.houseid];
            
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"enter_from"] = [self categoryName];
            traceParam[@"element_from"] = @"be_null";
            traceParam[@"log_pb"] = [cellModel logPb];
            traceParam[@"origin_from"] = origin_from ? : @"be_null";
            traceParam[@"origin_search_id"] = origin_search_id ? : @"be_null";
            traceParam[@"search_id"] = self.searchId;
            traceParam[@"rank"] = @(indexPath.row);
            
            NSDictionary *dict = @{@"house_type":@(FHHouseTypeSecondHandHouse) ,
                                   @"tracer": traceParam
                                   };
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
//        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listController.hasValidateData == YES) {
        return _houseList.count;
    } else {
        // PlaceholderCell Count
        return 10;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listController.hasValidateData == YES) {
        FHHouseListBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleImageCellId];
        FHHouseListBaseItemModel *cellModel = self.houseList[indexPath.row];
        [cell refreshWithData: cellModel];
//        [cell refreshTopMargin: 20];
//        [cell updateWithHouseCellModel:cellModel];
        return cell;
    } else {
        // PlaceholderCell
        FHHomePlaceHolderCell *cell = (FHHomePlaceHolderCell *)[tableView dequeueReusableCellWithIdentifier:kPlaceholderCellId];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.listController.hasValidateData) {
//        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
//        return isLastCell ? 106 : 86;
//    }
//    return 86;
    return 88;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self jump2DetailPage:indexPath];
}

#pragma mark tracer

- (void)addHouseShowLog:(NSIndexPath *)indexPath {
    if (self.houseList.count < 1 || indexPath.row >= self.houseList.count) {
        return;
    }
    if (!self.listController.hasValidateData) {
        return;
    }
    FHHouseListBaseItemModel * cellModel = self.houseList[indexPath.row];
    
    if (!cellModel) {
        return;
    }
    
    NSString *groupId = cellModel.groupId;
    NSString *imprId = cellModel.imprId;
    NSDictionary *logPb = cellModel.logPb;
    
    NSString *origin_from = self.listController.tracerDict[@"origin_from"];
    NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
    NSString *page_type = self.listController.tracerDict[@"category_name"];
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = @"old";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = [self categoryName];
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"group_id"] = groupId ? : @"be_null";
    tracerDict[@"impr_id"] = imprId ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"";
    tracerDict[@"rank"] = @(indexPath.row);
    tracerDict[@"origin_from"] = origin_from ? : @"be_null";
    tracerDict[@"origin_search_id"] = origin_search_id ? : @"be_null";
    tracerDict[@"log_pb"] = logPb ? : @"be_null";
    
    TRACK_EVENT(@"house_show", tracerDict);
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self addStayCategoryLog];
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (void)addCategoryRefreshLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    TRACK_EVENT(@"category_refresh", tracerDict);
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = self.listController.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_category", tracerDict);
    [self.listController tt_resetStayTime];
}

- (NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    NSString *origin_from = self.listController.tracerDict[@"origin_from"];
    tracerDict[@"origin_from"] = origin_from.length > 0 ? origin_from : @"be_null";
    NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
    tracerDict[@"origin_search_id"] = origin_search_id.length > 0 ? origin_search_id : @"be_null";
    tracerDict[@"search_id"] = self.searchId.length > 0 ? self.searchId : @"be_null";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"category_name"] = [self categoryName];
    NSString *enter_from = self.listController.tracerDict[@"page_type"];
    tracerDict[@"enter_from"] = enter_from.length > 0 ? enter_from : @"be_null";
    NSString *element_from = self.listController.tracerDict[@"element_from"];
    tracerDict[@"element_from"] = element_from.length > 0 ? element_from : @"be_null";
    return tracerDict;
}

- (NSString *)categoryName {
    return @"price_analysis_list";
}


@end


