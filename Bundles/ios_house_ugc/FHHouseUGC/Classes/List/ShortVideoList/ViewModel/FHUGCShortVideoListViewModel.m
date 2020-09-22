//
//  FHUGCShortVideoListViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHUGCShortVideoListViewModel.h"
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
#import "FHUGCCellHelper.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import "FHUGCShortVideoCell.h"

@interface FHUGCShortVideoListViewModel () <UIScrollViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic ,weak) FHBaseCollectionView *collectionView;
@property(nonatomic, weak) FHUGCShortVideoListController *viewController;
//当第一刷数据不足5个，同时feed还有新内容时，会继续刷下一刷的数据，这个值用来记录请求的次数
@property(nonatomic, assign) NSInteger retryCount;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHUGCCellManager *cellManager;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property(nonatomic, assign) BOOL needRefreshCell;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;

@end

@implementation FHUGCShortVideoListViewModel

- (instancetype)initWithCollectionView:(FHBaseCollectionView *)collectionView controller:(FHUGCShortVideoListController *)viewController {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        self.viewController = viewController;
        self.dataList = [[NSMutableArray alloc] init];
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = self.refer;
        
        [self configCollectionView];
    }
    
    return self;
}

- (void)viewWillAppear {
    self.isShowing = YES;
    [[SSImpressionManager shareInstance] enterGroupViewForCategoryID:self.categoryId concernID:nil refer:self.refer];
}

- (void)viewWillDisappear {
    self.isShowing = NO;
    [[SSImpressionManager shareInstance] leaveGroupViewForCategoryID:self.categoryId concernID:nil refer:self.refer];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[FHUGCShortVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([FHUGCShortVideoCell class])];
    
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.collectionView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
    
    if(self.viewController.tableViewNeedPullDown){
        // 下拉刷新
        [self.collectionView tt_addDefaultPullDownRefreshWithHandler:^{
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
        [self.collectionView finishPullDownWithSuccess:YES];
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
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }

    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.viewController.isLoadingData = NO;

        [wself.collectionView finishPullDownWithSuccess:YES];

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
                        wself.collectionView.hasMore = YES;
                    }else{
                        wself.collectionView.hasMore = feedListModel.hasMore;
                    }

                    //第一次拉取数据过少时，在多拉一次loadmore
                    if(wself.dataList.count > 0 && wself.dataList.count < 5 && wself.collectionView.hasMore && wself.retryCount < 1){
                        wself.retryCount += 1;
                        [wself requestData:NO first:NO];
                        return;
                    }
                    
                    wself.retryCount = 0;
                    wself.viewController.hasValidateData = wself.dataList.count > 0;

                    if(wself.dataList.count > 0){
                        [wself updateTableViewWithMoreData:wself.collectionView.hasMore];
                        [wself.viewController.emptyView hideEmptyView];
                    }else{
                        NSString *tipStr = @"暂无新内容";
                        [wself.viewController.emptyView showEmptyWithTip:tipStr errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:YES];
                        wself.refreshFooter.hidden = YES;
                    }
                    [wself.collectionView reloadData];

                    NSString *refreshTip = feedListModel.tips.displayInfo;
                    if (isHead && wself.dataList.count > 0 && ![refreshTip isEqualToString:@""] && wself.viewController.tableViewNeedPullDown && !wself.isRefreshingTip){
                        wself.isRefreshingTip = YES;
                        [wself.viewController showNotify:refreshTip completion:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                wself.isRefreshingTip = NO;
                            });
                        }];
                        [wself.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    }
                    
                    if(!self.viewController.alreadyReportPageMonitor && [self.categoryId isEqualToString:@"f_news_recommend"]){
                        [FHMainApi addUserOpenVCDurationLog:@"pss_discovery_recommend" resultType:FHNetworkMonitorTypeSuccess duration:[[NSDate date] timeIntervalSince1970] - self.viewController.startMonitorTime];
                        self.viewController.alreadyReportPageMonitor = YES;
                    }
                });
            });
        }
    }];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.collectionView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.collectionView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo || cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo2){
            cellModel.categoryId = self.categoryId;
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

- (NSInteger)getCellIndex:(FHFeedUGCCellModel *)cellModel {
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        FHFeedUGCCellModel *model = self.dataList[i];
        if([model.groupId isEqualToString:cellModel.groupId]){
            return i;
        }
    }
    return -1;
}

- (void)recordGroupWithCellModel:(FHFeedUGCCellModel *)cellModel status:(SSImpressionStatus)status {
    NSString *uniqueID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    /*impression统计相关*/
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryId;
    params.refer = self.refer;
    SSImpressionModelType modelType = [FHUGCCellManager impressModelTypeWithCellType:cellModel.cellType];
    [ArticleImpressionHelper recordItemWithUniqueID:uniqueID modelType:modelType logPb:cellModel.logPb status:status params:params];
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        [self traceClientShowAtIndexPath:indexPath];
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        /*impression统计相关*/
        SSImpressionStatus impressionStatus = self.isShowing ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
        [self recordGroupWithCellModel:cellModel status:impressionStatus];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // impression统计
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusEnd];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCShortVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHUGCShortVideoCell class]) forIndexPath:indexPath];
    
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        [cell refreshWithData:cellModel];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        self.currentCellModel = cellModel;
        NSArray *otherCellModels = nil;
        if((indexPath.row + 1) < self.dataList.count){
            NSInteger count = ((self.dataList.count - indexPath.row - 1) > 3) ? 3 : (self.dataList.count - indexPath.row - 1);
            otherCellModels = [self.dataList subarrayWithRange:NSMakeRange(indexPath.row + 1, count)];
        }
        [self.detailJumpManager jumpToSmallVideoDetail:cellModel otherVideos:otherCellModels showComment:NO enterType:@"feed_content_blank" extraDic:nil];
    }
}

#pragma UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.collectionView){
        if (scrollView.isDragging) {
            [self.viewController.notifyBarView performSelector:@selector(hideIfNeeds) withObject:nil];
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
    if(cellModel.cellSubType == FHUGCFeedListCellSubTypeFullVideo || cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCVideo){
        dict[@"video_type"] = @"video";
    }else if(cellModel.cellSubType == FHUGCFeedListCellSubTypeUGCSmallVideo){
        dict[@"video_type"] = @"small_video";
    }
    dict[@"event_tracking_id"] = @"93415";
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
