//
//  TTVReplyViewModel.m
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVReplyViewModel.h"
#import "ArticleURLSetting.h"
#import "TTVReplyListItem.h"
#import "TTVReplyModel.h"
#import "TTAccountManager.h"
#import "TTNetworkManager.h"

#define kLoadOnceCount 20

// 内部管理类
#pragma mark - TTVReplyManagedObject
@interface TTVReplyManagedObject: NSObject

@property (nonatomic, strong) NSMutableArray <TTVReplyListItem *> *allReplyItems;
@property (nonatomic, strong) NSMutableArray <TTVReplyListItem *> *hotReplyItems;

@property (nonatomic, strong) NSMutableSet *allUniqueIDSet;
@property (nonatomic, strong) NSMutableSet *hotUniqueIDSet;

@property (nonatomic, assign) CGFloat layoutWidth;

- (void)appendAllReplyItemsWithModels:(NSArray <id <TTVReplyModelProtocol>> *)models;
- (void)appendHotReplyItemsWithModels:(NSArray <id <TTVReplyModelProtocol>> *)models;
- (BOOL)insertReplyItemToTop:(id <TTVReplyModelProtocol>)model;
- (BOOL)delelteReplyItemWithReplyModel:(id <TTVReplyModelProtocol>)model;
- (TTVReplyListItem *)getReplyItemWithCommentID:(NSString *)commentID;
- (void)refreshLayoutsWithWidth:(CGFloat)width toItems:(NSArray *)items;
- (void)resetDatas;
@end

@implementation TTVReplyManagedObject
#pragma mark - Init
- (instancetype)init {
    
    if (self = [super init]) {
        
        [self resetDatas];
    }
    
    return self;
}

#pragma mark - Public Methods
- (void)appendAllReplyItemsWithModels:(NSArray<id <TTVReplyModelProtocol>> *)models {
    
    [self p_curItems:self.allReplyItems curSet:self.allUniqueIDSet appendItemsWithModels:models];
}

- (void)appendHotReplyItemsWithModels:(NSArray<id <TTVReplyModelProtocol>> *)models {
    
    [self p_curItems:self.hotReplyItems curSet:self.hotUniqueIDSet appendItemsWithModels:models];
}

- (BOOL)insertReplyItemToTop:(id <TTVReplyModelProtocol>)model {
    
    if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)] ||
        isEmptyString([model commentID]) ||
        [self p_curSet:self.allUniqueIDSet containsObject:[model commentID]]) {
        
        return NO;
    }
    
    TTVReplyListItem *item = [[TTVReplyListItem alloc] init];
    item.model = model;
    item.layout = [[TTVReplyListCellLayout alloc] initWithCommentModel:model containViewWidth:self.layoutWidth];
    
    if (self.allReplyItems.count > 0) {
        [self.allReplyItems insertObject:item atIndex:0];
    } else {
        
        [self.allReplyItems addObject:item];
    }
    
    [self.allUniqueIDSet addObject:[model commentID]];
    
    return YES;
}

- (BOOL)delelteReplyItemWithReplyModel:(id <TTVReplyModelProtocol>)model {
    
    if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)] ||
        isEmptyString([model commentID]) ||
        (![self p_curSet:self.allUniqueIDSet containsObject:[model commentID]] && ![self p_curSet:self.hotUniqueIDSet containsObject:[model commentID]])) {
        
        return NO;
    }
    
    if ([self.allUniqueIDSet containsObject:model.commentID]) {
        
        return [self p_deleteItemWith:model curItems:self.allReplyItems curSet:self.allUniqueIDSet];
    }
    
    if ([self.hotUniqueIDSet containsObject:model.commentID]) {
        
        return [self p_deleteItemWith:model curItems:self.hotReplyItems curSet:self.hotUniqueIDSet];
    }
    
    return NO;
}

- (void)resetDatas {
    
    [self.allReplyItems removeAllObjects];
    [self.hotReplyItems removeAllObjects];
    [self.hotUniqueIDSet removeAllObjects];
    [self.allUniqueIDSet removeAllObjects];
}

- (TTVReplyListItem *)getReplyItemWithCommentID:(NSString *)commentID {
    
    if (isEmptyString(commentID) ||
        (![self p_curSet:self.allUniqueIDSet containsObject:commentID] && ![self p_curSet:self.hotUniqueIDSet containsObject:commentID])) {
        
        return nil;
    }
    
    if ([self.allUniqueIDSet containsObject:commentID]) {
        
        return [self p_getItemWith:commentID curItems:self.allReplyItems];
    }
    
    if ([self.hotUniqueIDSet containsObject:commentID]) {
        
        return [self p_getItemWith:commentID curItems:self.hotReplyItems];
    }
    
    return nil;
}

- (void)refreshLayoutsWithWidth:(CGFloat)width toItems:(NSArray *)items {
    
    for (TTVReplyListItem *item in items) {
        
        if ([item isKindOfClass:[TTVReplyListItem class]]) {
            
            [item.layout setCellLayoutWithCommentModel:item.model containViewWidth:width];
        }
    }
}

