//
//  EssayGetRemoteDataOperation.m
//  Essay
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoGetRemoteDataOperation.h"
#import "VideoListDataOperationManager.h"
#import "VideoListDataHeader.h"
#import "VideoGetUpdatesNumberManager.h"
#import "OrderedData.h"
#import "SSOperation.h"
#import "NetworkUtilities.h"

@implementation VideoGetRemoteDataOperation

- (id)init
{
    self = [super init];
    if(self)
    {
        self.shouldExecuteBlock = ^(id dataContext){
            BOOL fromRemote = [[dataContext objectForKey:kSSDataOperationFromRemoteKey] boolValue];
            NSArray *sortedList = [dataContext objectForKey:kSSDataOperationOrderedListKey];
            BOOL result = fromRemote || ([sortedList count] == 0);
            
            if ([sortedList count] == 0) {
                [dataContext setObject:[NSNumber numberWithBool:NO] forKey:kVideoDataOperationGetStatsKey];
            }
            
            if(result)
            {
                if(!SSNetworkConnected())
                {
                    [dataContext setObject:[NSNumber numberWithBool:YES] forKey:kSSDataOperationLoadFinishedKey];
                    [self notifyWithData:nil
                                   error:[NSError errorWithDomain:kListDataErrorDomain code:kListDataNetworkError userInfo:nil]
                                userInfo:dataContext];
                    result = NO;
                }
                
            }
            
            [dataContext setObject:[NSNumber numberWithBool:result] forKey:kSSDataOperationFromRemoteKey];
            return result;
        };
    }
    
    return self;
}

- (void)execute:(id)operationContext
{
    self.hasFinished = NO;
    if(!self.shouldExecuteBlock(operationContext)) {
        self.hasFinished = YES;
        [self executeNext:operationContext];
        return;
    }
    
    NSArray *orderedDataList = [operationContext objectForKey:kSSDataOperationOrderedListKey];
    BOOL getMore = [[operationContext objectForKey:kSSDataOperationLoadMoreKey] boolValue];
    NSMutableDictionary *condition = [[[operationContext objectForKey:kSSDataOperationConditionKey] mutableCopy] autorelease];
    BOOL loadNewest = [[operationContext objectForKey:kVideoDataOperationLoadNewestKey] boolValue];
    DataSortType sortType = [[condition objectForKey:kListDataConditionSortTypeKey] intValue];
    
    if (getMore) {
        if ([orderedDataList count] > 0) {
            [condition setObject:[[orderedDataList lastObject] orderIndex] forKey:kVideoListDataConditionEarliestKey];
        }
    }
    else if (loadNewest) {
        if (sortType == DataSortTypeFavorite || [orderedDataList count] == 0) {
            [condition setObject:[NSNumber numberWithFloat:0.f] forKey:kVideoListDataConditionLatestKey];
        }
        else {
            NSNumber *updateTimestamp = updatesTimestamp();
            if (updateTimestamp) {
                [condition setObject:updateTimestamp forKey:kVideoListDataConditionLatestKey];
            }
            else {
                [condition setObject:[[orderedDataList objectAtIndex:0] orderIndex] forKey:kVideoListDataConditionLatestKey];
            }
        }
    }
   
    [operationContext setObject:condition forKey:kSSDataOperationConditionKey];
    NSDictionary *requestInfo = [self.delegate performSelector:@selector(requestInfoForRemoteDataOperation:operationContext:)
                                                    withObject:self
                                                    withObject:operationContext];
    [operationContext setObject:requestInfo forKey:kSSDataOperationRequestInfoKey];
    
    [self.operation cancelAndClearDelegate];
    self.operation = nil;
    self.operation = [SSHttpOperation httpOperationWithURLString:[requestInfo objectForKey:@"urlString"]
                                                    getParameter:[requestInfo objectForKey:@"parameter"]
                                                        userInfo:operationContext];
    [self.operation setFinishTarget:self selector:@selector(operation:result:error:userInfo:)];
    [SSOperationManager addOperation:self.operation];
}

- (void)operation:(SSHttpOperation*)operation result:(NSDictionary*)result error:(NSError*)tError userInfo:(id)userInfo
{
    if(tError) {
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:kSSDataOperationCanLoadMoreKey];
        [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kSSDataOperationLoadFinishedKey];
        NSError *newError = nil;
        
        if ([tError.domain isEqualToString:NetworkRequestErrorDomain]) {
            newError = [NSError errorWithDomain:kListDataErrorDomain code:kVideoListDataASINetworkError userInfo:nil];
        }
        else {
            newError = [NSError errorWithDomain:kListDataErrorDomain code:kListDataUnkownError userInfo:nil];
        }
        
        [self notifyWithData:nil error:newError userInfo:userInfo];
        self.hasFinished = YES;
    }
    else {
        [userInfo setObject:result forKey:kSSDataOperationRemoteDataKey];
        [self executeNext:userInfo];
    }
}

@end
