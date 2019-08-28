//
//  FHTopicDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/22.
//

#import "FHTopicDetailViewModel.h"
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

@interface FHTopicDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHTopicDetailViewController *detailController;
@property(nonatomic , weak) TTHttpTask *httpTopHeaderTask;
@property(nonatomic , weak) TTHttpTask *httpTopListTask;
@property (nonatomic, assign)   BOOL       canScroll;
@property (nonatomic, assign)   NSInteger       loadDataSuccessCount;
@property (nonatomic, strong)   NSMutableArray       *dataList;// FeedList数据，目前只有一个tab
@property (nonatomic, assign)   BOOL       hasFeedListData;// 第一次加载数据成功
@property (nonatomic, assign)   NSInteger       count;
@property (nonatomic, assign)   NSInteger       feedOffset;
@property (nonatomic, assign)   BOOL       hasMore;

@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property (nonatomic, assign)   BOOL       needRefreshCell;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;

@property(nonatomic, assign) NSInteger refer;
@property(nonatomic, assign) BOOL isShowing;
@property(nonatomic, copy) NSString *categoryName;

@end

@implementation FHTopicDetailViewModel

-(instancetype)initWithController:(FHTopicDetailViewController *)viewController
{   self = [super init];
    if (self) {
        self.detailController = viewController;
        self.ugcCellManager = [[FHUGCCellManager alloc] init];
        self.canScroll = NO;
        self.hasFeedListData = NO;
        self.hasMore = NO;
        self.needRefreshCell = NO;
        self.refer = 1;
        self.isShowing = NO;
        self.categoryName = @"forum_topic_thread";// 频道名称 服务端返回
        self.count = 20;// 每次20条
        self.feedOffset = 0;
        self.dataList = [[NSMutableArray alloc] init];
        self.hashTable = [NSHashTable weakObjectsHashTable];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCGoTop" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:nil];
        // 删帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCDelPostNotification object:nil];
        // 举报成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCReportPostNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadData {
    self.loadDataSuccessCount = 0;// 网络接口返回计数
    [self loadHeaderData];
    [self loadFeedListData];
}

// 请求顶部的header
- (void)loadHeaderData {
    if (self.httpTopHeaderTask) {
        [self.httpTopHeaderTask cancel];
    }
    __weak typeof(self) wSelf = self;
    self.httpTopHeaderTask = [FHHouseUGCAPI requestTopicHeader:@"" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;
        if (error) {
            wSelf.headerModel = nil;
        } else {
            if ([model isKindOfClass:[FHTopicHeaderModel class]]) {
                wSelf.headerModel = model;
                [wSelf.detailController refreshHeaderData];
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
    self.feedOffset = 0;
    __weak typeof(self) wSelf = self;
    self.httpTopListTask = [FHHouseUGCAPI requestTopicList:@"" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;
        if (error) {
            if (wSelf.feedOffset == 0) {
                // 说明是第一次请求
            } else {
                // 上拉加载loadmore
            }
        } else {
            if ([model isKindOfClass:[FHTopicFeedListModel class]]) {
                wSelf.hasFeedListData = YES;
                FHTopicFeedListModel *feedList = (FHTopicFeedListModel *)model;
                if (wSelf.feedOffset == 0) {
                    // 说明是第一次请求
                    [wSelf.dataList removeAllObjects];
                } else {
                    // 上拉加载loadmore
                }
                // 数据转模型 添加数据
                [feedList.data enumerateObjectsUsingBlock:^(FHTopicFeedListDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[FHTopicFeedListDataModel class]]) {
                        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:obj.content];
                        [wSelf.dataList addObject:cellModel];
                    }
                }];
        
                wSelf.hasMore = feedList.hasMore;
                wSelf.feedOffset = [feedList.offset integerValue];
            }
        }
        [wSelf processLoadingState];
    }];
}

// 刷新数据和状态
- (void)processLoadingState {
    if (self.loadDataSuccessCount >= 2) {
        [self.detailController endLoading];
        self.detailController.isLoadingData = NO;
        // 刷新数据
        if (self.headerModel && self.hasFeedListData && self.dataList.count > 0) {
            // 数据ok
            [self.detailController hiddenEmptyView];
            [self.detailController refreshHeaderData];
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
        } else {
            [self.detailController showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
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
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // impression统计
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusEnd];
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
        [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCLeaveTop" object:nil userInfo:@{@"canScroll":@"1"}];
    }
}

-(void)acceptMsg:(NSNotification *)notification{
    NSString *notificationName = notification.name;
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
    [self refreshCurrentCell];
}

- (void)viewWillDisappear {
    self.isShowing = NO;
}

- (void)refreshCurrentCell {
    if(self.needRefreshCell){
        self.needRefreshCell = NO;
        [self.currentCell refreshWithData:self.currentCellModel];
    }
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
    [self jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    //关闭引导cell
    if(cellModel.community.socialGroupId){
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = cellModel.community.socialGroupId;
        dict[@"tracer"] = @{@"enter_from":@"hot_discuss_feed_from",
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
    
}

// go detail
- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
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
        BOOL jump_comment = NO;
        if (showComment) {
            jump_comment = YES;
        }
        NSDictionary *dict = @{@"is_jump_comment":@(jump_comment)};
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
    self.needRefreshCell = YES;
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
    
    if(cellModel.isInsertGuideCell){
        NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
        guideDict[@"element_type"] = @"feed_community_guide_notice";
        guideDict[@"page_type"] = @"nearby_list";
        guideDict[@"enter_from"] = @"neighborhood_tab";
        TRACK_EVENT(@"element_show", guideDict);
    }
    
    if(cellModel.cellType == FHUGCFeedListCellTypeUGCRecommend){
        [self trackElementShow:rank];
    }
}

- (void)trackElementShow:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"element_type"] = @"like_neighborhood";
    dict[@"page_type"] = @"nearby_list";
    dict[@"enter_from"] = @"neighborhood_tab";
    dict[@"rank"] = @(rank);
    
    TRACK_EVENT(@"element_show", dict);
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"enter_from"] = @"nearby_list";
    dict[@"page_type"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    
    return dict;
}

- (NSString *)pageType {
    return @"topic_detail";
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
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:uniqueID itemID:itemID impressionID:nil aggrType:[cellModel.aggrType integerValue]];
    [ArticleImpressionHelper recordGroupWithUniqueID:uniqueID adID:nil groupModel:groupModel status:status params:params];
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {
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
}

@end
