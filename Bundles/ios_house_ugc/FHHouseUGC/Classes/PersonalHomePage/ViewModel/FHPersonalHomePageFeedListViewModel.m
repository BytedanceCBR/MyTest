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
#import "TTAccountManager.h"
#import "FHCommonDefines.h"
#import "FHUGCConfig.h"
#import "FHUtils.h"
#import "FHHouseRealtorDetailPlaceHolderCell.h"
        

typedef NS_ENUM(NSInteger,FHPersonalHomePageFeedListType){
    FHPersonalHomePageFeedListTypeDefault,
    FHPersonalHomePageFeedListTypeError,
    FHPersonalHomePageFeedListTypeNoFeed,
};

@interface FHPersonalHomePageFeedListErrorItemModel: NSObject
@property(nonatomic,assign) FHPersonalHomePageFeedListType feedType;
@end

@implementation FHPersonalHomePageFeedListErrorItemModel
@end

@interface FHPersonalHomePageFeedListViewModel () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,FHUGCBaseCellDelegate>
@property(nonatomic,weak) FHPersonalHomePageFeedListViewController *viewController;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) FHUGCCellManager *cellManager;
@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
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
        self.showPlaceHolder = YES;
        _dataList = [NSMutableArray array];
        _detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        _detailJumpManager.refer = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCDelPostNotification object:nil];
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
    [self.tableView registerClass:[FHHouseRealtorDetailPlaceHolderCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailPlaceHolderCell"];

    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        [self requestData:NO first:NO];
    }];
    self.emptyView.retryBlock = ^{
        StrongSelf;
        self.showPlaceHolder = YES;
        [self.dataList removeAllObjects];
        [self.tableView reloadData];
        [self.viewController retryLoadData];
    };
    
    self.refreshFooter.hidden = YES;
    self.tableView.mj_footer = self.refreshFooter;
    self.tableView.hasMore = NO;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    
    if (![TTReachability isNetworkConnected] && isFirst) {
        self.showPlaceHolder = NO;
        [self.tableView reloadData];
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
    }
    
    NSInteger listCount = self.dataList.count;
    
    if(isFirst){
        listCount = 0;
    }
    
    double behotTime = 0;
    NSString *lastGroupId = nil;
    if(!isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList lastObject];
        behotTime = [cellModel.behotTime doubleValue];
        lastGroupId = cellModel.groupId;
    }

    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"user_id"] = self.homePageManager.userId;
    extraDic[@"tab_name"] = self.viewController.tabName;
    extraDic[@"last_group_id"] = lastGroupId;
    self.categoryId = @"f_user_profile";
    
    WeakSelf;
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        self.viewController.isLoadingData = NO;
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        self.feedListModel = feedListModel;

        if (error) {
            self.showPlaceHolder = NO;
            [self.tableView reloadData];
            if(isFirst){
                [self showErrorViewNoNetWork];
            }else{
                [self loadMoreError];
            }
            return;
        }
        
        if(model){
            self.showPlaceHolder = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray *resultArr = [self convertModel:feedListModel.data isHead:isHead];
                if(isHead){
                    [self.dataList removeAllObjects];
                    [self.dataList addObjectsFromArray:resultArr];
                }else{
                    [self.dataList addObjectsFromArray:resultArr];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tableView.hasMore = feedListModel.hasMore;
                    [self reloadTableViewDataWithHasMore:feedListModel.hasMore];
                });
            });
        }else {
            self.showPlaceHolder = NO;
            [self reloadTableViewDataWithHasMore:feedListModel.hasMore];
        }
    }];
}



- (void)showErrorViewNoNetWork {
    self.tableView.backgroundColor = [UIColor themeWhite];
    self.refreshFooter.hidden = YES;
    [self setupEmptyView];
    FHPersonalHomePageFeedListErrorItemModel *item = [[FHPersonalHomePageFeedListErrorItemModel alloc] init];
    item.feedType = FHPersonalHomePageFeedListTypeError;
    [self.dataList addObject:item];
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
    }else{
        self.tableView.backgroundColor = [UIColor themeWhite];
        self.refreshFooter.hidden = YES;
        [self setupEmptyView];
        FHPersonalHomePageFeedListErrorItemModel *item = [[FHPersonalHomePageFeedListErrorItemModel alloc] init];
        item.feedType = FHPersonalHomePageFeedListTypeNoFeed;
        [self.dataList addObject:item];
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

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead  {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.categoryId = self.categoryId;
        cellModel.tableView = self.tableView;
        cellModel.enterFrom = [self.viewController categoryName];
        cellModel.tracerDic = self.homePageManager.tracerDict;
        
        if(cellModel){
            if(isHead){
                [resultArray addObject:cellModel];
                //去重逻辑
                [self removeDuplicaionModel:cellModel.groupId];
            }else{
                NSInteger index = [self getCellIndex:cellModel];
                if(index < 0){
                    [resultArray addObject:cellModel];
                }
            }
        }
    }
    return resultArray;
}

