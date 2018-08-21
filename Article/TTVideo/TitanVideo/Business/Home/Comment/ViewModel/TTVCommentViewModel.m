//
//  TTVCommentViewModel.m
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVCommentViewModel.h"
#import "TTVideoCommentResponse.h"
#import "TTVCommentListItem.h"
#import "TTVideoCommentItem+Extension.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "SSImpressionManager.h"
#import "FriendDataManager.h"
#import "TTVideoArticleServiceMessage.h"

#define kHasBlockedUnblockedUserNotification @"kHasBlockedUnblockedUserNotification"
#define kBlockedUnblockedUserIDKey @"kBlockedUnblockedUserIDKey"
#define kIsBlockingKey @"kIsBlockingKey"

/**
 *  评论内部管理对象
 */
#pragma mark - TTVCommentManagedObject

@interface TTVCommentManagedObject : NSObject
@property (nonatomic, strong) NSNumber * offset;
@property (nonatomic, copy) NSString * tabName;
@property (nonatomic, assign) BOOL needLoadingUpdate;
@property (nonatomic, assign) BOOL needLoadingMore;
@property (nonatomic, strong) NSMutableArray <TTVCommentListItem *> *items;
@property (nonatomic, strong) NSMutableArray <TTVCommentListItem *> *lastAppendItems;//最近一次获取的Models
@property (nonatomic, strong) NSArray<TTVCommentListItem *> *stashStickCommentItems; //置顶评论暂存
@property (nonatomic, strong) TTVCommentListItem *defaultReplyCommentItem; //默认回复评论

@property (nonatomic, strong) NSMutableSet * uniqueIDSet;
@property (nonatomic, assign) CGFloat layoutWidth;

- (NSMutableArray *)queryCommentItems;
- (void)appendCommentItems:(NSArray <TTVCommentListItem *> *)models;
- (BOOL)insertCommentItemToTop:(TTVCommentListItem *)model;
- (TTVCommentListItem *)getCommentItemeWithCommentID:(NSString *)commentID;
- (BOOL)deleteItem:(TTVCommentListItem *)item;
- (BOOL)deleteItemWithCommentID:(NSString *)commentID;
- (void)resetDatas;
@end

@implementation TTVCommentManagedObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetDatas];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserHandler:) name:kHasBlockedUnblockedUserNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollowStatus:) name:RelationActionSuccessNotification object:nil];
    }
    return self;
}

- (BOOL)deleteItem:(TTVCommentListItem *)item {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    
    __block BOOL status = NO;
    if (!item ||
        ![item isKindOfClass:[TTVCommentListItem class]] ||
        [item.commentModel.commentIDNum longLongValue] == 0 ||
        ![self.uniqueIDSet containsObject:item.commentModel.commentIDNum]) {
        
        return status;
    }
    
    [self.items enumerateObjectsUsingBlock:^(TTVCommentListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (item.commentModel.commentIDNum.longLongValue == obj.commentModel.commentIDNum.longLongValue) {
            
            [self.items removeObject:obj];
            [self.uniqueIDSet removeObject:obj.commentModel.commentIDNum];
            status = YES;
            
            *stop = YES;
        }
    }];
    
    return status;
}

- (BOOL)deleteItemWithCommentID:(NSString *)commentID {
    
    __block BOOL status = NO;
    if (isEmptyString(commentID) ||
        ![self.uniqueIDSet containsObject:commentID]) {
        
        return status;
    }
    
    [self.items enumerateObjectsUsingBlock:^(TTVCommentListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (commentID.longLongValue == obj.commentModel.commentIDNum.longLongValue) {
            
            [self.items removeObject:obj];
            [self.uniqueIDSet removeObject:obj.commentModel.commentIDNum];
            status = YES;
            
            *stop = YES;
        }
    }];
    
    return status;
}

