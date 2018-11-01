//
//  FHMapSearchHouseListViewModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchHouseListViewModel.h"
#import "Bubble-Swift.h"
#import "FHSearchHouseModel.h"
#import "FHHouseAreaHeaderView.h"
#import "FHMapSearchHouseListViewController.h"
#import "FHMapSearchModel.h"
#import "FHHouseSearcher.h"
#import "FHMapSearchConfigModel.h"

#define kCellId @"singleCellId"

@interface FHMapSearchHouseListViewModel ()

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHMapSearchDataListModel *neighbor;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) NIHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSTimeInterval startTimestamp;
@property(nonatomic , weak)   TTHttpTask * requestTask;

@end

@implementation FHMapSearchHouseListViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
    }
    return self;
}

-(void)registerCells:(UITableView *)tableView
{
    self.tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [NIHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadMoreData];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [tableView registerClass:SingleImageInfoCell.class forCellReuseIdentifier:kCellId];
}

-(void)setHeaderView:(FHHouseAreaHeaderView *)headerView
{
    _headerView = headerView;
    [headerView addTarget:self action:@selector(showNeighborDetail) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor
{
    if (self.requestTask.state == TTHttpTaskStateRunning) {
        [self.requestTask cancel];
    }
    
    [_houseList removeAllObjects];
    [_houseList addObjectsFromArray:data.items];
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
    [_headerView updateWithMode:neighbor];
    _tableView.tableHeaderView = _headerView;
    self.searchId = data.searchId;
    self.neighbor = neighbor;
    if (data.hasMore) {
        [self.tableView.mj_footer resetNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
    if (neighbor) {
        [self addNeighborShowLog:self.neighbor];
    }
}

-(void)showNeighborDetail
{
    if (self.listController.showNeighborhoodDetailBlock) {
        [self addShowNeighborDetailLog:self.neighbor];
        self.listController.showNeighborhoodDetailBlock(self.neighbor);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    FHSearchHouseDataItemsModel *item = _houseList[indexPath.row];
    [cell updateWithModel:item isLastCell:(indexPath.row == _houseList.count - 1)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self addHouseShowLog:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == _houseList.count - 1) {
        return 125;
//    }
//    return 105;
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
    FHSearchHouseDataItemsModel *model = _houseList[indexPath.row];
    if (self.listController.showHouseDetailBlock) {
        self.listController.showHouseDetailBlock(model);
        [self addHouseDetailShowLog:indexPath];
    }
}

-(void)dismiss
{
    [self handleDismiss:0.3];
}

-(void)handleDismiss:(CGFloat)duration
{
    self.tableView.userInteractionEnabled = false;
    if (self.listController.willSwipeDownDismiss) {
        self.listController.willSwipeDownDismiss(duration);
    }
    [UIView animateWithDuration:duration animations:^{
        self.listController.view.top = self.listController.parentViewController.view.height;
    } completion:^(BOOL finished) {
        if (self.listController.didSwipeDownDismiss) {
            self.listController.didSwipeDownDismiss();
        }
        self.tableView.userInteractionEnabled = true;
    }];
    [self.tableView.mj_footer resetNoMoreData];
    
    [self addHouseListDurationLog];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat minTop =  [self.listController minTop];
    if ([self.listController canMoveup]) {
        [self.listController moveTop:(self.tableView.superview.top - scrollView.contentOffset.y)];
        scrollView.contentOffset = CGPointZero;
    }else if (scrollView.contentOffset.y < 0){
        [self.listController moveTop:(self.tableView.superview.top - scrollView.contentOffset.y)];
        scrollView.contentOffset = CGPointZero;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.listController.view.top > self.listController.view.height*0.6) {
        [self handleDismiss:0.3];
    }else if(self.listController.view.top - [self.listController minTop] < 50){
        //吸附都顶部
        [self.listController moveTop:0];
        [self addEnterListPageLog];
    }else if([self.listController canMoveup]){
        //当前停留在中间
        self.listController.moveDock();
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y < -2.5) {
        //quickly swipe done
        [self handleDismiss:0.1];
    }
}

-(void)loadMoreData
{
    /*
     "exclude_id[]=\(self.houseId ?? "")&exclude_id[]=\(self.neighborhoodId)&neighborhood_id=\(self.neighborhoodId)&house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" +
     */
    if (self.requestTask.state == TTHttpTaskStateRunning) {
        [self.requestTask cancel];
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    if (self.neighbor.nid) {
        param[NEIGHBORHOOD_ID_KEY] = self.neighbor.nid;
    }
    param[HOUSE_TYPE_KEY] = @(self.configModel.houseType);
    if (self.searchId) {
        param[@"search_id"] = self.searchId;
    }
    if (self.configModel.suggestionParams) {
        param[SUGGESTION_PARAMS_KEY] = self.configModel.suggestionParams;
    }
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher houseSearchWithQuery:self.configModel.conditionQuery param:param offset:self.houseList.count needCommonParams:YES callback:^(NSError * _Nullable error, FHSearchHouseDataModel * _Nullable houseModel) {
        if (!wself) {
            return ;
        }
        
        if (!error && houseModel) {
            [wself.houseList addObjectsFromArray:houseModel.items];
            [wself.tableView reloadData];
            if (houseModel.hasMore) {
                [wself.tableView.mj_footer endRefreshing];
            }else{
                [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            //TODO: show error toast
        }
        
    }];
    
    self.requestTask = task;
    
    [self addHouseListLoadMoreLog];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self addHouseListDurationLog];
}

#pragma mark - log

-(NSMutableDictionary *)logBaseParams
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[@"enter_from"] = @"mapfind";
    param[@"category_name"] = @"same_neighborhood_list";
    param[@"element_from"] = @"half_category";
    param[@"search_id"] = self.searchId?:@"be_null";
    param[@"origin_from"] = self.configModel.originFrom?:@"be_null";
    param[@"origin_search_id"] = self.configModel.originSearchId ?: @"be_null";
 
    return param;
}

-(void)addEnterListPageLog
{
    NSMutableDictionary *param = [self logBaseParams];
    param[@"category_name"] = @"same_neighborhood_list";
    param[@"enter_type"] = @"slide_up";
    if (self.neighbor.logPb) {
        param[@"log_pb"] = [self.neighbor.logPb toDictionary];
    }
    
    [EnvContext.shared.tracer writeEvent:@"enter_category" params:param];
}

-(void)addHouseListDurationLog
{
    NSTimeInterval duration = [[NSDate date]timeIntervalSince1970] - _startTimestamp;
    if (duration < 0.5 || duration > 60*60) {
        //invalid log
        return;
    }
    
    NSMutableDictionary *param = [self logBaseParams];
    param[@"stay_time"] = @(duration*1000);
    if (self.neighbor.logPb) {
        param[@"log_pb"] = [self.neighbor.logPb toDictionary];
    }
    param[@"enter_type"] = @"slide_up";

    [EnvContext.shared.tracer writeEvent:@"stay_category" params:param];
    _startTimestamp = 0;
}

-(void)addHouseListLoadMoreLog
{
   NSMutableDictionary *param = [self logBaseParams];
    param[@"refresh_type"] = @"pre_load_more";
    param[@"enter_type"] = @"slide_up";
    [EnvContext.shared.tracer writeEvent:@"category_refresh" params:param];
}

-(void)addNeighborShowLog:(FHMapSearchDataListModel *)neighbor
{
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"house_type"] = @"neighborhood";
    param[@"page_type"] = @"mapfind";
    param[@"card_type"] = @"no_pic";
    param[@"element_type"] = @"half_category";
    param[@"group_id"] = neighbor.logPb.groupId ?: @"be_null";
    param[@"impr_id"] = neighbor.logPb.imprId ?: @"be_null";
    param[@"rank"] = @"0";
    if (neighbor.logPb) {
        param[@"log_pb"] = [neighbor.logPb toDictionary];
    }
    
    [EnvContext.shared.tracer writeEvent:@"house_show" params:param];
}

-(void)addShowNeighborDetailLog:(FHMapSearchDataListModel *)neighbor
{
    
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"house_type"] = @"old";
    param[@"page_type"] = @"neighborhood_detail";
    param[@"card_type"] = @"no_pic";
    param[@"group_id"] = neighbor.logPb.groupId ?: @"be_null";
    param[@"impr_id"] = neighbor.logPb.imprId ?: @"be_null";
    param[@"rank"] = @"0";
    if (neighbor.logPb) {
        param[@"log_pb"] = [neighbor.logPb toDictionary];
    }
    
    [EnvContext.shared.tracer writeEvent:@"go_detail" params:param];
}



-(void)addHouseShowLog:(NSIndexPath *)indexPath
{
    FHSearchHouseDataItemsModel *item = _houseList[indexPath.row];
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"house_type"] = @"old";
    param[@"page_type"] = @"mapfind";
    param[@"card_type"] = @"left_pic";
    param[@"group_id"] = item.logPb.groupId ?: @"be_null";
    param[@"impr_id"] = item.imprId ?: @"be_null";
    param[@"rank"] = @(indexPath.row);
    param[@"log_pb"] = [item.logPb toDictionary];
    
    if (item.logPb) {
        param[@"log_pb"] = [item.logPb toDictionary];
    }
    
    
    [EnvContext.shared.tracer writeEvent:@"house_show" params:param];
}

-(void)addHouseDetailShowLog:(NSIndexPath *)indexPath
{
    FHSearchHouseDataItemsModel *item = _houseList[indexPath.row];
    
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"house_type"] = @"old";
    param[@"page_type"] = @"old_detail";
    param[@"card_type"] = @"left_pic";
    param[@"group_id"] = item.logPb.groupId ?: @"be_null";
    param[@"impr_id"] = item.imprId ?: @"be_null";
    param[@"rank"] = @(indexPath.row);
    
    if (item.logPb) {
        param[@"log_pb"] = [item.logPb toDictionary];
    }
    
    [EnvContext.shared.tracer writeEvent:@"go_detail" params:param];
}


@end
