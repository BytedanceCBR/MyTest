//
//  FHPersonalHomePageViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageViewModel.h"
#import "FHPersonalHomePageProfileInfoModel.h"
#import "FHPersonalHomePageTabListModel.h"
#import "FHPersonalHomePageManager.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHHouseUGCAPI.h"
#import "FHCommonDefines.h"
#import "FHPersonalHomePageManager.h"


@interface FHPersonalHomePageViewModel () <UIScrollViewDelegate>
@property(nonatomic,weak) FHPersonalHomePageViewController *viewController;
@property(nonatomic,strong) FHPersonalHomePageProfileInfoModel *profileInfoModel;
@property(nonatomic,strong) FHPersonalHomePageTabListModel *tabListModel;
@property(nonatomic,strong) dispatch_group_t personalHomePageGroup;
@end

@implementation FHPersonalHomePageViewModel

-(instancetype)initWithController:(FHPersonalHomePageViewController *)viewController {
    if(self = [super init]) {
        self.viewController = viewController;
        self.viewController.scrollView.delegate = self;

        self.personalHomePageGroup = dispatch_group_create();
    }
    return self;
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.viewController startLoading];
        self.viewController.isLoadingData = YES;
        [self requestProfileInfo];
        [self requestFeedTabList];
        
        dispatch_group_notify(self.personalHomePageGroup, dispatch_get_main_queue(), ^{
            [self.viewController endLoading];
            [self.homePageManager updateProfileInfoWithModel:self.profileInfoModel tabListWithMdoel:self.tabListModel];
        });
    } else {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)requestProfileInfo {
    dispatch_group_enter(self.personalHomePageGroup);
    WeakSelf;
    NSString *userId = self.homePageManager.userId;
   [FHHouseUGCAPI requestHomePageInfoWithUserId:userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
       StrongSelf;
       if(!error && [model isKindOfClass:[FHPersonalHomePageProfileInfoModel class]]) {
           FHPersonalHomePageProfileInfoModel *profileInfoModel = (FHPersonalHomePageProfileInfoModel *) model;
           if([profileInfoModel.message isEqualToString:@"success"] && [profileInfoModel.errorCode integerValue] == 0) {
               self.profileInfoModel = profileInfoModel;
           }
       }
       dispatch_group_leave(self.personalHomePageGroup);
    }];
}

- (void)requestFeedTabList {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"channel_id"] = @"94349558589";
    params[@"user_id"] = self.homePageManager.userId;
    
    dispatch_group_enter(self.personalHomePageGroup);
    WeakSelf;
    [FHHouseUGCAPI requestPersonalHomePageTabList:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        if(!error && [model isKindOfClass:[FHPersonalHomePageTabListModel class]]) {
            FHPersonalHomePageTabListModel *tabListModel = (FHPersonalHomePageTabListModel *) model;
            self.tabListModel = tabListModel;
        }
        dispatch_group_leave(self.personalHomePageGroup);
    }];
<<<<<<< HEAD
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
=======
>>>>>>> f_alpha

}

-(void)requestProfileInfoAfterChange {
    if ([TTReachability isNetworkConnected]) {
        [self.viewController startLoading];
        self.viewController.isLoadingData = YES;
        [self requestProfileInfo];

        dispatch_group_notify(self.personalHomePageGroup, dispatch_get_main_queue(), ^{
            [self.viewController endLoading];
            [self.homePageManager updateProfileInfoWithModel:self.profileInfoModel];
        });
    } else {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.homePageManager scrollViewScroll:scrollView];
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.homePageManager scrollsToTop];
    return YES;
}



@end
