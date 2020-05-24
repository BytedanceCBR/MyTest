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
        NSMutableDictionary *popupClickDict = @{}.mutableCopy;
        NSMutableDictionary *popupTipsDict = @{}.mutableCopy;
        popupTipsDict[@"event_page"] = @"account_safe";
        popupTipsDict[@"event_type"] = @"show";
        popupTipsDict[@"event_belong"] = @"account";
        popupTipsDict[@"show_type"] = @"popup";
        popupTipsDict[@"platform"] = @"aweme";
        popupTipsDict[@"params_for_special"] = @"uc_login";
        
        popupClickDict[@"event_page"] = @"account_safe";
        popupClickDict[@"event_type"] = @"click";
        popupClickDict[@"event_belong"] = @"account";
        popupClickDict[@"platform"] = @"aweme";
        popupClickDict[@"params_for_special"] = @"uc_login";

        if ([event isEqualToString:@"tt_account_didDropOrignalaccount"]) {
            popupClickDict[@"popup_type"] = @"冲突弹框";
            popupClickDict[@"status_info"] = @"绑定失败";
            
            popupTipsDict[@"popup_type"] = @"冲突弹框";
            popupTipsDict[@"status_info"] = @"绑定失败";
            
            if ([params btd_intValueForKey:@"cancel"] == 0) {
                popupClickDict[@"status"] = @"on";
                popupTipsDict[@"status"] = @"on";
                popupClickDict[@"click_button"] = @"放弃原账号";
            } else {
                popupClickDict[@"status"] = @"off";
                popupTipsDict[@"status"] = @"off";
                popupClickDict[@"click_button"] = @"取消";
            }
        }
        if ([event isEqualToString:@"tt_account_switchBindAlertView"]) {
            popupClickDict[@"popup_type"] = @"冲突二次确认";
            popupClickDict[@"status_info"] = @"操作确认";
            
            popupTipsDict[@"popup_type"] = @"冲突二次确认";
            popupTipsDict[@"status_info"] = @"操作确认";
            if ([params btd_intValueForKey:@"cancel"] == 0) {
                popupClickDict[@"status"] = @"on";
                popupTipsDict[@"status"] = @"on";
                popupClickDict[@"click_button"] = @"确定";
            } else {
                popupClickDict[@"status"] = @"off";
                popupTipsDict[@"status"] = @"off";
                popupClickDict[@"click_button"] = @"取消";
            }
        }
        TRACK_EVENT(@"third_party_bind_popup_click", popupTipsDict);
        TRACK_EVENT(@"third_party_bind_popup_click", popupClickDict);
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
