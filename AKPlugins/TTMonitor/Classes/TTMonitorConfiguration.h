//
//  TTMonitorConfiguration.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/29.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMonitorConfigurationProtocol.h"
#import "TTNetworkMonitorRecorderConfigurationProtocol.h"
#import "TTMonitor.h"
#import "TTExtensions.h"
/**
 *  负责管理和获取监控相关的配置
 */
@interface TTMonitorConfiguration : NSObject<TTMonitorConfigurationProtocol, TTNetworkMonitorRecorderConfigurationProtocol>

@property(nonatomic, strong, readonly) NSString * appkey;
@property(nonatomic, copy, readonly) TTMonitorParamsBlock paramsBlock;
@property(nonatomic, copy, readwrite) NSDictionary * params;
@property(nonatomic, assign) MNetworkStatus networkStatus;

/**
 *  尝试去获取配置, 只需要在didFinishLaunch:中调用
 *
 *  @param force 正常情况下为NO，拉取间隔服务器可控。但有时候服务器挂了 会强制客户端重新拉取一次配置 此时就不管什么间隔了
 */

+ (TTMonitorConfiguration *)shareManager;

+ (void)tryFetchConfigWithForce:(BOOL)force;
/**
 *  监控track 在业务层需要补充的额外信息， 在该dict中返回， 注意，一定不要写延时的方法,因为调用的数据量会很大，业务层自己保证线程安全问题。
 *
 *  @return 监控track 在业务层需要补充的额外信息
 */
+ (NSDictionary *)monitorTrackAdditionalParameters;

- (void)configAppKey:(NSString *)appkey paramBlock:(TTMonitorParamsBlock)paramBlock;

+ (NSDictionary *)httpHeaderParams;

+ (double)queryActionIntervalForKey:(NSString *)queryKey;

+ (double)retryIntervalIfAllHostFailed;

+ (BOOL)queryIfEnabledForKey:(NSString *)queryKey;

+ (BOOL)enableNetStat;

+ (BOOL)needEncrypt;

+ (double)watchdogRecordLength;

+ (double)watchdogMonitorInterval;

+ (double)watchdogMonitorThreshold;

@end
