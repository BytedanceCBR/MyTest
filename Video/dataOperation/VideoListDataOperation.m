//
//  VideoListDataOperation.m
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoListDataOperation.h"
#import "VideoListDataHeader.h"
#import "VideoGetLocalDataOperation.h"
#import "VideoGetRemoteDataOperation.h"
#import "VideoPreInsertRemoteDataOperation.h"
#import "VideoInsertRemoteDataOperation.h"
#import "VideoSaveRemoteDataOperation.h"
#import "VideoPostSaveDataOperation.h"
#import "VideoGetStatsDataOperation.h"
#import "VideoURLSetting.h"
#import "AccountManager.h"

@interface VideoListDataOperation()<SSGetRemoteDataOperationDelegate>
- (NSDictionary*)requestInfoForRecentSortType:(id)context;
- (NSDictionary*)requestInfoForTopSortType:(id)context;
@end

@implementation VideoListDataOperation

static VideoListDataOperation *s_operation;
+ (VideoListDataOperation*)sharedOperation
{
    @synchronized(self) {
        if(!s_operation) {
            s_operation = [[VideoListDataOperation alloc] init];
        }
        
        return s_operation;
    }
}

- (id)init
{
    self = [super init];
    if(self) {
        VideoGetLocalDataOperation *localOperation = [[VideoGetLocalDataOperation alloc] init];
        VideoGetRemoteDataOperation *remoteOperation = [[VideoGetRemoteDataOperation alloc] init];
        remoteOperation.delegate = self;
        VideoPreInsertRemoteDataOperation *preInsertOperation = [[VideoPreInsertRemoteDataOperation alloc] init];
        VideoInsertRemoteDataOperation *insertOperation = [[VideoInsertRemoteDataOperation alloc] init];
        VideoSaveRemoteDataOperation *saveOperation = [[VideoSaveRemoteDataOperation alloc] init];
        VideoPostSaveDataOperation *postSaveOperation = [[VideoPostSaveDataOperation alloc] init];
        VideoGetStatsDataOperation *getStatsOperation = [[VideoGetStatsDataOperation alloc] init];
        
        [self addOperation:localOperation];
        [self addOperation:remoteOperation];
        [self addOperation:preInsertOperation];
        [self addOperation:insertOperation];
        [self addOperation:saveOperation];
        [self addOperation:postSaveOperation];
        [self addOperation:getStatsOperation];
        
        [localOperation release];
        [remoteOperation release];
        [preInsertOperation release];
        [insertOperation release];
        [saveOperation release];
        [postSaveOperation release];
        [getStatsOperation release];
    }
    
    return self;
}

#pragma mark - SSGetRemoteDataOperationDelegate

- (NSDictionary*)requestInfoForRemoteDataOperation:(SSGetRemoteDataOperation*)operation operationContext:(id)context
{
    NSDictionary *condition = [context objectForKey:kSSDataOperationConditionKey];
    DataSortType sortType = [[condition objectForKey:kListDataConditionSortTypeKey] intValue];
    NSDictionary *result = nil;
    switch (sortType) {
        case DataSortTypeRecent:
        {
            result = [self requestInfoForRecentSortType:context];
        }
            break;
        case DataSortTypeTop:
        {
            result = [self requestInfoForTopSortType:context];
        }
            break;
        case DataSortTypeFavorite:
        {
            result = [self requestInfoForFavoriteSortType:context];
        }
            break;
        default:
            break;
    }
    
    return result;
}

- (NSDictionary*)requestInfoForRecentSortType:(id)context
{
    NSDictionary *condition = [context objectForKey:kSSDataOperationConditionKey];
    BOOL loadNewest = [[context objectForKey:kVideoDataOperationLoadNewestKey] boolValue];
    BOOL loadMore = [[context objectForKey:kSSDataOperationLoadMoreKey] boolValue];
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithCapacity:30];
    NSArray *urlArray = [condition objectForKey:kListDataURLArrayKey];
    
    // hard code news here, because app will display all tags data, tagID will not set outside
    NSString *tag = SSLogicStringNODefault(@"vlTag");
