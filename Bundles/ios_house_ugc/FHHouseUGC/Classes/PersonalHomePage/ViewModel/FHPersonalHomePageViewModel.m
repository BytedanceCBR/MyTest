//
//  FHPersonalHomePageViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHPersonalHomePageViewModel.h"
#import "FHHouseListAPI.h"
#import "FHUserTracker.h"
#import "FHUGCBaseCell.h"
#import "FHUGCReplyCell.h"
#import "FHHouseUGCAPI.h"
#import "FHTopicFeedListModel.h"
#import "FHUGCTopicRefreshHeader.h"
#import "FHRefreshCustomFooter.h"
#import "FHFeedUGCCellModel.h"
#import "TTStringHelper.h"
#import "FHUGCBaseCell.h"
#import "TTGroupModel.h"
#import "ArticleImpressionHelper.h"
#import "FHUGCConfig.h"
#import "TTUGCDefine.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "FHUGCSmallVideoCell.h"
#import "AWEVideoConstants.h"
#import "TTURLUtils.h"
#import "FHUGCVideoCell.h"
#import "TTVFeedPlayMovie.h"
#import "TTVPlayVideo.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellAction.h"
#import "FHFeedListModel.h"
#import "ToastManager.h"
#import "TTAccountManager.h"
#import "FHUGCFeedDetailJumpManager.h"

@interface FHPersonalHomePageViewModel ()<FHUGCBaseCellDelegate>

@property (nonatomic, weak) FHPersonalHomePageController *detailController;
@property (nonatomic, weak) TTHttpTask *httpTopHeaderTask;
@property (nonatomic, weak) TTHttpTask *httpTopListTask;
@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, assign) NSInteger loadDataSuccessCount;
@property (nonatomic, strong) NSMutableArray *dataList;// FeedList数据，目前只有一个tab
@property (nonatomic, assign) BOOL firstLoadData;// 第一次加载数据成功
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger feedOffset;
@property (nonatomic, assign) BOOL hasMore;

@property (nonatomic, strong) FHUGCBaseCell *currentCell;
@property (nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property (nonatomic, assign) BOOL needRefreshCell;
@property (nonatomic, strong) NSMutableDictionary *clientShowDict;

@property (nonatomic, assign) NSInteger refer;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *tab_id;
@property (nonatomic, copy) NSString *appExtraParams;
@property (nonatomic, strong) FHErrorView *tableEmptyView;
//只上报一次埋点
@property (nonatomic, assign) BOOL reportedGoDetail;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;

@end

@implementation FHPersonalHomePageViewModel

-(instancetype)initWithController:(FHPersonalHomePageController *)viewController
{   self = [super init];
    if (self) {
        self.detailController = viewController;
        self.ugcCellManager = [[FHUGCCellManager alloc] init];
        self.canScroll = NO;
        self.firstLoadData = YES;
        self.hasMore = NO;
        self.needRefreshCell = NO;
        self.refer = 1;
        self.isShowing = NO;
        self.categoryName = @"forum_topic_thread";// 频道名称 服务端返回
        self.tab_id = @"1643017137463326";// 服务端返回
        self.count = 20;// 每次20条
        self.feedOffset = 0;
        self.dataList = [[NSMutableArray alloc] init];
        self.hashTable = [NSHashTable weakObjectsHashTable];
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = self.refer;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCGoTop" object:@"homePage"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:@"homePage"];
        // 删帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCDelPostNotification object:nil];
        // 举报成功
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCReportPostNotification object:nil];
        
        self.tableEmptyView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 500)];
        
        // 编辑成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadSuccessNotification" object:nil]; // 编辑发送成功
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 编辑发送成功 - 更新数据
- (void)postEditNoti:(NSNotification *)noti {
    if (noti && noti.userInfo) {
        NSDictionary *userInfo = noti.userInfo;
        NSString *groupId = userInfo[@"group_id"];
        if (groupId.length > 0) {
            __block NSUInteger index = -1;
            [self.dataList enumerateObjectsUsingBlock:^(FHFeedUGCCellModel*  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([cellModel.groupId isEqualToString:groupId]) {
                    index = idx;
                }
            }];
            // 找到 要更新的数据
            if (index >= 0 && index < self.dataList.count) {
                NSString *thread_cell = userInfo[@"thread_cell"];
                if (thread_cell && [thread_cell isKindOfClass:[NSString class]]) {
                    FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:thread_cell];
                    FHFeedUGCCellModel *lastCellModel = self.dataList[index];
                    cellModel.isFromDetail = NO;
                    cellModel.isStick = lastCellModel.isStick;
                    cellModel.stickStyle = lastCellModel.stickStyle;
                    cellModel.contentDecoration = lastCellModel.contentDecoration;
                    if (cellModel) {
                        self.dataList[index] = cellModel;
                    }
                    // 异步一下
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.currentTableView reloadData];
                    });
                }
            }
        }
    }
}


