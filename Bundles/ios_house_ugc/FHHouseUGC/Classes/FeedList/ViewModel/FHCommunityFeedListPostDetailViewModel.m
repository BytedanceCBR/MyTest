//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListPostDetailViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHTopicListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedUGCCellModel.h"
#import "Article.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "TTRoute.h"
#import "TTUGCDefine.h"
#import "FHUGCModel.h"
#import "FHFeedUGCContentModel.h"
#import "FHFeedListModel.h"
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
#import "FHUGCFullScreenVideoCell.h"
#import "FHCommunityFeedListController.h"
#import "UIDevice+BTDAdditions.h"

@interface FHCommunityFeedListPostDetailViewModel () <UITableViewDelegate, UITableViewDataSource,FHUGCBaseCellDelegate>

@property(nonatomic, weak) FHCommunityFeedListController *viewController;
@property(nonatomic, strong) FHErrorView *errorView;
//当第一刷数据不足5个，同时feed还有新内容时，会继续刷下一刷的数据，这个值用来记录请求的次数
@property(nonatomic, assign) NSInteger retryCount;

@end

@implementation FHCommunityFeedListPostDetailViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super initWithTableView:tableView];
    if (self) {
        self.viewController = viewController;
        self.dataList = [[NSMutableArray alloc] init];
        [self configTableView];
        // 删帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCDelPostNotification object:nil];
        // 举报成功
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCReportPostNotification object:nil];
        // 发帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
        // 置顶或取消置顶成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postTopSuccess:) name:kFHUGCTopPostNotification object:nil];
        // 加精或取消加精成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postGoodSuccess:) name:kFHUGCGoodPostNotification object:nil];
        
        // 编辑成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadSuccessNotification" object:nil]; // 编辑发送成功
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isNotInAllTab {
    return self.tabName && ![self.tabName isEqualToString:tabAll];
}

