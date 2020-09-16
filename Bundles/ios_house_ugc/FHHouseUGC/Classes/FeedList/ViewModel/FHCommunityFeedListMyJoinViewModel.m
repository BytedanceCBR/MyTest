//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListMyJoinViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHTopicListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedUGCCellModel.h"
#import "Article.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "TTUGCDefine.h"
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "TTURLUtils.h"
#import "HMDTTMonitor.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "FHUGCVideoCell.h"
#import "TTVFeedPlayMovie.h"
#import "TTVPlayVideo.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellAction.h"
#import "FHUGCFullScreenVideoCell.h"
#import "FHCommunityFeedListController.h"

@interface FHCommunityFeedListMyJoinViewModel () <UITableViewDelegate, UITableViewDataSource,FHUGCBaseCellDelegate>

@property(nonatomic, weak) FHCommunityFeedListController *viewController;
@property(nonatomic, assign) BOOL needDealFollowData;
@property (nonatomic, strong)   NSMutableArray       *lastGroupIdArr;
//当第一刷数据不足5个，同时feed还有新内容时，会继续刷下一刷的数据，这个值用来记录请求的次数
@property(nonatomic, assign) NSInteger retryCount;

@end

@implementation FHCommunityFeedListMyJoinViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super initWithTableView:tableView];
    if (self) {
        self.viewController = viewController;
        self.dataList = [[NSMutableArray alloc] init];
        self.lastGroupIdArr = [[NSMutableArray alloc] init];
        [self configTableView];
        // 删帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCDelPostNotification object:nil];
        // 关注状态变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
        // 编辑成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadSuccessNotification" object:nil]; // 编辑发送成功
    }
    
    return self;
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
                    cellModel.categoryId = self.categoryId;
                    cellModel.feedVC = self.viewController;
                    cellModel.tableView = self.tableView;
                    cellModel.isFromDetail = NO;
                    cellModel.isStick = lastCellModel.isStick;
                    cellModel.stickStyle = lastCellModel.stickStyle;
                    cellModel.contentDecoration = lastCellModel.contentDecoration;
                    if (cellModel) {
                        self.dataList[index] = cellModel;
                    }
                    // 异步一下
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
        }
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
    
    if(self.viewController.tableViewNeedPullDown){
        // 下拉刷新
        [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
            wself.isRefreshingTip = NO;
            [wself.viewController hideImmediately];
            [wself requestData:YES first:NO];
        }];
    }
}