- (void)startLoadData {
    self.loadDataSuccessCount = 0;// 网络接口返回计数
    self.feedOffset = 0;
    [self loadHeaderData];
}

// 下拉刷新
- (void)refreshLoadData {
    self.feedOffset = 0;
    [self loadFeedListData];
}

// 上拉刷新
- (void)loadMoreData {
    [self loadFeedListData];
}

// 请求顶部的header
- (void)onlyLoadHeaderData {
    if (self.httpTopHeaderTask) {
        [self.httpTopHeaderTask cancel];
    }
    
    __weak typeof(self) wSelf = self;
    self.httpTopListTask = [FHHouseUGCAPI requestHomePageInfoWithUserId:self.userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error && [model isKindOfClass:[FHPersonalHomePageModel class]]) {
            if([model.message isEqualToString:@"success"] && [wSelf.headerModel.dErrno integerValue] == 0){
                wSelf.headerModel = model;
                [wSelf.detailController refreshHeaderData:NO];
            }
        }
    }];
}

// 请求顶部的header
- (void)loadHeaderData {
    if (self.httpTopHeaderTask) {
        [self.httpTopHeaderTask cancel];
    }
    
    __weak typeof(self) wSelf = self;
    self.httpTopListTask = [FHHouseUGCAPI requestHomePageInfoWithUserId:self.userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;
        if (error) {
            wSelf.headerModel = nil;
            // 强制endLoading
            wSelf.loadDataSuccessCount += 1;
        } else {
            if ([model isKindOfClass:[FHPersonalHomePageModel class]] && [model.message isEqualToString:@"success"] && [wSelf.headerModel.dErrno integerValue] == 0) {
                wSelf.headerModel = model;
                if(wSelf.headerModel.data.logPb){
                    wSelf.detailController.tracerDict[@"log_pb"] = wSelf.headerModel.data.logPb;
                }
                [wSelf.detailController refreshHeaderData:YES];
                wSelf.detailController.mainScrollView.backgroundColor = [UIColor themeGray7];
                
                if([wSelf.headerModel.data.fHomepageAuth integerValue] == 0 || [[TTAccountManager userID] isEqualToString:wSelf.headerModel.data.userId]){
                    // 加载列表数据
                    [wSelf loadFeedListData];
                }
            } else {
                if ([model isKindOfClass:[FHPersonalHomePageModel class]]){
                    FHPersonalHomePageModel *homePageModel = (FHPersonalHomePageModel *)model;
                    if(homePageModel.data.desc.length > 0){
                        wSelf.headerModel = model;
                    }else{
                        wSelf.headerModel = nil;
                    }
                }else{
                    wSelf.headerModel = nil;
                }
                // 强制endLoading
                wSelf.loadDataSuccessCount += 1;
            }
        }
        [wSelf processLoadingState];
    }];
}

