//
//  TTFeedContainerViewModel.m
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTFeedContainerViewModel.h"
#import "TTFeedFetchLocalOperation.h"
#import "TTFeedFetchRemoteOperation.h"
#import "TTFeedInsertDataOperation.h"
#import "TTFeedSaveRemoteOperation.h"
#import "TTFeedMergeOperation.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "UIView+Refresh_ErrorHandler.h"
#import <SDWebImage/SDWebImageCompat.h>

@interface TTFeedContainerViewModel ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, copy)   NSString *categoryID;
@property (nonatomic, assign) ExploreOrderedDataListType listType;
@property (nonatomic, assign) NSUInteger refer;
@property (nonatomic, assign) ListDataOperationReloadFromType reloadType;//刷新方式
@property (nonatomic, assign) BOOL loadMore;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL hasNew;//还有更多内容
@property (nonatomic, strong) NSNumber *rankKey;
@property (nonatomic, copy)   NSArray *allItems;
@property (nonatomic, copy)   NSDictionary *remoteDict;
@property (nonatomic, copy)   NSArray *flattenList;
@property (nonatomic, copy)   NSArray *ignoreList;
@property (nonatomic, copy)   NSArray *increaseItems;
@property (nonatomic, assign) NSUInteger newNumber;
@property (nonatomic, strong) NSError *error;

@end

@implementation TTFeedContainerViewModel

- (instancetype)init {
    if (self = [super init]) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:2];
        _listType = ExploreOrderedDataListTypeCategory;
        _categoryID = @"";
        _refer = 1;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<TTFeedContainerViewModelDelegate>)delegate {
    if (self = [super init]) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:2];
        _listType = ExploreOrderedDataListTypeCategory;
        _refer = 1;
        if (delegate) {
            _delegate = delegate;
            if ([_delegate respondsToSelector:@selector(listType)]) {
                _listType = [_delegate listType];
            }
            if ([_delegate respondsToSelector:@selector(categoryID)]) {
                _categoryID = [_delegate categoryID];
            }
            if ([_delegate respondsToSelector:@selector(refer)]) {
                _refer = [_delegate refer];
            }
        }
    }
    return self;
}

