//
//  EssayGetLocalDataOperation.m
//  Essay
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoGetLocalDataOperation.h"
#import "ListDataHeader.h"
#import "VideoListDataHeader.h"
#import "OrderedVideoData.h"
#import "CachedDataManager.h"
#import "NetworkUtilities.h"

@implementation VideoGetLocalDataOperation

- (id)init
{
    self = [super init];
    if (self) {
        self.normalLoadCount  = 50;
        self.offlineLoadCount = 200;
        
        self.didFinishedBlock = ^(NSArray *newList, NSError *error,  id operationContext)
        {
            BOOL fromRemote = [[operationContext objectForKey:kSSDataOperationFromRemoteKey] boolValue];
            BOOL needStats = [[operationContext objectForKey:kVideoDataOperationGetStatsKey] boolValue];
            [operationContext setObject:[NSNumber numberWithBool:!fromRemote && !needStats] forKey:kSSDataOperationLoadFinishedKey];
            [self notifyWithData:newList error:error userInfo:operationContext];
        };
    }
    return self;
}

- (Class)orderedDataClass
{
    return [OrderedVideoData class];
}

- (void)execute:(id)operationContext
{
    self.hasFinished = NO;
    
    if(!self.shouldExecuteBlock(operationContext)) {
        self.hasFinished = YES;
        [self executeNext:operationContext];
        
        return;
    }
    
    BOOL loadNewest = [[operationContext objectForKey:kVideoDataOperationLoadNewestKey] boolValue];
    BOOL loadAllLocal = [[operationContext objectForKey:kVideoDataOperationLoadAllLocalKey] boolValue];
    BOOL clearCache = [[operationContext objectForKey:kVideoDataOperationClearCacheKey] boolValue];
    NSDictionary *condition = [operationContext objectForKey:kSSDataOperationConditionKey];
    NSMutableArray *orderedDataList = [operationContext objectForKey:kSSDataOperationOrderedListKey];
    if (orderedDataList == nil) {
        orderedDataList = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
    }
    NSMutableArray *originalDataList = [operationContext objectForKey:kSSDataOperationOriginalListKey];
    if (originalDataList == nil) {
        originalDataList = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
    }
    
    // from memory
    NSMutableDictionary *keyDict = [NSMutableDictionary dictionaryWithDictionary:condition];
    [keyDict removeObjectForKey:kVideoListDataConditionLatestKey];
    [keyDict removeObjectForKey:kVideoListDataConditionEarliestKey];
    
    if (clearCache) {
        [[CachedDataManager sharedManager] removeObjectForKey:keyDict];
    }
    
    NSArray *sortedDataList = [[CachedDataManager sharedManager] objectForKey:keyDict];
    
    // from store
    if([sortedDataList count] == 0) {
        
        NSUInteger count = self.normalLoadCount;
        if (!SSNetworkConnected()) {
            count = self.offlineLoadCount;
        }
        
        if (loadAllLocal) {
            count = NSUIntegerMax;
        }
        
        NSMutableDictionary *queryCondition = [condition mutableCopy];
        if (loadNewest) {
            [queryCondition removeObjectForKey:kVideoListDataConditionLatestKey];
            [queryCondition removeObjectForKey:kVideoListDataConditionEarliestKey];
        }
        else if (!loadAllLocal) {
            [queryCondition removeObjectForKey:kVideoListDataConditionEarliestKey];
        }
        
        sortedDataList = [[self orderedDataClass] entitiesWithCondition:queryCondition
                                                                  count:count
                                                                 offset:0];
        [queryCondition release];
    }
    
    [orderedDataList removeAllObjects];
    [originalDataList removeAllObjects];
    [orderedDataList addObjectsFromArray:sortedDataList];
    [originalDataList addObjectsFromArray:[orderedDataList valueForKeyPath:@"originalData"]];
    
    // store to cache
    [[CachedDataManager sharedManager] cacheObject:sortedDataList forKey:keyDict];
    
    // update context
    [operationContext setObject:orderedDataList forKey:kSSDataOperationOrderedListKey];
    [operationContext setObject:originalDataList forKey:kSSDataOperationOriginalListKey];
    
    if ([condition objectForKey:kListDataConditionSortTypeKey]) {
        [operationContext setObject:[NSNumber numberWithBool:YES] forKey:kSSDataOperationCanLoadMoreKey];
    }
    
    self.didFinishedBlock(sortedDataList, nil, operationContext);
    self.hasFinished = YES;
    
    [self executeNext:operationContext];
}

@end