// 编辑发送成功 - 更新数据
- (void)postEditNoti:(NSNotification *)noti {
    //多个tab时候，仅仅更新全部页面数据
    if([self isNotInAllTab]){
        return;
    }
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
                    cellModel.showCommunity = NO;
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

// 发帖成功，插入数据
- (void)postThreadSuccess:(NSNotification *)noti {
    //多个tab时候，仅仅强插在全部页面
    if([self isNotInAllTab]){
        return;
    }
    
    if (noti && noti.userInfo) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = nil;
        FHFeedContentModel *ugcContent = userInfo[@"feed_content"];
        if(ugcContent && [ugcContent isKindOfClass:[FHFeedContentModel class]]){
            cellModel = [FHFeedUGCCellModel modelFromFeedContent:ugcContent];
        }else if(userInfo[@"cell_model"]){
            cellModel = userInfo[@"cell_model"];
        }
        
        if(cellModel) {
            cellModel.tableView = self.tableView;
            cellModel.isFromDetail = NO;
            [self insertPostData:cellModel socialGroupIds:nil];
        }
    }
}
// 发帖和发投票后插入逻辑 social_group_ids 为空直接用cellModel.community.socialGroupId
- (void)insertPostData:(FHFeedUGCCellModel *)cellModel socialGroupIds:(NSString *)social_group_ids {
    if (cellModel == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        cellModel.showCommunity = NO;
        cellModel.feedVC = self.viewController;
        // 判断是否是需要插入的圈子,关注直接插入 不需要判断逻辑
        NSString *socialGroups = social_group_ids;
        if (socialGroups.length <= 0) {
            socialGroups = cellModel.community.socialGroupId;
        }
        if (cellModel && self.viewController.forumId.length > 0 && [socialGroups containsString:self.viewController.forumId]) {
            //去重逻辑
            [self removeDuplicaionModel:cellModel.groupId];
            // JOKER: 找到第一个非置顶贴的下标
            __block NSUInteger index = self.dataList.count;
            [self.dataList enumerateObjectsUsingBlock:^(FHFeedUGCCellModel*  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BOOL isStickTop = cellModel.isStick && (cellModel.stickStyle == FHFeedContentStickStyleTop || cellModel.stickStyle == FHFeedContentStickStyleTopAndGood);
                
                if(!isStickTop) {
                    index = idx;
                    *stop = YES;
                }
            }];
            
            if(self.viewController.beforeInsertPostBlock){
                self.viewController.beforeInsertPostBlock();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 插入在置顶贴的下方
                [self.dataList insertObject:cellModel atIndex:index];
                [self reloadTableViewData];
                [self.tableView layoutIfNeeded];
                self.needRefreshCell = NO;
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
        }
    });
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

- (FHErrorView *)errorView {
    if(!_errorView){
        _errorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400)];
    }
    return _errorView;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.viewController.isLoadingData){
        return;
    }
    
    self.viewController.needReloadData = NO;
    self.viewController.isLoadingData = YES;
    
    if(isFirst){
        self.tableView.scrollEnabled = NO;
        [self.viewController startLoading];
        self.retryCount = 0;
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
    if(self.socialGroupId){
        [extraDic setObject:self.socialGroupId forKey:@"social_group_id"];
    }
    if(lastGroupId){
        [extraDic setObject:lastGroupId forKey:@"last_group_id"];
    }
    if(self.tabName){
        [extraDic setObject:self.tabName forKey:@"tab_name"];
    }
    
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.viewController.isLoadingData = NO;
        if(isFirst){
            wself.tableView.scrollEnabled = YES;
        }
        
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
                if(isHead){
                    [wself.dataList removeAllObjects];
                }
                
                wself.tableView.hasMore = feedListModel.hasMore;
                
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
                    //第一次拉取数据过少时，在多拉一次loadmore
                    if(self.dataList.count > 0 && self.dataList.count < 5 && self.tableView.hasMore && self.retryCount < 1){
                        self.retryCount += 1;
                        [self requestData:NO first:NO];
                        return;
                    }
                    
                    wself.viewController.hasValidateData = wself.dataList.count > 0;
                    [wself reloadTableViewData];
                    
                    if(wself.viewController.requestSuccess){
                        wself.viewController.requestSuccess(wself.viewController.hasValidateData);
                    }
                });
            });
        }
    }];
}

- (void)reloadTableViewData {
    if(self.dataList.count > 0){
        [self updateTableViewWithMoreData:self.tableView.hasMore];
        self.tableView.backgroundColor = [UIColor themeGray7];
        
        CGFloat height = [self getVisibleHeight:5];
        if(height < self.viewController.errorViewHeight && height > 0 && self.viewController.errorViewHeight > 0){
            [self.tableView reloadData];
            CGFloat refreshFooterBottomHeight = self.tableView.mj_footer.height;
            if ([UIDevice btd_isIPhoneXSeries]) {
                refreshFooterBottomHeight += 34;
            }
            //设置footer来占位
            UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.viewController.errorViewHeight - height - refreshFooterBottomHeight)];
            tableFooterView.backgroundColor = [UIColor clearColor];
            self.tableView.tableFooterView = tableFooterView;
//            //修改footer的位置回到cell下方，不修改会在tableFooterView的下方
//            self.tableView.mj_footer.mj_y -= tableFooterView.height;
//            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,0.001)];
            [self.tableView reloadData];
        }
    }else{
        if([self isNotInAllTab]){
            [self.errorView showEmptyWithTip:@"暂无内容" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        }else{
            [self.errorView showEmptyWithTip:@"该圈子还没有内容，快去发布吧" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        }
        
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.viewController.errorViewHeight)];
        tableFooterView.backgroundColor = [UIColor whiteColor];
        [tableFooterView addSubview:self.errorView];
        self.tableView.tableFooterView = tableFooterView;
        self.refreshFooter.hidden = YES;
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.tableView reloadData];
    }
    self.retryCount = 0;
}

