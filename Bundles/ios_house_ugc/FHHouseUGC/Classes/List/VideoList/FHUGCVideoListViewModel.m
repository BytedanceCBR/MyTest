//
//  FHUGCVideoListViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/11.
//

#import "FHUGCVideoListViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedUGCCellModel.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "TTURLUtils.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "FHUGCVideoCell.h"
#import "TTVFeedPlayMovie.h"
#import "TTVPlayVideo.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellAction.h"
#import "TTUGCDefine.h"
#import "FHFeedCustomHeaderView.h"
#import "FHUGCFullScreenVideoCell.h"
#import "BTDResponder.h"
#import "FHUGCCellHelper.h"

@interface FHUGCVideoListViewModel () <UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate,UIScrollViewDelegate>

//当第一刷数据不足5个，同时feed还有新内容时，会继续刷下一刷的数据，这个值用来记录请求的次数
@property(nonatomic, assign) NSInteger retryCount;
@property(nonatomic, strong) FHUGCFullScreenVideoCell *currentVideoCell;
@property(nonatomic, assign) BOOL isFirst;
@property(nonatomic, assign) CGFloat oldY;

@end

@implementation FHUGCVideoListViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCVideoListController *)viewController {
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.isFirst = YES;
        self.dataList = [[NSMutableArray alloc] init];
        [self configTableView];
    }
    
    return self;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:wself.isFirst first:wself.isFirst];
        if(wself.isFirst){
            wself.isFirst = NO;
        }
    }];
    self.tableView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
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
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    //增加一个视频id字段
    extraDic[@"video_id"] = self.viewController.currentVideo.groupId;
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
            return;
        }

        if (error) {
            //TODO: show handle error
            [[ToastManager manager] showToast:@"网络异常"];
            [wself updateTableViewWithMoreData:YES];
            return;
        }

        if(model){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray *result = [wself convertModel:feedListModel.data isHead:isHead];
                if(isFirst){
                    [wself.clientShowDict removeAllObjects];
                }

                [wself.dataList addObjectsFromArray:result];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(isHead){
                        wself.tableView.hasMore = YES;
                    }else{
                        wself.tableView.hasMore = feedListModel.hasMore;
                    }

                    //第一次拉取数据过少时，在多拉一次loadmore
                    if(wself.dataList.count > 0 && wself.dataList.count < 3 && wself.tableView.hasMore && wself.retryCount < 1){
                        wself.retryCount += 1;
                        [wself requestData:NO first:NO];
                        return;
                    }
                    
                    wself.retryCount = 0;
                    wself.viewController.hasValidateData = wself.dataList.count > 0;

                    if(wself.dataList.count > 0){
                        [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                    }
                    
                    [wself.tableView reloadData];
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
        cellModel.isVideoJumpDetail = YES;
        cellModel.enterFrom = [self.viewController categoryName];
        //兜底逻辑
        if(cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCVideo){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeFullVideo;
            cellModel.numberOfLines = 2;
            [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines];
        }
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
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // impression统计
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusEnd];
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
        
        if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]]){
            FHUGCFullScreenVideoCell *vCell = (FHUGCFullScreenVideoCell *)cell;
            if(!vCell.videoItem){
                vCell.contentView.userInteractionEnabled = NO;
            }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

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
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    self.currentCellModel = cellModel;
    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(self.currentCell == self.currentVideoCell){
        self.detailJumpManager.currentCell = self.currentCell;
        [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
    }else{
        [self didVideoClicked:cellModel cell:self.currentCell];
    }
}

#pragma UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.currentVideoCell){
        CGRect frame = [self.currentVideoCell.videoView convertRect:self.currentVideoCell.videoView.bounds toView:self.viewController.view];
        if(scrollView.contentOffset.y - _oldY >= 0){
            //向上滑动
            if(frame.origin.y < CGRectGetMaxY(self.viewController.customNavBarView.frame)){
                [self pauseCurrentVideo];
            }
        }else{
            //向下滑动
            if(CGRectGetMaxY(frame) > screenHeight){
                [self pauseCurrentVideo];
            }
        }
    }
    self.oldY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startVideoPlay];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate){
        [self startVideoPlay];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self startVideoPlay];
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.tableView beginUpdates];
        [self.dataList removeObjectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView layoutIfNeeded];
        [self.tableView endUpdates];
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

- (void)didVideoClicked:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    NSInteger row = [self.dataList indexOfObject:cellModel];
    if(row < self.dataList.count && row >= 0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]]){
            FHUGCFullScreenVideoCell *vCell = (FHUGCFullScreenVideoCell *)cell;
            self.currentVideoCell.contentView.userInteractionEnabled = NO;
            vCell.contentView.userInteractionEnabled = YES;
            self.currentVideoCell = vCell;
            [vCell play];
        }
        
        if(row >= (self.dataList.count - 3)){
            //在刷一刷数据
            [self requestData:NO first:NO];
        }
    }
}

