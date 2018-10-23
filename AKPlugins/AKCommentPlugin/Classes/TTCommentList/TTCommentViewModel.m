//
//  TTCommentViewModel.m
//  Article
//
//  Created by 冯靖君 on 16/3/30.
//
//

#import "TTCommentViewModel.h"
#import "TTCommentModel.h"
#import "TTCommentReplyModel.h"
#import "TTCommentDataManager.h"
#import "TTUniversalCommentLayout.h"
#import "TTCommentModelProtocol.h"
#import "TTCommentDefines.h"
#import <TTImpression/SSImpressionModel.h>
#import <TTImpression/SSImpressionManager.h>
#import <TTFriendRelation/TTBlockManager.h>
#import <TTPlatformUIModel/TTGroupModel.h>
#import <TTFriendRelation/TTFollowManager.h>
#import <TTEntry/TTFollowNotifyServer.h>
#import <TTMonitor/TTMonitor.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTThemed/SSThemed.h>

/**
 *  评论内部管理对象
 */
#pragma mark - TTCommentManagedObject

@implementation TTCommentManagedObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        [self resetDatas];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockActionHandler:) name:kHasBlockedUnblockedUserNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followActionHandler:) name:RelationActionSuccessNotification object:nil];
    }
    return self;
}

- (BOOL)deleteModel:(id<TTCommentModelProtocol>)model {
    if ([_uniqueIDSet containsObject:model.commentID]) {
        [self.uniqueIDSet removeObject:model.commentID];
        id<TTCommentModelProtocol> needDelModel = nil;
        for (id<TTCommentModelProtocol> m in _commentModels) {
            if (![m conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
                continue;
            }
            if ([m.commentID longLongValue]== [model.commentID longLongValue]) {
                needDelModel = m;
                break;
            }
        }
        if (needDelModel) {
            for (TTUniversalCommentLayout *layout in self.commentLayoutArray) {
                if ([layout.identifier isEqualToNumber:needDelModel.commentID]) {
                    [self.commentLayoutArray removeObject:layout];
                    break;
                }
            }
            [self.commentModels removeObject:needDelModel];
            return YES;
        }
    }
    return NO;
}

- (void)insertCommentModelToTop:(id<TTCommentModelProtocol>)model {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    if (![model isAvailable]) {
        return;
    }
    
    if (!_uniqueIDSet) {
        self.uniqueIDSet = [NSMutableSet setWithCapacity:100];
    }
    
    if (!_commentModels) {
        self.commentModels = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    if (!_commentLayoutArray) {
        self.commentLayoutArray = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    if (![_uniqueIDSet containsObject:model.commentID]) {
        TTUniversalCommentLayout *layout = [[TTUniversalCommentLayout alloc] init];
        layout.showDelete = self.showDelete;
        [layout setCommentCellLayoutWithCommentModel:model constraintWidth:self.constraintWidth];
        [self.commentLayoutArray insertObject:layout atIndex:0];
        
        [self.uniqueIDSet addObject:model.commentID];
        [self.commentModels insertObject:model atIndex:0];
    }
}

- (void)appendCommentModels:(NSArray *)models {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    if (!_commentModels) {
        self.commentModels = [[NSMutableArray alloc] initWithCapacity:100];
    }

    if (!_commentLayoutArray) {
        self.commentLayoutArray = [[NSMutableArray alloc] initWithCapacity:100];
    }

    if ([models count] == 0) {
        return;
    }

    if (!_uniqueIDSet) {
        self.uniqueIDSet = [NSMutableSet setWithCapacity:100];
    }

    //去重
    for (id model in models) {
        if ([model conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
            id<TTCommentModelProtocol> commentModel = model;
            if (![commentModel isAvailable]) {
                continue;
            }
            if (![_uniqueIDSet containsObject:commentModel.commentID]) {
                TTUniversalCommentLayout *layout = [[TTUniversalCommentLayout alloc] init];
                layout.showDelete = self.showDelete;
                [layout setCommentCellLayoutWithCommentModel:model constraintWidth:self.constraintWidth];
                [self.commentLayoutArray addObject:layout];

                [self.uniqueIDSet addObject:commentModel.commentID];
                [self.commentModels addObject:commentModel];
            }
        }
    }
}

- (void)resetDatas {
    self.offset = @0;
    self.needLoadingUpdate = YES;
    self.needLoadingMore = NO;
    [self.uniqueIDSet removeAllObjects];
    [self.commentModels removeAllObjects];
    [self.commentLayoutArray removeAllObjects];
}

- (NSMutableArray <id<TTCommentModelProtocol>> *)queryCommentModels {
    return self.commentModels;
}

- (void)blockActionHandler:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    [self.commentModels enumerateObjectsUsingBlock:^(id<TTCommentModelProtocol>  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model conformsToProtocol:@protocol(TTCommentModelProtocol)] && [userID isEqualToString:[NSString stringWithFormat:@"%@", model.userID]]) {
            model.isBlocking = [[userInfo valueForKey:kIsBlockingKey] boolValue];
        }
    }];
}

- (void)followActionHandler:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *userID = [userInfo valueForKey:kRelationActionSuccessNotificationUserIDKey];
    NSNumber *actionType = [userInfo valueForKey:kRelationActionSuccessNotificationActionTypeKey];
    if (!isEmptyString(userID) && [actionType isKindOfClass:[NSNumber class]]) {
        [self.commentModels enumerateObjectsUsingBlock:^(id<TTCommentModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(TTCommentModelProtocol)] && [userID isEqualToString:[obj.userID stringValue]]) {
                if (actionType.integerValue == TTFollowActionTypeFollow) {
                    obj.isFollowing = YES;
                } else if (actionType.integerValue == TTFollowActionTypeUnfollow) {
                    obj.isFollowing = NO;
                }
            }
        }];
    }
}

