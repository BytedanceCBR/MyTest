//
//  FHPersonalHomePageFeedListViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageFeedListViewModel.h"
#import "FHPersonalHomePageViewModel.h"
#import "FHPersonalHomePageManager.h"
#import "UIScrollView+Refresh.h"
#import "FHRefreshCustomFooter.h"
#import "FHUGCCellManager.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseCell.h"
#import "TTHttpTask.h"
#import "TTReachability.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import "ToastManager.h"
        


@interface FHPersonalHomePageFeedListViewModel () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property(nonatomic,weak) FHPersonalHomePageFeedListViewController *viewController;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) FHUGCCellManager *cellManager;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property(nonatomic,copy) NSString *categoryId;
@property(nonatomic,strong) NSMutableArray *dataList;
@end

@implementation FHPersonalHomePageFeedListViewModel


-(instancetype)initWithController:(FHPersonalHomePageFeedListViewController *)viewController tableView:(UITableView *)tableView {
    if(self = [super init]) {
        _viewController = viewController;
        _tableView = tableView;
        _dataList = [NSMutableArray array];
        [self configTableView];
    }
    return self;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:self.tableView];
    
    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        [self requestData:NO first:NO];
    }];
    self.refreshFooter.hidden = YES;
    self.tableView.mj_footer = self.refreshFooter;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    
    if (![TTReachability isNetworkConnected] && isFirst) {
        [self showErrorViewNoNetWork];
        return;
    }

    if (self.requestTask) {
        [self.requestTask cancel];
        self.viewController.isLoadingData = NO;
    }
    
    if(self.viewController.isLoadingData){
        return;
    }
    self.viewController.isLoadingData = YES;
    
    if (isFirst) {
        [[FHPersonalHomePageManager shareInstance].viewController startLoading];
    }
    
    NSInteger listCount = self.dataList.count;
    
    if(isFirst){
        listCount = 0;
    }
    
    double behotTime = 0;
    if(!isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList lastObject];
        behotTime = [cellModel.behotTime doubleValue];
    }
    if(isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList firstObject];
        behotTime = [cellModel.behotTime doubleValue];
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"user_id"] = [FHPersonalHomePageManager shareInstance].userId;
    extraDic[@"tab_name"] = self.viewController.tabName;
    self.categoryId = @"f_user_profile";
    
    WeakSelf;
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        self.viewController.isLoadingData = NO;
        [[FHPersonalHomePageManager shareInstance].viewController endLoading];
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        self.feedListModel = feedListModel;

        if (error) {
            if(isFirst){
                [self showErrorViewNoNetWork];
            }else{
                [self loadMoreError];
            }
            return;
        }
        
        if(model){
            NSArray *resultArr = [self convertModel:feedListModel.data];
            if(isHead){
                [self.dataList removeAllObjects];
                [self.dataList addObjectsFromArray:resultArr];
            }else{
                [self.dataList addObjectsFromArray:resultArr];
            }
            self.tableView.hasMore = feedListModel.hasMore;
            [self reloadTableViewDataWithHasMore:feedListModel.hasMore];
        }
    }];
}

- (NSArray *)convertModel:(NSArray *)feedList{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.isHiddenConnectBtn = YES;
        cellModel.isInRealtorEvaluationList = YES;
        cellModel.categoryId = self.categoryId;
        cellModel.tableView = self.tableView;
        cellModel.enterFrom = [self.viewController categoryName];
        cellModel.isShowLineView = NO;
//        cellModel.tracerDic = self.tracerDic;
        switch (cellModel.cellType) {
            case FHUGCFeedListCellTypeUGC:
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerImage;
                break;
            case FHUGCFeedListCellTypeUGCSmallVideo:
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerVideo;
                break;
            default:
                break;
        }
//        cellModel.tracerDic = self.tracerDic;
        if (cellModel) {
            [resultArray addObject:cellModel];
        }
    }
    return resultArray;
}


- (void)showErrorViewNoNetWork {
    [self setFeedError:YES];
    [self.viewController.emptyView showEmptyWithTip:@"网络异常" errorImageName:kFHErrorMaskNoNetWorkImageName showRetry:YES];
    self.refreshFooter.hidden = YES;
    [self.tableView reloadData];
}

- (void)loadMoreError {
    [[ToastManager manager] showToast:@"网络异常"];
    self.refreshFooter.hidden = NO;
    [self.tableView.mj_footer endRefreshing];
//    [self.refreshFooter setUpNoMoreDataText:@"- 没有更多数据了 -" offsetY:-3];
//    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}


- (void)reloadTableViewDataWithHasMore:(BOOL)hasMore {
    if(self.dataList.count > 0){
        [self.viewController.emptyView hideEmptyView];
        self.tableView.backgroundColor = [UIColor themeGray7];

        self.tableView.mj_footer.hidden = NO;
        if (hasMore) {
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.refreshFooter setUpNoMoreDataText:@"- 我是有底线的哟 -" offsetY:-3];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [self setFeedError:NO];
    }else{
        [self.viewController.emptyView showEmptyWithTip:@"暂无内容" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        self.refreshFooter.hidden = YES;
        [self setFeedError:YES];
    }
    [self.tableView reloadData];
}

#pragma mark TableView protocol

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.dataList.count) {
        FHFeedUGCCellModel *cellModel = self.dataList[index];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        [cell refreshWithData:cellModel];
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.dataList.count) {
        FHFeedUGCCellModel *cellModel = self.dataList[index];
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

-(void)setFeedError:(BOOL)isError {
    NSMutableArray *feedErrorArray =  [FHPersonalHomePageManager shareInstance].feedErrorArray;
    NSInteger index = self.viewController.index;
    if(index >= 0 && index < feedErrorArray.count){
        feedErrorArray[index] = @(isError);
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[FHPersonalHomePageManager shareInstance] tableViewScroll:scrollView];
}

@end
