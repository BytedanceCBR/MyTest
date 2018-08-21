//
//  VideoConstants.h
//  Video
//
//  Created by Tianhang Yu on 12-7-26.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

// font
#define ChineseFont ChineseFontWithSize(14.f)
#define BoldChineseFont BoldChineseFontWithSize(14.f)
#define ChineseFontWithSize(x) [UIFont fontWithName:SSUIStringNoDefault(@"vuStandardFont") size:x]
#define BoldChineseFontWithSize(x) [UIFont fontWithName:SSUIStringNoDefault(@"vuStandardBoldFont") size:x]

// notifications
#define VideoMainViewChangeViewNotification @"VideoMainViewChangeViewNotification"
#define kVideoMainViewChangeToMoreView @"kVideoMainViewChangeToMoreView"
#define kVideoMainViewChangeToMVView @"kVideoMainViewChangeToMVView"
#define kVideoMainViewChangeToDownloadView @"kVideoMainViewChangeToDownloadView"
#define kVideoMainViewChangeToMineView @"kVideoMainViewChangeToMineView"

//// orientation lock
//#define kVideoOrientationLockSwitchUserDefaultKey @"kVideoOrientationLockSwitchUserDefaultKey"
//static inline void setOrientationLock (BOOL lock) {
//    [[NSUserDefaults standardUserDefaults] setBool:lock forKey:kVideoOrientationLockSwitchUserDefaultKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//static inline BOOL orientationLocked () {
//    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoOrientationLockSwitchUserDefaultKey];
//}
//
//// not wifi alert
//#define kNotWifiAlertClosedUserDefaultKey @"kNotWifiAlertClosedUserDefaultKey"

static inline bool notWifiAlertOn ()
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNotWifiAlertClosedUserDefaultKey];
}

static inline void setNotWifiAlertOn (bool on)
{
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kNotWifiAlertClosedUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


// date formmater
static NSDateFormatter *__yearToMiniteFormatter = nil;

static NSDateFormatter *YearToMiniteFormatter() {
    if (__yearToMiniteFormatter == nil) {
        __yearToMiniteFormatter = [[NSDateFormatter alloc] init];
        [__yearToMiniteFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return __yearToMiniteFormatter;
}

static NSDateFormatter *__hourToMiniteFormatter = nil;

static NSDateFormatter *HourToMiniteFormatter() {
    if (__hourToMiniteFormatter == nil) {
        __hourToMiniteFormatter = [[NSDateFormatter alloc] init];
        [__hourToMiniteFormatter setDateFormat:@"HH:mm"];
    }
    return __hourToMiniteFormatter;
}

static NSDateFormatter *__yearToDayFormatter = nil;

static NSDateFormatter *YearToDayFormatter() {
    if (__yearToDayFormatter == nil) {
        __yearToDayFormatter = [[NSDateFormatter alloc] init];
        [__yearToDayFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return __yearToDayFormatter;
}

@interface VideoConstants : NSObject

@end
