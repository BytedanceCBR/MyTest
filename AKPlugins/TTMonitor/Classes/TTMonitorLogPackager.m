//
//  TTMonitorLogPackager.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/2.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorLogPackager.h"

@implementation TTMonitorLogPackager

/**
 *  这里组装发送数据， 一次发送的数据包括tracker ，timer，counter，store信息
 *
 *  @param array
 *  @param aggregateTimeItem  timer
 *  @param aggregateCountItem counter
 *  @param storeItem          存储
 *
 *  @return 打包后的结果
 */
+ (NSDictionary *)packageTrack:(NSArray<TTMonitorTrackItem *> *)array
             aggregateTimeItem:(TTMonitorAggregateItem *)aggregateTimeItem
            aggregateCountItem:(TTMonitorAggregateItem *)aggregateCountItem
                     storeItem:(TTMonitorStoreItem *)storeItem
{
    NSMutableDictionary * result = [[NSMutableDictionary alloc] initWithCapacity:10];

    //打包统计部分
    NSMutableArray * data = [[NSMutableArray alloc] initWithCapacity:100];
    for (TTMonitorTrackItem * item in array) {
        if ([item.track isKindOfClass:[NSDictionary class]] &&
            [item.track count] > 0) {
            [data addObject:item.track];
        }
    }
    BOOL dataValide = NO;
    if ([data count] > 0) {
        [result setValue:data forKey:@"data"];
        dataValide = YES;
    }
    
    //打包store 部分
    if (storeItem && ![storeItem isEmpty]) {
        [result setValue:[storeItem currentPool] forKey:@"store"];
    }
    
    //打包聚合部分
    if (aggregateCountItem) {
        NSArray * counters = [self packageAggregateItem:aggregateCountItem];
        if ([counters count] > 0) {
            [result setValue:counters forKey:@"count"];
            dataValide = YES;
        }
    }
    
    if (aggregateTimeItem) {
        NSArray * timers = [self packageAggregateItem:aggregateTimeItem];
        if ([timers count] > 0) {
            [result setValue:timers forKey:@"timer"];
            dataValide = YES;
        }
    }
    
    if (!dataValide) {
        return nil;
    }
    [result setValue:[self headerDict] forKey:@"header"];
    
    return result;
}

+ (NSArray *)packageAggregateItem:(TTMonitorAggregateItem *)aggregateItem
{
    [aggregateItem aggregateAllData];
    NSDictionary * counterPools = [aggregateItem currentPool];
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:100];
    for (NSString * key in [counterPools allKeys]) {
        NSDictionary * innerDict = [counterPools objectForKey:key];
        
        for (NSString * innerKey in [innerDict allKeys]) {
            NSArray * innerNumbers = [innerDict objectForKey:innerKey];
            if ([innerNumbers count] > 0) {
                NSNumber * num = [innerNumbers firstObject];
                if ([num isKindOfClass:[NSNumber class]]) {
                    float value = (float)[num doubleValue];
                    if ([innerKey isKindOfClass:[NSString class]]) {
                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
                        [dict setValue:innerKey forKey:@"key"];
                        [dict setValue:@(value) forKey:@"value"];
                        [dict setValue:key forKey:@"type"];
                        [results addObject:dict];
                    }
                }
            }
        }
    }
    return results;
}

static NSMutableDictionary * s_headerParameter;

+ (NSDictionary *)headerDict
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:20];
        
        [result setValue:[[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] params] valueForKey:@"install_id"] forKey:@"install_id"];
        NSString *deviceID = [[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] params] valueForKey:@"device_id"];
        
        [result setValue:deviceID forKey:@"device_id"];
        [result setValue:[TTExtensions bundleIdentifier] forKey:@"package"];
        [result setValue:[TTExtensions versionName] forKey:@"app_version"];
        [result setValue:[NSNumber numberWithBool:[TTExtensions isJailBroken]] forKey:@"is_jailbroken"];
        
        NSString *carrierName = [TTExtensions carrierName];
        if(!carrierName) carrierName = @"";
        [result setValue:carrierName forKey:@"carrier"];
        
        NSString *carrierMCC = [TTExtensions carrierMCC];
        NSString *carrierMNC = [TTExtensions carrierMNC];
        if(!carrierMCC) carrierMCC = @"";
        if(!carrierMNC) carrierMNC = @"";
        [result setValue:[NSString stringWithFormat:@"%@%@",carrierMCC,carrierMNC] forKey:@"mcc_mnc"];
        
        
        [result setValue:[TTExtensions connectMethodName] forKey:@"access"];
        [result setValue:@"iOS" forKey:@"os"];
        [result setValue:[TTExtensions appDisplayName] forKey:@"display_name"];
        [result setValue:[TTExtensions OSVersion] forKey:@"os_version"];
        [result setValue:[TTDeviceExtension platformString] forKey:@"device_model"];
        [result setValue:[TTExtensions currentLanguage] forKey:@"language"];
        [result setValue:[TTExtensions MACAddress] forKey:@"mc"];
        [result setValue:[TTExtensions openUDID] forKey:@"openudid"];
        [result setValue:[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] appkey] forKey:@"appkey"];
        //[result setValue:[TTExtensions getCurrentChannel] forKey:@"channel"];
        [result setValue:[TTExtensions ssAppID] forKey:@"aid"];
        NSInteger millisecondsFromGMT =  [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        [result setValue:@(millisecondsFromGMT) forKey:@"timezone"];
        
        if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            NSString *vUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [result setValue:vUDID forKey:@"vid"];
            [result setValue:vUDID forKey:@"vendor_id"];
        }
        
        // idfa
        [result setValue:[TTExtensions idfaString] forKey:@"idfa"];
        [result setValue:[TTExtensions userAgentString] forKey:@"user_agent"];
        [result setValue:[TTExtensions resolutionString] forKey:@"resolution"];
        s_headerParameter = result;
    });
    return s_headerParameter;
}



@end
