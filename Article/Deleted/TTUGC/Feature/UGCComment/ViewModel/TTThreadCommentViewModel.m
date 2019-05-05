//
//  TTThreadCommentViewModel.m
//  Article
//
//  Created by chenjiesheng on 2017/1/18.
//
//

#import "TTThreadCommentViewModel.h"
#import "SSImpressionManager.h"
#import "TTGroupModel.h"
#import "TTThreadCommentEntity.h"
#import "FRForumServer.h"
#import "TTUniversalCommentLayout.h"
#import "FRForumMonitor.h"
#import "FRForumMonitorModel.h"
#import "TTAccountManager.h"
#import "TTCommentReplyModel.h"
#import "ExploreMomentDefine.h"

@interface TTThreadCommentViewModel ()
@property(nonatomic, strong) NSMutableDictionary <NSNumber *, TTCommentManagedObject *> *commentCategoryModels;
@property(nonatomic, strong) NSArray *stashStickCommentModels; //置顶评论太少时,本地暂存, 等下一次接口回来合并数据 😔写的心好累
@property(nonatomic, strong) NSArray <NSString *> *commentTabNames;
@property(nonatomic, assign) TTCommentCategory curCommentCategory;
@property(nonatomic, assign) TTCommentLoadMode lastLoadMode;
@property(nonatomic, assign, readwrite)BOOL detailNoComment;
@property(nonatomic, assign) BOOL hasSendFooterCellShowTracker;

/**
 *  核心标记。控件通过KVO监听，是否刷新列表。包括init、切换category和loadMore
 */
@property(nonatomic, assign) BOOL reloadFlag;

// UGC
@property(nonatomic, strong) NSError *refreshError;
@property(nonatomic, assign) uint64_t networkConsume;

@property(nonatomic, strong) NSString *authorID;
@end

@implementation TTThreadCommentViewModel

- (void)dealloc
{
    [self removeNotifications];
}

- (instancetype)initWithAuthorID:(NSString *)authorID
{
    self = [super init];
    if (self) {
        self.authorID = authorID;
        [self _commonInit];
        [self registerNotifications];
    }
    return self;
}

- (void)_commonInit
{
    _commentCategoryModels = [NSMutableDictionary dictionaryWithCapacity:2];
    _isLoading = NO;
    _isLoadingMore = NO;
    _curCommentCategory = TTCommentCategoryHot;
    _hasMoreStickComment = YES;
}

#pragma mark - public

- (void)tt_startLoadCommentsForMode:(TTCommentLoadMode)loadMode
              withCompletionHandler:(TTLoadCommentsCompletionHandler)handler
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(tt_loadCommentsForMode:possibleLoadMoreOffset:options:finishBlock:)]) {
        self.lastLoadMode = loadMode;
        if ([self p_isValidLoadRequest]) {
            [self p_setViewModelFlagsWithLoadMode:loadMode];
            WeakSelf;
            uint64_t startTime = [NSObject currentUnixTime];
            void (^finishBlock)(NSDictionary *, NSError *) = ^(NSDictionary *results, NSError *error) {
                FRArticleV2TabCommentsResponseModel *respModel = [[FRArticleV2TabCommentsResponseModel alloc] initWithDictionary:results error:nil];
                self.refreshError = error;
                if (error) {
                    self.loadResult = TTCommentLoadResultFailed;
                    [self p_resetViewModelFlags];
                    if (handler) {
                        handler(error);
                    }
                }
                else {
                    self.goTopicDetail = respModel.go_topic_detail.boolValue;
                    self.hasFoldComment = respModel.fold_comment_count.integerValue > 0;
                    self.hasMoreStickComment = respModel.stick_has_more.integerValue > 0;
                    if (loadMode == TTCommentLoadModeRefresh) {
                        [self p_parseRefreshResult:respModel withCompletionHandler:^{
                            if (handler) {
                                handler(error);
                            }
                        }];
                    }
                    else {
                        [self p_parseLoadMoreResult:respModel withCompletionHandler:^{
                            if (handler) {
                                handler(error);
                            }
                        }];
                    }
                }
            };
            TTCommentLoadOptions options = self.hasMoreStickComment? TTCommentLoadOptionsStick: 0;
            [self.datasource tt_loadCommentsForMode:loadMode
                             possibleLoadMoreOffset:[self p_curCommentManagedObject].offset
                                            options:options
                                        finishBlock:^(NSDictionary * _Nonnull results, NSError * _Nullable error, BOOL isStickComment) {
                                            uint64_t endTime = [NSObject currentUnixTime];
                                            StrongSelf;
                                            self.networkConsume = [NSObject machTimeToSecs:endTime - startTime] * 1000;
                                            if (error) {
                                                finishBlock(results, error);
                                                return;
                                            }
                                            FRArticleV2TabCommentsResponseModel *respModel = [[FRArticleV2TabCommentsResponseModel alloc] initWithDictionary:results error:nil];
                                            
                                            if (isStickComment && (options & TTCommentLoadOptionsStick) && [self needStashStickCommentModelsWithResult:respModel]) {
                                                uint64_t secStart = [NSObject currentUnixTime];
                                                [self.datasource tt_loadCommentsForMode:TTCommentLoadModeLoadMore
                                                                 possibleLoadMoreOffset:@(0)
                                                                                options:0
                                                                            finishBlock:^(NSDictionary * _Nonnull results, NSError * _Nullable error, BOOL isStickComment) {
                                                                                uint64_t secEnd = [NSObject currentUnixTime];
                                                                                self.networkConsume = [NSObject machTimeToSecs:secEnd - secStart] * 1000;
                                                                                finishBlock(results, error);
                                                                            }];
                                                return;
                                            }
                                            finishBlock(results, error);
                                        }];
        }
        else {
            if (handler) {
                handler(nil);
            }
        }
    }
}