@end

@interface TTCommentViewModel ()

@property(nonatomic, strong) NSMutableDictionary <NSNumber *, TTCommentManagedObject *> *commentCategoryModels;
@property(nonatomic, strong) NSArray *stashStickCommentModels; // 置顶评论太少时, 本地暂存, 等下一次接口回来合并数据
@property(nonatomic, strong) NSArray <NSString *> *commentTabNames; // 评论 tab 名称，目前已不区分 tab
@property(nonatomic, assign) TTCommentCategory curCommentCategory; // 已统一下发成 Hot
@property(nonatomic, assign) TTCommentLoadMode lastLoadMode;
@property(nonatomic, assign, readwrite)BOOL detailNoComment;
@property(nonatomic, assign) BOOL hasSendFooterCellShowTracker;
@property(nonatomic, assign) BOOL hasMoreStickComment;
/**
 *  核心标记。控件通过KVO监听，是否刷新列表。
 *  包括init、切换category和loadMore
 */
@property(nonatomic, assign) BOOL reloadFlag;

@end

@implementation TTCommentViewModel

- (void)dealloc {
    [self removeNotifications];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
        [self registerNotifications];
    }
    return self;
}

- (void)_commonInit {
    _commentCategoryModels = [NSMutableDictionary dictionaryWithCapacity:2];
    _isLoading = NO;
    _isLoadingMore = NO;
    _curCommentCategory = TTCommentCategoryHot;
    _hasMoreStickComment = YES;
}

#pragma mark - public