- (void)postDeleteSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        [self deleteCell:cellModel];
    }
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.viewController.isLoadingData){
        return;
    }
    
    NSString *refreshType = @"be_null";
    if(isHead){
        if(self.viewController.isRefreshTypeClicked){
            refreshType = @"click";
            self.viewController.isRefreshTypeClicked = NO;
        }else{
            refreshType = @"push";
        }
    }else{
        refreshType = @"pre_load_more";
    }
    [self trackCategoryRefresh:refreshType];
    
    self.viewController.isLoadingData = YES;
    
    if(self.isRefreshingTip){
        [self.tableView finishPullDownWithSuccess:YES];
        return;
    }
    
    if(isFirst){
        [self.viewController startLoading];
        self.retryCount = 0;
    }
    
    __weak typeof(self) wself = self;
    
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
        [FHUGCConfig sharedInstance].behotTime = behotTime;
    }
    
    //下拉刷新关闭视频播放
    if(isHead){
        [self endDisplay];
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.viewController.isLoadingData = NO;
        
        [wself.tableView finishPullDownWithSuccess:YES];
        
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        
        if (!wself) {
            if(isFirst){
                [wself.viewController endLoading];
            }
            return;
        }
        
        if (error) {
            //TODO: show handle error
            if(isFirst){
                [wself.viewController endLoading];
                if(error.code != -999){
                    [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                    wself.viewController.showenRetryButton = YES;
                    wself.refreshFooter.hidden = YES;
                }
            }else{
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            return;
        }
        
        if(model){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if(isHead && feedListModel.hasMore){
                    [wself.dataList removeAllObjects];
                }
                NSArray *result = [wself convertModel:feedListModel.data isHead:isHead];
                if(isFirst){
                    [wself.clientShowDict removeAllObjects];
                    [wself.dataList removeAllObjects];
                }
                if(isHead){
                    // JOKER: 头部插入时，旧数据的置顶全部取消，以新数据中的置顶贴子为准
                    [wself.dataList enumerateObjectsUsingBlock:^(FHFeedUGCCellModel *  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        cellModel.isStick = NO;
                    }];
                    // 头部插入新数据
                    [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
                }else{
                    [wself.dataList addObjectsFromArray:result];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(isHead){
                        wself.tableView.hasMore = YES;
                    }else{
                        wself.tableView.hasMore = feedListModel.hasMore;
                    }

                    //第一次拉取数据过少时，在多拉一次loadmore
                    if(wself.dataList.count > 0 && wself.dataList.count < 5 && wself.tableView.hasMore && wself.retryCount < 1){
                        wself.retryCount += 1;
                        [wself requestData:NO first:NO];
                        return;
                    }
                    
                    wself.retryCount = 0;
                    wself.viewController.hasValidateData = wself.dataList.count > 0;

                    if(wself.dataList.count > 0){
                        [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                        [wself.viewController.emptyView hideEmptyView];
                    }else{
                        [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                        wself.viewController.showenRetryButton = YES;
                        wself.refreshFooter.hidden = YES;
                        // 关注列表为空时上报监控数据
                        if (isHead) {
                            // 下拉
                            if (![[[NSBundle mainBundle] infoDictionary][@"CHANNEL_NAME"] isEqualToString:@"local_test"]) {
                                // 线上App Store
                                NSString *categoryName = wself.categoryId ?: @"f_ugc_follow";
                                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_feed_empty" metric:nil category:@{@"status":@(1)} extra:@{@"category":categoryName}];
                            }
                        }
                    }
                    [wself.tableView reloadData];
                    
                    if(wself.viewController.requestSuccess){
                        wself.viewController.requestSuccess(wself.viewController.hasValidateData);
                    }
                    
                    NSString *refreshTip = feedListModel.tips.displayInfo;
                    if (isHead && wself.dataList.count > 0 && ![refreshTip isEqualToString:@""] && wself.viewController.tableViewNeedPullDown && !wself.isRefreshingTip){
                        wself.isRefreshingTip = YES;
                        [wself.viewController showNotify:refreshTip completion:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                wself.isRefreshingTip = NO;
                            });
                        }];
                        [wself.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    } else {
                        UIEdgeInsets contentInset = wself.tableView.originContentInset;
                        contentInset.top = 0;
                        wself.tableView.originContentInset = contentInset;
                    }
                });
            });
        }
    }];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.categoryId = self.categoryId;
        cellModel.feedVC = self.viewController;
        cellModel.tableView = self.tableView;
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

