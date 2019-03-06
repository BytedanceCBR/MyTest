//
//  FHTransactionHistoryViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/20.
//

#import "FHTransactionHistoryViewModel.h"
#import <TTRoute.h>
#import <TTHttpTask.h>
#import "FHTransactionHistoryCell.h"
#import "FHHouseDetailAPI.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import <UIScrollView+Refresh.h>
#import "FHUserTracker.h"
#import "FHTransactionHistoryModel.h"
#import "FHRefreshCustomFooter.h"

#define kCellId @"cell_id"

@interface FHTransactionHistoryViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHTransactionHistoryController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, copy) NSString *neighborhoodId;
@property(nonatomic, assign) NSInteger page;
@property(nonatomic, copy) NSString *searchId;
@property(nonatomic, assign) NSInteger limit;
@property(nonatomic, assign) BOOL showPlaceHolder;
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;

@end

@implementation FHTransactionHistoryViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHTransactionHistoryController *)viewController neighborhoodId:(nonnull NSString *)neighborhoodId
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _limit = 15;
        _neighborhoodId = neighborhoodId;
        _tableView = tableView;
        _showPlaceHolder = YES;
        _isFirstLoad = YES;
        
        [tableView registerClass:[FHTransactionHistoryCell class] forCellReuseIdentifier:kCellId];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [weakSelf requestData:NO];
        }];
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
        self.tableView.mj_footer = self.refreshFooter;
        
        self.viewController = viewController;
        
    }
    return self;
}

- (void)requestData:(BOOL)isHead {
    [self.requestTask cancel];
    
    if(isHead){
        self.page = 0;
        self.searchId = nil;
        [self.dataList removeAllObjects];
        [self.clientShowDict removeAllObjects];
    }
    
    if(self.isFirstLoad){
        [self.viewController tt_startUpdate];
    }
    
    __weak typeof(self) wself = self;
    
    self.requestTask = [FHHouseDetailAPI requestNeighborhoodTransactionHistoryByNeighborhoodId:self.neighborhoodId searchId:self.searchId page:self.page count:15 completion:^(FHTransactionHistoryModel * _Nullable model, NSError * _Nullable error) {
        
        if(wself.isFirstLoad){
            [wself.viewController tt_endUpdataData];
        }
        
        [wself.tableView.mj_footer endRefreshing];
        
        if (!wself) {
            return;
        }
        
        if (error && wself.dataList.count == 0) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }
        
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
        
            wself.tableView.hasMore = model.data.hasMore;
            wself.viewController.hasValidateData = self.dataList.count > 0;
            [wself.dataList addObjectsFromArray:model.data.list];
            wself.page++;
            [wself updateTableViewWithMoreData:model.data.hasMore];
            
            if(!model.data.hasMore && wself.dataList.count < 10)
            {
                wself.tableView.mj_footer.hidden = YES;
            }
            
            if(wself.dataList.count > 0){
                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
                [wself.viewController.emptyView showEmptyWithTip:@"暂无小区成交历史" errorImageName:@"group-9" showRetry:NO];
            }
            
            if(wself.isFirstLoad){
                wself.isFirstLoad = NO;
                [wself addEnterCategoryLog];
            }
            
            if(!isHead){
                [wself trackRefresh];
            }
        }
    }];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_category", tracerDict);
}

- (NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = self.viewController.tracerDict.mutableCopy;
    tracerDict[@"search_id"] = self.searchId ? self.searchId : @"be_null";
    return tracerDict;
}

- (NSString *)categoryName {
    NSString *categoryName = @"neighborhood_trade_list";
    return categoryName;
}

//列表页刷新 埋点
- (void)trackRefresh {
    NSMutableDictionary *dict = [[self categoryLogDict] mutableCopy];
    dict[@"refresh_type"] = @"pre_load_more";
    dict[@"search_id"] = self.searchId ? self.searchId : @"be_null";
    TRACK_EVENT(@"category_refresh", dict);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHTransactionHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    BOOL isLast = (indexPath.row == self.dataList.count - 1);
    
    if (indexPath.row < self.dataList.count) {
        FHDetailNeighborhoodDataTotalSalesListModel *model = self.dataList[indexPath.row];
        [cell updateWithModel:model];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

@end