- (void)tt_startLoadCommentsForMode:(TTCommentLoadMode)loadMode withCompletionHandler:(TTCommentLoadCompletionHandler)handler {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tt_loadCommentsForMode:possibleLoadMoreOffset:options:finishBlock:)]) {
        self.lastLoadMode = loadMode;
        if ([self p_isValidLoadRequest]) {
            [self p_setViewModelFlagsWithLoadMode:loadMode];
            __weak typeof(self) weakSelf = self;
            CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
            
            void (^finishBlock)(NSDictionary *results, NSError *error, NSNumber *cost) = ^void(NSDictionary *results, NSError *error, NSNumber *cost) {
                if (error) {
                    weakSelf.loadResult = TTCommentLoadResultFailed;
                    [weakSelf p_resetViewModelFlags];
                    if (handler) {
                        handler(error);
                    }
                } else {
                    [[TTMonitor shareManager] trackService:@"detail_comment_load" value:cost extra:nil];
                    if (results[@"fold_comment_count"]) {
                        NSInteger foldCommentCount = [results tt_integerValueForKey:@"fold_comment_count"];
                        weakSelf.hasFoldComment = foldCommentCount > 0;
                    }
                    if (results[@"go_topic_detail"]) {
                        weakSelf.goTopicDetail = [results[@"go_topic_detail"] boolValue];
                    }
                    if (results[@"stick_has_more"]) {
                        weakSelf.hasMoreStickComment = [results tt_boolValueForKey:@"stick_has_more"];
                    }
                    if (loadMode == TTCommentLoadModeRefresh) {
                        [weakSelf p_parseRefreshResult:results withCompletionHandler:^{
                            if (handler) {
                                handler(error);
                            }
                        }];
                    } else {
                        [weakSelf p_parseLoadMoreResult:results withCompletionHandler:^{
                            if (handler) {
                                handler(error);
                            }
                        }];
                    }
                }
            };

            TTCommentLoadOptions options = self.hasMoreStickComment ? TTCommentLoadOptionsStick : 0;
            [self.dataSource tt_loadCommentsForMode:loadMode
                             possibleLoadMoreOffset:[self p_curCommentManagedObject].offset
                                            options:options
                                        finishBlock:^(NSDictionary * _Nonnull results, NSError * _Nullable error, BOOL isStickComment) {
                                            NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
                                            NSNumber *cost = @((CFAbsoluteTimeGetCurrent() - start) * 1000);
                                            if (error) {
                                                finishBlock(results, error, cost);
                                                return;
                                            }
                                            if (isStickComment && (options & TTCommentLoadOptionsStick) && [weakSelf needStashStickCommentModelsWithResult:results]) {
                                                [weakSelf.dataSource tt_loadCommentsForMode:loadMode
                                                                     possibleLoadMoreOffset:@(0)
                                                                                    options:0
                                                                                finishBlock:^(NSDictionary * _Nonnull results, NSError * _Nullable error, BOOL isStickComment) {
                                                                                    finishBlock(results, error, cost);
                                                }];
                                                return;
                                            }
                                            finishBlock(results, error, cost);
                                        }];
        } else {
            if (handler) {
                handler(nil);
            }
        }
    }
}

- (void)tt_refreshLayout:(void(^)())completion {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    //处理数据,解析JSON,生成layout
    TTCommentManagedObject *manager = [self p_curCommentManagedObject];
    NSMutableArray *cacheArray = [[NSMutableArray alloc] init];
    for (id model in [manager queryCommentModels]) {
        TTUniversalCommentLayout *layout = [[TTUniversalCommentLayout alloc] init];
        if ([model conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
            [layout setCommentCellLayoutWithCommentModel:model constraintWidth:self.constraintWidth];
            if ([self.dataSource respondsToSelector:@selector(tt_shouldShowDeleteComments)]) {
                layout.showDelete = [self.dataSource tt_shouldShowDeleteComments];
            }
        }
        [cacheArray addObject:layout];
    }
    manager.commentLayoutArray = cacheArray;
    if (completion) {
        completion();
    }
}

- (void)setConstraintWidth:(CGFloat)constraintWidth {
    _constraintWidth = constraintWidth;
    [self p_curCommentManagedObject].constraintWidth = _constraintWidth;
}

- (NSArray <id<TTCommentModelProtocol>> *)tt_curCommentModels {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    return [[self p_curCommentManagedObject] queryCommentModels];
}

- (NSArray *)tt_curCommentLayoutArray {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    return [[self p_curCommentManagedObject] commentLayoutArray];
}

- (void)tt_setCommentCategory:(TTCommentCategory)category {
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

- (NSArray <NSString *> *)tt_commentTabNames {
    return self.commentTabNames;
}

- (TTGroupModel *)tt_groupModel {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tt_groupModel)]) {
        return [self.dataSource tt_groupModel];
    }
    return nil;
}

- (void)tt_addToTopWithCommentModel:(id <TTCommentModelProtocol>)commentModel {
    if (commentModel) {
        self.commentTotalNum ++;
        [[self p_curCommentManagedObject] insertCommentModelToTop:commentModel];
        [self p_setShouldRefreshCommentTableView];
    }
}

- (void)tt_removeCommentWithCommentID:(NSString *)commentID {
    if (isEmptyString(commentID)) {
        return;
    }

    __block TTCommentModel *toDeletedCommentModel = nil;
    [[self tt_curCommentModels] enumerateObjectsUsingBlock:^(TTCommentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.commentID.stringValue isEqualToString:commentID]) {
            toDeletedCommentModel = obj;
            *stop = YES;
        }
    }];

    if (toDeletedCommentModel) {
        [self tt_removeComment:toDeletedCommentModel];
    }
}

