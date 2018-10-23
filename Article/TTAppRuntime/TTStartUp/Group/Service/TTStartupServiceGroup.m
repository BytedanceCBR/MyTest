//
//  TTStartupServiceGroup.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTStartupServiceGroup.h"
#import "TTMonitorStartupTask.h"
#import "TTABHelperTask.h"
#import "TTCustomUISettingTask.h"
#import "TTCellRegisterTask.h"
#import "TTMapperRegisterTask.h"
#import "TTAVPlayerTask.h"
#import "TTTimeIntervalTask.h"
#import "TTLocationStartupTask.h"
#import "TTSpotlightTask.h"
#import "TTUniversalLinksTask.h"
//#import "TTCollectDiskSpaceTask.h"
#import "TTCookieStartupTask.h"
#import "TTBackgroundModeTask.h"
//#import "TTPrivateLetterTask.h"
#import "TTiOS10NotificationCheckTask.h"
#import "TTCommonURLSettingTask.h"
#import "TTLaunchTimerTask.h"
#import "TTFeedPreloadTask.h"
#import "TTSettingsManager.h"
#import "TTIESPlayerTask.h"
#import "TTStartupAKActivityTabTask.h"
#import "TTStartupAKLaunchTask.h"

@implementation TTStartupServiceGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupServiceGroup *)serviceGroup {
    TTStartupServiceGroup *group = [[TTStartupServiceGroup alloc] init];
    
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeMonitor]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeCustomUISetting]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeCellRegister]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeMapperRegister]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeAVPlayer]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeTimeInterval]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeLocation]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeSpotlight]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeUniversalLinks]];
//    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeCollectDiskSpace]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeCookie]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeBackgroundMode]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypePrivateLetter]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeiOS10NotificationCheck]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeReporter]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeLaunchTime]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeStatistics]];
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeFeedPreload]];
    }
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeIESPlayer]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeAkActivityTab]];
    [group.tasks addObject:[[self class] serviceStartupForType:TTServiceStartupTypeAkLaunch]];
    
    return group;
}

+ (TTStartupTask *)serviceStartupForType:(TTServiceStartupType)type {
    switch (type) {
        case TTServiceStartupTypeMonitor:
            return [[TTMonitorStartupTask alloc] init];
            break;
        case TTServiceStartupTypeCustomUISetting:
            return [[TTCustomUISettingTask alloc] init];
            break;
        case TTServiceStartupTypeCellRegister:
            return [[TTCellRegisterTask alloc] init];
            break;
        case TTServiceStartupTypeMapperRegister:
            return [[TTMapperRegisterTask alloc] init];
            break;
        case TTServiceStartupTypeAVPlayer:
            return [[TTAVPlayerTask alloc] init];
            break;
        case TTServiceStartupTypeTimeInterval:
            return [[TTTimeIntervalTask alloc] init];
            break;
        case TTServiceStartupTypeLocation:
            return [[TTLocationStartupTask alloc] init];
            break;
        case TTServiceStartupTypeSpotlight:
            return [[TTSpotlightTask alloc] init];
            break;
        case TTServiceStartupTypeUniversalLinks:
            return [[TTUniversalLinksTask alloc] init];
            break;
//        case TTServiceStartupTypeCollectDiskSpace:
//            return [[TTCollectDiskSpaceTask alloc] init];
//            break;
        case TTServiceStartupTypeCookie:
            return [[TTCookieStartupTask alloc] init];
            break;
        case TTServiceStartupTypeBackgroundMode:
            return [[TTBackgroundModeTask alloc] init];
            break;
//        case TTServiceStartupTypePrivateLetter:
//            return [[TTPrivateLetterTask alloc] init];
//            break;
        case TTServiceStartupTypeiOS10NotificationCheck:
            return [[TTiOS10NotificationCheckTask alloc] init];
            break;
        case TTServiceStartupTypeReporter:
            return [[TTCommonURLSettingTask alloc] init];
            break;
        case TTServiceStartupTypeLaunchTime:
            return [[TTLaunchTimerTask alloc] init];
            break;
        case TTServiceStartupTypeFeedPreload:
            return [[TTFeedPreloadTask alloc] init];
            break;
        case TTServiceStartupTypeIESPlayer:
            return [[TTIESPlayerTask alloc] init];
            break;
        case TTServiceStartupTypeAkActivityTab:
            return [[TTStartupAKActivityTabTask alloc] init];
            break;
        case TTServiceStartupTypeAkLaunch:
            return [[TTStartupAKLaunchTask alloc] init];
            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