- (BOOL)insertCommentItemToTop:(TTVCommentListItem *)item {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);

    if (!item ||
        ![item isKindOfClass:[TTVCommentListItem class]] ||
        [item.commentModel.commentIDNum longLongValue] == 0 ||
        [self.uniqueIDSet containsObject:item.commentModel.commentIDNum]) {
        
        return NO;
    }
    
    [item.layout setCellLayoutWithCommentModel:item.commentModel containViewWidth:self.layoutWidth];
    [self.uniqueIDSet addObject:item.commentModel.commentIDNum];
    [self.items insertObject:item atIndex:0];
    
    return YES;
}

- (void)appendCommentItems:(NSArray <TTVCommentListItem *> *)originItems {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    
    [self.lastAppendItems removeAllObjects];
    
    if (originItems.count == 0) {
        return;
    }
    
    //去重
    for (TTVCommentListItem *item in originItems) {
        
        if (item.commentModel.commentIDNum.longLongValue == 0) {
            continue;
        }
        
        if (![self.uniqueIDSet containsObject:item.commentModel.commentIDNum]) {
            
            [self.uniqueIDSet addObject:item.commentModel.commentIDNum];
            [item.layout setCellLayoutWithCommentModel:item.commentModel containViewWidth:self.layoutWidth];
            [self.lastAppendItems addObject:item];
            [self.items addObject:item];
        }
    }
}

- (TTVCommentListItem *)getCommentItemeWithCommentID:(NSString *)commentID {
    
    if (isEmptyString(commentID) || ![self.uniqueIDSet containsObject:commentID]) {
        
        return nil;
    }
    
    for (TTVCommentListItem *item in self.queryCommentItems) {
        
        if ([item isKindOfClass:[TTVCommentListItem class]] && [item.commentModel.commentIDNum.stringValue isEqualToString:commentID]) {
            
            return item;
        }
    }
    
    return nil;
}

- (void)resetDatas {
    
    self.offset = @0;
    self.needLoadingUpdate = YES;
    self.needLoadingMore = NO;
    [self.lastAppendItems removeAllObjects];
    [self.uniqueIDSet removeAllObjects];
    [self.items removeAllObjects];
}

- (NSMutableArray <TTVCommentListItem *> *)queryCommentItems {
    
    return self.items;
}

- (void)blockUnblockUserHandler:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    
    [self.items enumerateObjectsUsingBlock:^(TTVCommentListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[TTVCommentListItem class]]) {
            
            if ([obj.commentModel conformsToProtocol:@protocol(TTVCommentModelProtocol)] && [userID isEqualToString:[NSString stringWithFormat:@"%@", obj.commentModel.userID]]) {
                obj.commentModel.isBlocking = [[userInfo valueForKey:kIsBlockingKey] boolValue];
            }
        }
    }];
}

- (void)updateFollowStatus:(NSNotification *)notification {

    NSDictionary *userInfo = notification.userInfo;
    NSString *userID = [userInfo tt_stringValueForKey:kRelationActionSuccessNotificationUserIDKey];
    FriendActionType actionType = [userInfo tt_intValueForKey:kRelationActionSuccessNotificationActionTypeKey];
    
    [self.items enumerateObjectsUsingBlock:^(TTVCommentListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.commentModel conformsToProtocol:@protocol(TTVCommentModelProtocol)] && [userID isEqualToString:[NSString stringWithFormat:@"%@", obj.commentModel.userID]]) {
            obj.commentModel.isFollowing = (actionType == FriendActionTypeFollow) ? YES : NO;
        }
    }];
}

#pragma mark - Getters & Setters