- (void)removeDuplicaionModel:(NSString *)groupId {
    for (FHFeedUGCCellModel *itemModel in self.dataList) {
        if([groupId isEqualToString:itemModel.groupId]){
            [self.dataList removeObject:itemModel];
            break;
        }
    }
}


- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.detailJumpManager.currentCell = cell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}


- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    [self.detailJumpManager goToCommunityDetail:cellModel];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    
    dict[TRACER_KEY] = traceParam;
    
    if (url) {
        BOOL isOpen = YES;
        if ([url.absoluteString containsString:@"concern"]) {
            // 话题
            traceParam[@"enter_from"] = @"personal_homepage_detail";
            traceParam[@"enter_type"] = @"click";
            traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
            traceParam[@"log_pb"] = cellModel.logPb;
        }
        else if([url.absoluteString containsString:@"profile"]) {
            // JOKER:
        }
        else if([url.absoluteString containsString:@"webview"]) {
            
        }
        else {
            isOpen = NO;
        }
        
        if(isOpen) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.detailJumpManager.currentCell = cell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)postDeleteSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        [self deleteCell:cellModel];
    }
}

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row >= 0 && row < self.dataList.count){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.dataList removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if(self.dataList.count == 0) {
            self.refreshFooter.hidden = YES;
            if(self.tableView.hasMore) {
                [self requestData:YES first:YES];
            } else {
                [self setupEmptyView];
                FHPersonalHomePageFeedListErrorItemModel *item = [[FHPersonalHomePageFeedListErrorItemModel alloc] init];
                item.feedType = FHPersonalHomePageFeedListTypeNoFeed;
                [self.dataList addObject:item];
                self.tableView.backgroundColor = [UIColor whiteColor];
                [self.tableView reloadData];
            }
        }
    }
}

- (NSInteger)getCellIndex:(FHFeedUGCCellModel *)cellModel {
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        FHFeedUGCCellModel *model = self.dataList[i];
        if([model.groupId isEqualToString:cellModel.groupId]){
            return i;
        }
    }
    return -1;
}

#pragma mark TableView protocol

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showPlaceHolder) {
        return 10;
    }
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showPlaceHolder) {
        NSString *identifier = @"FHHouseRealtorDetailPlaceHolderCell";
        FHHouseRealtorDetailPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.placeHolderImageName = @"personal_page_place";
        [cell setPersolanPage];
        [cell.contentView setBackgroundColor:[UIColor colorWithHexStr:@"#f8f8f8"]];
        return cell;
    }
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.dataList.count) {
        id model = self.dataList[index];
        if([model isKindOfClass:[FHPersonalHomePageFeedListErrorItemModel class]]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"error_cell"];
            if(!cell) {
                cell = [[UITableViewCell alloc] init];
            }
            FHPersonalHomePageFeedListErrorItemModel *item = (FHPersonalHomePageFeedListErrorItemModel *)model;
            if(item.feedType == FHPersonalHomePageFeedListTypeError) {
                [self.emptyView showEmptyWithTip:@"网络异常" errorImageName:kFHErrorMaskNoNetWorkImageName showRetry:YES];
            } else if(item.feedType == FHPersonalHomePageFeedListTypeNoFeed){
                NSString *emptyTip = [[TTAccountManager userID] isEqualToString:self.homePageManager.userId] ? @"你还没有发布任何内容，快去发布吧" :@"TA没有留下任何足迹，去其他地方看看吧！";
                [self.emptyView showEmptyWithTip:emptyTip errorImageName:@"fh_ugc_home_page_no_auth" showRetry:NO];
            }
            UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
            selectedBackgroundView.backgroundColor = [UIColor themeWhite];
            cell.selectedBackgroundView = selectedBackgroundView;
            cell.contentView.backgroundColor = [UIColor themeWhite];
            [cell.contentView addSubview:self.emptyView];
            return cell;
        } else if([model isKindOfClass:[FHFeedUGCCellModel class]]) {
            FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)model;
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
    }
    return [[FHUGCBaseCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showPlaceHolder) {
        return 282;
    }
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.dataList.count) {
        id model = self.dataList[index];
        if([model isKindOfClass:[FHPersonalHomePageFeedListErrorItemModel class]]) {
            return CGRectGetHeight(self.tableView.frame);
        } else if([model isKindOfClass:[FHFeedUGCCellModel class]]) {
            FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)model;
            Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
            if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
                return [cellClass heightForData:cellModel];
            }
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.dataList.count) {
        id model = self.dataList[index];
        if([model isKindOfClass:[FHPersonalHomePageFeedListErrorItemModel class]]) {
            return;
        } else if([model isKindOfClass:[FHFeedUGCCellModel class]]) {
            FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)model;
            self.detailJumpManager.currentCell = [tableView cellForRowAtIndexPath:indexPath];
            [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.homePageManager tableViewScroll:scrollView];
}

@end
