//
//  TTStartupInterfaceGroup.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupInterfaceGroup.h"
#import "TTUserInfoStartupTask.h"
#import "TTAppAlertStartupTask.h"
#import "TTAppSettingsStartupTask.h"
//#import "TTUGCPermissionStartupTask.h"
#import "TTUmengTrackStartupTask.h"
#import "TTUserConfigReportTask.h"
#import "TTAppStoreADTask.h"
#import "TTRouteSelectStartupTask.h"
#import "TTFetchBadgeTask.h"
#import "TTGetDomainTask.h"
#import "TTFeedbackCheckTask.h"
#import "TTGetCategoryTask.h"
#import "TTProfileEntryStartupTask.h"
//#import "TTUploadContactsStartupTask.h"
//#import "TTSFActivityDataTask.h"
#import "TTStartupTask.h"


@implementation TTStartupInterfaceGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupInterfaceGroup *)interfaceGroup {
    TTStartupInterfaceGroup *group = [[TTStartupInterfaceGroup alloc] init];
    
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeUserInfo]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeAppAlert]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeAppSettings]];
//    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeUGCPermission]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeUmengTrack]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeUserConfig]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeAppStoreAD]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeRouteSelect]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeFetchBadge]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeGetDomain]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeFeedbackCheck]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeGetCategory]];
    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeProfileEntry]];
//    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeUploadContacts]];
//    [group.tasks addObject:[[self class] interfaceStartupForType:TTInterfaceStartupTypeSFActivityData]];
    return group;
}

+ (TTStartupTask *)interfaceStartupForType:(TTInterfaceStartupType)type {
    switch (type) {
        case TTInterfaceStartupTypeUserInfo:
            return [[TTUserInfoStartupTask alloc] init];
            break;
        case TTInterfaceStartupTypeAppAlert:
            return [[TTAppAlertStartupTask alloc] init];
            break;
        case TTInterfaceStartupTypeAppSettings:
            return [[TTAppSettingsStartupTask alloc] init];
            break;
//        case TTInterfaceStartupTypeUGCPermission:
//            return [[TTUGCPermissionStartupTask alloc] init];
//            break;
        case TTInterfaceStartupTypeUmengTrack:
            return [[TTUmengTrackStartupTask alloc] init];
            break;
        case TTInterfaceStartupTypeUserConfig:
            return [[TTUserConfigReportTask alloc] init];
            break;
        case TTInterfaceStartupTypeAppStoreAD:
            return [[TTAppStoreADTask alloc] init];
            break;
        case TTInterfaceStartupTypeRouteSelect:
            return [[TTRouteSelectStartupTask alloc] init];
            break;
        case TTInterfaceStartupTypeFetchBadge:
            return [[TTFetchBadgeTask alloc] init];
            break;
        case TTInterfaceStartupTypeGetDomain:
            return [[TTGetDomainTask alloc] init];
            break;
        case TTInterfaceStartupTypeFeedbackCheck:
            return [[TTFeedbackCheckTask alloc] init];
            break;
        case TTInterfaceStartupTypeGetCategory:
            return [[TTGetCategoryTask alloc] init];
            break;
        case TTInterfaceStartupTypeProfileEntry:
            return [[TTProfileEntryStartupTask alloc] init];
            break;
//        case TTInterfaceStartupTypeUploadContacts:
//            return [[TTUploadContactsStartupTask alloc] init];
//            break;
//        case TTInterfaceStartupTypeSFActivityData:
//            return [[TTSFActivityDataTask alloc] init];
//            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