- (void)tt_refreshLayout:(void(^)())completion {
    //处理数据,解析JSON,生成layout
    TTCommentManagedObject *manager = [self p_curCommentManagedObject];
    NSMutableArray *cacheArray = [[NSMutableArray alloc] init];
    for (id model in [manager queryCommentModels]) {
        if ([model conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
            TTUniversalCommentLayout *layout = [[TTUniversalCommentLayout alloc] init];
            [layout setCellLayoutWithCommentModel:model containViewWidth:self.containViewWidth];
            [cacheArray addObject:layout];
        }
    }
    manager.commentLayoutArray = cacheArray;
    if (completion) {
        completion();
    }
}

- (void)setContainViewWidth:(CGFloat)containViewWidth {
    _containViewWidth = containViewWidth;
    [self p_curCommentManagedObject].layoutWidth = _containViewWidth;
}

- (NSArray <id<TTCommentModelProtocol>> *)tt_curCommentModels {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    return [[self p_curCommentManagedObject] queryCommentModels];
}

- (NSArray *)tt_curCommentLayoutArray {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    return [[self p_curCommentManagedObject] commentLayoutArray];
}

- (void)tt_setCommentCategory:(TTCommentCategory)category
{
    //首次切换到category时刷新列表
    self.curCommentCategory = category;
    if (![self p_hasLoadCommentsForCurCategory]) {
        [self tt_startLoadCommentsForMode:TTCommentLoadModeRefresh
                    withCompletionHandler:nil];
    }
    else {
        [self p_setShouldRefreshCommentTableView];
    }
}

- (NSArray <NSString *> *)tt_commentTabNames
{
    return self.commentTabNames;
}

- (NSString *)tt_primaryID
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(tt_primaryID)]){
        return [self.datasource tt_primaryID];
    }
    return nil;
}

- (void)tt_addToTopWithCommentModel:(id <TTCommentModelProtocol>)commentModel
{
    if (commentModel) {
        if (!isEmptyString(commentModel.commentContent)) {
            self.commentTotalNum += 1;
            if ([self.delegate respondsToSelector:@selector(commentViewModel:refreshCommentCount:)]) {
                [self.delegate commentViewModel:self refreshCommentCount:(int)self.commentTotalNum];
            }
            [[self p_curCommentManagedObject] insertCommentModelToTop:commentModel];
            [self p_setShouldRefreshCommentTableView];
        }
    }
}

- (void)tt_removeComment:(id<TTCommentModelProtocol>)model
{
    if ([model.commentID longLongValue] == 0) {
        return;
    }
    
    BOOL deleteSucceeded = [[self p_curCommentManagedObject] deleteModel:model];
    
    if (deleteSucceeded) {
        self.commentTotalNum--;
        if ([self.delegate respondsToSelector:@selector(commentViewModel:refreshCommentCount:)]) {
            [self.delegate commentViewModel:self refreshCommentCount:(int)self.commentTotalNum];
        }
        //[[SSModelManager sharedManager] save:nil];
        [self p_setShouldRefreshCommentTableView];
    }
}

