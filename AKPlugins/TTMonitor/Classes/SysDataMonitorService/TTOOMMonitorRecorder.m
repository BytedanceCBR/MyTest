//
//  TTOOMMonitorRecorder.m
//  Pods
//
//  Created by ShaJie on 1/6/2017.
//
//

#import "TTOOMMonitorRecorder.h"
#import "TTOOMMonitor.h"
#import "TTMonitor.h"
#import "TTMonitorConfiguration.h"

static BOOL AppCrashedAtLastTimeLaunch = FALSE;
static const int64_t OOMMonitorRunChecksDelay = 5; // 5s 后开始 OOM 检查逻辑
static NSString * const OOMMonitorServiceName = @"oom_monitor_service";

@interface TTOOMMonitorRecorder ()

@property (nonatomic, strong) TTOOMMonitor * monitor;

@end

@implementation TTOOMMonitorRecorder

#pragma mark - override super

- (NSString *)type
{
    return @"oom_monitor";
}

- (BOOL)isEnabled
{
    return [TTMonitorConfiguration queryIfEnabledForKey:@"oom_monitor"];
}

#pragma mark - oom logging

- (TTOOMMonitor *)monitor
{
    @synchronized (self) {
        if (!_monitor) {
            _monitor = [TTOOMMonitor new];
        }
    }
    return _monitor;
}

- (void)tryOOMDetection
{
    // 只需要检查一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 延迟 5s 进行，以便从外部获得是否程序上次是否 crash 的信息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OOMMonitorRunChecksDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self executeOOMCheck];
        });
        
    });
}

- (void)executeOOMCheck
{
    if (![self isEnabled]) return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        BOOL crashDetected = FALSE;
        @synchronized ([self class]) {
            crashDetected = AppCrashedAtLastTimeLaunch;
        }
        
        TTTerminationType type = [self.monitor runCheckWithWhetherCrashDetected:crashDetected];
        
        [self tryToLogTerminationType:type];
    });
}

- (void)tryToLogTerminationType:(TTTerminationType)type
{
    // 目前策略暂定为只记录 FOOM
    if (type == TTTerminationTypeForegroundOOM) {
        NSString * deviceID = [[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] params] valueForKey:@"device_id"];
        if (deviceID.length) {
            NSDictionary * value = @{@"type" : @(type),
                                     @"did":deviceID};
            [[TTMonitor shareManager] trackService:OOMMonitorServiceName value:value extra:nil];
        }
    }
}

- (void)handleApplicationTermination
{
    if (![self isEnabled]) return;
    [self.monitor logApplicationForcelyTermination];
}

- (void)handleApplicationEnterForeground
{
    if (![self isEnabled]) return;
    [self.monitor logApplicationEnterForeground];
}

- (void)handleApplicationEnterBackground
{
    if (![self isEnabled]) return;
    [self.monitor logApplicationEnterBackground];
}

#pragma mark - class

+ (void)setAppCrashFlagForLastTimeLaunch
{
    @synchronized (self) {
        AppCrashedAtLastTimeLaunch = YES;
    }
}

@end
