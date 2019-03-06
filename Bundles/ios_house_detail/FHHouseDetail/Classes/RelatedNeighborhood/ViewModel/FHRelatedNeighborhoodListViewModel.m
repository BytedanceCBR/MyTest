//
//  FHRelatedNeighborhoodListViewModel.m
//  Pods
//
//  Created by 张静 on 2019/2/24.
//

#import "FHRelatedNeighborhoodListViewModel.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseListAPI.h"
#import "FHNeighborListModel.h"
#import "FHHouseBridgeManager.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <FHCommonUI/ToastManager.h>
#import <FHHouseBase/FHUserTracker.h>
#import "FHHouseTypeManager.h"
#import <FHHouseBase/FHSingleImageInfoCell.h>
#import <FHHouseBase/FHSingleImageInfoCellModel.h>
#import "FHRelatedNeighborhoodListViewController.h"
#import <TTUIWidget/UIViewController+Track.h>
#import "FHHouseDetailAPI.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import <FHCommonUI/FHErrorView.h>
#import <TTReachability/TTReachability.h>

#define kPlaceholderCellId @"placeholder_cell_id"
#define kSingleImageCellId @"single_image_cell_id"

@interface FHRelatedNeighborhoodListViewModel ()

@property (nonatomic , strong) NSMutableArray *houseList;
@property (nonatomic , copy) NSString *searchId;
@property(nonatomic , assign) BOOL hasMore;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowTracerDic; // 埋点key记录
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHRelatedNeighborhoodListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property(nonatomic , assign) BOOL hasEnterCategory;
@property(nonatomic , assign) BOOL isRefresh;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;// 周边小区
@property (nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , weak) FHErrorView *maskView;

@end

@implementation FHRelatedNeighborhoodListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        wself.isRefresh = YES;
        [wself requestRelatedNeighborhoodSearch:wself.neighborhoodId searchId:wself.searchId offset:@(1)];
    };
}

-(instancetype)initWithController:(FHRelatedNeighborhoodListViewController *)viewController tableView:(UITableView *)tableView {
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

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        [wself loadMore];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    _refreshFooter.hidden = YES;
    [_tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kSingleImageCellId];
    [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceholderCellId];
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
    [self requestRelatedNeighborhoodSearch:self.neighborhoodId searchId:self.searchId offset:[NSString stringWithFormat:@"%ld",self.houseList.count]];
}

// 周边小区
- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId searchId:(NSString*)searchId offset:(NSString *)offset
{
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

    __weak typeof(self) wSelf = self;
    TTHttpTask *httpTask = [FHHouseDetailAPI requestRelatedNeighborhoodSearchByNeighborhoodId:neighborhoodId searchId:searchId offset:offset query:nil count:15 completion:^(FHDetailRelatedNeighborhoodResponseModel * _Nullable model, NSError * _Nullable error) {

        wSelf.relatedNeighborhoodData = model.data;
        [wSelf processDetailRelatedData:model error:error];
    }];
    _httpTask = httpTask;
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData:(FHDetailRelatedNeighborhoodResponseModel *)model error:(NSError *)error {
    if (model != NULL && error == NULL) {
        BOOL hasMore = model.data.hasMore;
        self.searchId = model.data.searchId;
        NSArray *items = model.data.items;
        if (items.count > 0) {
            self.listController.hasValidateData = YES;
            self.maskView.hidden = YES;
            // 转换模型类型
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                if ([obj isKindOfClass:[FHDetailRelatedNeighborhoodResponseDataItemsModel class]]) {
                    FHHouseNeighborDataItemsModel *model = [self neighborDataByRelatedModel:obj];
                    cellModel.neighborModel = model;
                }
                if (cellModel) {
                    [self.houseList addObject:cellModel];
                }
            }];
            [self.tableView reloadData];
            [self updateTableViewWithMoreData:hasMore];
            
            if (hasMore && self.houseList.count <= 10) {
                self.refreshFooter.hidden = YES;
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

- (FHHouseNeighborDataItemsModel *)neighborDataByRelatedModel:(FHDetailRelatedNeighborhoodResponseDataItemsModel *)item
{
    NSDictionary *dict = [item toDictionary];
    FHHouseNeighborDataItemsModel *model = [[FHHouseNeighborDataItemsModel alloc]initWithDictionary:dict error:nil];
    return model;
}

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

-(void)jump2DetailPage:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.houseList.count) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    if (cellModel) {
        NSString *origin_from = self.listController.tracerDict[@"origin_from"];
        NSString *origin_search_id = self.listController.tracerDict[@"origin_search_id"];
        NSString *page_type = self.listController.tracerDict[@"category_name"];
        NSString *urlStr = NULL;
        FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
        if (theModel) {
            urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id];
        }
        if (urlStr.length > 0) {
            FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"enter_from"] = page_type ? : @"be_null";
            traceParam[@"element_from"] = @"be_null";
            traceParam[@"log_pb"] = [cellModel logPb];
            traceParam[@"origin_from"] = origin_from ? : @"be_null";
            traceParam[@"origin_search_id"] = origin_search_id ? : @"be_null";
            traceParam[@"search_id"] = self.searchId;
            traceParam[@"rank"] = @(indexPath.row);
            
            NSDictionary *dict = @{@"house_type":@(FHHouseTypeNeighborhood) ,
                                   @"tracer": traceParam
                                   };
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
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
        
        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
        return isLastCell ? 125 : 105;
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
    [self jump2DetailPage:indexPath];
}

#pragma mark tracer

-(void)addHouseShowLog:(NSIndexPath *)indexPath
{
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
    NSString *page_type = self.listController.tracerDict[@"category_name"];
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = @"neighborhood" ? : @"be_null";
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

- (void)viewWillAppear:(BOOL)animated
{

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self addStayCategoryLog];
}

-(void)addEnterCategoryLog
{
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    [FHUserTracker writeEvent:@"enter_category" params:tracerDict];
}

-(void)addCategoryRefreshLog
{
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    [FHUserTracker writeEvent:@"category_refresh" params:tracerDict];
}

-(void)addStayCategoryLog
{
    NSTimeInterval duration = self.listController.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    [self.listController tt_resetStayTime];
}

-(NSDictionary *)categoryLogDict
{
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