- (void)tt_removeCommentInTableWithCommentID:(NSString *)commentID {
    if (isEmptyString(commentID)) {
        return;
    }

    __block TTThreadCommentEntity * needDeleteCommentEntity = nil;
    [[self tt_curCommentModels] enumerateObjectsUsingBlock:^(TTThreadCommentEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.commentID.stringValue isEqualToString:commentID]) {
            needDeleteCommentEntity = obj;
            *stop = YES;
        }
    }];

    if (needDeleteCommentEntity) {
        [self tt_removeComment:needDeleteCommentEntity];
    }


}

- (void)tt_removeCommentWithCommentID:(NSString *)commentID{
    if (commentID.longLongValue == 0){
        return;
    }
    WeakSelf;
    [self deleteComment:commentID finish:^(TTThreadCommentEntity * _Nullable deleteComment, NSError * _Nullable error) {
        StrongSelf;
        if (![deleteComment.commentID.stringValue isEqualToString:commentID]){
            return;
        }
        [self tt_removeComment:deleteComment];
        if (!isEmptyString([self tt_primaryID])) {
            //通知个人主页动态列表删除帖子评论
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentNotificationKey
                                                                object:self
                                                              userInfo:@{@"thread_id":[self tt_primaryID],
                                                                         @"id":commentID}];
        }
    }];
}

- (void)deleteComment:(NSString * _Nonnull)commentID finish:(void(^ _Nullable)(TTThreadCommentEntity * _Nullable deleteComment, NSError * _Nullable error))finish {
    if (commentID.longLongValue == 0 || [self tt_curCommentModels].count == 0) {
        if (finish) {
            finish(nil, [NSError new]);
        }
        return;
    }
    
    __block TTThreadCommentEntity * needDeleteCommentEntity = nil;
    [[self tt_curCommentModels] enumerateObjectsUsingBlock:^(TTThreadCommentEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.commentID.stringValue isEqualToString:commentID]) {
            needDeleteCommentEntity = obj;
            *stop = YES;
        }
    }];
    
    BOOL deleteSelfComment = NO;
    BOOL deleteOthersComment = NO;
    if (needDeleteCommentEntity && [TTAccountManager isLogin]) {
        NSString *selfUID = [TTAccountManager userID];
        if (!isEmptyString(selfUID)) {
            if ([needDeleteCommentEntity.userID.stringValue isEqualToString:selfUID]) { //自己的评论
                deleteSelfComment = YES;
            } else if ([self.authorID isEqualToString:selfUID]) { //他人的评论，但在自己的帖子下面，这里不管用户权限就行，显示入口做了判断，最终保护由后台做
                deleteOthersComment = YES;
            }
        }
    }
    
    if (deleteSelfComment) {
        [[FRForumServer sharedInstance_tt] deleteCommentWithCommentID:commentID.longLongValue finish:^(NSError * _Nullable error) {
            if (error) {
                if (finish) {
                    finish(nil, error);
                }
            }else {
                if (finish) {
                    finish(needDeleteCommentEntity, error);
                }
            }
        }];
    } else if (deleteOthersComment){
        [[FRForumServer sharedInstance_tt] authorDeleteComment:commentID.longLongValue groupID:self.tid finish:^(NSError * _Nullable error) {
            if (error) {
                if (finish) {
                    finish(nil, error);
                }
            }else {
                if (finish) {
                    finish(needDeleteCommentEntity, error);
                }
            }
        }];
    } else {
        if (finish) {
            finish(nil, [NSError new]);
        }
    }
}

- (BOOL)tt_needLoadingUpdate
{
    return [self p_curCommentManagedObject].needLoadingUpdate;
}

- (BOOL)tt_needLoadingMore
{
    return [self p_curCommentManagedObject].needLoadingMore;
}

#pragma mark - private

