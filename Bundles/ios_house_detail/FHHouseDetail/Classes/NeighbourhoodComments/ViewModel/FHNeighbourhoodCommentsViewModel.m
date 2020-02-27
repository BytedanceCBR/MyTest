//
//  FHNeighbourhoodCommentsViewModel.m
//  FHHouseDetail
//
//  Created by 王志舟 on 2020/2/23.
//

#import "FHNeighbourhoodCommentsViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHTopicListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedUGCCellModel.h"
#import "Article.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "FHUGCGuideHelper.h"
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

@interface FHNeighbourhoodCommentsViewModel () <UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate,UIScrollViewDelegate>

@property(nonatomic, strong) FHFeedUGCCellModel *guideCellModel;
@property(nonatomic, assign) BOOL alreadShowFeedGuide;

@end

@implementation FHNeighbourhoodCommentsViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHNeighbourhoodCommentsController *)viewController {
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
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

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.viewController.isLoadingData){
        return;
    }
    
    self.viewController.isLoadingData = YES;
    
    if(self.isRefreshingTip){
        [self.tableView finishPullDownWithSuccess:YES];
        return;
    }
    
    if(isFirst){
        [self.viewController startLoading];
    }
    
    __weak typeof(self) wself = self;
    
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
    if(isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList firstObject];
        behotTime = [cellModel.behotTime doubleValue];
        lastGroupId = cellModel.groupId;
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
    if(lastGroupId){
        [extraDic setObject:lastGroupId forKey:@"last_group_id"];
    }
    FHNeighbourhoodCommentsController *vc = (FHNeighbourhoodCommentsController *)self.viewController;
    if(vc.neighborhoodId){
        [extraDic setObject:vc.neighborhoodId forKey:@"neighborhood_id"];
    }
    @weakify(self);
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        @strongify(self);
        wself.viewController.isLoadingData = NO;
        if(isFirst){
            [wself.viewController endLoading];
        }
        
        [wself.tableView finishPullDownWithSuccess:YES];
        
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        
        if(wself.viewController.title.length > 0) {
            NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:@"[0-9]+" options:NSRegularExpressionCaseInsensitive error:nil];
            NSMutableString *title = [regExp stringByReplacingMatchesInString:self.viewController.title options:NSMatchingReportProgress range:NSMakeRange(0, self.viewController.title.length) withTemplate:wself.feedListModel.totalNumber];
            self.viewController.customNavBarView.title.text = title;
        }
        
        if (!wself) {
            return;
        }
        
        if (error) {
            //TODO: show handle error
            if(isFirst){
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
            if(isHead){
                [wself.dataList removeAllObjects];
            }
            
            wself.tableView.hasMore = feedListModel.hasMore;
            
            NSArray *result = [wself convertModel:feedListModel.data isHead:isHead];
            
            if(isFirst){
                [self.clientShowDict removeAllObjects];
                [wself.dataList removeAllObjects];
            }
            if(isHead){
                // JOKER: 头部插入时，旧数据的置顶全部取消，以新数据中的置顶贴子为准
                [self.dataList enumerateObjectsUsingBlock:^(FHFeedUGCCellModel *  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    cellModel.isStick = NO;
                }];
                // 头部插入新数据
                [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
            }else{
                [wself.dataList addObjectsFromArray:result];
            }
            
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                [wself.viewController.emptyView hideEmptyView];
            }else{
                [wself.viewController.emptyView showEmptyWithTip:@"暂无新内容，快去发布吧" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
                wself.viewController.showenRetryButton = NO;
                wself.refreshFooter.hidden = YES;
            }
            [wself.tableView reloadData];
            
            NSString *refreshTip = feedListModel.tips.displayInfo;
            if (isHead && wself.dataList.count > 0 && ![refreshTip isEqualToString:@""] && wself.viewController.tableViewNeedPullDown && !wself.isRefreshingTip){
                wself.isRefreshingTip = YES;
                [wself.viewController showNotify:refreshTip completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.isRefreshingTip = NO;
                    });
                }];
                [wself.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
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
        cellModel.isInNeighbourhoodCommentsList = YES;
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodComments;
        cellModel.categoryId = self.categoryId;
        cellModel.feedVC = self.viewController;
        cellModel.tableView = self.tableView;
        cellModel.enterFrom = [self.viewController categoryName];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        
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
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    self.currentCellModel = cellModel;
    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
    [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
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

- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        if(cellModel.hasVideo){
            //跳转视频详情页
            [self jumpToVideoDetail:cellModel showComment:showComment enterType:enterType];
        }else{
            BOOL canOpenURL = NO;
            if (!canOpenURL && !isEmptyString(cellModel.openUrl)) {
                NSURL *url = [TTStringHelper URLWithURLString:cellModel.openUrl];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    canOpenURL = YES;
                    [[UIApplication sharedApplication] openURL:url];
                }
                else if([[TTRoute sharedRoute] canOpenURL:url]){
                    canOpenURL = YES;
                    //优先跳转openurl
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                }
            }else{
                NSURL *openUrl = [NSURL URLWithString:cellModel.detailScheme];
                [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
            }
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGC){
        [self jumpToPostDetail:cellModel showComment:showComment enterType:enterType];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2){
        //根据url跳转
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeArticleComment || cellModel.cellType == FHUGCFeedListCellTypeArticleComment2){
        // 评论
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"enter_from"] = @"hot_discuss_feed";
        traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
        traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
        traceParam[@"log_pb"] = cellModel.logPb;
        dict[TRACER_KEY] = traceParam;
        
        dict[@"data"] = cellModel;
        dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
        dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        // 问题 回答
        NSDictionary *dict = @{@"is_jump_comment":@(showComment)};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVote){
        [self goToVoteDetail:cellModel value:0];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo){
        //小视频
        if (![TTReachability isNetworkConnected]) {
            [[ToastManager manager] showToast:@"网络异常"];
            return;
        }
        WeakSelf;
        TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
            StrongSelf;
            CGRect imageFrame = [self selectedSmallVideoFrame];
            imageFrame.origin = CGPointZero;
            return imageFrame;
        } updateTargetViewBlock:^UIView *{
            StrongSelf;
            return [self currentSelectSmallVideoView];
        }];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        [info setValue:exitManager forKey:HTSVideoDetailExitManager];
        if (showComment) {
            [info setValue:@(1) forKey:AWEVideoShowComment];
        }
        if(cellModel.tracerDic){
            NSMutableDictionary *tracerDic = [cellModel.tracerDic mutableCopy];
            tracerDic[@"page_type"] = @"small_video_detail";
            tracerDic[@"enter_type"] = enterType;
            tracerDic[@"enter_from"] = [self pageType];
            [info setValue:tracerDic forKey:@"extraDic"];
        }
        
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:TTRouteUserInfoWithDict(info)];
    }  else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVoteInfo) {
        // 投票
        NSMutableDictionary *dict = @{@"begin_show_comment":@(showComment)}.mutableCopy;
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"enter_from"] = @"hot_discuss_feed";
        traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
        traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
        traceParam[@"log_pb"] = cellModel.logPb;
        dict[@"tracer"] = traceParam;
        dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)jumpToPostDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_from"] = @"hot_discuss_feed";
    traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    dict[TRACER_KEY] = traceParam;
    
    dict[@"data"] = cellModel;
    dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
    dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    FHFeedUGCContentModel *contentModel = cellModel.originData;
    NSString *routeUrl = @"sslocal://thread_detail";
    if (contentModel && [contentModel isKindOfClass:[FHFeedUGCContentModel class]]) {
        NSString *schema = contentModel.schema;
        if (schema.length > 0) {
            routeUrl = schema;
        }
    }
    
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)jumpToVideoDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    NSMutableDictionary *dict = @{}.mutableCopy;
    
    if(self.currentCell && [self.currentCell isKindOfClass:[FHUGCVideoCell class]]){
        FHUGCVideoCell *cell = (FHUGCVideoCell *)self.currentCell;
        
        TTVFeedCellSelectContext *context = [[TTVFeedCellSelectContext alloc] init];
        context.refer = self.refer;
        context.categoryId = self.categoryId;
        context.feedListViewController = self;
        context.clickComment = showComment;
        context.enterType = enterType;
        context.enterFrom = [self pageType];
        
        [cell didSelectCell:context];
    }else if (cellModel.openUrl) {
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
    self.needRefreshCell = NO;
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
    [self jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    //关闭引导cell
    [FHUGCGuideHelper hideFeedGuide];
    
    if(cellModel.community.socialGroupId){
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = cellModel.community.socialGroupId;
        dict[@"tracer"] = @{@"enter_from":@"hot_discuss_feed",
                            @"enter_type":@"click",
                            @"rank":cellModel.tracerDic[@"rank"] ?: @"be_null",
                            @"log_pb":cellModel.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)closeFeedGuide:(FHFeedUGCCellModel *)cellModel {
    self.alreadShowFeedGuide = YES;
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

- (void)goToVoteDetail:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    [self trackVoteClickOptions:cellModel value:value];
    if([TTAccountManager isLogin] || !cellModel.vote.needUserLogin){
        if(cellModel.vote.openUrl){
            NSString *urlStr = cellModel.vote.openUrl;
            if(value > 0){
                NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                urlStr = [urlStr stringByAppendingString:append];
            }
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        [self gotoLogin:cellModel value:value];
    }
}

- (void)gotoLogin:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value  {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self pageType] forKey:@"enter_from"];
    [params setObject:@"" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(cellModel.vote.openUrl){
                        NSString *urlStr = cellModel.vote.openUrl;
                        if(value > 0){
                            NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                            urlStr = [urlStr stringByAppendingString:append];
                        }
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                    }
                });
            }
        }
    }];
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
}

- (void)trackElementShow:(NSInteger)rank elementType:(NSString *)elementType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"element_type"] = elementType ? elementType : @"be_null";
    dict[@"page_type"] = @"hot_discuss_feed";
    dict[@"enter_from"] = @"neighborhood_tab";
    dict[@"rank"] = @(rank);
    
    TRACK_EVENT(@"element_show", dict);
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"];
    dict[@"page_type"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    dict[@"comment_id"] = cellModel.groupId;
    
    return dict;
}

- (NSString *)pageType {
    return @"neiborhood_comment_list";
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_comment";
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
@end