- (void)startFetchDataLoadMore:(BOOL)loadMore fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadType:(ListDataOperationReloadFromType)reloadType {
    self.loadMore = loadMore;
    self.reloadType = reloadType;
    
    TTFeedFetchLocalOperation  *fetchLocalOperation = nil;
    TTFeedFetchRemoteOperation *fetchRemoteOperation = nil;
    TTFeedInsertDataOperation *insertDataOperation = nil;
    TTFeedSaveRemoteOperation *saveRemoteOperation = nil;
    TTFeedMergeOperation *mergeOperation = nil;
    
    BOOL needPersistence = YES;
    if ([self.delegate respondsToSelector:@selector(needPesistence)]) {
        needPersistence = [self.delegate needPesistence];
    }
    
    if ([SSCommonLogic feedRefreshClearAllEnable]) {
        needPersistence = YES;
    }
    
    if (fromLocal && needPersistence) {
        fetchLocalOperation = [[TTFeedFetchLocalOperation alloc] initWithViewModel:self];
        __weak typeof(fetchLocalOperation) weakOperation = fetchLocalOperation;
        [fetchLocalOperation setCompletionBlock:^{
            self.canLoadMore = weakOperation.canLoadMore;
            self.allItems = weakOperation.allItems;
            self.error = fetchRemoteOperation.error;
            if ([self.delegate respondsToSelector:@selector(didFetchDataformRemote:error:)]) {
                dispatch_main_sync_safe(^{
                    [self.delegate didFetchDataformRemote:NO error:self.error];
                });
            }
        }];
        [self.queue addOperation:fetchLocalOperation];
    }
    
    if (fromRemote) {
        fetchRemoteOperation = [[TTFeedFetchRemoteOperation alloc] initWithViewModel:self];
        if (fetchLocalOperation) {
            [fetchRemoteOperation addDependency:fetchLocalOperation];
        }
        __weak typeof(fetchRemoteOperation) weakOperation = fetchRemoteOperation;
        [fetchRemoteOperation setCompletionBlock:^{
            self.rankKey = weakOperation.rankKey;
            self.remoteDict = weakOperation.remoteDict;
            self.flattenList = weakOperation.flattenList;
            self.error = weakOperation.error;
        }];
        [self.queue addOperation:fetchRemoteOperation];
    }
    
    if (fromLocal || fromRemote) {
        insertDataOperation = [[TTFeedInsertDataOperation alloc] initWithViewModel:self];
        __weak typeof(insertDataOperation) weakOperation = insertDataOperation;
        if (fetchRemoteOperation) {
            [insertDataOperation addDependency:fetchRemoteOperation];
        }
        [insertDataOperation setCompletionBlock:^{
            self.increaseItems = weakOperation.increaseItems;
            self.newNumber = weakOperation.newNumber;
            self.ignoreList = weakOperation.ignoreIDs;
        }];
        
        if ([SSCommonLogic feedRefreshClearAllEnable]) {
            if (!fromLocal && fromRemote) {
                [self.queue addOperation:insertDataOperation];
            }
        } else {
            [self.queue addOperation:insertDataOperation];
        }
    }
    
    if (fromRemote && needPersistence) {
        saveRemoteOperation = [[TTFeedSaveRemoteOperation alloc] initWithViewModel:self];
        if (insertDataOperation) {
            [saveRemoteOperation addDependency:insertDataOperation];
        }
        [self.queue addOperation:saveRemoteOperation];
    }
    
    if (fromLocal || fromRemote) {
        mergeOperation = [[TTFeedMergeOperation alloc] initWithViewModel:self];
        __weak typeof(mergeOperation) weakOperation = mergeOperation;
        if (self.delegate && [self.delegate respondsToSelector:@selector(asyncPersistence)] && ![self.delegate asyncPersistence]) {
            if (saveRemoteOperation) {
                [mergeOperation addDependency:saveRemoteOperation];
            }
        } else {
            if (fetchRemoteOperation) {
                [mergeOperation addDependency:insertDataOperation];
            }
        }
        [mergeOperation setCompletionBlock:^{
            self.canLoadMore = weakOperation.canLoadMore;
            self.allItems = weakOperation.sortedAllItems;
            self.increaseItems = weakOperation.sortedIncreaseItems;
            self.hasNew = weakOperation.hasNew;
            if ([self.delegate respondsToSelector:@selector(didFetchDataformRemote:error:)]) {
                dispatch_main_sync_safe(^{
                [self.delegate didFetchDataformRemote:YES error:self.error];
                });
            }
        }];
        
        if ([SSCommonLogic feedRefreshClearAllEnable]) {
            if (!fromLocal && fromRemote) {
                [self.queue addOperation:mergeOperation];
            }
        } else {
            [self.queue addOperation:mergeOperation];
        }
    }
}

- (BOOL)removeDataSourceArrayIfNeeded:(NSArray *)deletingArray {
    BOOL success = NO;
    NSMutableArray *mutableAllItems = [NSMutableArray arrayWithArray:self.allItems];
    if (!SSIsEmptyArray(deletingArray)
        && [[deletingArray firstObject] isKindOfClass:[[self.allItems firstObject] class]]) {
        success = YES;
        [mutableAllItems removeObjectsInArray:deletingArray];
        self.allItems = [mutableAllItems copy];
    }
    return success;
}

- (BOOL)removeDataSourceItemIfNeeded:(id)deletingItem {
    BOOL success = NO;
    NSMutableArray *mutableAllItems = [NSMutableArray arrayWithArray:self.allItems];
    if (deletingItem
        && [deletingItem isKindOfClass:[[self.allItems firstObject] class]]) {
        if ([mutableAllItems containsObject:deletingItem]) {
            success = YES;
            [mutableAllItems removeObject:deletingItem];
            self.allItems = [mutableAllItems copy];
        }
    }
    return success;
}

- (void)cleanupDataSource {
    self.categoryID = @"";
    self.loadMore = NO;
    self.canLoadMore = NO;
    self.hasNew = NO;
    self.rankKey = nil;
    self.allItems = nil;
    self.remoteDict = nil;
    self.flattenList = nil;
    self.ignoreList = nil;
    self.increaseItems = nil;
    self.newNumber = 0;
}

- (BOOL)insertDataSourceItem:(id)insertingItem atIndex:(NSUInteger)index {
    BOOL success = NO;
    NSMutableArray *mutableAllItems = [NSMutableArray arrayWithArray:self.allItems];
    if ((insertingItem
        && [insertingItem isKindOfClass:[[self.allItems firstObject] class]]) || self.allItems.count == 0) {
        if (![mutableAllItems containsObject:insertingItem]) {
            success = YES;
            [mutableAllItems insertObject:insertingItem atIndex:index];
            self.allItems = [mutableAllItems copy];
        }
    }
    return success;
}

@end
