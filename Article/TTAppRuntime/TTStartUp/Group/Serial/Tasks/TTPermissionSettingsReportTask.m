//
//  TTPermissionSettingsReportTask.m
//  Article
//
//  Created by chenren on 05/07/2017.
//
//

#import "TTPermissionSettingsReportTask.h"
#import "TTLocationManager.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTUserSettingsManager+Notification.h"
#import "TTUserSettingsManager+NetworkTraffic.h"
#import "APNsManager.h"

@implementation TTPermissionSettingsReportTask

- (NSString *)taskIdentifier
{
    return @"TTPermissionSettingsReportTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    // 延时2.5秒，避免影响启动速度
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reportPermissionSettings];
    });
}

- (void)reportPermissionSettings
{
    NSInteger apnNotifyValue = 1;
    if ([TTUserSettingsManager apnsNewAlertClosed]) {
        apnNotifyValue = 0;
    }
    
    BOOL apnNotifyEnabled = NO;
    if([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        apnNotifyEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        apnNotifyEnabled = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
    }
    
    if (!apnNotifyEnabled) {
        apnNotifyValue = 0;
    }
    
    TTNetworkTrafficSetting settingType = [TTUserSettingsManager networkTrafficSetting];
    
    TTUserSettingsFontSize settingFontSize = [TTUserSettingsManager settingFontSize];
    
    NSInteger locationAuth = 1;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        locationAuth = 0;
    }
    
    [TTTrackerWrapper eventV3:@"permission_collection" params:@{@"font_size":@(settingFontSize), @"coarse_location":@(locationAuth), @"notification":@(apnNotifyValue), @"network_setting":@(settingType)}];
    [[APNsManager sharedManager] sendAppNoticeStatus];
}

@end
