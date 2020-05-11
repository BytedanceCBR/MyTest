//
//  FHContainerStartupTask.m
//  Pods
//
//  Created by 张静 on 2020/2/4.
//

#import "FHContainerStartupTask.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import <TTMonitor/TTMonitor.h>
#import <Heimdallr/HMDTTMonitor.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTKitchen/TTKitchen.h>
#import <FHHouseBase/FHUserTracker.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>

@implementation FHContainerStartupTask

//- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
//    [super startWithApplication:application options:launchOptions];
//
//    [FHContainerStartupTask registerInterfaces];
//}

+ (void)registerInterfaces
{
    BDUG_BIND_CLASS_PROTOCOL([FHContainerStartupTask class], BDUGTrackerInterface);
    BDUG_BIND_CLASS_PROTOCOL([FHContainerStartupTask class], BDUGMonitorInterface);
    BDUG_BIND_CLASS_PROTOCOL([FHContainerStartupTask class], BDUGSettingsInterface);
}

- (void)event:(NSString *)event params:(NSDictionary *)params {

    [FHUserTracker writeEvent:event params:params];
    if ([event isEqualToString:@"tt_account_didDropOrignalaccount"] || [event isEqualToString:@"tt_account_switchBindAlertView"]) {
        //绑定冲突 取消 tt_account_didDropOrignalaccount param.cancel = 1
        //绑定冲突 放弃原账号 tt_account_didDropOrignalaccount param.cancel = 0
        //绑定冲突 解绑原账号 取消 tt_account_switchBindAlertView param.cancel = 1
        //绑定冲突 解绑原账号 确定 tt_account_switchBindAlertView param.cancel = 0
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[@"event_page"] = @"account_safe";
        tracerDict[@"event_type"] = @"click";
        tracerDict[@"event_belong"] = @"account";
        tracerDict[@"platform"] = @"aweme";
        tracerDict[@"params_for_special"] = @"uc_login";
        if ([event isEqualToString:@"tt_account_switchBindAlertView"] && [params btd_intValueForKey:@"cancel"] == 0) {
            tracerDict[@"status"] = @"on";
        } else {
            tracerDict[@"status"] = @"off";
        }
        if ([event isEqualToString:@"tt_account_didDropOrignalaccount"]) {
            tracerDict[@"popup_type"] = @"冲突弹框";
            if ([params btd_intValueForKey:@"cancel"] == 0) {
                tracerDict[@"click_button"] = @"放弃原账号";
            } else {
                tracerDict[@"click_button"] = @"取消";
            }
        }
        if ([event isEqualToString:@"tt_account_switchBindAlertView"]) {
            tracerDict[@"popup_type"] = @"冲突二次确认";
            if ([params btd_intValueForKey:@"cancel"] == 0) {
                tracerDict[@"click_button"] = @"确定";
            } else {
                tracerDict[@"click_button"] = @"取消";
            }
        }
        TRACK_EVENT(@"third_party_bind_popup_click", tracerDict);
    }
}

- (void)trackService:(NSString *)serviceName attributes:(NSDictionary *)attributes {
    [[HMDTTMonitor defaultManager] hmdTrackService:serviceName metric:nil category:nil extra:attributes];
}

- (void)trackService:(NSString *)serviceName metric:(NSDictionary <NSString *, NSNumber *> *)metric category:(NSDictionary *)category extra:(NSDictionary *)extraValue {
    [[HMDTTMonitor defaultManager] hmdTrackService:serviceName metric:metric category:category extra:extraValue];
}

- (void)trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extraValue {
    [[HMDTTMonitor defaultManager] hmdTrackService:serviceName value:value extra:extraValue];
}


- (id)objectForKeyPath:(NSString *)keyPath defaultValue:(id)defaultValue stable:(BOOL)stable {
    NSDictionary *dic = [[TTSettingsManager sharedManager]settingForKey:keyPath defaultValue:defaultValue freeze:stable];
    return [[TTSettingsManager sharedManager]settingForKey:keyPath defaultValue:defaultValue freeze:stable];
}

@end