- (void)showCustomErrorView:(FHEmptyMaskViewType)type {
    if(self.dataList.count <= 0){
        [self.errorView showEmptyWithTip:@"网络异常" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.viewController.errorViewHeight)];
        tableFooterView.backgroundColor = [UIColor whiteColor];
        [tableFooterView addSubview:self.errorView];
        self.tableView.tableFooterView = tableFooterView;
        self.refreshFooter.hidden = YES;
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.tableView reloadData];
    }
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

- (CGFloat)getVisibleHeight:(NSInteger)maxCount {
    CGFloat height = 0;
    if(self.dataList.count <= maxCount){
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
            if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
                height += [cellClass heightForData:cellModel];
            }
        }
    }
    return height;
}

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.categoryId = self.categoryId;
        cellModel.feedVC = self.viewController;
        cellModel.tableView = self.tableView;
        cellModel.showCommunity = NO;
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

- (void)postDeleteSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        [self deleteCell:cellModel];
    }
}

- (void)postTopSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        cellModel.showCommunity = NO;
        BOOL isTop = [userInfo[@"isTop"] boolValue];
        [self topCell:cellModel isTop:isTop];
    }
}

- (void)postGoodSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        NSInteger row = [self getCellIndex:cellModel];
        
        if(row < self.dataList.count && row >= 0){
            FHFeedUGCCellModel *originCellModel = self.dataList[row];
            originCellModel.isStick = cellModel.isStick;
            originCellModel.stickStyle = cellModel.stickStyle;
            originCellModel.contentDecoration = cellModel.contentDecoration;
            originCellModel.ischanged = YES;
            
            [self refreshCell:originCellModel];
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
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.viewController.scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:YES];
}

- (void)topCell:(FHFeedUGCCellModel *)cellModel isTop:(BOOL)isTop {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        FHFeedUGCCellModel *originCellModel = self.dataList[row];
        originCellModel.isStick = cellModel.isStick;
        originCellModel.stickStyle = cellModel.stickStyle;
        originCellModel.contentDecoration = cellModel.contentDecoration;
        originCellModel.ischanged = YES;
        
        [self.dataList removeObjectAtIndex:row];
        if(isTop){
            [self.dataList insertObject:originCellModel atIndex:0];
        }else{
            if(self.dataList.count == 0){
                [self.dataList insertObject:originCellModel atIndex:0];
            }else{
                for (NSInteger i = 0; i < self.dataList.count; i++) {
                    FHFeedUGCCellModel *item = self.dataList[i];
                    //最后还没找到，插到最后
                    
                    if(!item.isStick || (item.isStick && (item.stickStyle != FHFeedContentStickStyleTop && item.stickStyle != FHFeedContentStickStyleTopAndGood))){
                        //找到第一个不是置顶的cell
                        [self.dataList insertObject:originCellModel atIndex:i];
                        break;
                    }
                    
                    if(i == (self.dataList.count - 1)){
                        [self.dataList insertObject:originCellModel atIndex:(i + 1)];
                        break;
                    }
                }
                
            }
        }
        [self reloadTableViewData];
    }
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.dataList removeObjectAtIndex:row];
        [self reloadTableViewData];
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
    NSMutableDictionary *dict =  [self trackDict:cellModel rank:rank];
    if(cellModel.cellSubType == FHUGCFeedListCellSubTypeFullVideo || cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCVideo){
        dict[@"video_type"] = @"video";
    }else if(cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCSmallVideo){
        dict[@"video_type"] = @"small_video";
    }
    if (cellModel.cellSubType == FHUGCFeedListCellSubTypeSmallVideoList ) {
        dict[@"group_id"] = cellModel.originGroupId;
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
    dict[@"category_name"] = [self categoryName];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    dict[@"group_id"] = cellModel.groupId;
    dict[@"social_group_id"] = self.socialGroupId;
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
    return @"community_group_detail";
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

- (NSString *)categoryName {
    NSString *str = @"";
    
    if(self.categoryId.length > 0){
        str = [str stringByAppendingString:self.categoryId];
    }
    
    if(self.tabName.length > 0){
        str = [str stringByAppendingString: [NSString stringWithFormat:@"_%@",self.tabName]];
    }
    
    return str;
}

@end