- (void)tt_removeComment:(id<TTCommentModelProtocol>)model {
    if ([model.commentID longLongValue] == 0) {
        return;
    }
    
    BOOL deleteSucceeded = [[self p_curCommentManagedObject] deleteModel:model];
    [self p_setShouldRefreshCommentTableView];
    if (deleteSucceeded) {
        self.commentTotalNum--;
        if ([self.delegate respondsToSelector:@selector(commentViewModel:refreshCommentCount:)]) {
            [self.delegate commentViewModel:self refreshCommentCount:(int)self.commentTotalNum];
        }
    }
}

- (BOOL)tt_needLoadingUpdate {
    return [self p_curCommentManagedObject].needLoadingUpdate;
}

- (BOOL)tt_needLoadingMore {
    return [self p_curCommentManagedObject].needLoadingMore;
}

#pragma mark - private

- (void)p_parseRefreshResult:(NSDictionary *)results withCompletionHandler:(void(^)())handler {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    // 更新评论数量及是否显示“添加话题”
    self.commentTotalNum = [results intValueForKey:@"total_number" defaultValue:0];
    if ([self.delegate respondsToSelector:@selector(commentViewModel:refreshCommentCount:)]) {
        [self.delegate commentViewModel:self refreshCommentCount:(int)self.commentTotalNum];
    }
    
    // 评论tabInfo
    NSDictionary *tabInfo = [results dictionaryValueForKey:@"tab_info" defalutValue:nil];
    self.curCommentCategory = [tabInfo[@"current_tab_index"] integerValue];
    self.commentTabNames = [tabInfo arrayValueForKey:@"tabs" defaultValue:nil];
    NSString *currentTabName = self.commentTabNames[self.curCommentCategory];
    self.banComment = [[results objectForKey:@"ban_comment"] boolValue];
    self.banEmojiInput = [[results objectForKey:@"ban_face"] boolValue];
    self.detailNoComment = [[results objectForKey:@"detail_no_comment"] boolValue];
    self.commentPlaceholder = [results stringValueForKey:@"placeholder" defaultValue:kCommentInputPlaceHolder];

    // 处理数据,解析JSON,生成layout
    if (![self p_curCommentManagedObject]) {
        TTCommentManagedObject *managerObject = [[TTCommentManagedObject alloc] init];
        managerObject.constraintWidth = self.constraintWidth;
        managerObject.tabName = currentTabName;
        managerObject.needLoadingUpdate = YES;
        managerObject.needLoadingMore = YES;
        if ([self.dataSource respondsToSelector:@selector(tt_shouldShowDeleteComments)]) {
            managerObject.showDelete = [self.dataSource tt_shouldShowDeleteComments];
        }
        [self p_setCommentObject:managerObject fromCommentDatas:results];
        [self.commentCategoryModels setObject:managerObject forKey:@(self.curCommentCategory)];
    } else {
        [self p_setCommentObject:[self p_curCommentManagedObject] fromCommentDatas:results];
    }

    self.loadResult = TTCommentLoadResultSuccess;
    [self p_setShouldRefreshCommentTableView];
    [self p_resetViewModelFlags];
    if (handler) {
        handler();
    }
}

- (void)p_parseLoadMoreResult:(NSDictionary *)results withCompletionHandler:(void(^)())handler {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    TTCommentManagedObject *object = [self p_curCommentManagedObject];
    object.needLoadingUpdate = NO;
    object.needLoadingMore = [[results objectForKey:@"has_more"] boolValue];
    NSArray *datas = [results arrayValueForKey:@"data" defaultValue:@[]];
    NSArray *stickDatas = [results arrayValueForKey:@"stick_comments" defaultValue:@[]];
    NSArray *stickCommentModels = [self p_commentDictsToCommentModels:stickDatas isStick:YES];
    NSArray *commentModels = [self p_commentDictsToCommentModels:datas isStick:NO];

    if (self.stashStickCommentModels.count) {
        stickDatas = [self.stashStickCommentModels arrayByAddingObjectsFromArray:stickDatas];
        self.stashStickCommentModels = nil;
    }

    [object appendCommentModels:stickCommentModels];
    [object appendCommentModels:commentModels];
    object.offset = @([object.offset intValue] + TTCommentDefaultLoadMoreOffsetCount);
    self.loadResult = TTCommentLoadResultSuccess;
    [self p_setShouldRefreshCommentTableView];
    [self p_resetViewModelFlags];
    if (handler) {
        handler();
    }
}

