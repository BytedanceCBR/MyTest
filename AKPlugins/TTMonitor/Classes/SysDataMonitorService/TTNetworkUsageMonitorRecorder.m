//
//  TTNetworkUsageMonitorRecorder.m
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTNetworkUsageMonitorRecorder.h"
#import "TTMonitor.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

#define MB (1024.0 * 1024.0)

 uint64_t sys_wifi_send;
 uint64_t sys_wifi_received;
 uint64_t sys_wwan_send;
 uint64_t sys_wwan_received;

CFAbsoluteTime appTimeInterval;
CFAbsoluteTime appTotalUseTimeInterval;

static uint64_t app_wifi_send;
static uint64_t app_wifi_received;
static uint64_t app_wwan_send;
static uint64_t app_wwan_received;
static uint64_t app_networkCost_oneLaunch;
static uint64_t app_wwanCost_oneLaunch;
static uint64_t app_wifiCost_oneLaunch;

@interface TTNetworkUsageMonitorRecorder ()

@end

@implementation TTNetworkUsageMonitorRecorder

+(void)initialize{
    [TTNetworkUsageMonitorRecorder updteInfo];
    app_wifi_send = sys_wifi_send;
    app_wwan_send = sys_wwan_send;
    app_wifi_received = sys_wifi_received;
    app_wwan_received = sys_wwan_received;
    appTimeInterval = [[NSDate date] timeIntervalSince1970];
}

-(void)resetNetworkData{
    [TTNetworkUsageMonitorRecorder updteInfo];
    app_wifi_send = sys_wifi_send;
    app_wwan_send = sys_wwan_send;
    app_wifi_received = sys_wifi_received;
    app_wwan_received = sys_wwan_received;
    appTimeInterval = [[NSDate date] timeIntervalSince1970];
}

+(void)updteInfo{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    sys_wifi_send = 0;
    sys_wifi_received = 0;
    sys_wwan_send = 0;
    sys_wwan_received = 0;

    NSString *name=[[NSString alloc]init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    sys_wifi_send+=networkStatisc->ifi_obytes;
                    sys_wifi_received+=networkStatisc->ifi_ibytes;
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    sys_wwan_send+=networkStatisc->ifi_obytes;
                    sys_wwan_received+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
}

- (NSString *)type{
    return @"network_monitor";
}

- (double)monitorInterval{
    double value = [TTMonitorConfiguration queryActionIntervalForKey:@"network_monitor_interval"];
    if (value<=0) {
        value = 60*60;
    }
    return value;
}

- (BOOL)isEnabled{
    return [TTMonitorConfiguration queryIfEnabledForKey:@"network_monitor"];
}

- (void)recordIfNeeded:(BOOL)isTermite{
    if (![self isEnabled]) {
        return;
    }
    [TTNetworkUsageMonitorRecorder updteInfo];
    double networkCost = (sys_wwan_received-app_wwan_received) +
                        (sys_wifi_received - app_wifi_received) +
                        (sys_wifi_send - app_wifi_send) +
                        (sys_wwan_send - app_wwan_send);
    
    double wwandownstream = sys_wwan_received-app_wwan_received;
    double wwanupstream = sys_wwan_send - app_wwan_send;
    double wwanCost = wwandownstream + wwanupstream;
    
    double wifidownstream = sys_wifi_received - app_wifi_received;
    double wifiUpStream = sys_wifi_send - app_wifi_send;
    double wifiCost = wifidownstream + wifiUpStream;
    
    double durationOfThisUse = [[NSDate date] timeIntervalSince1970] - appTimeInterval;
    appTotalUseTimeInterval += durationOfThisUse;
    double networkCostMB = networkCost/(1024.0*1024.0);
    
    NSMutableDictionary * netUsageDetail = [[NSMutableDictionary alloc] init];
    if (wwandownstream/MB>0) {
     [netUsageDetail setValue:@(wwandownstream/MB) forKey:@"wwandownstream"];
    }
    if (wwanupstream/MB>0) {
     [netUsageDetail setValue:@(wwanupstream/MB) forKey:@"wwanupstream"];
    }
    if (wwanCost/MB > 0) {
        [netUsageDetail setValue:@(wwanCost/MB) forKey:@"wwanCost"];
    }
    if (wifidownstream/MB > 0) {
        [netUsageDetail setValue:@(wifidownstream/MB) forKey:@"wifidownstream"];
    }
    if (wifiUpStream/MB>0) {
        [netUsageDetail setValue:@(wifiUpStream/MB) forKey:@"wifiUpStream"];
    }
    if (wifiCost/MB > 0) {
        [netUsageDetail setValue:@(wifiCost/MB) forKey:@"wifiCost"];
    }
    if (durationOfThisUse>0) {
     [netUsageDetail setValue:@(durationOfThisUse) forKey:@"durationOfThisUse"];
    }
    [[TTMonitor shareManager] trackService:@"network_usage_service" value:netUsageDetail extra:nil];
    
    app_networkCost_oneLaunch += networkCostMB;
    app_wifiCost_oneLaunch += wifiCost;
    app_wwanCost_oneLaunch += wwanCost;
    
    [[TTMonitor shareManager] event:[self type] label:@"network_cost" duration:networkCostMB needAggregate:NO];
    if (isTermite) {
        NSMutableDictionary * netUsageDetailForOneLaunch = [[NSMutableDictionary alloc] init];
        if (app_wifiCost_oneLaunch/MB>0) {
            [netUsageDetailForOneLaunch setValue:@(app_wifiCost_oneLaunch/MB) forKey:@"app_wifiCost_oneLaunch"];
        }
        if (app_wwanCost_oneLaunch/MB > 0) {
            [netUsageDetailForOneLaunch setValue:@(app_wwanCost_oneLaunch/MB) forKey:@"app_wwanCost_oneLaunch"];
        }
        if (app_networkCost_oneLaunch/MB) {
            [netUsageDetailForOneLaunch setValue:@(app_networkCost_oneLaunch/MB) forKey:@"app_networkCost_oneLaunch"];
        }
        if (appTotalUseTimeInterval>0) {
            [netUsageDetailForOneLaunch setValue:@(appTotalUseTimeInterval) forKey:@"appTotalUseTimeInterval"];
        }
        [[TTMonitor shareManager] trackService:@"network_usage_onelaunch_service" value:netUsageDetailForOneLaunch extra:nil];
        [[TTMonitor shareManager] event:[self type] label:@"network_cost_oneLaunch" duration:app_networkCost_oneLaunch needAggregate:NO];
    }
}


@end