// 请求FeedList
- (void)loadFeedListData {
    if (self.httpTopListTask) {
        [self.httpTopListTask cancel];
    }
    self.detailController.isLoadingData = YES;
    
    __weak typeof(self) wSelf = self;
    self.httpTopListTask = [FHHouseUGCAPI requestHomePageFeedListWithUserId:self.userId offset:self.feedOffset count:self.count completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;

        if (error) {
            if (wSelf.feedOffset == 0) {
                // 说明是第一次请求
            } else {
                // 上拉加载loadmore
                [[ToastManager manager] showToast:@"网络异常"];
                self.currentTableView.mj_footer.hidden = NO;
                [self.currentTableView.mj_footer endRefreshing];
                return;
            }
        } else {
            FHFeedListModel *feedList = nil;
            if ([model isKindOfClass:[FHFeedListModel class]]) {
                feedList = (FHFeedListModel *)model;
            }
            
            if(feedList){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    // 数据转模型 添加数据
                    NSMutableArray *tempArray = [NSMutableArray new];
                    [feedList.data enumerateObjectsUsingBlock:^(FHFeedListDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[FHFeedListDataModel class]]) {
                            FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:obj.content];
                            if (cellModel) {
                                [tempArray addObject:cellModel];
                            }
                        }
                    }];
                    
                    if (wSelf.feedOffset == 0) {
                        // 说明是第一次请求--之前的数据保留（去重）
                        if (tempArray.count > 0) {
                            // 有返回（下拉）
                            [tempArray enumerateObjectsUsingBlock:^(FHFeedUGCCellModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (obj.groupId.length > 0) {
                                    [self removeDuplicaionModel:obj.groupId];
                                }
                            }];
                        }
                        // 再插入顶部
                        if (self.dataList.count > 0) {
                            // JOKER: 头部插入时，旧数据的置顶全部取消，以新数据中的置顶贴子为准
                            [self.dataList enumerateObjectsUsingBlock:^(FHFeedUGCCellModel *  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                                cellModel.isStick = NO;
                            }];
                            // 头部插入新数据
                            [tempArray addObjectsFromArray:self.dataList];
                        }
                        [self.dataList removeAllObjects];
                        if (tempArray.count > 0) {
                            [self.dataList addObjectsFromArray:tempArray];
                        }
                    } else {
                        // 上拉加载loadmore
                        if (tempArray.count > 0) {
                            [self.dataList enumerateObjectsUsingBlock:^(FHFeedUGCCellModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (obj.groupId.length > 0) {
                                    // 新数据去重
                                    for (FHFeedUGCCellModel *itemModel in tempArray) {
                                        if([obj.groupId isEqualToString:itemModel.groupId]){
                                            [tempArray removeObject:itemModel];
                                            break;
                                        }
                                    }
                                }
                            }];
                            // 插入底部
                            if (tempArray.count > 0) {
                                [self.dataList addObjectsFromArray:tempArray];
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wSelf.hasMore = feedList.hasMore;
                        wSelf.feedOffset = [feedList.offset integerValue];// 时间序 服务端返回的是时间
                        [wSelf processLoadingState];
                    });
                });
            }else{
                [wSelf processLoadingState];
            }
        }
    }];
}

- (void)removeDuplicaionModel:(NSString *)groupId {
    for (FHFeedUGCCellModel *itemModel in self.dataList) {
        if([groupId isEqualToString:itemModel.groupId]){
            [self.dataList removeObject:itemModel];
            break;
        }
    }
}