- (void)videoPlayFinished:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    BOOL isTopVc = [BTDResponder isTopViewController:self.viewController];
    
    if(!isTopVc){
        return;
    }

    if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]){
        FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *vCell = (FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *)cell;
        UIView *view = [vCell cell_movieView];
        if ([view isKindOfClass:[TTVPlayVideo class]]) {
            TTVPlayVideo *movieView = (TTVPlayVideo *)view;
            
            UIView *tipView = movieView.player.playerView.tipView;
            if([tipView isKindOfClass:[TTVPlayerControlTipView class]]){
                TTVPlayerControlTipView *view = (TTVPlayerControlTipView *)tipView;
                view.finishedView.alpha = 0;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    view.finishedView.alpha = 1;
                });
            }
            
            if (!movieView.player.context.isFullScreen &&
                !movieView.player.context.isRotating) {
                NSInteger row = [self.dataList indexOfObject:cellModel];
                if(row >= 0){
                    row += 1;
                    if(row < self.dataList.count){
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]]){
                            FHUGCFullScreenVideoCell *vCell = (FHUGCFullScreenVideoCell *)cell;
                            self.currentVideoCell.contentView.userInteractionEnabled = NO;
                            vCell.contentView.userInteractionEnabled = YES;
                            self.currentVideoCell = vCell;
                            [vCell play];
                        }

                        if(row >= (self.dataList.count - 3)){
                            //在刷一刷数据
                            [self requestData:NO first:NO];
                        }
                    }else{

                    }
                }
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSInteger row = [self.dataList indexOfObject:cellModel];
                    if(row >= 0){
                        row += 1;
                        if(row < self.dataList.count){
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                            if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]]){
                                FHUGCFullScreenVideoCell *vCell = (FHUGCFullScreenVideoCell *)cell;
                                self.currentVideoCell.contentView.userInteractionEnabled = NO;
                                vCell.contentView.userInteractionEnabled = YES;
                                self.currentVideoCell = vCell;
                                [vCell play];
                            }

                            if(row >= (self.dataList.count - 3)){
                                //在刷一刷数据
                                [self requestData:NO first:NO];
                            }
                        }else{

                        }
                    }
                });
            }
        }
    }
}

- (void)startVideoPlay {
    FHUGCFullScreenVideoCell *cell = [self getFitableVideoCell];
    if(cell != self.currentVideoCell){
        self.currentVideoCell.contentView.userInteractionEnabled = NO;
        cell.contentView.userInteractionEnabled = YES;
        self.currentVideoCell = cell;
    }
    
    if(![self.currentVideoCell cell_isPlaying]){
        [cell play];
    }
}

- (void)readyCurrentVideo {
    FHUGCFullScreenVideoCell *videoCell = [self getFitableVideoCell];
    if(videoCell){
        videoCell.contentView.userInteractionEnabled = YES;
        self.currentVideoCell = videoCell;
    }
}

- (void)autoPlayCurrentVideo {
    [self.currentVideoCell play];
}

- (FHUGCFullScreenVideoCell *)getFitableVideoCell {
    NSArray *cells = [self.tableView visibleCells];
    for (NSInteger i = 0; i < cells.count; i++) {
        UITableViewCell *cell = cells[i];
        if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]){
            FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *vCell = (FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *)cell;
            CGRect frame = [vCell.videoView convertRect:vCell.videoView.bounds toView:self.viewController.view];
            if(frame.origin.y >= CGRectGetMaxY(self.viewController.customNavBarView.frame)){
                return vCell;
            }
        }
    }
    return nil;
}

- (void)stopCurrentVideo {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    if(self.currentVideoCell){
        if([self.currentVideoCell isKindOfClass:[FHUGCFullScreenVideoCell class]] && [self.currentVideoCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]){
            FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *vCell = (FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *)self.currentVideoCell;
            UIView *view = [vCell cell_movieView];
            if ([view isKindOfClass:[TTVPlayVideo class]]) {
                TTVPlayVideo *movieView = (TTVPlayVideo *)view;
                if (!movieView.player.context.isFullScreen &&
                    !movieView.player.context.isRotating) {
                    if (movieView.player.context.playbackState != TTVVideoPlaybackStateBreak || movieView.player.context.playbackState != TTVVideoPlaybackStateFinished) {
                        [movieView stop];
                    }
                    [movieView removeFromSuperview];
                }
            }
            [vCell endDisplay];
        }
    }
}

- (void)pauseCurrentVideo {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    if(self.currentVideoCell){
        if([self.currentVideoCell isKindOfClass:[FHUGCFullScreenVideoCell class]] && [self.currentVideoCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]){
            FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *vCell = (FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *)self.currentVideoCell;
            UIView *view = [vCell cell_movieView];
            if ([view isKindOfClass:[TTVPlayVideo class]]) {
                TTVPlayVideo *movieView = (TTVPlayVideo *)view;
                if (!movieView.player.context.isFullScreen &&
                    !movieView.player.context.isRotating) {
                    if (movieView.player.context.playbackState != TTVVideoPlaybackStateBreak || movieView.player.context.playbackState != TTVVideoPlaybackStateFinished) {
                        [movieView.player pause];
                    }
                }
            }
        }
    }
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
    NSMutableDictionary *dict = [self trackDict:cellModel rank:rank];
    TRACK_EVENT(@"feed_client_show", dict);
    
    if(cellModel.attachCardInfo){
        [self trackCardShow:cellModel rank:rank];
    }
    
    if(cellModel.cellType == FHUGCFeedListCellTypeUGCRecommend){
        //对于热门小区的展现，在cell里面报，这里就不报了
        if(![cellModel.hotCommunityCellType isEqualToString:@"hot_social"]){
            [self trackElementShow:rank elementType:@"like_neighborhood"];
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCHotTopic){
        [self trackElementShow:rank elementType:@"hot_topic"];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2) {
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

- (void)trackElementShow:(NSInteger)rank elementType:(NSString *)elementType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"element_type"] = elementType ? elementType : @"be_null";
    dict[@"page_type"] = [self pageType];
    dict[@"enter_from"] = self.viewController.tracerDict[@"origin_from"];
    dict[@"rank"] = @(rank);
    
    TRACK_EVENT(@"element_show", dict);
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
    return self.categoryId;
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
    dict[@"category_name"] = self.categoryId;
    TRACK_EVENT(@"category_refresh", dict);
}

@end
