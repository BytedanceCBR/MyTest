//
//  FHPersonalHomePageFeedListViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageFeedListViewModel.h"
#import "FHPersonalHomePageViewModel.h"
#import "FHPersonalHomePageManager.h"
#import "FHUGCFeedDetailJumpManager.h"
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
#import "FHUserTracker.h"
#import "FHCommonDefines.h"
#import "FHUtils.h"
        


@interface FHPersonalHomePageFeedListViewModel () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,FHUGCBaseCellDelegate>
@property(nonatomic,weak) FHPersonalHomePageFeedListViewController *viewController;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) FHUGCCellManager *cellManager;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property(nonatomic,copy) NSString *categoryId;
@property(nonatomic,strong) NSMutableArray *dataList;
@property(nonatomic,assign) BOOL isFeedError;
@end

@implementation FHPersonalHomePageFeedListViewModel


-(instancetype)initWithController:(FHPersonalHomePageFeedListViewController *)viewController tableView:(UITableView *)tableView {
    if(self = [super init]) {
        _viewController = viewController;
        _tableView = tableView;
        _dataList = [NSMutableArray array];
        _detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        _detailJumpManager.refer = 1;
        _isFeedError = NO;
        [self configTableView];
    }
    return self;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"error_cell"];

    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        [self requestData:NO first:NO];
    }];
    self.emptyView.retryBlock = ^{
        StrongSelf;
        self.isFeedError = NO;
        [self.tableView reloadData];
        [self.viewController retryLoadData];
    };
    
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
        [self.homePageManager.viewController startLoading];
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
    extraDic[@"user_id"] = self.homePageManager.userId;
    extraDic[@"tab_name"] = self.viewController.tabName;
    self.categoryId = @"f_user_profile";
    
    WeakSelf;
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        self.viewController.isLoadingData = NO;
        [self.homePageManager.viewController endLoading];
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



- (void)showErrorViewNoNetWork {
    self.isFeedError = YES;
    [self setupEmptyView];
    [self.emptyView showEmptyWithTip:@"网络异常" errorImageName:kFHErrorMaskNoNetWorkImageName showRetry:YES];
    self.tableView.backgroundColor = [UIColor themeWhite];
    self.refreshFooter.hidden = YES;
    [self.tableView reloadData];
}

- (void)loadMoreError {
    [[ToastManager manager] showToast:@"网络异常"];
    self.refreshFooter.hidden = NO;
    [self.tableView.mj_footer endRefreshing];
}


- (void)reloadTableViewDataWithHasMore:(BOOL)hasMore {
    if(self.dataList.count > 0){
        [self.emptyView hideEmptyView];
        self.tableView.backgroundColor = [UIColor themeGray7];

        self.tableView.mj_footer.hidden = NO;
        if (hasMore) {
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.refreshFooter setUpNoMoreDataText:@"- 没有更多信息了 -" offsetY:-3];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.homePageManager refreshScrollStatus];
        self.isFeedError = NO;
    }else{
        self.tableView.backgroundColor = [UIColor themeWhite];
        [self setupEmptyView];
        [self.emptyView showEmptyWithTip:@"网络异常" errorImageName:kFHErrorMaskNoNetWorkImageName showRetry:YES];
        self.refreshFooter.hidden = YES;
        self.isFeedError = YES;
    }
    [self.tableView reloadData];
}

- (FHErrorView *)emptyView {
    if(!_emptyView) {
        _emptyView = [[FHErrorView alloc] init];
        _emptyView.hidden = YES;
    }
    return _emptyView;
}

- (void)setupEmptyView {
    CGFloat tablistHeight = self.homePageManager.feedViewController.headerView.hidden ? 0 : 44;
    CGFloat height = (SCREEN_HEIGHT -  self.homePageManager.viewController.profileInfoView.viewHeight + tablistHeight);
    self.emptyView.hidden = NO;
    self.emptyView.frame = CGRectMake(0,0,SCREEN_WIDTH ,height);
}

#pragma mark UGC

- (NSArray *)convertModel:(NSArray *)feedList {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.categoryId = self.categoryId;
        cellModel.tableView = self.tableView;
        cellModel.enterFrom = [self.viewController categoryName];
        cellModel.tracerDic = self.homePageManager.tracerDict;
        
        if (cellModel) {
            [resultArray addObject:cellModel];
        }
    }
    return resultArray;
}


- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.detailJumpManager.currentCell = cell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}


- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    [self.detailJumpManager goToCommunityDetail:cellModel];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self lookAllLinkClicked:cellModel cell:nil];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.detailJumpManager.currentCell = cell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}


#pragma mark TableView protocol

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isFeedError) {
        return 1;
    }
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isFeedError) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"error_cell"];
        if(!cell) {
            cell = [[UITableViewCell alloc] init];
        }
        cell.contentView.backgroundColor = [UIColor themeWhite];
        [cell.contentView addSubview:self.emptyView];
        return cell;
    }
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
    if(self.isFeedError) {
        return CGRectGetHeight(self.tableView.frame);
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isFeedError) {
        return;
    }
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.dataList.count) {
        FHFeedUGCCellModel *cellModel = self.dataList[index];
        self.detailJumpManager.currentCell = [tableView cellForRowAtIndexPath:indexPath];
        [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.homePageManager tableViewScroll:scrollView];
}

@end
