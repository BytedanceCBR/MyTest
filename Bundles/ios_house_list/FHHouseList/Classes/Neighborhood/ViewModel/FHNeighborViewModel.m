//
//  FHNeighborViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHNeighborViewModel.h"
#import "FHNeighborListViewController.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseListAPI.h"
#import "FHNeighborListModel.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseSingleImageInfoCellBridgeDelegate.h"
#import "FHRefreshCustomFooter.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"

#define kPlaceholderCellId @"placeholder_cell_id"
#define kSingleImageCellId @"single_image_cell_id"

@interface FHNeighborViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHNeighborListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property(nonatomic , assign) BOOL lastHasMore;
@property(nonatomic , assign) BOOL hasEnterCategory;

@end

@implementation FHNeighborViewModel

-(instancetype)initWithController:(FHNeighborListViewController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        self.listController = viewController;
        self.tableView = tableView;
        self.lastHasMore = NO;
        self.hasEnterCategory = NO;
        self.houseShowTracerDic = [NSMutableDictionary new];
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kSingleImageCellId];
    [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceholderCellId];
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

- (void)processError:(FHEmptyMaskViewType)maskViewType tips:(NSString *)tips {
    // 此时需要看是否已经有有效数据，如果已经有的话只需要toast提示，不显示空页面
    if (self.houseList.count > 0) {
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
    [self updateTableViewWithMoreData:self.lastHasMore];
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
        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleImageCellId];
        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
        id model = _houseList[indexPath.row];
        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
        [cell updateWithHouseCellModel:cellModel];
        [cell refreshTopMargin: 20];
        [cell refreshBottomMargin:isLastCell ? 20 : 0];
        return cell;
    } else {
        // PlaceholderCell
        FHPlaceHolderCell *cell = (FHPlaceHolderCell *)[tableView dequeueReusableCellWithIdentifier:kPlaceholderCellId];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"----------:willDisplayCell : %ld",indexPath.row);
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
}

-(FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
    
    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc] init];
    
    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.secondModel = obj;
    } else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        FHHouseRentDataItemsModel *item = (FHHouseRentDataItemsModel *)obj;
        cellModel.rentModel = obj;
    }
    return cellModel;
}

// 统一处理网络数据返回
- (void)processQueryData:(id<FHBaseModelProtocol>)model error:(NSError *)error {
    if (model != NULL && error == NULL) {
        BOOL hasMore = NO;
        NSString *searchId = @"";
        NSArray *items = NULL;
        if ([model isKindOfClass:[FHSameNeighborhoodHouseResponse class]]) {
            searchId = ((FHSameNeighborhoodHouseResponse *)model).data.searchId;
            hasMore = ((FHSameNeighborhoodHouseResponse *)model).data.hasMore;
            items = ((FHSameNeighborhoodHouseResponse *)model).data.items;
        } else if ([model isKindOfClass:[FHHouseRentModel class]]) {
            searchId = ((FHHouseRentModel *)model).data.searchId;
            hasMore = ((FHHouseRentModel *)model).data.hasMore;
            items = ((FHHouseRentModel *)model).data.items;
        } else if ([model isKindOfClass:[FHRelatedHouseResponse class]]) {
            searchId = ((FHRelatedHouseResponse *)model).data.searchId;
            hasMore = ((FHRelatedHouseResponse *)model).data.hasMore;
            items = ((FHRelatedHouseResponse *)model).data.items;
        }
        if (searchId.length > 0) {
            self.searchId = searchId;
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
        } else {
            [self processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL];
        }
        // enter category
        if (!self.hasEnterCategory) {
            [self addEnterCategoryLog];
            self.hasEnterCategory = YES;
        }
    } else {
        [self processError:FHEmptyMaskViewTypeNetWorkError tips:@"网络异常"];
    }
}

#pragma mark - Request

- (void)requestHouseInSameNeighborhoodSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset
{
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestHouseInSameNeighborhoodQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHSameNeighborhoodHouseResponse class] completion:^(FHSameNeighborhoodHouseResponse * _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
}

- (void)requestRentInSameNeighborhoodSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestRentInSameNeighborhoodQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHHouseRentModel class] completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
}

- (void)requestRelatedHouseSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    // condition添加请求参数到url后面
    self.httpTask = [FHHouseListAPI requestRelatedHouseSearchWithQuery:self.condition houseId:houseId offset:offset count:15 class:[FHRelatedHouseResponse class] completion:^(FHRelatedHouseResponse * _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
}

- (void)requestRentRelatedHouseSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestRentHouseSearchWithQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHHouseRentModel class] completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
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
    NSString *house_type = [[FHHouseTypeManager sharedInstance] traceValueForType:self.listController.houseType];
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
    
    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    NSString *origin_from = self.listController.tracerDict[@"origin_from"];
    tracerDict[@"origin_from"] = origin_from.length > 0 ? origin_from : @"be_null";
    NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
    tracerDict[@"origin_search_id"] = origin_search_id.length > 0 ? origin_search_id : @"be_null";
    tracerDict[@"search_id"] = self.searchId.length > 0 ? self.searchId : @"be_null";
    NSString *enter_type = self.listController.tracerDict[@"enter_type"];
    tracerDict[@"enter_type"] = enter_type.length > 0 ? enter_type : @"be_null";
    NSString *category_name = self.listController.tracerDict[@"category_name"];
    tracerDict[@"category_name"] = category_name.length > 0 ? category_name : @"be_null";
    NSString *enter_from = self.listController.tracerDict[@"enter_from"];
    tracerDict[@"enter_from"] = enter_from.length > 0 ? enter_from : @"be_null";
    NSString *element_from = self.listController.tracerDict[@"element_from"];
    tracerDict[@"element_from"] = element_from.length > 0 ? element_from : @"be_null";
    return tracerDict;
}

@end
