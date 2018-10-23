//
//  TTFPSMonitor.m
//  testTintPerformance
//
//  Created by tyh on 2017/11/15.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import "TTFPSMonitor.h"
#import "TTMonitor.h"
#import "TTMonitorConfiguration.h"
#import "TTDeviceExtension.h"

//一共4种type监控
//主feed、详情页、西瓜视频、火山小视频
static NSString *const TTFPSMonitorNewsListView = @"ArticleTabBarStyleNewsListViewController";
static NSString *const TTFPSMonitorDetailContainerView = @"TTDetailContainerViewController";
static NSString *const TTFPSMonitorTTVVideoTabView = @"TTVVideoTabViewController";
static NSString *const TTFPSMonitorTSVTabViewController = @"TSVTabViewController";


static NSString *const TTFPSMonitorLastTime = @"TTFPSMonitorLastTime";
//监控时间间隔 1days
static NSUInteger const TTFPSMonitorPassedTime = 1 * 24 * 60 * 60;
//监控持续时间 30min
static NSUInteger const TTFPSMonitorContinueTime = 30 * 60;
//最小采纳取均值上报数
static NSUInteger const TTFPSMonitorMinUploadCount = 60;

@implementation TTFPSMonitor
{
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    NSTimeInterval _monitorTime;
    NSDictionary *_fpsDic;
}
+ (instancetype)sharedMonitor {
    static TTFPSMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[self alloc] init];
    });
    return monitor;
}

- (instancetype)init
{
    if (self) {
        self = [super init];
        _lastTime = 0;
        _count = 0;
        _monitorTime = 0;
    }
    return self;
}


- (void)startMonitor
{
    if ([self isDebug]) {
        return;
    }
    if (![self isEnabled]) {
        return;
    }
    if (![NSThread isMainThread]) {
        NSLog(@"must start in main thread");
        return;
    }
    
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastTime = [defults valueForKey:TTFPSMonitorLastTime];
    if (lastTime) {
        NSTimeInterval passedTime = [[NSDate date] timeIntervalSince1970] - [lastTime doubleValue];
        //隔1天监控一次
        if (passedTime > TTFPSMonitorPassedTime) {
            [self _startMonitor];
        }
    }else{
        [self _startMonitor];
    }
}

- (void)_startMonitor{
    //已启动
    if (_link) {
        return;
    }
    //可重复初始化
    _lastTime = 0;
    _count = 0;
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    //只初始化一次
    if (!_fpsDic) {
        _fpsDic = [NSMutableDictionary dictionary];
        [_fpsDic setValue:[NSMutableArray array] forKey:TTFPSMonitorNewsListView];
        [_fpsDic setValue:[NSMutableArray array] forKey:TTFPSMonitorDetailContainerView];
        [_fpsDic setValue:[NSMutableArray array] forKey:TTFPSMonitorTTVVideoTabView];
        [_fpsDic setValue:[NSMutableArray array] forKey:TTFPSMonitorTSVTabViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}
- (void)appWillResignActive {
    [self stopMonitor];
}

- (void)appDidBecomeActive {
    [self startMonitor];
}

- (void)stopMonitor
{
    [_link invalidate];
    _link = nil;
    _lastTime = 0;
    _count = 0;
    
}


- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    if (_monitorTime > TTFPSMonitorContinueTime) {
        [self monitorDidComplete];
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    //大约认为是1s
    _monitorTime++;
    
    if ([NSRunLoop currentRunLoop].currentMode == UITrackingRunLoopMode) {
        
        UIViewController *activeVC = [self activeVC];
        if (!activeVC) {
            return;
        }
        NSString *vcName = NSStringFromClass([activeVC class]);
        NSMutableArray *fpsArray = [_fpsDic valueForKey:vcName];
        if (fpsArray) {
            [fpsArray addObject:[NSNumber numberWithFloat:(int)round(fps)]];
        }
    }
    
}


- (void)monitorDidComplete
{
    [self stopMonitor];
    
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [defults setValue:[NSNumber numberWithDouble:time] forKey:TTFPSMonitorLastTime];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        for (NSString *fpsType in [_fpsDic allKeys]) {
            NSArray *fpsArray = _fpsDic[fpsType];
            if (!fpsArray || fpsArray.count < TTFPSMonitorMinUploadCount) {
                continue;
            }
            long long sum = 0;
            for (NSNumber *fps in fpsArray) {
                sum += [fps intValue];
            }
            float finnalFps = sum/(float)fpsArray.count;
            [params setValue:[NSNumber numberWithFloat:finnalFps] forKey:fpsType];
        }
        if ([params allKeys].count > 0) {
            [params setValue:[NSNumber numberWithInt:[TTDeviceExtension getDeviceType]] forKey:@"status"];
            [[TTMonitor shareManager] trackService:@"tt_fps_monitor" attributes:params];
        }
        //置空
        _fpsDic = nil;
    });
}

//获取当前屏幕显示的 View Controller
- (UIViewController *)activeVC
{
    UIWindow * window   = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    return [self nextTopForViewController:window.rootViewController];
    
}

- (UIViewController *)nextTopForViewController:(UIViewController *)inViewController {
    while (inViewController.presentedViewController) {
        inViewController = inViewController.presentedViewController;
    }
    if ([inViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UITabBarController *)inViewController).selectedViewController];
        return selectedVC;
    } else if ([inViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UINavigationController *)inViewController).visibleViewController];
        return selectedVC;
    } else {
        return inViewController;
    }
}

- (BOOL)isEnabled {
    return [TTMonitorConfiguration isEnabledForMetricsType:@"fps_monitor"];
}

- (BOOL)isDebug {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}
@end


