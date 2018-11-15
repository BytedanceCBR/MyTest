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
#import "UIViewController+HUD.h"


#define kCellId @"singleCellId"

@interface FHMapSearchHouseListViewModel ()

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHMapSearchDataListModel *neighbor;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) NIHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSTimeInterval startTimestamp;
@property(nonatomic , weak)   TTHttpTask * requestTask;
@property(nonatomic , assign) BOOL enteredFullListPage;
@property(nonatomic , assign) CGPoint currentOffset;
@property(nonatomic , assign) BOOL dismissing;
@property(nonatomic , strong) FHMapSearchDataListModel *currentNeighbor;

@end

@implementation FHMapSearchHouseListViewModel

-(instancetype)initWithController:(FHMapSearchHouseListViewController *)viewController tableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        self.listController = viewController;
        self.tableView = tableView;
        
        [self configTableView];
        
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [NIHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadHouseData:NO];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [_tableView registerClass:SingleImageInfoCell.class forCellReuseIdentifier:kCellId];
}

-(void)setHeaderView:(FHHouseAreaHeaderView *)headerView
{
    _headerView = headerView;
    _tableView.tableHeaderView = _headerView;
    [headerView addTarget:self action:@selector(showNeighborDetail) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setMaskView:(FHErrorMaskView *)maskView
{
    _maskView = maskView;
    maskView.hidden = YES;
    __weak typeof(self) wself = self;
    _maskView.retryBlock = ^{
        [wself reloadingHouseData];
    };
}

-(void)updateWithHouseData:(FHSearchHouseDataModel *_Nullable)data neighbor:(FHMapSearchDataListModel *)neighbor
{
    if (self.requestTask.state == TTHttpTaskStateRunning) {
        [self.requestTask cancel];
    }
    self.currentNeighbor = neighbor;
    [_headerView updateWithMode:neighbor];
    
    [_houseList removeAllObjects];
    self.neighbor = neighbor;
    if (data) {
        [_houseList addObjectsFromArray:data.items];
        self.searchId = data.searchId;
        if (data.hasMore) {
            [self.tableView.mj_footer resetNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    } else {
        self.searchId = nil;
        [self reloadingHouseData];
    }
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
    
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
    if (neighbor) {
        [self addNeighborShowLog:self.neighbor];
    }
    
    _maskView.hidden = YES;
    [self addEnterListPageLog];
}

-(void)showNeighborDetail
{
    if (self.listController.showNeighborhoodDetailBlock) {
//        [self addShowNeighborDetailLog:self.neighbor];
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
    if (indexPath.row == self.houseList.count -1) {
        return 125;
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
    FHSearchHouseDataItemsModel *model = _houseList[indexPath.row];
    if (self.listController.showHouseDetailBlock) {
        self.listController.showHouseDetailBlock(model,indexPath.row);
    }
}

-(void)dismiss
{
    [self handleDismiss:0.3];
}

-(void)handleDismiss:(CGFloat)duration
{
    if (_dismissing) {
        return;
    }
    self.dismissing = YES;
    self.tableView.scrollEnabled = false;
    if (self.listController.willSwipeDownDismiss) {
        self.listController.willSwipeDownDismiss(duration);
    }
    [UIView animateWithDuration:duration animations:^{
        self.listController.view.top = self.listController.parentViewController.view.height;
    } completion:^(BOOL finished) {
        if (self.listController.didSwipeDownDismiss) {
            self.listController.didSwipeDownDismiss();
        }
        self.tableView.scrollEnabled = true;
        self.dismissing = NO;
    }];
    [self.tableView.mj_footer resetNoMoreData];
    
    [self addHouseListDurationLog];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.scrollEnabled) {
        //不是用户主动滑动
        scrollView.contentOffset = CGPointZero;
        return;
    }
    
    CGFloat minTop =  [self.listController minTop];
    if ([self.listController canMoveup]) {
        [self.listController moveTop:(self.tableView.superview.top - scrollView.contentOffset.y)];
        scrollView.contentOffset = CGPointZero;
        //PM 要求不能一下滑上去
        if (fabs(self.listController.view.top - [self.listController minTop]) < 0.2) {
            scrollView.scrollEnabled = NO;
            [self.headerView hideTopTip:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                scrollView.scrollEnabled = YES;
            });
        }
    }else if (scrollView.contentOffset.y < 0){
        [self.listController moveTop:(self.tableView.superview.top - scrollView.contentOffset.y)];
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
    if (self.listController.view.top > self.listController.view.height*0.6) {
        [self handleDismiss:0.3];
    }else if((self.listController.view.top > [self.listController minTop]) && (self.listController.view.top - [self.listController minTop]  < 50)){
        //吸附都顶部
        [self.headerView hideTopTip:YES];
        [self.listController moveTop:0];
//        [self addEnterListPageLog];
    }else if((self.listController.view.top > [self.listController minTop]) ){//&& (self.listController.view.top < self.listController.view.height*0.7)
        [self.headerView hideTopTip:NO];
        [self.listController moveTop:[self.listController initialTop]];
        self.listController.moveDock();
//        [self addHouseListDurationLog];
    }
//    else if([self.listController canMoveup]){
//        //当前停留在中间
//        [self.headerView hideTopTip:NO];
//        self.listController.moveDock();
//        [self addHouseListDurationLog];
//    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.contentOffset.y < 1 && (self.listController.view.top > [self.listController minTop]) && velocity.y < -2.5) {
        //quickly swipe done
        [self handleDismiss:0.1];
    }
    if (scrollView.contentOffset.y > 50 && velocity.y < -2) {
        *targetContentOffset =  CGPointMake(0, 0.5);
    }
}

-(void)reloadingHouseData
{
    CGPoint offset = CGPointMake(0, -(self.listController.view.bottom - self.listController.view.superview.height));
    [self.listController showLoadingAlert:nil offset:offset];
    [self.houseList removeAllObjects];
    [self.tableView reloadData];
    [self loadHouseData:YES];
    self.tableView.mj_footer.hidden = YES;
}

-(void)loadHouseData:(BOOL)showLoading
{
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
//    if (self.configModel.suggestionParams) {
//        param[SUGGESTION_PARAMS_KEY] = self.configModel.suggestionParams;
//    }
    
    if (showLoading) {
        self.tableView.scrollEnabled = NO;
    }
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher houseSearchWithQuery:self.configModel.conditionQuery param:param offset:self.houseList.count needCommonParams:YES callback:^(NSError * _Nullable error, FHSearchHouseDataModel * _Nullable houseModel) {
        
        if (!wself) {
            return ;
        }
        if (showLoading) {
            [wself.listController dismissLoadingAlert];
        }
                        
        if (!error && houseModel) {
            wself.searchId = houseModel.searchId;
            if (showLoading) {
                [wself addHouseListShowLog:wself.neighbor houseListModel:houseModel];
            }
            
            if (wself.houseList.count == 0) {
                //first page
                wself.currentNeighbor.onSaleCount = houseModel.total;
                [wself.headerView updateWithMode:wself.currentNeighbor];
                
                NSString *toast = [NSString stringWithFormat:@"共找到%@套房源",houseModel.total];
                [[[EnvContext shared] toast] showToast:toast duration:1];
            }
            
            [wself.houseList addObjectsFromArray:houseModel.items];
            [wself.tableView reloadData];
            if (houseModel.hasMore) {
                [wself.tableView.mj_footer endRefreshing];
            }else{
                [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            wself.tableView.mj_footer.hidden = NO;
            wself.tableView.scrollEnabled = YES;
        
            if (wself.houseList.count == 0) {
                //没有数据 提示数据走丢了
                [wself.maskView showErrorWithTip:@"数据走丢了"];
                wself.maskView.hidden = false;
            }
            
        }else{
            if (error) {
                [wself.maskView showErrorWithTip:@"网络异常"];
                wself.maskView.hidden = false;
            }else{
                wself.maskView.hidden = true;
            }
        }
    }];
    
    self.requestTask = task;
    if (!showLoading) {
        [self addHouseListLoadMoreLog];
    }
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
    if (_enteredFullListPage) {
        return;
    }
    _enteredFullListPage = YES;
    NSMutableDictionary *param = [self logBaseParams];
    param[@"category_name"] = @"same_neighborhood_list";
    param[@"enter_type"] = @"slide_up";
    
    [EnvContext.shared.tracer writeEvent:@"enter_category" params:param];
}

-(void)addHouseListDurationLog
{
    if (!_enteredFullListPage) {
        return;
    }
    _enteredFullListPage = NO;
    
    NSTimeInterval duration = [[NSDate date]timeIntervalSince1970] - _startTimestamp;
    if (duration < 0.5 || duration > 60*60) {
        //invalid log
        return;
    }
    
    NSMutableDictionary *param = [self logBaseParams];
    param[@"stay_time"] = @(duration*1000);

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
    param[@"search_id"] = neighbor.logPb.searchId ?: @"be_null";
    param[@"rank"] = @"0";
    if (neighbor.logPb) {
        param[@"log_pb"] = [neighbor.logPb toDictionary];
    }
    
    [EnvContext.shared.tracer writeEvent:@"house_show" params:param];
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
    if ([self.listController canMoveup]) {
        param[@"element_type"] = @"half_category";
    }else{
        param[@"element_type"] = @"be_null";
    }
    
    if (item.logPb) {
        param[@"log_pb"] = [item.logPb toDictionary];
    }
        
    [EnvContext.shared.tracer writeEvent:@"house_show" params:param];
}

-(void)addHouseListShowLog:(FHMapSearchDataListModel*)model houseListModel:(FHSearchHouseDataModel *)houseDataModel
{
    NSMutableDictionary *param = [self logBaseParams];
    param[@"search_id"] = houseDataModel.searchId;
    param[@"enter_from"] = @"old_list";
    [EnvContext.shared.tracer writeEvent:@"mapfind_half_category" params:param];
}

@end