#pragma mark - Private Methods
- (BOOL)p_curSet:(NSMutableSet *)curSet containsObject:(NSString *)uniqueID {
    
    if (isEmptyString(uniqueID)) {
        
        return NO;
    }
    
    return [curSet containsObject:uniqueID];
}

- (void)p_curItems:(NSMutableArray <TTVReplyListItem *> *)curItems
            curSet:(NSMutableSet *)curSet
appendItemsWithModels:(NSArray<id <TTVReplyModelProtocol>> *)models {
    
    if (![models isKindOfClass:[NSArray class]]) {
        
        return ;
    }
    
    for (id <TTVReplyModelProtocol> model in models) {
        
        if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)] ||
            isEmptyString([model commentID]) ||
            [self p_curSet:curSet containsObject:[model commentID]]) {
            
            continue;
        }
        
        TTVReplyListItem *item = [[TTVReplyListItem alloc] init];
        item.model = model;
        item.layout = [[TTVReplyListCellLayout alloc] initWithCommentModel:model containViewWidth:self.layoutWidth];
        
        [curItems addObject:item];
        [curSet addObject:[model commentID]];
    }
}

- (BOOL)p_deleteItemWith:(id <TTVReplyModelProtocol>)model
                curItems:(NSMutableArray <TTVReplyListItem *> *)curItems
                  curSet:(NSMutableSet *)curSet {
    
    __block BOOL status = NO;
    [curItems enumerateObjectsUsingBlock:^(TTVReplyListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj.model.commentID isEqualToString:[model commentID]]) {
            
            [curItems removeObject:obj];
            [curSet removeObject:obj.model.commentID];
            
            status = YES;
            *stop = YES;
        }
    }];
    
    return status;
}

- (TTVReplyListItem *)p_getItemWith:(NSString *)commentID curItems:(NSMutableArray <TTVReplyListItem *> *)curItems {
    
    if (isEmptyString(commentID)) {
        
        return nil;
    }
    
    for (TTVReplyListItem *item in curItems) {
        
        if ([[item.model commentID] isEqualToString:commentID]) {
            
            return item;
        }
    }
    
    return nil;
}