- (NSMutableArray<TTVCommentListItem *> *)items {
    
    if (!_items) {
        _items = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    return _items;
}

- (NSMutableSet *)uniqueIDSet {
    
    if (!_uniqueIDSet) {
        _uniqueIDSet = [NSMutableSet setWithCapacity:100];
    }
    
    return _uniqueIDSet;
}

- (NSMutableArray<TTVCommentListItem *> *)lastAppendItems {
    
    if (!_lastAppendItems) {
        _lastAppendItems = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    return _lastAppendItems;
}

@end

#pragma mark - TTVCommentViewModel

@interface TTVCommentViewModel()

@property(nonatomic, strong) NSMutableDictionary <NSNumber *, TTVCommentManagedObject *> *commentCategoryModels;

@property(nonatomic, assign) TTVCommentCategory curCommentCategory;

@property(nonatomic, assign) TTVCommentLoadMode lastLoadMode;

@property(nonatomic, strong) NSArray <NSString *> *commentTabNames;

@property (nonatomic, strong) TTVideoCommentService *commentService;

@property(nonatomic, assign, readwrite)BOOL detailNoComment;

@property(nonatomic, assign) BOOL hasSendFoldCommentCellShowTracker;
@property(nonatomic, assign) BOOL hasMoreStickComment;

@property (nonatomic, strong) NSString *topCommentID;// 记录最后一次返回的最后一个评论

/**
 *  核心标记。控件通过KVO监听，是否刷新列表。包括init、切换category和loadMore
 */
@property(nonatomic, assign) BOOL reloadFlag;

@end
@implementation TTVCommentViewModel

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _commentCategoryModels = [NSMutableDictionary dictionaryWithCapacity:2];
    _isLoading = NO;
    _isLoadingMore = NO;
    _curCommentCategory = TTVCommentCategoryHot;
    _hasMoreStickComment = YES;
    _commentService = [[TTServiceCenter sharedInstance] getService:[TTVideoCommentService class]];
}

#pragma mark - Notification


#pragma mark - Life Cycle

#pragma mark - Public Methods

- (void)startLoadCommentsForMode:(TTVCommentLoadMode)loadMode
               completionHandler:(TTVLoadCommentsCompletionHandler)handler {
    
    self.lastLoadMode = loadMode;
    
    if (![self p_isValidLoadRequest]) {
        
        (!handler) ?: handler(nil);
        
        return ;
    }
    
    [self p_setViewModelFlagsWithLoadMode:loadMode];
    [self p_fetchDataWithParameters:[self p_getCommentParameterForMode:loadMode] completeBlock:handler];
}

- (NSArray<TTVCommentListItem *> *)curCommentItems {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);

    return [[self p_curCommentManagedObject] queryCommentItems];
}

- (TTVCommentListItem *)commentItemAtIndex:(NSUInteger)index {
    
    if (index >= [self curCommentItems].count) {
        
        return nil;
    }
    
    return [self curCommentItems][index];
}

- (TTVCommentListItem *)commentItemWithCommentID:(NSString *)commentID {
    
    return [[self p_curCommentManagedObject] getCommentItemeWithCommentID:commentID];
}

- (BOOL)removeCommentItemWithCommentID:(NSString *)commentID {
    
    BOOL status = [[self p_curCommentManagedObject] deleteItemWithCommentID:commentID];
    (!status) ?: [self p_setShouldRefreshCommentTableView];

    return status;
}

- (TTVCommentListItem *)defaultReplyCommentItem
{
    return [self p_curCommentManagedObject].defaultReplyCommentItem;
}

- (void)clearDefaultReplyCommentItem
{
    [self p_curCommentManagedObject].defaultReplyCommentItem = nil;
}

- (BOOL)removeCommentItem:(TTVCommentListItem *)item {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    
    BOOL status = [[self p_curCommentManagedObject] deleteItem:item];
    
    (!status) ?: [self p_setShouldRefreshCommentTableView];
    
    if (status) {
        self.commentTotalNum --;
        [[self getArticle] setCommentCount:(int)self.commentTotalNum];
        
        SAFECALL_MESSAGE(TTVideoArticleServiceMessage, @selector(message_updateCommentCount:groupId:), message_updateCommentCount:@([self getArticle].commentCount) groupId:@([[self getArticle] uniqueID]).stringValue);
    }
    
    return status;
}

