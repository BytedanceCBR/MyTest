//
//  TTMonitorConfigurationProtocol.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/11.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTTMonitorConfigurationUpdatedNotification @"kTTMonitorConfigurationUpdatedNotification"

@protocol TTMonitorConfigurationProtocol <NSObject>

@required
#pragma mark -- config

/**
 *  需要上报的host
 *
 *  @return 需要上报的host
 */
+ (NSArray *)reportHosts;

/**
 *  黑名单
 *
 *  @return 不需要监控的url list
 */
+ (NSArray *)blackList;

/**
 *  最大的上报重试次数
 *
 *  @return 默认值4
 */
+ (NSInteger)maxReportRetryCount;

/**
 *  一次上报允许最大的log数
 *
 *  @return 一次上报允许最大的log数
 */
+ (NSInteger)onceReportMaxLogCount;


/**
 *  轮询上报间隔, 单位：秒
 *
 *  @return 轮询上报间隔， 单位：秒
 */
+ (NSInteger)reportPollingInterval;

/**
 *  需要上报的dns数据
 *
 *  @return 需要上报的dns数据
 */
+ (NSArray *)dnsReportList;
/**
 *  上报dns的最小间隔
 *
 *  @return 上报dns的最小间隔时间
 */
+ (double)dnsReportInterval;

///拉取监控配置
+ (void)tryFetchConfigWithForce:(BOOL)force;

- (void)tryFetchConfigWithForce:(BOOL)force;

+ (BOOL)isEnabledForLogType:(NSString *)logType;

+ (BOOL)isEnabledForMetricsType:(NSString *)logType;

+ (BOOL)isEnabledForServiceType:(NSString *)logType;

@end

