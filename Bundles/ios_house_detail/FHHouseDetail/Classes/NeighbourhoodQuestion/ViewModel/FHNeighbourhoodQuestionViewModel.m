//
//  FHNeighbourhoodQuestionViewModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHNeighbourhoodQuestionViewModel.h"
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

@interface FHNeighbourhoodQuestionViewModel () <UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate,UIScrollViewDelegate>

@property(nonatomic, weak) FHNeighbourhoodQuestionController *viewController;
@property(nonatomic, strong) FHFeedUGCCellModel *guideCellModel;
@property(nonatomic, assign) BOOL alreadShowFeedGuide;

@end

@implementation FHNeighbourhoodQuestionViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHNeighbourhoodQuestionController *)viewController {
    self = [super initWithTableView:tableView];
    if (self) {
        self.viewController = viewController;
        self.dataList = [[NSMutableArray alloc] init];
        [self configTableView];
    }
    
    return self;
}

- (void)dealloc {
    
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
            [wself requestData:YES first:NO];
        }];
    }
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.viewController.isLoadingData){
        return;
    }
    
    self.viewController.isLoadingData = YES;
    
    
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
        lastGroupId = cellModel.qid;
    }
    if(isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList firstObject];
        behotTime = [cellModel.behotTime doubleValue];
        lastGroupId = cellModel.qid;
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
    FHNeighbourhoodQuestionController *vc = (FHNeighbourhoodQuestionController *)self.viewController;
    if(vc.neighborhoodId){
        [extraDic setObject:vc.neighborhoodId forKey:@"neighborhood_id"];
    }
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.viewController.isLoadingData = NO;
        if(isFirst){
            [wself.viewController endLoading];
        }
        
        [wself.tableView finishPullDownWithSuccess:YES];
        
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        
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
    //fake
//    if(isHead){
//        [resultArray addObject:[FHFeedUGCCellModel modelFromFake3:YES]];
//        [resultArray addObject:[FHFeedUGCCellModel modelFromFake3:YES]];
//        [resultArray addObject:[FHFeedUGCCellModel modelFromFake3:YES]];
//        [resultArray addObject:[FHFeedUGCCellModel modelFromFake3:YES]];
////        [self removeDuplicaionModel:[FHFeedUGCCellModel modelFromFake].groupId];
//    }

    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.isInNeighbourhoodQAList = YES;
        cellModel.categoryId = self.categoryId;
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
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

#pragma UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewController.scrollViewDelegate scrollViewDidScroll:scrollView];
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
    dict[@"origin_from"] = self.viewController.tracerDict[@"origin_from"];
    dict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"];
    dict[@"element_from"] = self.viewController.tracerDict[@"element_from"];
    dict[@"page_type"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    dict[@"group_id"] = cellModel.groupId;
    dict[@"category_name"] = self.categoryId;
    
    if([self.viewController isKindOfClass:[FHNeighbourhoodQuestionController class]]){
        FHNeighbourhoodQuestionController *vc = (FHNeighbourhoodQuestionController *)self.viewController;
        dict[@"from_gid"] = vc.neighborhoodId;
    }
    
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
    return @"neighborhood_question_list";
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

@end