// 刷新数据和状态
- (void)processLoadingState {
    NSString *showType = @"be_null";
    NSInteger requestCount = 0;
    if([self.headerModel.data.fHomepageAuth integerValue] == 0 || [[TTAccountManager userID] isEqualToString:self.headerModel.data.userId]){
        requestCount = 2;
    }else{
        requestCount = 1;
    }
    
    if (self.loadDataSuccessCount >= requestCount) {
        [self.detailController endLoading];
        self.detailController.isLoadingData = NO;
        // 刷新数据
        if (self.headerModel && self.dataList.count > 0) {
            // 数据ok
            [self.detailController hiddenEmptyView];
             self.currentTableView.backgroundColor = [UIColor themeGray7];
//            [self.detailController refreshHeaderData:NO];
            // 移除空页面
            if (self.tableEmptyView) {
                [self.tableEmptyView removeFromSuperview];
            }
            self.currentTableView.scrollEnabled = YES;
            [self.currentTableView reloadData];
            // hasMore
            FHRefreshCustomFooter *refreshFooter = (FHRefreshCustomFooter *)self.currentTableView.mj_footer;
            self.currentTableView.mj_footer.hidden = NO;
            if (self.hasMore == NO) {
                [refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
                [refreshFooter endRefreshingWithNoMoreData];
            }else {
                [refreshFooter endRefreshing];
            }
            
            showType = @"personal_full";
            [self trackGoDetail:showType];
            
        } else {
            if (self.headerModel) {
//                [self.detailController refreshHeaderData:NO];
                self.currentTableView.mj_footer.hidden = YES;
                self.currentTableView.backgroundColor = [UIColor whiteColor];
                
                if([self.headerModel.dErrno integerValue] != 0){
                    // 添加空态页
                    NSString *desc = self.headerModel.data.desc ? self.headerModel.data.desc : @"获取用户信息失败";
                    [self.detailController.emptyView showEmptyWithTip:desc errorImageName:@"fh_ugc_home_page_no_auth" showRetry:NO];
                    
                    showType = @"personal_error";
                    [self trackGoDetail:showType];
                    
                }else if([self.headerModel.data.fHomepageAuth integerValue] == 0 || [[TTAccountManager userID] isEqualToString:self.headerModel.data.userId]){
                    if (self.dataList.count <= 0) {
                        // 添加空态页
                        [self.currentTableView addSubview:self.tableEmptyView];
                        NSString *tipStr = [[TTAccountManager userID] isEqualToString:self.userId] ? @"你还没有发布任何内容，快去发布吧" : @"TA没有留下任何足迹，去其他地方看看吧！";
                        [self.tableEmptyView showEmptyWithTip:tipStr errorImageName:@"fh_ugc_home_page_no_auth" showRetry:NO];
                        self.currentTableView.scrollEnabled = NO;
                        
                        showType = @"personal_blank";
                        [self trackGoDetail:showType];
                    }
                }else{
                    // 添加空态页
                    [self.currentTableView addSubview:self.tableEmptyView];
                    [self.tableEmptyView showEmptyWithTip:@"TA暂时没有对外公开个人页面" errorImageName:@"fh_ugc_home_page_no_auth" showRetry:NO];
                    self.currentTableView.scrollEnabled = NO;
                    
                    showType = @"personal_null";
                    [self trackGoDetail:showType];
                }
            } else {
                [self.detailController showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.ugcCellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        cellModel.tableView = tableView;
        
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        [self traceClientShowAtIndexPath:indexPath];
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        /*impression统计相关*/
        SSImpressionStatus impressionStatus = self.isShowing ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
        [self recordGroupWithCellModel:cellModel status:impressionStatus];
        
        if (![cell isKindOfClass:[FHUGCVideoCell class]]) {
            return;
        }
        //视频
        if(cellModel.hasVideo){
            FHUGCVideoCell *cellBase = (FHUGCVideoCell *)cell;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
            [self willFinishLoadTable];
            
            [cellBase willDisplay];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // impression统计
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusEnd];
        
        if(cellModel.hasVideo){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
            [self willFinishLoadTable];
            
            if([cell isKindOfClass:[FHUGCVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                FHUGCVideoCell<TTVFeedPlayMovie> *cellBase = (FHUGCVideoCell<TTVFeedPlayMovie> *)cell;
                BOOL hasMovie = NO;
                NSArray *indexPaths = [tableView indexPathsForVisibleRows];
                for (NSIndexPath *path in indexPaths) {
                    if (path.row < self.dataList.count) {
                        
                        BOOL hasMovieView = NO;
                        if ([cellBase respondsToSelector:@selector(cell_hasMovieView)]) {
                            hasMovieView = [cellBase cell_hasMovieView];
                        }
                        
                        if ([cellBase respondsToSelector:@selector(cell_movieView)]) {
                            UIView *view = [cellBase cell_movieView];
                            if (view && ![self.movieViews containsObject:view]) {
                                [self.movieViews addObject:view];
                            }
                        }
                        if (cellModel == self.movieViewCellData) {
                            hasMovie = YES;
                            break;
                        }
                    }
                }
                
                if (self.isShowing) {
                    if (!hasMovie) {
                        [cellBase endDisplay];
                    }
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        Class cellClass = [self.ugcCellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
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
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        self.currentCellModel = cellModel;
        self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
        self.detailJumpManager.currentCell = self.currentCell;
        [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
    }
}
#pragma mark - UIScrollViewDelegate
//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canScroll) {
        [[self.hashTable allObjects] enumerateObjectsUsingBlock:^(UIScrollView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setContentOffset:CGPointZero];
        }];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<=0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCLeaveTop" object:@"homePage" userInfo:@{@"canScroll":@"1"}];
    }
}

-(void)acceptMsg:(NSNotification *)notification{
    NSString *notificationName = notification.name;
    id obj = notification.object;
    if ([notificationName isEqualToString:@"kFHUGCGoTop"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    }else if([notificationName isEqualToString:@"kFHUGCLeaveTop"]){
        [[self.hashTable allObjects] enumerateObjectsUsingBlock:^(UIScrollView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setContentOffset:CGPointZero];
        }];
        self.canScroll = NO;
    }
}

- (UITableView *)currentTableView {
    UITableView *ret = nil;
    NSInteger index = self.currentSelectIndex;
    NSArray *arr = [self.hashTable allObjects];
    if (index >= 0 && index < arr.count) {
        return arr[index];
    }
    return ret;
}

- (void)viewWillAppear {
    self.isShowing = YES;
    if(self.firstLoadData){
        self.firstLoadData = NO;
    }else{
        [self onlyLoadHeaderData];
    }
}

- (void)viewWillDisappear {
    self.isShowing = NO;
}

- (void)postDeleteSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        [self deleteCell:cellModel];
    }
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        UITableView *tableView = self.currentTableView;
        [tableView beginUpdates];
        [self.dataList removeObjectAtIndex:row];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView layoutIfNeeded];
        [tableView endUpdates];
        if (self.dataList.count <= 0) {
            self.hasMore = NO;
            [self processLoadingState];
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

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    [self trackClickComment:cellModel];
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    [self.detailJumpManager goToCommunityDetail:cellModel];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
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
            traceParam[@"enter_from"] = [self pageType];
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

- (void)endDisplay {
    NSArray *cells = self.currentTableView.visibleCells;
    for (id cell in cells) {
        if([cell isKindOfClass:[FHUGCVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
            FHUGCVideoCell<TTVFeedPlayMovie> *cellBase = (FHUGCVideoCell<TTVFeedPlayMovie> *)cell;
            if([cellBase cell_isPlayingMovie]){
                [cellBase endDisplay];
            }
        }
    }
}

#pragma mark - 视频相关

- (void)willFinishLoadTable {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didFinishLoadTable) object:nil];
    [self performSelector:@selector(didFinishLoadTable) withObject:nil afterDelay:0.1];
}

- (void)didFinishLoadTable {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    NSArray *cells = [self.currentTableView visibleCells];
    NSMutableArray *visibleCells = [NSMutableArray arrayWithCapacity:cells.count];
    for (id cell in cells) {
        if([cell isKindOfClass:[FHUGCVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]){
            FHUGCVideoCell<TTVFeedPlayMovie> *vCell = (FHUGCVideoCell<TTVFeedPlayMovie> *)cell;
            UIView *view = [vCell cell_movieView];
            if (view) {
                [visibleCells addObject:view];
            }
        }
    }
    
    for (UIView *view in self.movieViews) {
        if ([view isKindOfClass:[TTVPlayVideo class]]) {
            TTVPlayVideo *movieView = (TTVPlayVideo *)view;
            if (!movieView.player.context.isFullScreen &&
                !movieView.player.context.isRotating && ![visibleCells containsObject:movieView]) {
                if (movieView.player.context.playbackState != TTVVideoPlaybackStateBreak || movieView.player.context.playbackState != TTVVideoPlaybackStateFinished) {
                    [movieView stop];
                }
                [movieView removeFromSuperview];
            }
        }
    }
    
    self.movieViewCellData = nil;
    self.movieView = nil;
    [self.movieViews removeAllObjects];
}

#pragma mark - 埋点

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *groupId = cellModel.groupId;
    if(groupId){
        if (self.clientShowDict[groupId]) {
            return;
        }
        
        self.clientShowDict[groupId] = @(indexPath.row);
        [self trackClientShow:cellModel rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [self trackDict:cellModel rank:rank];
    TRACK_EVENT(@"feed_client_show", dict);
    
    if(cellModel.attachCardInfo){
        [self trackCardShow:cellModel rank:rank];
    }
    
    if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2) {
        NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
        guideDict[@"origin_from"] = self.detailController.tracerDict[@"origin_from"] ;
        guideDict[@"page_type"] = [self pageType];
        guideDict[@"description"] = cellModel.desc;
        guideDict[@"item_title"] = cellModel.title;
        guideDict[@"item_id"] = cellModel.groupId;
        guideDict[@"rank"] = @(rank);
        TRACK_EVENT(@"banner_show", guideDict);
    }else  if(cellModel.cellType == FHUGCFeedListCellTypeUGCEncyclopedias){
        NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
        guideDict[@"origin_from"] = self.detailController.tracerDict[@"origin_from"] ;
        guideDict[@"page_type"] = [self pageType];
        guideDict[@"card_type"] = @"encyclopedia";
        guideDict[@"impr_id"] = cellModel.tracerDic[@"log_pb"][@"impr_id"] ?: @"be_null";;
        guideDict[@"group_id"] = cellModel.groupId;
        guideDict[@"rank"] = @(rank);
        TRACK_EVENT(@"card_show", guideDict);
    }
}

- (void)trackCardShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    if(cellModel.attachCardInfo.extra && cellModel.attachCardInfo.extra.event.length > 0){
        //是房源卡片
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"origin_from"] = cellModel.tracerDic[@"origin_from"] ? cellModel.tracerDic[@"origin_from"] : @"be_null";
        dict[@"page_type"] = [self pageType];
        dict[@"enter_from"] = self.enter_from.length > 0 ? self.enter_from : @"be_null";
        dict[@"group_id"] = cellModel.attachCardInfo.extra.groupId ?: @"be_null";
        dict[@"from_gid"] = cellModel.attachCardInfo.extra.fromGid ?: @"be_null";
        dict[@"group_source"] = cellModel.attachCardInfo.extra.groupSource ?: @"be_null";
        dict[@"impr_id"] = cellModel.attachCardInfo.extra.imprId ?: @"be_null";
        dict[@"house_type"] = cellModel.attachCardInfo.extra.houseType ?: @"be_null";
        TRACK_EVENT(cellModel.attachCardInfo.extra.event ?: @"card_show", dict);
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"origin_from"] = cellModel.tracerDic[@"origin_from"] ? cellModel.tracerDic[@"origin_from"] : @"be_null";
        dict[@"page_type"] = [self pageType];
        dict[@"enter_from"] = self.enter_from.length > 0 ? self.enter_from : @"be_null";
        dict[@"from_gid"] = cellModel.groupId;
        dict[@"group_source"] = @(5);
        dict[@"impr_id"] = cellModel.tracerDic[@"log_pb"][@"impr_id"] ?: @"be_null";
        dict[@"card_type"] = cellModel.attachCardInfo.cardType ?: @"be_null";
        dict[@"card_id"] = cellModel.attachCardInfo.id ?: @"be_null";
        TRACK_EVENT(@"card_show", dict);
    }
}

- (void)trackElementShow:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"element_type"] = @"like_neighborhood";
    dict[@"page_type"] = [self pageType];
    dict[@"enter_from"] = self.enter_from.length > 0 ? self.enter_from : [self pageType];// 这个埋点是上个页面从哪来
    dict[@"rank"] = @(rank);
    
    TRACK_EVENT(@"element_show", dict);
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"enter_from"] = self.enter_from.length > 0 ? self.enter_from : [self pageType];// 这个埋点是上个页面从哪来
    dict[@"page_type"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    dict[@"category_name"] = self.categoryName;
    dict[@"group_id"] = cellModel.groupId;
    if(cellModel.logPb[@"impr_id"]){
        dict[@"impr_id"] = cellModel.logPb[@"impr_id"];
    }
    if(cellModel.logPb[@"group_source"]){
        dict[@"impr_id"] = cellModel.logPb[@"group_source"];
    }
    
    return dict;
}

- (NSString *)pageType {
    return @"personal_homepage_detail";
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_comment";
    TRACK_EVENT(@"click_comment", dict);
}

- (void)recordGroupWithCellModel:(FHFeedUGCCellModel *)cellModel status:(SSImpressionStatus)status {
    NSString *uniqueID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    NSString *itemID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    /*impression统计相关*/
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryName;
    params.refer = self.refer;
    SSImpressionModelType modelType = [FHUGCCellManager impressModelTypeWithCellType:cellModel.cellType];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:uniqueID itemID:itemID impressionID:nil aggrType:[cellModel.aggrType integerValue]];
    [ArticleImpressionHelper recordItemWithUniqueID:uniqueID modelType:modelType logPb:cellModel.logPb status:status params:params];
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dataList.count == 0) {
            return;
        }
        
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.refer = self.refer;
        UITableView *tableView = self.currentTableView;
        for (FHUGCBaseCell *cell in [tableView visibleCells]) {
            if ([cell isKindOfClass:[FHUGCBaseCell class]]) {
                id data = cell.currentData;
                if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
                    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
                    if (self.isShowing) {
                        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusRecording];
                    }
                    else {
                        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusSuspend];
                    }
                }
            }
        }
    });
    
}

#pragma mark - 埋点

- (void)trackGoDetail:(NSString *)showType {
    if(!self.reportedGoDetail){
        self.reportedGoDetail = YES;
        self.detailController.tracerDict[@"show_type"] = showType;
        [self.detailController addGoDetailLog];
    }
}

@end