- (void)p_parseRefreshResult:(FRArticleV2TabCommentsResponseModel *)results withCompletionHandler:(void(^)())handler
{
    self.commentTotalNum = results.total_number.integerValue;
    if ([self.delegate respondsToSelector:@selector(commentViewModel:refreshCommentCount:)]) {
        [self.delegate commentViewModel:self refreshCommentCount:(int)self.commentTotalNum];
    }
    //评论tabInfo
    FRCommentTabInfoStructModel *tabInfo = results.tab_info;
    self.curCommentCategory = tabInfo.current_tab_index.integerValue;
    self.commentTabNames = tabInfo.tabs;
    NSString *currentTabName = self.commentTabNames[self.curCommentCategory];
    self.bannComment = results.ban_comment.boolValue;
    self.banEmojiInput = results.ban_face.boolValue;
    self.detailNoComment = results.detail_no_comment.boolValue;

    //处理数据,解析JSON,生成layout
    if (![self p_curCommentManagedObject]) {
        TTCommentManagedObject *managerObject = [[TTCommentManagedObject alloc] init];
        managerObject.layoutWidth = self.containViewWidth;
        managerObject.tabName = currentTabName;
        managerObject.needLoadingUpdate = YES;
        managerObject.needLoadingMore = results.has_more.boolValue;
        [self p_setCommentObject:managerObject
                      fromResult:results];
        [self.commentCategoryModels setObject:managerObject forKey:@(self.curCommentCategory)];
    }
    else {
        [self p_setCommentObject:[self p_curCommentManagedObject]
                      fromResult:results];
    }
    self.loadResult = TTCommentLoadResultSuccess;
    [self p_setShouldRefreshCommentTableView];
    [self p_resetViewModelFlags];
    if (handler) {
        handler();
    }
}

- (void)p_parseLoadMoreResult:(FRArticleV2TabCommentsResponseModel *)results withCompletionHandler:(void(^)())handler
{
    TTCommentManagedObject *object = [self p_curCommentManagedObject];
    NSArray<FRNewCommentDataStructModel *>* commentStructModels = results.data;
    NSArray<FRNewCommentDataStructModel *>* stickStructModels = results.stick_comments;

    if (self.stashStickCommentModels.count) {
        stickStructModels = [self.stashStickCommentModels arrayByAddingObjectsFromArray:stickStructModels];
        self.stashStickCommentModels = nil;
    }

    if (!commentStructModels && !stickStructModels){
        return;
    }
    self.commentTotalNum = results.total_number.integerValue;
    object.needLoadingUpdate = NO;
    object.needLoadingMore = results.has_more.boolValue;

    NSArray * commentModels = [self p_commentOriginModelToCommentModels:commentStructModels isStick:NO];
    NSArray * stickModels = [self p_commentOriginModelToCommentModels:stickStructModels isStick:YES];

    [object appendCommentModels:stickModels];
    [object appendCommentModels:commentModels];

    object.offset = @([object.offset intValue] + TTCommentDefaultLoadMoreOffsetCount);
    self.loadResult = TTCommentLoadResultSuccess;
    [self p_setShouldRefreshCommentTableView];
    [self p_resetViewModelFlags];
    if (handler) {
        handler();
    }
}

- (BOOL)needStashStickCommentModelsWithResult:(FRArticleV2TabCommentsResponseModel *)results {
    BOOL hasMoreStick = results.stick_has_more.integerValue > 0;
    BOOL hasMore = results.has_more.integerValue > 0;
    if (hasMoreStick) {
        return NO;
    }
    if (!hasMore) {
        return NO;
    }

    NSArray *stickDatas = results.stick_comments;
    if (stickDatas.count >= 10) {
        return NO;
    }

    self.stashStickCommentModels = stickDatas;
    return YES;
}

- (void)p_setShouldRefreshCommentTableView
{
    //notify KVO
    self.reloadFlag = !self.reloadFlag;
}

- (BOOL)p_hasLoadCommentsForCurCategory
{
    return !![self tt_curCommentModels];
}


- (BOOL)p_isUnnecessaryLoad
{
    TTCommentManagedObject *curManagedObject = [self p_curCommentManagedObject];
    BOOL forbidRefresh = (self.lastLoadMode == TTCommentLoadModeRefresh) && curManagedObject && ![self p_curCommentManagedObject].needLoadingUpdate;
    BOOL forbidLoadMore = (self.lastLoadMode == TTCommentLoadModeLoadMore) && curManagedObject && ![self p_curCommentManagedObject].needLoadingMore;
    return forbidRefresh || forbidLoadMore;
}

- (BOOL)p_isLoadingMore
{
    //仅同时响应一次loadMore
    return (self.lastLoadMode == TTCommentLoadModeLoadMore) && self.isLoadingMore;
}

- (BOOL)p_isInvalidLoadMore
{
    return (self.lastLoadMode == TTCommentLoadModeLoadMore) && ![self tt_curCommentModels].count;
}

- (BOOL)p_isValidLoadRequest
{
    if ([self p_isUnnecessaryLoad]) {
        return NO;
    }
    if ([self p_isInvalidLoadMore]) {
        return NO;
    }
    if ([self p_isLoadingMore]) {
        return NO;
    }
    return YES;
}

