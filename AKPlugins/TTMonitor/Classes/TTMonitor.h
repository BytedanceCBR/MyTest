//
//  TTMonitor.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMonitorDefine.h"
#import "TTMonitorLogPackagerProtocol.h"
#import "TTMonitorConfigurationProtocol.h"
#import "TTDebugRealMonitorManager.h"

/**
 *  监控,内部只维持一个队列，包括发送和收集以及存储
 */
typedef NSDictionary *(^TTMonitorParamsBlock)(void);
typedef NSURL *(^TTURLTransformBlock)(NSURL *url);

@interface TTMonitor : NSObject

@property (nonatomic, assign)BOOL stopMonitor;
@property (nonatomic, copy)TTURLTransformBlock urlTransformBlock;

+ (TTMonitor *)shareManager;

/**
 *  设置打包的类的class
 *
 *  @param packClass 设置打包的类的class
 */
- (void)setPackagerClass:(Class<TTMonitorLogPackagerProtocol>)packClass;

- (void)setMonitorConfiguration:(Class<TTMonitorConfigurationProtocol>)configurationClass;

- (void)startIfNeed;

- (void)startWithAppkey:(NSString *)appKey paramsBlock:(TTMonitorParamsBlock)block;

#pragma mark -- 监控日志

- (void)trackData:(NSDictionary *)data
             type:(TTMonitorTrackerType)type;

- (void)trackData:(NSDictionary *)data
             logTypeStr:(NSString *)logType;

- (void)trackService:(NSString *)serviceName
          attributes:(NSDictionary *)attributes;
/**
 *  监控某个service的值，并上报
 *
 *  @param serviceName
 *  @param value       是一个float类型的，不可枚举
 *  @param extraValue  额外信息，方便追查问题使用
 */
- (void)trackService:(NSString *)serviceName
               value:(id)value
               extra:(NSDictionary *)extraValue;

/**
 *  监控某个service的状态，并上报
 *
 *  @param serviceName
 *  @param status      是一个int类型的值，可枚举的几种状态
 *  @param extraValue  额外信息，方便追查使用
 */
- (void)trackService:(NSString *)serviceName
              status:(NSInteger)status
               extra:(NSDictionary *)extraValue;


/**
 *  监控统计-count打点  type和label非常重要，是在服务端区分不同事件的唯一参考，譬如
 [[TTMonitor shareManager] event:@"monitor_fps" label:@"feed" count:60 needAggregate:NO];
 上面的这条统计，在服务端metrics这样查询：client.monitor_fps.feed.ios 就可以查到了。当然还可以继续.其他信息（版本号等，但
 但client.monitor.monitor_fps.feed是必须的）。
 *
 *  @param type     监控的类型，自己定义  相当于title
 *  @param label    可以作为一种简要的解释 相当于subtitle
 *  @param count    具体数字
 *  @param needAggr 要不要聚合   聚合就会求均值
 */
- (void)event:(NSString *)type label:(NSString *)label count:(NSUInteger)count needAggregate:(BOOL)needAggr;

/**
 *   监控统计-count打点  默认count是1
 *
 *  @param type     监控的类型，自己定义  相当于title
 *  @param label    可以作为一种简要的解释 相当于subtitle
 *  @param needAggr 要不要聚合   聚合就会求均值
 */
- (void)event:(NSString *)type label:(NSString *)label needAggregate:(BOOL)needAggr;

#pragma mark -- timer
/**
 *  监控统计-time打点  type和label非常重要，是在服务端区分不同事件的唯一参考，譬如
 [[TTMonitor shareManager] event:@"monitor_launch" label:@"duratin" count:60 needAggregate:NO];
 上面的这条统计，在服务端metrics这样查询：client.monitor_launch.duratin.ios 就可以查到了。当然还可以继续.其他信息（版本号等，但
 但client.monitor.monitor_launch.duratin.ios是必须的）。
 *
 *  @param type     监控的类型，自己定义  相当于title
 *  @param label    可以作为一种简要的解释 相当于subtitle
 *  @param duration    具体数字
 *  @param needAggr 要不要聚合   聚合就会求均值
 */
- (void)event:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr;

#pragma mark -- storer
- (void)storeEvent:(NSString *)type label:(NSString *)label value:(float)value;

#pragma mark -- debugreal
- (void)debugRealEvent:(NSString *)type label:(NSString *)label traceCode:(NSString *)traceCode;

- (void)debugRealEvent:(NSString *)type label:(NSString *)label traceCode:(NSString *)traceCode userInfo:(NSDictionary *)userInfo;
#pragma mark -- dns report
- (void)reportDNSList;

#pragma mark -- oom monitor
// For OOM Detection
+ (void)setAppCrashFlagForLastTimeLaunch;


@end
