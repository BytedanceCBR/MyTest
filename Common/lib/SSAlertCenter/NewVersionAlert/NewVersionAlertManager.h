//
//  NewVersionAlertManager.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSBaseAlertManager.h"
#import "TTInfoHelper.h"

#define CheckNewVersionFinishedNotification @"CheckNewVersionFinishedNotification"

#define kNewVersionAlertLastVersionNameUserDefaultKey @"kNewVersionAlertLastVersionNameUserDefaultKey"
static inline void setLastVersionName(NSString* versionName) {
    if (!isEmptyString(versionName)) {
        [[NSUserDefaults standardUserDefaults] setObject:versionName forKey:kNewVersionAlertLastVersionNameUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

static inline NSString* lastVersionName() {
    NSString *lastVersionName = [[NSUserDefaults standardUserDefaults] objectForKey:kNewVersionAlertLastVersionNameUserDefaultKey];
    if (isEmptyString(lastVersionName)) {
        lastVersionName = [TTInfoHelper versionName];
        setLastVersionName(lastVersionName);
    }
    return lastVersionName;
}

#define kNewVersionCheckRecordDictUserDefaultKey @"kNewVersionCheckRecordDictUserDefaultKey"
#define kNewVersionLastDelayDaysKey @"kNewVersionLastDelayDaysKey"
#define kNewVersionCheckRecordLastTimeKey @"kNewVersionCheckRecordLastTimeKey"

static void setNewVersionCheckRecordDict (NSDictionary *dict) {
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kNewVersionCheckRecordDictUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSDictionary* newVersionCheckRecordDict () {
    NSDictionary *recordDict = [[NSUserDefaults standardUserDefaults] objectForKey:kNewVersionCheckRecordDictUserDefaultKey];
    if (!recordDict) {
        return [NSDictionary dictionary];
    }
    else {
        return recordDict;
    }
}

static NSString* checkRecordKey (NSString *newVersion) {
    return [NSString stringWithFormat:@"%@_%@", [TTInfoHelper versionName], newVersion];
}

static inline void updateNewVersionLastDelayDaysAndCheckRecordLastTime (NSString *newVersion) {
    NSString *recordKey = checkRecordKey(newVersion);
    NSMutableDictionary *recordDict = [newVersionCheckRecordDict() mutableCopy];
    NSMutableDictionary *versionDict = [[recordDict objectForKey:recordKey] mutableCopy];
    
    if (!versionDict) {
        [recordDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:1], kNewVersionLastDelayDaysKey,
                               [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], kNewVersionCheckRecordLastTimeKey,
                               nil]
                       forKey:recordKey];
    }
    else {
        NSNumber *days = [versionDict objectForKey:kNewVersionLastDelayDaysKey];
        if (!days) {
            [versionDict setObject:[NSNumber numberWithInt:1] forKey:kNewVersionLastDelayDaysKey];
        }
        else {
            [versionDict setObject:[NSNumber numberWithInt:[days intValue]*2] forKey:kNewVersionLastDelayDaysKey];
        }
        
        [versionDict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]
                        forKey:kNewVersionCheckRecordLastTimeKey];
        
        [recordDict setObject:versionDict forKey:recordKey];
    }
        
    setNewVersionCheckRecordDict(recordDict);
}


@interface NewVersionAlertManager : SSBaseAlertManager

- (void)startAlertAutoCheck:(BOOL)autoCheck;
- (BOOL)hasNewVersion;

@end
