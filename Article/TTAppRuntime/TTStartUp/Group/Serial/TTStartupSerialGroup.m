//
//  TTStartupSerialGroup.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTStartupSerialGroup.h"
#import "TTGetInstallIDTask.h"
#import "TTAppLogStartupTask.h"
#import "TTRegisterSettingsTask.h"
#import "TTNetworkSerializerTask.h"
#import "TTCleanDatabaseTask.h"
#import "TTClearCacheTask.h"
#import "TTURLCacheSettingTask.h"
#import "TTSDWebImageCacheSettingTask.h"
//#import "TTWeiboExpirationDetectTask.h"
#import "TTAppPageManagerTask.h"
#import "TTHandleShorcutItemTask.h"
#import "TTHandleFirstLauchTask.h"
#import "TTNetworkNotifyTask.h"
#import "TTHandleAPNSTask.h"
#import "TTWatchConnectionTask.h"
#import "TTOrientationTask.h"
#import "TTFabricSDKRegister.h"
#import "TTCrashAttemptFixTask.h"
#import "TTAccountSDKRegister.h"
#import "TTSetHookTask.h"
#import "TTPermissionSettingsReportTask.h"
#import "TTCrashRepotTask.h"
#import "TTABHelperTask.h"
#import "TTSetUseBDWebImageTask.h"

@implementation TTStartupSerialGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupSerialGroup *)serialGroup {
    TTStartupSerialGroup *group = [[TTStartupSerialGroup alloc] init];
    
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeCrashAttemptFix]];
    [group.tasks addObject:[[self class] serialStartupForType:TTServiceStartupTypeCrashReport]];
    [group.tasks addObject:[[self class] serialStartupForType:TTServiceStartupTypeUseBDWebImage]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeFabric]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeClientABHelper]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeAccountSDK]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeNetworkSerializer]];
    [group.tasks addObject:[[self class] serialStartupForType:TTInterfaceStartupTypeGetInstallID]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeAppLog]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeRegisterSettings]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeCleanDatabase]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeClearCache]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeURLCacheSetting]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeSDWebImageCacheSetting]];
//    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeWeiboExpirationDetect]];
    [group.tasks addObject:[[self class] serialStartupForType:TTServiceStartupTypeAppPageManager]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeHandleShortcutItem]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeNetworkNotify]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeHanleAPNS]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeWatchConnetion]];
    [group.tasks addObject:[[self class] serialStartupForType:TTServiceStartupTypeOrientation]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeHandleFirstLaunch]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypeSetHook]];
    [group.tasks addObject:[[self class] serialStartupForType:TTSerialStartupTypePermissionSettingsReport]];
    return group;
    
}

+ (TTStartupTask *)serialStartupForType:(TTSerialStartupType)type {
    switch (type) {
        case TTSerialStartupTypeCrashAttemptFix:
            return [[TTCrashAttemptFixTask alloc] init];
            break;
        case TTServiceStartupTypeCrashReport:
            return [[TTCrashRepotTask alloc] init];
            break;
        case TTSerialStartupTypeFabric:
            return [[TTFabricSDKRegister alloc] init];
            break;
        case TTSerialStartupTypeClientABHelper:
            return [[TTABHelperTask alloc] init];
            break;
        case TTSerialStartupTypeAccountSDK:
            return [[TTAccountSDKRegister alloc] init];
            break;
        case TTSerialStartupTypeNetworkSerializer:
            return [[TTNetworkSerializerTask alloc] init];
            break;
        case TTInterfaceStartupTypeGetInstallID:
            return [[TTGetInstallIDTask alloc] init];
            break;
        case TTSerialStartupTypeAppLog:
            return [[TTAppLogStartupTask alloc] init];
            break;
        case TTSerialStartupTypeRegisterSettings:
            return [[TTRegisterSettingsTask alloc] init];
            break;
        case TTSerialStartupTypeCleanDatabase:
            return [[TTCleanDatabaseTask alloc] init];
            break;
        case TTSerialStartupTypeClearCache:
            return [[TTClearCacheTask alloc] init];
            break;
        case TTSerialStartupTypeURLCacheSetting:
            return [[TTURLCacheSettingTask alloc] init];
            break;
        case TTSerialStartupTypeSDWebImageCacheSetting:
            return [[TTSDWebImageCacheSettingTask alloc] init];
            break;
//        case TTSerialStartupTypeWeiboExpirationDetect:
//            return [[TTWeiboExpirationDetectTask alloc] init];
//            break;
        case TTServiceStartupTypeAppPageManager:
            return [[TTAppPageManagerTask alloc] init];
            break;
        case TTSerialStartupTypeHandleShortcutItem:
            return [[TTHandleShorcutItemTask alloc] init];
            break;
        case TTSerialStartupTypeNetworkNotify:
            return [[TTNetworkNotifyTask alloc] init];
            break;
        case TTSerialStartupTypeHanleAPNS:
            return [[TTHandleAPNSTask alloc] init];
            break;
        case TTSerialStartupTypeWatchConnetion:
            return [[TTWatchConnectionTask alloc] init];
            break;
        case TTServiceStartupTypeOrientation:
            return [[TTOrientationTask alloc] init];
            break;
        case TTSerialStartupTypeHandleFirstLaunch:
            return [[TTHandleFirstLauchTask alloc] init];
            break;
        case TTSerialStartupTypeSetHook:
            return [[TTSetHookTask alloc] init];
            break;
        case TTSerialStartupTypePermissionSettingsReport:
            return [[TTPermissionSettingsReportTask alloc] init];
            break;
        case TTServiceStartupTypeUseBDWebImage:
            return [[TTSetUseBDWebImageTask alloc] init];
            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
