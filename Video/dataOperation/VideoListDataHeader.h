//
//  VideoListDataHeader.h
//  Essay
//
//  Created by 于天航 on 12-8-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#ifndef Video_ListData_h
#define Video_ListData_h

#import "ListDataHeader.h"

// Need notification to other list views when rebuild dataOperation because all list views share the same dataOpeartion.
#define kVideoDataOperationRebuildKey @"kVideoDataOperationRebuildKey"

#define kVideoDataOperationClearCacheKey @"kVideoDataOperationClearCacheKey"
#define kVideoDataOperationHasRemoteKey @"kVideoDataOperationHasRemoteKey"

#define kVideoDataOperationGetUpdateNumberKey @"kVideoDataOperationGetUpdateNumberKey"
#define kVideoDataOperationGetStatsKey @"kVideoDataOperationGetStatsKey"
#define kVideoDataOperationLoadNewestKey @"kVideoDataOperationLoadNewestKey"
#define kVideoDataOperationLoadAllLocalKey @"kVideoDataOperationLoadAllLocalKey"
#define kVideoDataOperationGetStatsHasDeadLinkKey @"kVideoDataOperationGetStatsHasDeadLinkKey"

#define kVideoListDataConditionLatestKey @"kVideoListDataConditionLatestKey"
#define kVideoListDataConditionEarliestKey @"kVideoListDataConditionEarliestKey"
#define kVideoListDataDownloadDataListType @"kVideoListDataDownloadDataListType"

// error
#define kVideoListDataASINetworkError 1000

#define kVideoPositionRecordCondition @"kVideoPositionRecordCondition"
#define kVideoPositionRecordConditionLatestTimestampKey @"kVideoPositionRecordConditionLatestTimestampKey"
#define kVideoPositionRecordConditionEarliestTimestampKey @"kVideoPositionRecordConditionEarliestTimestampKey"
#define kVideoPositionRecordConditionPositionTimestampKey @"kVideoPositionRecordConditionPositionTimestampKey"

#define kVideoPositionRecordConditionSortTypeKey @"kVideoPositionRecordConditionSortTypeKey"

static inline void setPositionRecordCondition (NSDictionary *condition, DataSortType sortType) {
    
    NSTimeInterval earliest = [[condition objectForKey:kVideoPositionRecordConditionEarliestTimestampKey] doubleValue];
    NSTimeInterval latest = [[condition objectForKey:kVideoPositionRecordConditionLatestTimestampKey] doubleValue];
    NSTimeInterval position = [[condition objectForKey:kVideoPositionRecordConditionPositionTimestampKey] doubleValue];
    
    double secondsPerDay = 60*60*24.f;
    double filterRange = (sortType == DataSortTypeRecent ? secondsPerDay : 4*secondsPerDay);
    if (latest - position > filterRange || position - earliest > filterRange) {
        NSMutableDictionary *tmpCondition = [NSMutableDictionary dictionaryWithDictionary:condition];
        
        if (latest - position > filterRange) {
            [tmpCondition setObject:[NSNumber numberWithDouble:position + filterRange] forKey:kVideoPositionRecordConditionLatestTimestampKey];
        }
        
        if (position - earliest > filterRange) {
            [tmpCondition setObject:[NSNumber numberWithDouble:position - filterRange] forKey:kVideoPositionRecordConditionEarliestTimestampKey];
        }

        condition = tmpCondition;
    }
    
    NSMutableDictionary *recordCondition = [[[[NSUserDefaults standardUserDefaults] objectForKey:kVideoPositionRecordCondition] mutableCopy] autorelease];
    if (!recordCondition) {
        recordCondition = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    [recordCondition setObject:condition forKey:[NSString stringWithFormat:@"%d", sortType]];
    
    [[NSUserDefaults standardUserDefaults] setObject:recordCondition forKey:kVideoPositionRecordCondition];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline NSDictionary* positionRecordCondition (DataSortType sortType) {
    NSDictionary *condition = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoPositionRecordCondition];
    return [condition objectForKey:[NSString stringWithFormat:@"%d", sortType]];
}

#define kVideoPositionRecordSwitchUserDefaultKey @"kVideoPositionRecordSwitchUserDefaultKey"
static inline void setPositionRecordOn (BOOL on) {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kVideoPositionRecordSwitchUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL positionRecordOn () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoPositionRecordSwitchUserDefaultKey];
}

#endif