- (void)addToTopWithCommentItem:(TTVCommentListItem *)item {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    if (![item isKindOfClass:[TTVCommentListItem class]] || [item.commentModel.commentIDNum longLongValue] == 0) {
        return;
    }
    
    BOOL result = [[self p_curCommentManagedObject] insertCommentItemToTop:item];
    
    if (result) {
        self.commentTotalNum ++;
        [self p_setShouldRefreshCommentTableView];
    }
}

- (BOOL)needLoadingUpdate {
    
    return [self p_curCommentManagedObject].needLoadingUpdate;
}

- (BOOL)needLoadingMore {
    
    return [self p_curCommentManagedObject].needLoadingMore;
}

- (BOOL)isFooterCellWithIndexPath:(NSIndexPath *)indexPath {
    
    if (![self needShowFooterCell]) {
        return NO;
    }
    
    if (indexPath.row == self.curCommentItems.count) {
        return YES;
    }
    
    return NO;
}

- (BOOL)needShowFooterCell {
    //hasMore
    BOOL hasMore = [self needLoadingUpdate] || [self needLoadingMore];
    NSUInteger commentCount = [self curCommentItems].count;
    
    if (hasMore) {
        return NO;
    }
    
    if (!self.hasFoldComment && commentCount == 0) {
        return NO;
    }
    
    return YES;
}

- (void)refreshLayout:(void(^)())completion {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    
    TTVCommentManagedObject *manager = [self p_curCommentManagedObject];
    
    for (TTVCommentListItem *item in [manager queryCommentItems]) {
        if ([item isKindOfClass:[TTVCommentListItem class]]) {
                
            [item.layout setCellLayoutWithCommentModel:item.commentModel containViewWidth:self.containViewWidth];
        }
    }
    if (completion) {
        completion();
    }
}

- (void)setContainViewWidth:(CGFloat)containViewWidth {
    _containViewWidth = containViewWidth;
    [self p_curCommentManagedObject].layoutWidth = _containViewWidth;
}

#pragma mark - Private Methods

- (NSMutableDictionary *)p_getCommentParameterForMode:(TTVCommentLoadMode)loadMode {
    
    id <TTVArticleProtocol> article = [self.datasource serveArticle];
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:9];
    
    parameter[kItemIDForComment] = [article groupModel].itemID;
    parameter[kGroupIDForComment] = [article groupModel].groupID;
    parameter[kAggrTypeForComment] = @([article groupModel].aggrType);
    parameter[kZZidsForComment] = article.zzCommentsIDString;
    parameter[kCountForComment] = @(TTVCommentDefaultLoadMoreFetchCount);
    parameter[kTabIndexForComment] = @0;// 热度
    TTVCommentLoadOptions options = self.hasMoreStickComment? TTVCommentLoadOptionsStick: 0;

    BOOL foldCommentEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"folder_comments_of_article_detail" defaultValue:@NO freeze:NO] boolValue];
    if (foldCommentEnabled) {
        if (options & TTVCommentLoadOptionsFold) {
            parameter[kFoldForComment] = @2; //非折叠区评论
        } else {
            parameter[kFoldForComment] = @1; //折叠区评论
        }
    }
    
    if (loadMode == TTVCommentLoadModeLoadMore) {
        
        parameter[kOffsetForComment] = [self p_curCommentManagedObject].offset;
        parameter[kTopCommentIDForComment] = self.topCommentID;
    }
    
    return parameter;
}

