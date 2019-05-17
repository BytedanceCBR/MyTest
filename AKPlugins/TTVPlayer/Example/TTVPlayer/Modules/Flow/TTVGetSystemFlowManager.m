//
//  TTVGetSystemFlowManager.m
//  Article
//
//  Created by wangdi on 2017/6/29.
//
//

#import "TTVGetSystemFlowManager.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

uint64_t ttv_flow_sys_wwan_send;
uint64_t ttv_flow_sys_wwan_received;

static uint64_t flow_app_wwan_send;
static uint64_t flow_app_wwan_received;

@implementation TTVGetSystemFlowManager

+ (void)initialize
{
    if (self == [TTVGetSystemFlowManager self]) {
        [self _updateInfo];
        flow_app_wwan_send = ttv_flow_sys_wwan_send;
        flow_app_wwan_received = ttv_flow_sys_wwan_received;
    }
}

+ (void)_updateInfo
{
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *flow_cursor;
    const struct if_data *flow_networkStatisc;
    ttv_flow_sys_wwan_send = 0;
    ttv_flow_sys_wwan_received = 0;
    NSString *name=[[NSString alloc]init];
    success = getifaddrs(&addrs) == 0;
    if (success) {
        flow_cursor = addrs;
        while (flow_cursor != NULL) {
            name=[NSString stringWithFormat:@"%s",flow_cursor->ifa_name];
            if (flow_cursor->ifa_addr->sa_family == AF_LINK) {
                //pdp_ip
                //en
                if ([name hasPrefix:@"pdp_ip"]) {
                    flow_networkStatisc = (const struct if_data *) flow_cursor->ifa_data;
                    ttv_flow_sys_wwan_send+= flow_networkStatisc->ifi_obytes;
                    ttv_flow_sys_wwan_received += flow_networkStatisc->ifi_ibytes;
                }
            }
            flow_cursor = flow_cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
}

+ (void)resetFlowData
{
    [self _updateInfo];
    flow_app_wwan_send = ttv_flow_sys_wwan_send;
    flow_app_wwan_received = ttv_flow_sys_wwan_received;
}

+ (int64_t)getCurrentUsingFlow
{
    [self _updateInfo];
    double wwandownstream = ttv_flow_sys_wwan_received - flow_app_wwan_received;
    double wwanupstream = ttv_flow_sys_wwan_send - flow_app_wwan_send;
    double wwanCost = (wwandownstream + wwanupstream) / 1024;
    return wwanCost;
}

@end
