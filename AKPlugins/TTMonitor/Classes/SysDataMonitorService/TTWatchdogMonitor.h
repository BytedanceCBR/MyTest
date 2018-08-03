//
//  TTWatchDogMonitor.h
//  XSQWatchDogDemo
//
//  Created by xushuangqing on 2017/7/17.
//  Copyright © 2017年 xushuangqing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @param stackTraceSymbols 主线程调用栈符号，可能有<reduct>
 @param stackTraceAddresses 主线程调用栈地址
 */
typedef void(^TTWatchdogCallback)(NSString *stackTraceSymbols);

@interface TTWatchdogMonitor : NSObject

/**
 多长时间检查一次卡顿
 */
@property (nonatomic, assign, readonly) NSTimeInterval checkInterval;

/**
 主线程多久未响应即代表卡顿
 */
@property (nonatomic, assign, readonly) NSTimeInterval watchdogThreshold;

/**
 发现卡顿后的回调
 */
@property (nonatomic, copy, readonly) TTWatchdogCallback watchdogCallback;

/**
 watchdog监测必须是一个单例
 */
+ (instancetype)sharedMonitor;

/**
 开始卡顿监控

 @param interval 多长时间检查一次
 @param threshold 主线程多久未响应即代表卡顿
 @param callback 发现卡顿后的回调
 */
- (void)startMonitorWithInterval:(NSTimeInterval)interval watchdogThreshold:(NSTimeInterval)threshold watchdogCallback:(TTWatchdogCallback)callback;

/**
 取消卡顿监控
 */
- (void)cancelMonitor;

@end