- (void)p_fetchDataWithParameters:(NSMutableDictionary *)parameter completeBlock:(TTVLoadCommentsCompletionHandler)complete {
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent(); // 统计使用

    BOOL isStickComment = NO;
    TTVCommentLoadOptions options = self.hasMoreStickComment? TTVCommentLoadOptionsStick: 0;
    if (options & TTVCommentLoadOptionsStick) {
        [parameter setValue:self.datasource.msgId forKey:kMsgIDForComment];
        isStickComment = !isEmptyString(self.datasource.msgId);
        isStickComment = YES;
    }
    
    void (^finishBlock)(id response, NSError *error) = ^void(id response, NSError *error) {
        
        if (!error) {
            
            NSNumber *cost = @((CFAbsoluteTimeGetCurrent() - start) * 1000);
            [[TTMonitor shareManager] trackService:@"detail_comment_load" value:cost extra:nil];
            
            if ([response isKindOfClass:[TTVideoCommentResponse class]]) {
                
                [self p_parseRefreshResult:response];
                self.loadResult = TTVCommentLoadResultSuccess;
                
            }
        } else {
            self.loadResult = TTVCommentLoadResultFailed;
        }
        
        [self p_setShouldRefreshCommentTableView];
        [self p_resetViewModelFlags];
        
        (!complete) ?: complete(error);

    };
    
    [self.commentService getCommentWithParameters:parameter completion:^(id response, NSError *error) {

        if (!error) {
            
            if (isStickComment && (options & TTVCommentLoadOptionsStick) && !self.isLoadingMore && [self needStashStickCommentModelsWithResponse:response]) {
                
                [parameter removeObjectForKey:kMsgIDForComment];
                [self.commentService getCommentWithParameters:parameter completion:^(id response, NSError *error) {
                    finishBlock(response, error);
                }];
                return;
            }
        }
            
        finishBlock (response, error);
    }];
}

- (BOOL)needStashStickCommentModelsWithResponse:(TTVideoCommentResponse *)response {
    
    BOOL hasMoreStick = response.originData.stick_has_more.boolValue;
    BOOL hasMore = response.originData.has_more.boolValue;
    if (hasMoreStick) {
        return NO;
    }
    if (!hasMore) {
        return NO;
    }

    NSArray *stickDatas = response.stickCommentItems;
    if (stickDatas.count >= 10) {
        return NO;
    }
    NSArray<TTVCommentListItem *> *stashStickComments = [self p_constructCommentListItemWithItems:stickDatas];

    if (![self p_curCommentManagedObject]) {
        TTVCommentManagedObject *managerObject = [[TTVCommentManagedObject alloc] init];
        managerObject.layoutWidth = self.containViewWidth;
        managerObject.tabName = (self.commentTabNames.count > self.curCommentCategory) ? self.commentTabNames[self.curCommentCategory]: nil;
        managerObject.needLoadingUpdate = YES;
        managerObject.needLoadingMore = YES;
        [self.commentCategoryModels setObject:managerObject forKey:@(self.curCommentCategory)];
    }
    [self p_curCommentManagedObject].stashStickCommentItems = stashStickComments;
    return YES;
}

- (BOOL)p_hasLoadCommentsForCurCategory
{
    return !![self curCommentItems];
}

- (BOOL)p_isUnnecessaryLoad
{
    TTVCommentManagedObject *curManagedObject = [self p_curCommentManagedObject];
    BOOL forbidRefresh = (self.lastLoadMode == TTVCommentLoadModeRefresh) && curManagedObject && ![self  needLoadingUpdate];
    BOOL forbidLoadMore = (self.lastLoadMode == TTVCommentLoadModeLoadMore) && curManagedObject && ![self needLoadingMore];
    return forbidRefresh || forbidLoadMore;
}

- (BOOL)p_isLoadingMore
{
    //仅同时响应一次loadMore
    return (self.lastLoadMode == TTVCommentLoadModeLoadMore) && self.isLoadingMore;
}