- (BOOL)needStashStickCommentModelsWithResult:(NSDictionary *)results {
    BOOL hasMoreStick = [results tt_boolValueForKey:@"stick_has_more"];
    BOOL hasMore = [results tt_boolValueForKey:@"has_more"];
    if (hasMoreStick) {
        return NO;
    }
    if (!hasMore) {
        return NO;
    }
    
    NSArray *stickDatas = [results arrayValueForKey:@"stick_comments" defaultValue:@[]];
    if (stickDatas.count >= 10) {
        return NO;
    }
    
    self.stashStickCommentModels = stickDatas;
    return YES;
}

- (void)p_setShouldRefreshCommentTableView {
    //notify KVO
    self.reloadFlag = !self.reloadFlag;
}

- (BOOL)p_hasLoadCommentsForCurCategory {
    return !![self tt_curCommentModels];
}

- (BOOL)p_isUnnecessaryLoad {
    TTCommentManagedObject *curManagedObject = [self p_curCommentManagedObject];
    BOOL forbidRefresh = (self.lastLoadMode == TTCommentLoadModeRefresh) && curManagedObject && ![self p_curCommentManagedObject].needLoadingUpdate;
    BOOL forbidLoadMore = (self.lastLoadMode == TTCommentLoadModeLoadMore) && curManagedObject && ![self p_curCommentManagedObject].needLoadingMore;
    return forbidRefresh || forbidLoadMore;
}

- (BOOL)p_isLoadingMore {
    //仅同时响应一次loadMore
    return (self.lastLoadMode == TTCommentLoadModeLoadMore) && self.isLoadingMore;
}

- (BOOL)p_isInvalidLoadMore {
    return (self.lastLoadMode == TTCommentLoadModeLoadMore) && ![self tt_curCommentModels].count;
}

- (BOOL)p_isValidLoadRequest {
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

- (TTCommentManagedObject *)p_curCommentManagedObject {
    return [self.commentCategoryModels objectForKey:@(self.curCommentCategory)];
}

- (void)p_setViewModelFlagsWithLoadMode:(TTCommentLoadMode)mode {
    self.isLoading = YES;
    self.isLoadingMore = (mode == TTCommentLoadModeLoadMore);
}

- (void)p_resetViewModelFlags {
    self.isLoading = NO;
    self.isLoadingMore = NO;
}

- (void)p_setCommentObject:(TTCommentManagedObject *)managerObject fromCommentDatas:(NSDictionary *)commentDatas {
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    managerObject.needLoadingUpdate = NO;
    managerObject.needLoadingMore = [[commentDatas objectForKey:@"has_more"] boolValue];

    NSArray *datas = [commentDatas objectForKey:@"data"];
    NSArray *stickDatas = [commentDatas tt_arrayValueForKey:@"stick_comments"];
    if (self.stashStickCommentModels.count) {
        stickDatas = [self.stashStickCommentModels arrayByAddingObjectsFromArray:stickDatas];
        self.stashStickCommentModels = nil;
    }
    NSArray *stickCommentModels = [self p_commentDictsToCommentModels:stickDatas isStick:YES];
    NSArray *commentModels = [self p_commentDictsToCommentModels:datas isStick:NO];

    if (managerObject.commentModels.count == 0 && stickCommentModels.count) {
        self.defaultReplyCommentModel = stickCommentModels.firstObject;
    }
    [managerObject appendCommentModels:stickCommentModels];
    [managerObject appendCommentModels:commentModels];
    
    managerObject.offset = @([[commentDatas objectForKey:@"offset"] intValue]);
    if ([managerObject.offset intValue] == 0) {
        managerObject.offset = @([datas count]);
    }
}

- (NSArray *)p_commentDictsToCommentModels:(NSArray *)dataDicts isStick:(BOOL)isStick {
    NSMutableArray *dataModels = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *dict in dataDicts) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            id<TTCommentModelProtocol> model = [[TTCommentModel alloc] initWithDictionary:[dict dictionaryValueForKey:@"comment" defalutValue:nil] groupModel:[self tt_groupModel]];
            model.isStick = isStick;
            if (isEmptyString(model.commentContent)) {
                continue;
            }
            if (model != nil) {
                [dataModels addObject:model];
            }
        }
    }
    return dataModels;
}

- (BOOL)tt_isFooterCellWithIndexPath:(NSIndexPath *)indexPath {
    if (![self tt_needShowFooterCell]) {
        return NO;
    }

    if (indexPath.row == self.tt_curCommentModels.count) {
        return YES;
    }

    return NO;
}

