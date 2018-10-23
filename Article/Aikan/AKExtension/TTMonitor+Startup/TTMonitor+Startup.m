//
//  TTMonitor+Startup.m
//  LiveStreaming
//
//  Created by SongLi.02 on 9/7/16.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import "TTMonitor+Startup.h"
#import "TTNetworkManagerMonitorNotifier.h"
#import "TTSystemMonitorManager.h"
#import <objc/runtime.h>

typedef void(^HTSMonitorBlock)(void);

@implementation TTMonitor (Startup)

+ (void)startWithAppkey:(NSString *)appKey paramsBlock:(TTMonitorParamsBlock)paramsBlock
{
    if ([self isStart]) {
        return;
    }
    
    [TTMonitor setIsStart:YES];
    [TTSystemMonitorManager defaultMonitorManager];
    [[TTNetworkManagerMonitorNotifier defaultNotifier] setEnable:YES];
    [[TTMonitor shareManager] startWithAppkey:appKey paramsBlock:paramsBlock];
    [TTMonitor excuteStoredEventActions];
}

+ (void)trackData:(NSDictionary *)data type:(TTMonitorTrackerType)type
{
    NSDictionary *dataCopy = data.copy;
    [self dealEventAction:^{
        [[TTMonitor shareManager] trackData:dataCopy type:type];
    }];
}

+ (void)trackData:(NSDictionary *)data logTypeStr:(NSString *)logType
{
    NSDictionary *dataCopy = data.copy;
    [self dealEventAction:^{
        [[TTMonitor shareManager] trackData:dataCopy logTypeStr:logType];
    }];
}

+ (void)trackService:(NSString *)serviceName value:(float)value extra:(NSDictionary *)extraValue
{
    NSDictionary *extraValueCopy = extraValue.copy;
    [self dealEventAction:^{
        [[TTMonitor shareManager] trackService:serviceName value:@(value) extra:extraValueCopy];
    }];
}

+ (void)trackService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue
{
    NSDictionary *extraValueCopy = extraValue.copy;
    [self dealEventAction:^{
        [[TTMonitor shareManager] trackService:serviceName status:status extra:extraValueCopy];
    }];
}

+ (void)event:(NSString *)type label:(NSString *)label count:(NSUInteger)count needAggregate:(BOOL)needAggr
{
    [self dealEventAction:^{
        [[TTMonitor shareManager] event:type label:label count:count needAggregate:needAggr];
    }];
}

+ (void)event:(NSString *)type label:(NSString *)label needAggregate:(BOOL)needAggr
{
    [self dealEventAction:^{
        [[TTMonitor shareManager] event:type label:label needAggregate:needAggr];
    }];
}

+ (void)event:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr
{
    [self dealEventAction:^{
        [[TTMonitor shareManager] event:type label:label duration:duration needAggregate:needAggr];
    }];
}

+ (void)storeEvent:(NSString *)type label:(NSString *)label value:(float)value
{
    [self dealEventAction:^{
        [[TTMonitor shareManager] storeEvent:type label:label value:value];
    }];
}

+ (void)debugRealEvent:(NSString *)type label:(NSString *)label traceCode:(NSString *)traceCode
{
    [self dealEventAction:^{
        [[TTMonitor shareManager] debugRealEvent:type label:label traceCode:traceCode];
    }];
}

+ (void)debugRealEvent:(NSString *)type label:(NSString *)label traceCode:(NSString *)traceCode userInfo:(NSDictionary *)userInfo
{
    NSDictionary *userInfoCopy = userInfo.copy;
    [self dealEventAction:^{
        [[TTMonitor shareManager] debugRealEvent:type label:label traceCode:traceCode userInfo:userInfoCopy];
    }];
}


#pragma mark - PrivateMethods

+ (void)dealEventAction:(HTSMonitorBlock)block
{
    if ([self isStart]) {
        block();
    } else {
        [[self cachedEvents] addObject:[block copy]];
    }
}

+ (void)excuteStoredEventActions
{
    for (HTSMonitorBlock block in [self cachedEvents]) {
        block();
    }
    [[self cachedEvents] removeAllObjects];
}

+ (BOOL)isStart
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

+ (void)setIsStart:(BOOL)isStart
{
    objc_setAssociatedObject(self, @selector(isStart), @(isStart), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (NSMutableArray<HTSMonitorBlock> *)cachedEvents
{
    NSMutableArray *cachedEvents = objc_getAssociatedObject(self, _cmd);
    if (!cachedEvents) {
        cachedEvents = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, cachedEvents, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cachedEvents;
}

@end
