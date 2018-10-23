//
//  EssayPostSaveDataOperation.m
//  Essay
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoPostSaveDataOperation.h"
#import "ListDataHeader.h"
#import "VideoListDataHeader.h"
#import "SSModelManager.h"
#import "OrderedVideoData.h"
#import "ListDataUtil.h"
#import "CachedDataManager.h"

@implementation VideoPostSaveDataOperation

- (Class)orderedDataClass
{
    return [OrderedVideoData class];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.shouldExecuteBlock = ^(id dataContext){
            BOOL fromRemote = [[dataContext objectForKey:kSSDataOperationFromRemoteKey] boolValue];
            return fromRemote;
        };
    }
    return self;
}

- (void)execute:(id)operationContext
{
    if (!self.shouldExecuteBlock(operationContext)) {
        [self executeNext:operationContext];
        return;
    }
    
    NSArray *newData = [operationContext objectForKey:kSSDataOperationInsertedDataKey];
    BOOL getMore = [[operationContext objectForKey:kSSDataOperationLoadMoreKey] boolValue];
    NSMutableArray *orderedDataList = [operationContext objectForKey:kSSDataOperationOrderedListKey];
    if (orderedDataList == nil) {
        orderedDataList = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
    }
    NSMutableArray *originalDataList = [operationContext objectForKey:kSSDataOperationOriginalListKey];
    if (originalDataList == nil) {
        originalDataList = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
    }
    BOOL loadNewest = [[operationContext objectForKey:kVideoDataOperationLoadNewestKey] boolValue];
    
    NSUInteger queryDBCount;
    NSDictionary *result = [operationContext objectForKey:kSSDataOperationRemoteDataKey];
    NSDictionary *condition = [operationContext objectForKey:kSSDataOperationConditionKey];
    
    if (getMore) {
        queryDBCount =[orderedDataList count] + [newData count];
    }
    else {
        BOOL hasMore = [[[result objectForKey:@"result"] objectForKey:@"has_more"] boolValue];
        if(!hasMore) {
            queryDBCount = [orderedDataList count] + [newData count];
        }
        else {
            queryDBCount = [newData count];
        }
    }
    
    [orderedDataList removeAllObjects];
    [originalDataList removeAllObjects];
    NSError *error = nil;
    
    NSMutableDictionary *queryCondition = [condition mutableCopy];
    if (loadNewest) {
        [queryCondition removeObjectForKey:kVideoListDataConditionLatestKey];
        [queryCondition removeObjectForKey:kVideoListDataConditionEarliestKey];
    }
    else {
        if (getMore) {
            [queryCondition removeObjectForKey:kVideoListDataConditionEarliestKey];
        }
    }
    
    [orderedDataList addObjectsFromArray:[OrderedVideoData entitiesWithCondition:queryCondition
                                                                           count:queryDBCount
                                                                          offset:0]];
    [queryCondition release];
    [originalDataList addObjectsFromArray:[orderedDataList valueForKeyPath:@"originalData"]];

    // store to cache
    NSMutableDictionary *keyDict = [NSMutableDictionary dictionaryWithDictionary:condition];
    [keyDict removeObjectForKey:kVideoListDataConditionLatestKey];
    [keyDict removeObjectForKey:kVideoListDataConditionEarliestKey];
    [[CachedDataManager sharedManager] cacheObject:orderedDataList forKey:keyDict];

    // update context
    DataSortType sortType = [[condition objectForKey:kListDataConditionSortTypeKey] intValue];
    BOOL canLoadMore = YES;
    if(sortType == DataSortTypeFavorite || sortType == DataSortTypeRecent || sortType == DataSortTypeHot) {
        if(getMore && [newData count] == 0) {
            canLoadMore = NO;
        }
        else {
            canLoadMore = YES;
        }
    }
    [operationContext setObject:[NSNumber numberWithBool:canLoadMore] forKey:kSSDataOperationCanLoadMoreKey];
    [operationContext setObject:orderedDataList forKey:kSSDataOperationOrderedListKey];
    [operationContext setObject:originalDataList forKey:kSSDataOperationOriginalListKey];
    
    BOOL needStats = [[operationContext objectForKey:kVideoDataOperationGetStatsKey] boolValue];
    [operationContext setObject:[NSNumber numberWithBool:!needStats] forKey:kSSDataOperationLoadFinishedKey];
    
    self.hasFinished = YES;
    [self notifyWithData:newData error:error userInfo:operationContext];
    [self executeNext:operationContext];
}

@end
