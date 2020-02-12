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

- (void)event:(NSString *)event params:(NSDictionary *)params
{
    [FHUserTracker writeEvent:event params:params];
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
