//
//  SSUserConfigurationReporter.m
//  Article
//
//  Created by Dianwei on 13-5-8.
//
//

#import <CoreLocation/CoreLocation.h>
#import "SSUserConfigurationReporter.h"
#import "SSOperationManager.h"
#import "SSHttpOperation.h"

#import "CommonURLSetting.h"
#import "InstallIDManager.h"
#import "SSCommon+JSON.h"
#import "TTLocationManager.h"

#import "APNsManager.h"
#import "NewsDetailLogicManager.h"
#import "NewsLogicSetting.h"
#import "NewsUserSettingManager.h"
#import "ExploreItemActionManager.h"


#define kConfigurationStorageKey    @"kConfigurationStorageKey"
#define kAllConfigSyncTimeIntervalKey @"kAllConfigSyncTimeIntervalKey"

@interface SSUserConfigurationReporter(){
    
    int _retryTime;
    BOOL _isSyncConfigRequest;
}

@end

@implementation SSUserConfigurationReporter

static SSUserConfigurationReporter *s_reporter;
+ (SSUserConfigurationReporter*)sharedReporter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_reporter = [[SSUserConfigurationReporter alloc] init];
    });
    
    return s_reporter;
}

- (id)init
{
    self = [super init];
    if(self)
    {
    }
    
    return self;
}


- (void)startReportUserConfiguration
{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationStorageKey]];
    
    _isSyncConfigRequest = NO;
    
    if (data.count == 0) {
        NSTimeInterval lastSyncTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kAllConfigSyncTimeIntervalKey] doubleValue];
        
        // 距上次同步时间1天以上，同步所有当前设置
        if ([[NSDate date] timeIntervalSince1970] - lastSyncTime > 3600 * 24) {
            data = [NSMutableDictionary dictionaryWithDictionary:[self currentConfiguration]];
            _isSyncConfigRequest = YES;
        }
    }
    
    [data setValue:@([CLLocationManager locationServicesEnabled]) forKey:@"LBS_enabled"];
    
    NSNumber * nightModeValue = @1;
    if ([[TTThemeManager  sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        nightModeValue = @0;
    }
     
    [data setValue:nightModeValue forKey:@"night_mode"];
    
    [data setValue:[TTLocationManager currentLBSStatus] forKey:@"LBS_status"];

    
    if(!isEmptyString([TTLocationManager sharedManager].city)) {
        [data setValue:[TTLocationManager sharedManager].city forKey:@"city"];
    }
    
    if([[TTLocationManager sharedManager] placemarkItem])
    {
        [data setValue:@([[TTLocationManager sharedManager] placemarkItem].coordinate.latitude) forKey:@"latitude"];
        [data setValue:@([[TTLocationManager sharedManager] placemarkItem].coordinate.longitude) forKey:@"longitude"];
    }
    
    BOOL apnsEnabled = NO;
    
    if([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        apnsEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else
    {
        apnsEnabled = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
    }
    
    [data setValue:@(apnsEnabled) forKey:@"apns_enabled"];
    
    if(data.count > 0)
    {
        NSMutableDictionary *postParam = [NSMutableDictionary dictionaryWithCapacity:10];
        [postParam setValue:[[InstallIDManager sharedManager] deviceID] forKey:@"device_id"];
        [postParam setObject:[TTSandBoxHelper appName] forKey:@"app_name"];
        [postParam setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
        [postParam setValue:[[InstallIDManager sharedManager] installID] forKey:@"install_id"];
        [postParam setValue:[TTSandBoxHelper versionName] forKey:@"version"];
        [postParam setValue:[data JSONRepresentation] forKey:@"data"];
        
        WeakSelf;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting reportUserConfigurationString] params:postParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            StrongSelf;
            if (error) {
                // 重试一次
                if (_retryTime == 0) {
                    _retryTime ++;
                    [self startReportUserConfiguration];
                }
                else {
                    _retryTime = 0;
                }
                return;
            }
            // 发送成功清除发生变动的设置
            [self purgeConfiguration];
            _retryTime = 0;
            
            if (_isSyncConfigRequest) {
                NSTimeInterval syncTime = [[NSDate date] timeIntervalSince1970];
                [[NSUserDefaults standardUserDefaults] setObject:@(syncTime) forKey:kAllConfigSyncTimeIntervalKey];
            }
        }];
    }
}

- (void)purgeConfiguration
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfigurationStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addConfigurationValue:(id)value key:(NSString*)key
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationStorageKey]];
    
    [dict setValue:value forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kConfigurationStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)currentConfiguration
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // 推送
    NSNumber *apnNotifyValue = apnsNewAlertClosed() ? @0 : @1;
    [dict setValue:apnNotifyValue forKey:kConfigAPNNotify];
        
    // 列表显示摘要
    ReadMode mode = [NewsLogicSetting userSetReadMode];
    NSNumber *abstractMode = (mode == ReadModeAbstract ? @1 : @0);
    [dict setValue:abstractMode forKey:kArticleConfigListMode];
        
//    // 收藏时转发
//    NSNumber *retweetWhenRepin = retweetWhenRepinOn() ? @1 : @0;
//    [dict setValue:retweetWhenRepin forKey:kConfigRepostFavor];
        
    // 夜间模式
    NSNumber *nightModeValue = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @0 : @1;
    [dict setValue:nightModeValue forKey:kConfigNightMode];
    
    // 省流量设置
    NetworkTrafficSetting settingType = [SSUserSettingManager networkTrafficSetting];
    [dict setValue:@(settingType) forKey:kArticleConfigImageMode];

    // 字体设置
    NSNumber *fontSettingIndex = @([SSUserSettingManager fontSettingIndex]);
    [dict setValue:fontSettingIndex forKey:kArticleConfigFontSize];
    
    return [dict copy];
}

@end
