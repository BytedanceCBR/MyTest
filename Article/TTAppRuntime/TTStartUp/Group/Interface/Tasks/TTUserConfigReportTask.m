//
//  TTUserConfigReportTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTUserConfigReportTask.h"
#import "TTUserSettingsReporter.h"
#import "TTInstallIDManager.h"
#import "TTLocationManager.h"
#import "TTSettingsManager.h"

@implementation TTUserConfigReportTask

- (NSString *)taskIdentifier {
    return @"UserConfigReport";
}

- (BOOL)isConcurrent{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue];
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [TTUserSettingsReporter startWithConfigParams:^NSDictionary *{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"install_id"];
        [params setValue:[[TTInstallIDManager sharedInstance] deviceID ] forKey:@"device_id"];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        NSNumber * nightModeValue = @1;
        if ([[TTThemeManager  sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            nightModeValue = @0;
        }
        [data setValue:nightModeValue forKey:@"night_mode"];
        
        [data setValue:[TTLocationManager currentLBSStatus] forKey:@"LBS_status"];
        
        if(!isEmptyString([TTLocationManager sharedManager].city)) {
            [data setValue:[TTLocationManager sharedManager].city forKey:@"city"];
        }
        
        if([[TTLocationManager sharedManager] placemarkItem]) {
            [data setValue:@([[TTLocationManager sharedManager] placemarkItem].coordinate.latitude) forKey:@"latitude"];
            [data setValue:@([[TTLocationManager sharedManager] placemarkItem].coordinate.longitude) forKey:@"longitude"];
        }
        [params setValue:[data copy] forKey:@"data_params"];
        
        return [params copy];
    }];
    [TTUserSettingsReporter sharedInstance].reportUrl = [CommonURLSetting reportUserConfigurationString];
    [[TTUserSettingsReporter sharedInstance] startReportUserConfiguration];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![[defaults objectForKey:@"get_phone_info_upload"] boolValue]) {
        NSString *deviceName = [UIDevice currentDevice].name;
        if (!isEmptyString(deviceName)) {
            [TTTrackerWrapper eventV3:@"get_phone_info" params:@{@"phone_name":deviceName}];
        }
        [defaults setBool:YES forKey:@"get_phone_info_upload"];
        [defaults synchronize];
    }
    
}

@end
