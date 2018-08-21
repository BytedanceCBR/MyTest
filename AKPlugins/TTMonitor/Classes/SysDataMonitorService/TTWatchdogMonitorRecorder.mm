//
//  TTWatchdogMonitorRecorder.m
//  Pods
//
//  Created by xushuangqing on 2017/7/18.
//
//

#import "TTWatchdogMonitorRecorder.h"
#import "TTMonitorConfiguration.h"
#import "TTWatchdogMonitor.h"
#import "TTMonitor.h"
#import "TTMonitorReporter.h"
#import <Foundation/Foundation.h>

#include <mach-o/getsect.h>
#include <stdio.h>
#include <mach-o/dyld.h>
#include <string.h>

NSString * const TTWatchDogDidTrigeredNotification = @"TTWatchDogDidTrigeredNotification";

#define kMaxCountOnGroup 10

uint64_t StaticBaseAddress(void)
{
#ifndef __LP64__
    const struct segment_command * command = getsegbyname("__TEXT");
#else
    const struct segment_command_64 * command = getsegbyname("__TEXT");
#endif
    uint64_t addr = command->vmaddr;
    return addr;
}

intptr_t ImageSlide(void)
{
    char path[1024];
    uint32_t size = sizeof(path);
    if (_NSGetExecutablePath(path, &size) != 0) return -1;
    for (uint32_t i = 0; i < _dyld_image_count(); i++)
    {
        if (strcmp(_dyld_get_image_name(i), path) == 0)
            return _dyld_get_image_vmaddr_slide(i);
    }
    return 0;
}

uint64_t DynamicBaseAddress(void)
{
    return StaticBaseAddress() + ImageSlide();
}

static NSString * const TTWatchdogMonitorServiceName = @"tt_monitor_watchdog";

@interface TTWatchdogMonitorRecorder ()
@property (nonatomic, strong)TTMonitorReporter * reporter;
@property (nonatomic, strong) NSMutableArray * threadHoldItems;
@property (nonatomic, strong) dispatch_queue_t threadhold_queue;
@property (nonatomic, assign)NSTimeInterval lastRecorderTime;
@end

@implementation TTWatchdogMonitorRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.threadhold_queue = dispatch_queue_create("com.threadhold.queue", DISPATCH_QUEUE_CONCURRENT);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        self.lastRecorderTime = 0;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appWillResignActive {
    if (![self isEnabled]) {
        return;
    }
    [self cancelWatchdogDetection];
    [self _reportNow];
}

- (void)appDidBecomeActive {
    if (![self isEnabled]) {
        return;
    }
    if (![self monitorHasLength]) {
        [self tryWatchdogDetection];
    }
}

#pragma mark - switch

- (BOOL)isDebug {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}

- (BOOL)isEnabled {
    static BOOL enabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enabled = [TTMonitorConfiguration isEnabledForMetricsType:@"watchdog_monitor"];
    });
    return enabled;
}

- (BOOL)monitorHasLength {
    return [self monitorLength] > 0;
}

// 0 代表不作限制
- (double)monitorLength {
    static double length = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        length = [TTMonitorConfiguration watchdogRecordLength];
    });
    return length;
}

#pragma mark - detection

- (void)startMonitor {
    [self tryWatchdogDetection];
    if ([self monitorHasLength]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self monitorLength] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cancelWatchdogDetection];
        });
    }
}

- (void)tryWatchdogDetection {

    if (![self isEnabled]) {
        return;
    }
    
    // 连接调试器时无法得到正确回调，不连接调试器时没有dSYM上报上来也没什么用
    if ([self isDebug]) {
        return;
    }
    
    [[TTWatchdogMonitor sharedMonitor] startMonitorWithInterval:[TTMonitorConfiguration watchdogMonitorInterval] watchdogThreshold:[TTMonitorConfiguration watchdogMonitorThreshold] watchdogCallback:^(NSString *stackTraceSymbols) {
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        if (self.lastRecorderTime != 0) {
            if (time - self.lastRecorderTime < 60) {
                return ;
            }
        }
        self.lastRecorderTime = time;

        NSArray<NSString *> *symbolArray = [stackTraceSymbols componentsSeparatedByString:@"\n"];
        
        __block NSString *targetedSymbol = nil;
        [symbolArray enumerateObjectsUsingBlock:^(NSString * _Nonnull symbolString, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray<NSString *>* parts = [symbolString componentsSeparatedByString:@" "];
            if ([parts containsObject:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleName"]]) {
                targetedSymbol = symbolString;
                *stop = YES;
            }
        }];
        
        NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
        [value setValue:targetedSymbol forKey:@"tar_sym"];
        NSString *buildTime = [NSString stringWithFormat:@"%s %s", __DATE__ ,__TIME__];
        [value setValue:buildTime forKey:@"build_time"];
        
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:stackTraceSymbols forKey:@"symbols"];
        uint64_t baseAddr = DynamicBaseAddress();
        [extra setValue:[@(baseAddr) stringValue] forKey:@"baseAddr"];
        dispatch_barrier_sync(self.threadhold_queue, ^{
            if (!self.threadHoldItems) {
                self.threadHoldItems = [[NSMutableArray alloc] init];
            }
            [self.threadHoldItems addObject:extra];
        });
        if (self.threadHoldItems.count>kMaxCountOnGroup) {
            [self _reportNow];
        }
        [[TTMonitor shareManager] trackService:TTWatchdogMonitorServiceName value:value extra:extra];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TTWatchDogDidTrigeredNotification object:nil];

    }];
}

-(void)_reportNow{
    if (self.threadHoldItems.count<=0) {
        return;
    }
    __block NSDictionary * reoporterData = nil;
    dispatch_sync(self.threadhold_queue, ^{
        NSDictionary * header = [TTMonitorConfiguration httpHeaderParams];
        if (header) {
            reoporterData = [NSDictionary dictionaryWithObjectsAndKeys:[self.threadHoldItems copy],@"data",header,@"header", nil];
        }
        
    });
    if (!self.reporter) {
        self.reporter = [[TTMonitorReporter alloc] init];
        [self.reporter setMonitorConfiguration:[TTMonitorConfiguration class]];
    }
    dispatch_barrier_sync(self.threadhold_queue, ^{
        [self.threadHoldItems removeAllObjects];
    });
    [self.reporter reportForData:reoporterData reportType:TTReportDataTypeWatchDog];
    
    
    
}

- (void)cancelWatchdogDetection {
    [[TTWatchdogMonitor sharedMonitor] cancelMonitor];
}

@end