- (BOOL)p_isInvalidLoadMore
{
    return (self.lastLoadMode == TTVCommentLoadModeLoadMore) && ([self curCommentItems].count <= 0);
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

- (void)p_setViewModelFlagsWithLoadMode:(TTVCommentLoadMode)mode {
    self.isLoading = YES;
    self.isLoadingMore = (mode == TTVCommentLoadModeLoadMore);
}

- (void)p_resetViewModelFlags {
    self.isLoading = NO;
    self.isLoadingMore = NO;
}

- (TTVCommentManagedObject *)p_curCommentManagedObject {
    
    return [self.commentCategoryModels objectForKey:@(self.curCommentCategory)];
}

- (void)p_parseRefreshResult:(TTVideoCommentResponse *)response {
    
    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);

    self.commentTotalNum = response.originData.total_number.integerValue;
    // TODOLJ article 更新
    [[self getArticle] setCommentCount:(int)self.commentTotalNum];
    SAFECALL_MESSAGE(TTVideoArticleServiceMessage, @selector(message_updateCommentCount:groupId:), message_updateCommentCount:@([self getArticle].commentCount) groupId:@([[self getArticle] uniqueID]).stringValue);
//    [[self getArticle] ]showAddForum = response.originData.show_add_forum;TODOLJ
//    [[self getArticle] save];
    // 从之前代码逻辑来看，毛线用没有，还特么添乱！！！
//    self.curCommentCategory = response.originData.tab_info.current_tab_index.integerValue;
    self.commentTabNames = response.originData.tabs;
    self.bannComment = response.originData.ban_comment.boolValue;
    self.banEmojiInput = response.originData.ban_face.boolValue;
    self.detailNoComment = response.originData.detail_no_comment.boolValue;
    self.goTopicDetail = response.originData.go_topic_detail.boolValue;
    self.hasFoldComment = (response.originData.fold_comment_count.integerValue > 0);
    self.hasMoreStickComment = response.originData.stick_has_more.boolValue;
    
    if (![self p_curCommentManagedObject]) {
        TTVCommentManagedObject *managerObject = [[TTVCommentManagedObject alloc] init];
        managerObject.layoutWidth = self.containViewWidth;
        managerObject.tabName = (self.commentTabNames.count > self.curCommentCategory) ? self.commentTabNames[self.curCommentCategory]: nil;
        managerObject.needLoadingUpdate = YES;
        managerObject.needLoadingMore = YES;
        [self.commentCategoryModels setObject:managerObject forKey:@(self.curCommentCategory)];
    }
    
    [self p_setCommentObject:[self p_curCommentManagedObject] fromResult:response];
}

- (void)p_setCommentObject:(TTVCommentManagedObject *)managerObject fromResult:(TTVideoCommentResponse *)response {

    NSAssert([NSThread isMainThread], @"modify datasource not be in MainThread! %s", __FUNCTION__);
    managerObject.needLoadingUpdate = NO;
    managerObject.needLoadingMore = response.originData.has_more.boolValue;
    
    NSMutableArray<TTVCommentListItem *> *stickComments = [NSMutableArray array];
    
    if ([managerObject.stashStickCommentItems count]) {
        [stickComments addObjectsFromArray:managerObject.stashStickCommentItems];
        managerObject.stashStickCommentItems = nil;
    }
    if (response.stickCommentItems.count){
        [stickComments addObjectsFromArray:[self p_constructCommentListItemWithItems:response.stickCommentItems]];
        
    }
    if ([managerObject.items count] == 0 && [stickComments count]) {
        managerObject.defaultReplyCommentItem = stickComments.firstObject;
    }
    
    [managerObject appendCommentItems:stickComments];
    [managerObject appendCommentItems:[self p_constructCommentListItemWithItems:response.commentItems]];
    
    self.topCommentID = ((TTVCommentListItem *)[managerObject.queryCommentItems lastObject]).commentModel.commentIDNum.stringValue;
    
    if (response.originData.offset.integerValue > 0) {
        
        managerObject.offset = @(managerObject.offset.integerValue + response.originData.offset.integerValue);
    } else {
        
        managerObject.offset = @(managerObject.offset.integerValue + TTVCommentDefaultLoadMoreOffsetCount);
    }
}

- (NSArray <TTVCommentListItem *>*)p_constructCommentListItemWithItems:(NSArray *)items {
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for (TTVideoCommentItem *item in items) {
        
        if ([item isKindOfClass:[TTVideoCommentItem class]]) {
            
            TTVCommentListItem *listItem = [TTVCommentListItem new];
            listItem.commentModel = item;
            listItem.commentModel.groupModel = [[self.datasource serveArticle] groupModel];
            
            [results addObject:listItem];
        }
    }
    
    return results;
}

