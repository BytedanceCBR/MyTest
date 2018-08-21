//
//  TTWatchDogMonitor.m
//  XSQWatchDogDemo
//
//  Created by xushuangqing on 2017/7/17.
//  Copyright © 2017年 xushuangqing. All rights reserved.
//

#import "TTWatchdogMonitor.h"
#import "BSBacktraceLogger.h"
#include <signal.h>
#include <pthread.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>

#pragma mark - Tools

dispatch_source_t createGCDTimer(NSTimeInterval interval, NSTimeInterval leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    uint64_t unixInterval = interval * NSEC_PER_SEC;
    uint64_t unixLeeway = leeway * NSEC_PER_SEC;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, unixInterval), unixInterval, unixLeeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

#pragma mark - ping pong loop

typedef void(^TTPingResultBlock)(BOOL timeout);

//一次异步线程对主线程的访问，通过是否超时判断当前主线程是否卡死
@interface TTPingPongLoop : NSObject

- (instancetype)initWithTimeoutInterval:(NSTimeInterval)timeoutInterval backgroundQueue:(dispatch_queue_t)queue callback:(TTPingResultBlock)callback;

@end

@interface TTPingPongLoop ()

@property (nonatomic, strong) dispatch_source_t pongTimer;

@end

@implementation TTPingPongLoop

- (instancetype)initWithTimeoutInterval:(NSTimeInterval)timeoutInterval backgroundQueue:(dispatch_queue_t)queue callback:(TTPingResultBlock)callback {
    self = [super init];
    if (self) {
        [self startPingWithTimeoutInterval:timeoutInterval backgroundQueue:queue callback:callback];
    }
    return self;
}

- (void)startPingWithTimeoutInterval:(NSTimeInterval)timeoutInterval backgroundQueue:(dispatch_queue_t)queue callback:(TTPingResultBlock)callback {
    self.pongTimer = createGCDTimer(timeoutInterval, timeoutInterval/1000, queue, ^{
        if (self.pongTimer) {
            dispatch_source_cancel(self.pongTimer);
            self.pongTimer = nil;
            if (callback) {
                callback(YES);
            }
        }
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(queue, ^{
            if (self.pongTimer) {
                dispatch_source_cancel(self.pongTimer);
                self.pongTimer = nil;
                if (callback) {
                    callback(NO);
                }
            }
        });
    });
}

@end


@interface TTWatchdogMonitor ()

/**
 每隔一段时间做一次PingPongLoop检验
 */
@property (nonatomic, strong) dispatch_source_t pingTimer;

/**
 一个异步串行队列
 */
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, assign) NSTimeInterval checkInterval;
@property (nonatomic, assign) NSTimeInterval watchdogThreshold;
@property (nonatomic, copy) TTWatchdogCallback watchdogCallback;

@end

@implementation TTWatchdogMonitor

#pragma mark - life cycle

+ (instancetype)sharedMonitor {
    static TTWatchdogMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[self alloc] init];
    });
    return monitor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serialQueue = dispatch_queue_create("com.byted.tt_monitor_watchdog_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma - monitor

- (void)startMonitorWithInterval:(NSTimeInterval)interval watchdogThreshold:(NSTimeInterval)threshold watchdogCallback:(TTWatchdogCallback)callback {
    
    if (![NSThread isMainThread]) {
        NSLog(@"Error: startWatch must be called from main thread!");
        return;
    }
    
    if (interval < 0.001) {
        NSLog(@"Error: interval is too short");
        return;
    }
    
    if (threshold < 0.001) {
        NSLog(@"Error: threshold is too short");
        return;
    }
    
    [self cancelMonitor];
    
    self.checkInterval = interval;
    self.watchdogThreshold = threshold;
    self.watchdogCallback = callback;
    
    [self pingMainThread];
    self.pingTimer = createGCDTimer(self.checkInterval, self.checkInterval / 10000, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self pingMainThread];
    });
}

- (void)cancelMonitor {
    if (self.pingTimer) {
        dispatch_source_cancel(self.pingTimer);
        _pingTimer = nil;
    }
    self.checkInterval = 0.0;
    self.watchdogThreshold = 0.0;
    self.watchdogCallback = nil;
}

- (void)pingMainThread
{
    TTPingPongLoop *loop = [[TTPingPongLoop alloc] initWithTimeoutInterval:self.watchdogThreshold backgroundQueue:self.serialQueue callback:^(BOOL timeout) {
        if (timeout) {
            [self onPongTimeout];
        }
    }];
    
    //防止warning
    (void)loop;
}

#pragma mark - result handle

- (void)onPongTimeout
{
    NSString *mainThreadTraceString = [BSBacktraceLogger bs_backtraceOfMainThread];
    if (self.watchdogCallback) {
        self.watchdogCallback(mainThreadTraceString);
    }
}

@end