#pragma mark - Getters & Setters
- (NSMutableArray<TTVReplyListItem *> *)allReplyItems {
    
    if (!_allReplyItems) {
        
        _allReplyItems = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return _allReplyItems;
}

- (NSMutableArray<TTVReplyListItem *> *)hotReplyItems {
    
    if (!_hotReplyItems) {
        
        _hotReplyItems = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return _hotReplyItems;
}

- (NSMutableSet *)allUniqueIDSet {
    
    if (!_allUniqueIDSet) {
        
        _allUniqueIDSet = [[NSMutableSet alloc] initWithCapacity:1];
    }
    
    return _allUniqueIDSet;
}

- (NSMutableSet *)hotUniqueIDSet {
    
    if (!_hotUniqueIDSet) {
        
        _hotUniqueIDSet = [[NSMutableSet alloc] initWithCapacity:1];
    }
    
    return _hotUniqueIDSet;
}

@end

#pragma mark - TTVReplyViewModel
@interface TTVReplyViewModel()

@property (nonatomic, strong) TTVReplyManagedObject *managedObject;

@property (nonatomic, assign) NSUInteger totalReplyCount;

@property (nonatomic, assign) NSInteger currentOffset;
/**
 *  核心标记。控件通过KVO监听，是否刷新列表。包括init、切换category和loadMore
 */
@property(nonatomic, assign) BOOL reloadFlag;
@end

@implementation TTVReplyViewModel

#pragma mark - Init
- (instancetype)initWithCommentModel:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel containViewWidth:(CGFloat)width {
    
    if (self = [super init]) {
        
        _commentModel = commentModel;
        self.containViewWidth = width;
        _hasMore = YES;
    }
    
    return self;
}
#pragma mark - Public Methods

- (NSArray<TTVReplyListItem *> *)curHotReplyItems {
    
    return self.managedObject.hotReplyItems;
}

- (NSArray<TTVReplyListItem *> *)curAllReplyItems {
    
    return self.managedObject.allReplyItems;
}

- (NSUInteger)totalReplyItemsCount {
    //如果totalReplyCount是0，则返回现有总数
    return self.totalReplyCount ? self.totalReplyCount : (self.managedObject.hotReplyItems.count + self.managedObject.allReplyItems.count);
}

- (void)removeReplyItemWithReplyModel:(id <TTVReplyModelProtocol>)model {
    
    if ([self.managedObject delelteReplyItemWithReplyModel:model]) {
        
        self.totalReplyCount -= 1;
        [self p_setShouldRefreshReplyTableView];
    };
}

- (void)removeReplyItemWithCommentID:(NSString *)commentID {
    
    [self removeReplyItemWithReplyModel:[self curReplyItemWithCommentID:commentID].model];
}

- (TTVReplyListItem *)hotReplyItemAtIndex:(NSUInteger)index {
    
    if (self.managedObject.hotReplyItems.count <= index) {
        
        return nil;
    }
    
    return self.managedObject.hotReplyItems[index];
}

- (TTVReplyListItem *)allReplyItemAtIndex:(NSUInteger)index {
    
    if (self.managedObject.allReplyItems.count <= index) {
        
        return nil;
    }
    
    return self.managedObject.allReplyItems[index];
}

- (TTVReplyListItem *)curReplyItemWithCommentID:(NSString *)commentID {
    
    return [self.managedObject getReplyItemWithCommentID:commentID];
}

- (void)addToTopWithReplyModel:(id<TTVReplyModelProtocol>)model {
    
    if ([self.managedObject insertReplyItemToTop:model]) {
        
        //新插入的回复不是第一条回复，则滚动到插入位置
        if (self.managedObject.allReplyItems.count > 1) {
            self.needMarkedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        }
        self.totalReplyCount += 1;
        [self p_setShouldRefreshReplyTableView];
    }
}

- (void)refreshLayoutsWithWidth:(CGFloat)width {
    
    [self.managedObject refreshLayoutsWithWidth:width toItems:[self curAllReplyItems]];
    [self.managedObject refreshLayoutsWithWidth:width toItems:[self curHotReplyItems]];
    
    [self p_setShouldRefreshReplyTableView];
}

- (void)startLoadReplyListFinishBlock:(void(^)(NSError *error))finishBlock {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:3];
    [param setValue:self.commentModel.commentIDNum.stringValue forKey:@"id"];
    [param setValue:@(kLoadOnceCount) forKey:@"count"];
    [param setValue:@(_currentOffset) forKey:@"offset"];
    self.loading = YES;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting replyedCommentListURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        
        NSDictionary *dataDict = [jsonObj isKindOfClass:[NSDictionary class]]? [jsonObj dictionaryValueForKey:@"data" defalutValue:nil]: nil;
        
        self.hasMore = [dataDict integerValueForKey:@"has_more" defaultValue:0] != 0 ? YES : NO;
        self.currentOffset = [dataDict intValueForKey:@"offset" defaultValue:0];
        self.totalReplyCount = [dataDict unsignedIntegerValueForKey:@"total_count" defaultValue:0];
        
        NSArray *hotComments = [dataDict arrayValueForKey:@"hot_comments" defaultValue:nil];
        NSArray *allComments = [dataDict arrayValueForKey:@"data" defaultValue:nil];
        
        NSArray<id <TTVReplyModelProtocol>> *hotCommentModels = [TTVReplyModel arrayOfModelsFromDictionaries:hotComments];
        
        NSArray<id <TTVReplyModelProtocol>> *allCommentModels = [TTVReplyModel arrayOfModelsFromDictionaries:allComments];
        
        [self.managedObject appendHotReplyItemsWithModels:hotCommentModels];
        [self.managedObject appendAllReplyItemsWithModels:allCommentModels];
        
        self.loading = NO;
        [self p_setShouldRefreshReplyTableView];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            (!finishBlock) ?: finishBlock(error);
        });
    }];
}

// 二级评论点赞
- (void)handleReplyCommentDigWithCommentID:(NSString *)commentID replayID:(NSString *)replayID finishBlock:(void(^)(NSError *error))finishBlock
{
    [self handleReplyCommentDigWithCommentID:commentID replayID:replayID ifDigg:NO finishBlock:finishBlock];
}

- (void)handleReplyCommentDigWithCommentID:(NSString *)commentID replayID:(NSString *)replayID ifDigg:(BOOL)ifDigg finishBlock:(void(^)(NSError *error))finishBlock
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
    [param setValue:self.commentModel.commentIDNum.stringValue forKey:@"id"];
    [param setValue:replayID forKey:@"reply_id"];
    [param setValue:ifDigg ? @"cancel_digg": @"digg" forKey:@"action"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting replyedCommentDigURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        finishBlock(error);
    }];
}


- (void)deleteReplyedComment:(NSString *)replyCommentID InHostComment:(NSString *)hostCommentID {
    if ([replyCommentID longLongValue] == 0 || [hostCommentID longLongValue] == 0) {
        LOGI(@"删除文章评论的ID不能为0");
        return;
    }
    if (![TTAccountManager isLogin]) {
        LOGI(@"删除评论必须登录");
        return;
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
    [param setValue:hostCommentID forKey:@"id"];
    [param setValue:replyCommentID forKey:@"reply_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting deleteReplyedCommentURLString] params:param method:@"POST" needCommonParams:YES callback:nil];
}

#pragma mark - Private Methods
- (void)p_setShouldRefreshReplyTableView {
    //notify KVO
    self.reloadFlag = !self.reloadFlag;
}

#pragma mark - Getters & Setters
- (TTVReplyManagedObject *)managedObject {
    
    if (!_managedObject) {
        
        _managedObject = [[TTVReplyManagedObject alloc] init];
    }
    
    return _managedObject;
}

- (void)setContainViewWidth:(CGFloat)containViewWidth {
    
    _containViewWidth = containViewWidth;
    
    self.managedObject.layoutWidth = containViewWidth;
}
@end