- (BOOL)tt_isFooterEmptyCellIndexPath:(NSIndexPath *)indexPath {
    if (![self tt_needShowFooterCell]) {
        if (indexPath.row == [self tt_curCommentModels].count) {
            return YES;
        }
    } else {
        if (indexPath.row == ([self tt_curCommentModels].count + 1)) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)tt_needShowFooterCell {
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

#pragma mark - Notification

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertForwardComment:) name:@"kArticleCommentViewInsertForwardCommentNotification" object:nil]; // TODO 只有 ArticleCommentView 发送...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertForwardComment:) name:@"kTTCommentDetailForwardCommentNotification" object:nil]; // TODO 没有发送方...
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)insertForwardComment:(id)notification {
    NSDictionary *userInfo = [notification userInfo];

    if (![userInfo objectForKey:@"error"]) {
        NSDictionary *commentModelDict = [NSMutableDictionary dictionaryWithDictionary:[[notification userInfo] objectForKey:@"data"]];
        if (![[self tt_groupModel].groupID isEqualToString:[commentModelDict tt_stringValueForKey:@"group_id"]]) {
            return;
        }

        TTCommentModel *commentModel = [[TTCommentModel alloc] initWithDictionary:commentModelDict groupModel:[self tt_groupModel]];
        [self tt_addToTopWithCommentModel:commentModel];
    }
}

#pragma mark - overrides methods

- (NSString *)groupId {
    return [self tt_groupModel].groupID;
}

@end

@implementation TTCommentViewModel (TTCommentTrack)

- (void)tt_sendShowTrackForEmbeddedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self p_sendShowTrackForFooterCellIfNeed:indexPath];
}

- (void)p_sendShowTrackForFooterCellIfNeed:(NSIndexPath *)indexPath {
    if (self.hasSendFooterCellShowTracker) {
        return;
    }

    if (!self.hasFoldComment) {
        return;
    }

    if (![self tt_isFooterCellWithIndexPath:indexPath]) {
        return;
    }

    self.hasSendFooterCellShowTracker = YES;
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:[self tt_groupModel].itemID forKey:@"item_id"];

    // TODO 这个埋点的事件看起来有问题
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"show", [self tt_groupModel].groupID, nil, extra.copy);
}

@end

@implementation TTCommentViewModel (TTCommentImpression)

- (void)tt_registerToImpressionManager:(id)object {
    [[SSImpressionManager shareInstance] addRegist:object];
}

- (void)tt_unregisterFromImpressionManager:(id)object {
    [[SSImpressionManager shareInstance] removeRegist:object];
}

- (void)tt_enterCommentImpression {
    [[SSImpressionManager shareInstance] enterCommentViewForGroupID:[self tt_groupModel].impressionDescription];
}

- (void)tt_leaveCommentImpression {
    [[SSImpressionManager shareInstance] leaveCommentViewForGroupID:[self tt_groupModel].impressionDescription];
}

- (void)tt_recordForComment:(id<TTCommentModelProtocol>)commentModel status:(SSImpressionStatus)status {
    if ([self tt_groupModel]) {
        TTGroupModel *groupModel = [self tt_groupModel];

        if ([commentModel.commentID longLongValue] != 0 && isEmptyString(groupModel.groupID)) {
            NSString * cIDStr = [NSString stringWithFormat:@"%@", commentModel.commentID];
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra addEntriesFromDictionary:@{@"comment_position": @"article_detail", @"comment_type": @"comment"}];
            [extra setValue:groupModel.itemID forKey:@"item_id"];
            [extra setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
            //记录reply信息，原始
            NSArray<TTCommentReplyModel *> *commentReplyList = [commentModel replyModelArr];
            NSDictionary *userInfo;
            if([commentReplyList count] != 0)
            {
                NSMutableArray<NSString*> *replyIDs = [NSMutableArray new];
                [commentReplyList enumerateObjectsUsingBlock:^(TTCommentReplyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [replyIDs addObject:obj.replyID];
                }];
                userInfo = @{@"extra":extra,@"replyIDs":replyIDs};
            }else
            {
                userInfo = @{@"extra":extra};
            }

            [[SSImpressionManager shareInstance] recordCommentImpressionGroupID:groupModel.impressionDescription commentID:cIDStr status:status userInfo:userInfo];
        }
    }
}

@end
