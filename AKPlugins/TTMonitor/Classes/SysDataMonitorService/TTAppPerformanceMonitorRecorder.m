//
//  TTAppPerformanceMonitorRecorder.m
//  Pods
//
//  Created by 苏瑞强 on 2017/9/13.
//
//

#import "TTAppPerformanceMonitorRecorder.h"
#import "TTMonitorConfiguration.h"
#import "TTMonitor.h"
#import "TTMemoryUsageMonitorRecorder.h"

@implementation TTAppPerformanceMonitorRecorder{
    NSTimeInterval _startTime;
}

-(id)init{
    self = [super init];
    if (self) {
        _startTime = [[NSDate date] timeIntervalSince1970];
        if ([self isEnabled]) {
            NSString * lauchEvent = [NSString stringWithFormat:@"iOS%ld_launch",[[[UIDevice currentDevice] systemVersion] integerValue]];
            [[TTMonitor shareManager] trackService:lauchEvent status:1 extra:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        }
    }
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (NSString *)type{
    return @"cpu_monitor";
}

- (double)monitorInterval{
    double value = [TTMonitorConfiguration queryActionIntervalForKey:@"user_event_monitor_interval"];
    if (value<=0) {
        value = 30;
    }
    return value;
}

- (BOOL)isEnabled{
    return [TTMonitorConfiguration queryIfEnabledForKey:@"user_event_performance_monitor"];
}

- (void)handleReceiveMemoryWarning:(NSNotification *)notify{
    NSTimeInterval useage = [[NSDate date] timeIntervalSince1970] - _startTime;
    double memNow = memory_now();
    [[TTMonitor shareManager] trackService:@"appReceiveMemWarnung" value:@{@"usage":@(useage),@"mem":@(memNow)} extra:nil];
}

- (void)handleAppEnterBackground{
    NSTimeInterval useage = [[NSDate date] timeIntervalSince1970] - _startTime;
    double memNow = memory_now();
    static NSInteger times = 0;
    times++;
    [[TTMonitor shareManager] trackService:@"appEnterBackGround" value:@{@"usage":@(useage),@"mem":@(memNow),@"times":@(times)} extra:nil];
    
}

- (void)handleAppEnterForground{
    [[TTMonitor shareManager] trackService:@"appEnterForGround" attributes:nil];
}

@end