- (void)p_setShouldRefreshCommentTableView {
    //notify KVO
    self.reloadFlag = !self.reloadFlag;
}

- (id<TTVArticleProtocol>)getArticle
{
    if ([self.datasource respondsToSelector:@selector(serveArticle)]) {
        return [self.datasource serveArticle];
    }
    return nil;
}

@end

#pragma mark - TTVCommentTrack

@implementation TTVCommentViewModel (TTVCommentTrack)

- (void)sendCommentClickTrackWithTagIndex:(NSInteger)index
{
    NSString *label;
    if (index) {
        label = @"time_order_comment";
    }
    else {
        label = @"smart_order_comment";
    }
    NSString *tag = [[self getArticle] isImageSubject]?@"slide_detail":@"detail";
    wrapperTrackEvent(tag, label);
}

- (void)sendShowTrackForEmbeddedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [self p_sendShowTrackForFoldCommentCellIfNeed:indexPath];
}

- (void)p_sendShowTrackForFoldCommentCellIfNeed:(NSIndexPath *)indexPath {
    
    if (self.hasSendFoldCommentCellShowTracker) {
        return;
    }
    
    if (!self.hasFoldComment) {
        return;
    }
    
    if (![self isFooterCellWithIndexPath:indexPath]) {
        return;
    }
    
    self.hasSendFoldCommentCellShowTracker = YES;
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.getArticle.itemID forKey:@"item_id"];
    
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"show", self.getArticle.groupModel.groupID, nil, extra.copy);
    
        [extra setValue:@"comment_bottom" forKey:@"position"];
        wrapperTrackEventWithCustomKeys(@"fold_comment_reason", @"show", self.getArticle.groupModel.groupID, nil, extra);
}

@end

#pragma mark - TTVCommentImpression

@implementation TTVCommentViewModel (TTVCommentImpression)

- (void)registerToImpressionManager:(id)object
{
    [[SSImpressionManager shareInstance] addRegist:object];
}

- (void)unregisterFromImpressionManager:(id)object
{
    [[SSImpressionManager shareInstance] removeRegist:object];
}

- (void)enterCommentImpression
{
    [[SSImpressionManager shareInstance] enterCommentViewForGroupID:[self getArticle].groupModel.impressionDescription];
}

- (void)leaveCommentImpression
{
    [[SSImpressionManager shareInstance] leaveCommentViewForGroupID:[self getArticle].groupModel.impressionDescription];
}

- (void)recordForComment:(TTVCommentListItem *)commentItem status:(SSImpressionStatus)status
{
          TTGroupModel *groupModel = [self getArticle].groupModel;
         NSString *commentID = commentItem.commentModel.commentIDNum.stringValue;
        if ([commentItem.commentModel.commentIDNum longLongValue] != 0 && groupModel.groupID != 0) {
            NSString * cIDStr = [NSString stringWithFormat:@"%@", commentID];
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:groupModel.itemID forKey:@"item_id"];
            [extra setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
            [extra setValue:@"article_detail" forKey:@"comment_position"];
            [extra setValue:@"comment" forKey:@"comment_type"];
        
            //记录reply信息,视频当时评论不显示时，已好
            NSArray<TTReplyListStructModel*>* commentReplyInfo = [commentItem.commentModel replyList];
            NSDictionary *uInfo;
            if([commentReplyInfo count] != 0)
            {
                NSMutableArray<NSString*> *replyIDs = [NSMutableArray new];
                [commentReplyInfo enumerateObjectsUsingBlock:^(TTReplyListStructModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(obj.id != 0)
                    {
                        [replyIDs addObject:[NSString stringWithFormat:@"%@",obj.id]];
                    }
                }];
                uInfo = @{@"extra":extra,@"replyIDs":replyIDs};
            }else
            {
                uInfo = @{@"extra":extra};
            }
             
            [[SSImpressionManager shareInstance] recordCommentImpressionGroupID:groupModel.impressionDescription commentID:cIDStr status:status userInfo:uInfo];
        }
}

@end
