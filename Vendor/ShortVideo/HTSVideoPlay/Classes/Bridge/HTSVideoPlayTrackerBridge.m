//
//  HTSVideoPlayTrackerBridge.m
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import "HTSVideoPlayTrackerBridge.h"
#import "TTModuleBridge.h"

@implementation HTSVideoPlayTrackerBridge

+ (void)trackEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSString *)extra attributes:(NSDictionary *)attributes
{
    NSMutableDictionary *moduleParams = [NSMutableDictionary dictionary];
    [moduleParams setValue:event forKey:@"event"];
    [moduleParams setValue:label forKey:@"label"];
    [moduleParams setValue:value forKey:@"value"];
    [moduleParams setValue:extra forKey:@"extra"];
    [moduleParams setValue:attributes forKey:@"attributes"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"HTSSendTrack" object:nil withParams:moduleParams complete:nil];
}

+ (void)trackEvent:(NSString *)event params:(NSDictionary *)params
{
    NSMutableDictionary *moduleParams = [NSMutableDictionary new];
    [moduleParams setValue:event forKey:@"event"];
    [moduleParams setValue:params forKey:@"params"];
    
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"HTSV3SendTrack" object:nil withParams:[moduleParams copy] complete:nil];
}

+ (void)monitorEvent:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr
{
    NSMutableDictionary *moduleParams = [NSMutableDictionary dictionary];
    [moduleParams setValue:@"duration" forKey:@"monitor_type"];
    [moduleParams setValue:type forKey:@"type"];
    [moduleParams setValue:label forKey:@"label"];
    [moduleParams setValue:@(duration) forKey:@"duration"];
    [moduleParams setValue:@(needAggr) forKey:@"needAggr"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"HTSSendMonitor" object:nil withParams:moduleParams complete:^(id  _Nullable result) {
    }];
}

+ (void)monitorService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue
{
    NSMutableDictionary *moduleParams = [NSMutableDictionary dictionary];
    [moduleParams setValue:@"status" forKey:@"monitor_type"];
    [moduleParams setValue:serviceName forKey:@"serviceName"];
    [moduleParams setValue:@(status) forKey:@"status"];
    [moduleParams setValue:extraValue forKey:@"extraValue"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"HTSSendMonitor" object:nil withParams:moduleParams complete:^(id  _Nullable result) {
    }];
}

+ (void)monitorData:(NSDictionary *)data logTypeStr:(NSString *)logType
{
    NSMutableDictionary *moduleParams = [NSMutableDictionary dictionary];
    [moduleParams setValue:@"log" forKey:@"monitor_type"];
    [moduleParams setValue:data forKey:@"data"];
    [moduleParams setValue:logType forKey:@"logType"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"HTSSendMonitor" object:nil withParams:moduleParams complete:^(id  _Nullable result) {
    }];
}

@end
