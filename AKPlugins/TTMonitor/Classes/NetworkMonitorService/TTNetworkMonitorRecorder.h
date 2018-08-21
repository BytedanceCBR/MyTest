//
//  TTNetworkMonitorRecorder.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/9.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TTNetworkMonitorRecorderConfigurationProtocol.h"
#import "TTNetworkManager.h"

typedef NSDictionary *(^TTNetworkMonitorRecorderTrackParamsBlock)(void);

/**
 *  网络监控的初始化类， 如果需要使用监控服务，需要进行如下配置：
 *  1.设置配置类， 配置类指导recorder如何进行采样。
 *  2.通过trackParamsblock设置track的业务层参数逻辑
 *
 */
@interface TTNetworkMonitorRecorder : NSObject

/// In general, it only makes sense to have one recorder for the entire application.
+ (instancetype)defaultRecorder;

/**
 *  设置配置类
 *
 *  @param configuration 设置配置类
 */
- (void)setConfigurationClass:(Class<TTNetworkMonitorRecorderConfigurationProtocol>)configuration;

/**
 *  设置tracker的参数的block
 *  考虑到各业务组需要统计的可能不同， 所以将配置暴露
 *  该block会在异步调用，业务层要保证异步调用安全问题。建议尽量不要有耗时操作，如果要，需要优化或者看下实现。
 */
@property(nonatomic, copy)TTNetworkMonitorRecorderTrackParamsBlock trackParamsblock;



// Recording network activity

/// Call when app is about to send HTTP request.
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID
                                     request:(TTHttpRequest *)request
                                   startDate:(NSDate *)startDate
                               hasTriedTimes:(NSInteger)hasTriedTimes;

/// Call when HTTP request has finished loading.
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID
                              responseBody:(id)responseBody
                                  response:(TTHttpResponse *)response
                              finishedDate:(NSDate *)finishedDate;

/// Call when HTTP request has failed to load.
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID
                                   error:(NSError *)error
                                response:(TTHttpResponse *)response
                            responseBody:(id)responseBody
                            finishedDate:(NSDate *)finishedDate;

- (NSDictionary *)pickTrackParams;

@end