//    NSString *tag = [condition objectForKey:kListDataConditionTagKey];
    
    if (urlArray != nil && [urlArray count] > 0) {
        
        [urlString appendString:[urlArray objectAtIndex:0]];
        if([urlString rangeOfString:@"tag"].location == NSNotFound) {
            NSString *sep = [urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
            [urlString appendFormat:@"%@tag=%@", sep, tag];
        }
    }
    
    if ([urlString length] == 0)  {
        [urlString appendString:[NSString stringWithFormat:@"%@?tag=%@", [VideoURLSetting recentURLString], tag]];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:5];
    
    int count = ListDataVideoRemoteNormalLoadCount;
    
    if (loadMore) {
            [param setObject:[condition objectForKey:kVideoListDataConditionEarliestKey] forKey:@"max_behot_time"];
    }
    else {
        if (loadNewest) {
            [param setObject:[condition objectForKey:kVideoListDataConditionLatestKey] forKey:@"min_behot_time"];
        }
        else {
            [param setObject:[condition objectForKey:kVideoListDataConditionLatestKey] forKey:@"max_behot_time"];
        }
    }
    
    if ([[AccountManager sharedManager] sessionKey]) {
        [param setObject:[[AccountManager sharedManager] sessionKey] forKey:@"session_key"];
    }
    
    [param setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:urlString, @"urlString", param, @"parameter", nil];
    [urlString release];
    return result;
}

- (NSDictionary*)requestInfoForTopSortType:(id)context
{
    NSDictionary *condition = [context objectForKey:kSSDataOperationConditionKey];
    NSArray *urlArray = [condition objectForKey:kListDataURLArrayKey];
    NSMutableString *urlString = [NSMutableString stringWithCapacity:10];
    
    // hard code news here, because app will display all tags data, tagID will not set outside
    NSString *tag = SSLogicStringNODefault(@"vlTag");
//    NSString *tagStr = [condition objectForKey:kListDataConditionTagKey];
    DataRangeType rangeType = [[condition objectForKey:kListDataConditionRangeTypeKey] intValue];
    
    if (urlArray != nil && [urlArray count] > 1) {
        [urlString appendString:[urlArray objectAtIndex:1]];
        if([urlString rangeOfString:@"tag"].location == NSNotFound) {
            NSString *sep = [urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
            [urlString appendFormat:@"%@tag=%@", sep, tag];
        }
    }
    
    if ([urlString length] == 0) {
        [urlString appendString:[NSString stringWithFormat:@"%@?tag=%@", [VideoURLSetting topURLString], tag]];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"offset", nil];
    
    int daysNumber = 0;
    int count = 0;
    switch (rangeType)
    {
        case DataRangeDaily:
            daysNumber = 1;
            count = 10;
            break;
        case DataRangeWeekly:
            daysNumber = 7;
            count = 100;
            break;
        case DataRangeMonthly:
            daysNumber = 30;
            count = 100;
            break;
        default:
            break;
    }
    if (daysNumber > 0) {
        [param setObject:[NSNumber numberWithInt:daysNumber] forKey:@"days"];
    }
    if (count > 0) {
        [param setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    }
    if ([[AccountManager sharedManager] sessionKey]) {
        [param setObject:[[AccountManager sharedManager] sessionKey] forKey:@"session_key"];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:urlString, @"urlString", param, @"parameter", nil];
}

- (NSDictionary *)requestInfoForFavoriteSortType:(id)context
{
    BOOL loadMore = [[context objectForKey:kSSDataOperationLoadMoreKey] boolValue];
    NSDictionary * condition = [context objectForKey:kSSDataOperationConditionKey];
    NSArray *urlArray = [condition objectForKey:kListDataURLArrayKey];
    NSMutableString * urlString = [NSMutableString stringWithCapacity:10];
    
    // hard code news here, because app will display all tags data, tagID will not set outside
    NSString *tag = SSLogicStringNODefault(@"vlTag");
//    NSString *tagStr = [condition objectForKey:kListDataConditionTagKey];
    
    if (urlArray != nil && [urlArray count] > 0) {
        [urlString appendString:[urlArray objectAtIndex:0]];
        if([urlString rangeOfString:@"tag"].location == NSNotFound)
        {
            NSString *sep = [urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
            [urlString appendFormat:@"%@tag=%@", sep, tag];
        }
    }
    
    if ([urlString length] == 0)
    {
        [urlString appendString:[NSString stringWithFormat:@"%@?tag=%@", [VideoURLSetting getFavoritesURLString], tag]];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", ListDataVideoRemoteNormalLoadCount], @"count", nil];
    
    if ([[AccountManager sharedManager] sessionKey]) {
        [param setObject:[[AccountManager sharedManager] sessionKey] forKey:@"session_key"];
    }
    
    if (loadMore) {
        [param setObject:[condition objectForKey:kVideoListDataConditionEarliestKey] forKey:@"max_repin_time"];
    }
    else {
        [param setObject:[condition objectForKey:kVideoListDataConditionLatestKey] forKey:@"min_repin_time"];
    }
    
    [param setObject:[NSString stringWithFormat:@"%i", ListDataTypeVideo] forKey:@"item_type"];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:urlString, @"urlString", param, @"parameter", nil];
}

@end