- (void)followStateChanged:(NSNotification *)notification {
    BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
    NSString *socialGroupId = notification.userInfo[@"social_group_id"];
    
    NSMutableArray *dataList = [self.dataList mutableCopy];
    //当取消关注时候，需要删掉所有相关的数据
    if(!followed){
        for (NSInteger i = 0; i < self.dataList.count; i++) {
            FHFeedUGCCellModel *cellModel = self.dataList[i];
            if([socialGroupId isEqualToString:cellModel.community.socialGroupId]){
                [dataList removeObject:cellModel];
            }
        }
    }
    
    self.dataList = [dataList mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        [self traceClientShowAtIndexPath:indexPath];
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        /*impression统计相关*/
        SSImpressionStatus impressionStatus = self.isShowing ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
        [self recordGroupWithCellModel:cellModel status:impressionStatus];
        
        if (![cell isKindOfClass:[FHUGCVideoCell class]] && ![cell isKindOfClass:[FHUGCFullScreenVideoCell class]]) {
            return;
        }
        //视频
        if(cellModel.hasVideo){
            FHUGCBaseCell *cellBase = (FHUGCBaseCell *)cell;
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
            
            if([cell isKindOfClass:[FHUGCBaseCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                FHUGCBaseCell<TTVFeedPlayMovie> *cellBase = (FHUGCBaseCell<TTVFeedPlayMovie> *)cell;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        
        if (cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCLynx && cellModel.lynxData[@"channel_name"]) {
              [tableView registerClass:NSClassFromString(cellIdentifier) forCellReuseIdentifier:cellModel.lynxData[@"channel_name"]];
              cellIdentifier = cellModel.lynxData[@"channel_name"];
        }
        
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        cellModel.cell = cell;

        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return ceil([cellClass heightForData:cellModel]);
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        self.currentCellModel = cellModel;
        self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
        self.detailJumpManager.currentCell = self.currentCell;
        [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
    }
}

#pragma UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewController.scrollViewDelegate scrollViewDidScroll:scrollView];
    if(scrollView == self.tableView){
        if (scrollView.isDragging) {
            [self.viewController.notifyBarView performSelector:@selector(hideIfNeeds) withObject:nil];
        }
    }
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.dataList removeObjectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
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
            traceParam[@"element_from"] = @"feed_topic";
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

#pragma mark - 视频相关

- (void)willFinishLoadTable {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didFinishLoadTable) object:nil];
    [self performSelector:@selector(didFinishLoadTable) withObject:nil afterDelay:0.1];
}

- (void)didFinishLoadTable {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    NSArray *cells = [self.tableView visibleCells];
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
    NSMutableDictionary *dict =  [self trackDict:cellModel rank:rank];
    if(cellModel.cellSubType == FHUGCFeedListCellSubTypeFullVideo || cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCVideo){
        dict[@"video_type"] = @"video";
    }else if(cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCSmallVideo){
        dict[@"video_type"] = @"small_video";
    }
    TRACK_EVENT(@"feed_client_show", dict);
    
    if(cellModel.attachCardInfo){
        [self trackCardShow:cellModel rank:rank];
    }
    
    if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2) {
        NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
        guideDict[@"origin_from"] = self.viewController.tracerDict[@"origin_from"];
        guideDict[@"page_type"] = [self pageType];
        guideDict[@"description"] = cellModel.desc;
        guideDict[@"item_title"] = cellModel.title;
        guideDict[@"item_id"] = cellModel.groupId;
        guideDict[@"rank"] = @(rank);
        TRACK_EVENT(@"banner_show", guideDict);
    }
}

- (void)trackCardShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dic =  [self trackDict:cellModel rank:rank];
    if(cellModel.attachCardInfo.extra && cellModel.attachCardInfo.extra.event.length > 0){
        //是房源卡片
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"origin_from"] = dic[@"origin_from"] ?: @"be_null";
        dict[@"page_type"] = [self pageType];
        dict[@"enter_from"] = dic[@"enter_from"] ? dic[@"enter_from"] : @"be_null";
        dict[@"group_id"] = cellModel.attachCardInfo.extra.groupId ?: @"be_null";
        dict[@"from_gid"] = cellModel.attachCardInfo.extra.fromGid ?: @"be_null";
        dict[@"group_source"] = cellModel.attachCardInfo.extra.groupSource ?: @"be_null";
        dict[@"impr_id"] = cellModel.attachCardInfo.extra.imprId ?: @"be_null";
        dict[@"house_type"] = cellModel.attachCardInfo.extra.houseType ?: @"be_null";
        TRACK_EVENT(cellModel.attachCardInfo.extra.event ?: @"card_show", dict);
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"origin_from"] = dic[@"origin_from"] ?: @"be_null";
        dict[@"page_type"] = [self pageType];
        dict[@"enter_from"] = dic[@"enter_from"] ? dic[@"enter_from"] : @"be_null";
        dict[@"from_gid"] = cellModel.groupId;
        dict[@"group_source"] = @(5);
        dict[@"impr_id"] = cellModel.tracerDic[@"log_pb"][@"impr_id"] ?: @"be_null";
        dict[@"card_type"] = cellModel.attachCardInfo.cardType ?: @"be_null";
        dict[@"card_id"] = cellModel.attachCardInfo.id ?: @"be_null";
        TRACK_EVENT(@"card_show", dict);
    }
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.viewController.tracerDict[@"origin_from"] ?: @"be_null";
    dict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"] ?: @"be_null";
    dict[@"page_type"] = [self pageType];
    dict[@"category_name"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    dict[@"group_id"] = cellModel.groupId;
    if(cellModel.logPb[@"impr_id"]){
        dict[@"impr_id"] = cellModel.logPb[@"impr_id"];
    }
    if(cellModel.logPb[@"group_source"]){
        dict[@"group_source"] = cellModel.logPb[@"group_source"];
    }
    if(cellModel.fromGid){
        dict[@"from_gid"] = cellModel.fromGid;
    }
    if(cellModel.fromGroupSource){
        dict[@"from_group_source"] = cellModel.fromGroupSource;
    }
    
    return dict;
}

- (NSString *)pageType {
    return @"my_join_feed";
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    TRACK_EVENT(@"click_comment", dict);
}

- (void)trackVoteClickOptions:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"log_pb"] = cellModel.logPb;
    if(value == [cellModel.vote.leftValue integerValue]){
        dict[@"click_position"] = @"1";
    }else if(value == [cellModel.vote.rightValue integerValue]){
        dict[@"click_position"] = @"2";
    }else{
        dict[@"click_position"] = @"vote_content";
    }
    TRACK_EVENT(@"click_options", dict);
}

- (void)trackCategoryRefresh:(NSString *)refreshType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.viewController.tracerDict[@"origin_from"] ?: @"be_null";
    dict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"] ?: @"be_null";
    dict[@"refresh_type"] = refreshType;
    dict[@"category_name"] = [self pageType];
    TRACK_EVENT(@"category_refresh", dict);
}

@end
