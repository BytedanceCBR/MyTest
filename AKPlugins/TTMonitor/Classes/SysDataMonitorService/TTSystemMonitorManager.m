//
//  TTSystemMonitorManager.m
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTSystemMonitorManager.h"
#import "TTCPUUsageMonitorRecorder.h"
#import "TTMemoryUsageMonitorRecorder.h"
#import "TTNetworkUsageMonitorRecorder.h"
#import "TTBatteryUsageMonitorRecorder.h"
#import "TTDiskUsageMonitorRecorder.h"
#import "TTOOMMonitorRecorder.h"
#import "TTWatchdogMonitorRecorder.h"
#import "TTAppPerformanceMonitorRecorder.h"
#import "TTFPSMonitor.h"

@interface TTSystemMonitorManager ()

@property (nonatomic, strong) NSTimer * timer;

@property(nonatomic, strong) TTCPUUsageMonitorRecorder * cpuRecorder;
@property(nonatomic, strong) TTMemoryUsageMonitorRecorder * memoryRecorder;
@property(nonatomic, strong) TTNetworkUsageMonitorRecorder * networkRecorder;
@property(nonatomic, strong) TTBatteryUsageMonitorRecorder * batteryRecorder;
@property(nonatomic, strong) TTDiskUsageMonitorRecorder * diskRecorder;
@property(nonatomic, strong) TTAppPerformanceMonitorRecorder * performanceRecorder;
@property(nonatomic, strong) TTOOMMonitorRecorder * oomRecorder;
@property(nonatomic, strong) TTWatchdogMonitorRecorder *watchdogRecorder;

@end

@implementation TTSystemMonitorManager

+ (instancetype)defaultMonitorManager
{
    static TTSystemMonitorManager *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

- (void)enableMonitor{
}

-(id)init{
    self = [super init];
    if (self) {
        [self registNotification];
        [self constructRecorders];
        [self startTimer];
        [self tryOOMDetection];
        [self tryWatchdogDetection];
        [self tryFPSDetection];
    }
    return self;
}

-(void)constructRecorders{
    self.cpuRecorder = [[TTCPUUsageMonitorRecorder alloc] init];
    self.memoryRecorder = [[TTMemoryUsageMonitorRecorder alloc] init];
    self.networkRecorder = [[TTNetworkUsageMonitorRecorder alloc] init];
    self.batteryRecorder = [[TTBatteryUsageMonitorRecorder alloc] init];
    self.diskRecorder = [[TTDiskUsageMonitorRecorder alloc] init];
    self.oomRecorder = [[TTOOMMonitorRecorder alloc] init];
    self.watchdogRecorder = [[TTWatchdogMonitorRecorder alloc] init];
    self.performanceRecorder = [[TTAppPerformanceMonitorRecorder alloc] init];
}

- (void)tryFPSDetection
{
    [[TTFPSMonitor sharedMonitor] startMonitor];
}

- (void)tryWatchdogDetection
{
    [self.watchdogRecorder startMonitor];
}

-(void)tryOOMDetection
{
    [self.oomRecorder tryOOMDetection];
}

-(void)startTimer{
    NSTimeInterval cpuInterval = [self.cpuRecorder monitorInterval];
    NSTimeInterval memoryInterval = [self.memoryRecorder monitorInterval];
    NSTimeInterval timerInterval = MIN(cpuInterval, memoryInterval);
    if (timerInterval<10) {
        timerInterval = 10;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(timeFire:) userInfo:nil repeats:NO];
    
}

- (void)stopTimer{
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

-(void)timeFire:(id)sender{
    [self stopTimer];
    [self.cpuRecorder recordIfNeeded:NO];
    [self.memoryRecorder recordIfNeeded:NO];
    [self startTimer];
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStartNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFinishNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTerminteNotification:) name:UIApplicationWillTerminateNotification object:nil];
}

-(void)receiveStartNotification:(NSNotification *)notify{
    [self.networkRecorder resetNetworkData];
    [self startTimer];
    [self.oomRecorder handleApplicationEnterForeground];
    [self.performanceRecorder handleAppEnterForground];
}

-(void)receiveFinishNotification:(NSNotification *)notify{
    [self stopTimer];
    [self.networkRecorder recordIfNeeded:NO];
    [self.batteryRecorder recordIfNeeded:NO];
    [self.diskRecorder recordIfNeeded:NO];
    [self.oomRecorder handleApplicationEnterBackground];
    [self.performanceRecorder handleAppEnterBackground];
}

-(void)receiveTerminteNotification:(NSNotification *)notify{
    [self.networkRecorder recordIfNeeded:YES];
    [self.batteryRecorder recordIfNeeded:YES];
    [self.oomRecorder handleApplicationTermination];
    [self.performanceRecorder handleAppEnterBackground];
}


// For OOM Detection
+ (void)setAppCrashFlagForLastTimeLaunch
{
    [TTOOMMonitorRecorder setAppCrashFlagForLastTimeLaunch];
}



@end