- (TTCommentManagedObject *)p_curCommentManagedObject
{
    return [self.commentCategoryModels objectForKey:@(self.curCommentCategory)];
}

- (void)p_setViewModelFlagsWithLoadMode:(TTCommentLoadMode)mode
{
    self.isLoading = YES;
    self.isLoadingMore = (mode == TTCommentLoadModeLoadMore);
}

- (void)p_resetViewModelFlags
{
    self.isLoading = NO;
    self.isLoadingMore = NO;
}

- (void)p_setCommentObject:(TTCommentManagedObject *)managerObject fromResult:(FRArticleV2TabCommentsResponseModel *)results
{
    managerObject.needLoadingUpdate = NO;
    
    NSArray * tmpSonCommentModels = [self p_commentOriginModelToCommentModels:results.data isStick:NO];
    
    NSMutableArray * sonCommentModels = [NSMutableArray arrayWithCapacity:20];
    if ([tmpSonCommentModels count] > 0) {
        [sonCommentModels addObjectsFromArray:tmpSonCommentModels];
    }
    
    NSArray *stickComments = results.stick_comments;
    if (self.stashStickCommentModels.count) {
        stickComments = [self.stashStickCommentModels arrayByAddingObjectsFromArray:stickComments];
        self.stashStickCommentModels = nil;
    }
    
    NSArray * stickCommentModels = [self p_commentOriginModelToCommentModels:stickComments isStick:YES];
    
    if (managerObject.commentModels.count == 0 && stickCommentModels.count) {
        self.defaultReplyCommentModel = stickCommentModels.firstObject;
    }
    [managerObject appendCommentModels:stickCommentModels];
    [managerObject appendCommentModels:sonCommentModels];
    
    managerObject.offset = @(managerObject.offset.integerValue + 20);
}

- (NSArray *)p_commentOriginModelToCommentModels:(NSArray<FRNewCommentDataStructModel *> *)datas isStick:(BOOL)isStick
    {
    NSMutableArray * dataModels = [NSMutableArray arrayWithCapacity:20];
    NSString *groupID = [self tt_primaryID];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID: groupID];
    [dataModels addObjectsFromArray:[TTThreadCommentEntity createEntitiesWithArray:datas groupModel:groupModel]];
    if (isStick) {
        for (TTThreadCommentEntity *entity in dataModels) {
            entity.isStick = isStick;
        }
    }
    return dataModels;
}

- (BOOL)isFooterCellWithIndexPath:(NSIndexPath *)indexPath {
    if (![self needShowFooterCell]) {
        return NO;
    }

    if (indexPath.row == self.tt_curCommentModels.count) {
        return YES;
    }

    return NO;
}

- (BOOL)needShowFooterCell {

    //hasMore
    BOOL hasMore = [self tt_needLoadingUpdate] || [self tt_needLoadingMore];
    NSUInteger commentCount = [self tt_curCommentModels].count;

    if (hasMore) {
        return NO;
    }

    if (!self.hasFoldComment && commentCount == 0) {
        return NO;
    }

    return YES;
}

- (BOOL)isFooterPlainCellIndexPath:(NSIndexPath *)indexPath{

    if (![self needShowFooterCell]) {

        if (indexPath.row == [self tt_curCommentModels].count) {
            return YES;
        }
    }
    else {

        if (indexPath.row == ([self tt_curCommentModels].count + 1)) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Notification

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertForwardComment:) name:@"kTTCommentDetailForwardCommentNotification" object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)insertForwardComment:(NSNotification *)notification {
    NSDictionary *commentModelDict = (NSDictionary *)[notification object];
    if (SSIsEmptyDictionary(commentModelDict)){
        return;
    }
    NSString *groupID = [self tt_primaryID];
    if (![groupID isEqualToString:[commentModelDict tt_stringValueForKey:@"group_id"]]) {
        return;
    }
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID: groupID];
    TTThreadCommentEntity *commentModel = [[TTThreadCommentEntity alloc] initWithDictionary:commentModelDict groupModel:groupModel];

    [self tt_addToTopWithCommentModel:commentModel];
}

#pragma mark - 端监控

- (void)monitorWithError:(NSError *)error totalConsume:(uint64_t)totalConsume networkConsume:(uint64_t)networkConsume isRefresh:(BOOL)isRefresh {
    //端监控
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:@(networkConsume) forKey:TTForumMonitorExtraKeyNetwork];
    [extra setValue:error.domain forKey:TTForumMonitorExtraKeyErrorDomain];
    [extra setValue:@(error.code) forKey:TTForumMonitorExtraKeyErrorCode];
    [extra setValue:[self tt_primaryID] forKey:TTForumMonitorExtraKeyThreadID];
    [FRForumMonitor trackThreadCommentError:error extra:extra];
    
    NSMutableDictionary * monitorDictionary = [NSMutableDictionary dictionary];
    [monitorDictionary setValue:@(networkConsume) forKey:@"network"];
    if (error == nil) {
        [monitorDictionary setValue:@(totalConsume) forKey:@"total"];
        [monitorDictionary setValue:@(1) forKey:@"data_valid"];
    }else {
        [monitorDictionary setValue:@(0) forKey:@"data_valid"];
    }
    [monitorDictionary setValue:isRefresh?@(1):@(0) forKey:@"is_refresh"];
    [monitorDictionary setValue:[self tt_primaryID] forKey:@"thread_id"];
    [FRForumMonitor threadDetailCommentMonitorFetchDataPerformanceWithData:monitorDictionary.copy];
}

- (void)monitorWithTotalConsume:(uint64_t)totalConsume{
    if (totalConsume && _networkConsume){
        [self monitorWithError:_refreshError
                  totalConsume:totalConsume
                networkConsume:_networkConsume isRefresh:self.lastLoadMode == TTCommentLoadModeRefresh];
        _networkConsume = 0;
    }
}

#pragma mark - overrides methods

- (NSString *)groupId {
    return [self tt_primaryID];
}

@end

@implementation TTThreadCommentViewModel (TTCommentTrack)

- (void)tt_sendShowTrackForEmbeddedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [self p_sendShowTrackForFooterCellIfNeed:indexPath];
}

- (void)p_sendShowTrackForFooterCellIfNeed:(NSIndexPath *)indexPath {

    if (self.hasSendFooterCellShowTracker) {
        return;
    }

    if (!self.hasFoldComment) {
        return;
    }

    if (![self isFooterCellWithIndexPath:indexPath]) {
        return;
    }

    self.hasSendFooterCellShowTracker = YES;
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:@(self.fid) forKey:@"forum_id"];

    wrapperTrackEventWithCustomKeys(@"fold_comment", @"show", @(self.tid).stringValue, nil, extra.copy);
}

@end

@implementation TTThreadCommentViewModel (TTCommentImpression)

- (void)tt_registerToImpressionManager:(id)object
{
    [[SSImpressionManager shareInstance] addRegist:object];
}

- (void)tt_unregisterFromImpressionManager:(id)object
{
    [[SSImpressionManager shareInstance] removeRegist:object];
}

- (void)tt_enterCommentImpression
{
    [[SSImpressionManager shareInstance] enterCommentViewForGroupID:[self tt_primaryID]];
}

- (void)tt_leaveCommentImpression
{
    [[SSImpressionManager shareInstance] leaveCommentViewForGroupID:[self tt_primaryID]];
}

- (void)tt_recordForComment:(id<TTCommentModelProtocol>)commentModel status:(SSImpressionStatus)status
{
    //微头条帖子：
    NSDictionary *uInfo;
    if ([commentModel.commentID longLongValue] != 0 && commentModel.groupModel.groupID != 0) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        //设置微头条回复所需的信息
        [extra setValue:@"article_detail" forKey:@"comment_position"];
        [extra setValue:@"comment" forKey:@"comment_type"];
        [extra setValue:commentModel.groupModel.groupID forKey:@"item_id"];
        [extra setValue:@(commentModel.groupModel.aggrType) forKey:@"aggr_type"];
        //记录reply信息，原始
        NSArray<TTCommentReplyModel*>* commentReplyInfo = [commentModel replyModelArr];
        if([commentReplyInfo count] != 0)
        {
            NSMutableArray<NSString*> *replyIDs = [NSMutableArray new];
            [commentReplyInfo enumerateObjectsUsingBlock:^(TTCommentReplyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [replyIDs addObject:obj.replyID];
            }];
            uInfo = @{@"extra":extra,@"replyIDs":replyIDs};
        }else
        {
            uInfo = @{@"extra":extra};
        }
    }
    
    [[SSImpressionManager shareInstance] recordCommentImpressionGroupID:[self tt_primaryID] commentID:commentModel.commentID.stringValue status:status userInfo:uInfo];
}

@end
