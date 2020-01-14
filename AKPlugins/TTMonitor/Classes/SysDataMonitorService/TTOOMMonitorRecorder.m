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
static NSString * const OOMMonitorAppViewControllerFileName     = @"OOMMonitorAppViewControllerFileName.txt";

@interface TTOOMMonitorRecorder ()
{
    NSString * _enteredViewControllerFile;
    NSString *_lastSessionFinalViewController; //上次进程的最后一个VC
}

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

- (instancetype)init {
    self = [super init];
    if (self) {
        _enteredViewControllerFile = [[TTOOMMonitor oomMonitorStateDirectory] stringByAppendingPathComponent:OOMMonitorAppViewControllerFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_enteredViewControllerFile]) {
            _lastSessionFinalViewController = [NSString stringWithContentsOfFile:_enteredViewControllerFile
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:_enteredViewControllerFile error:nil];
        }
        UIViewController *topmostVC = [[self class] correctTopmostViewController];
        if (topmostVC) {
            [self handleViewAppear:topmostVC];
        }
    }
    return self;
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
                                     @"did":deviceID,
                                     @"vc":_lastSessionFinalViewController?:@"",
                                     };
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

- (void)handleViewAppear:(UIViewController *)viewController {
    if (![self isEnabled]) {
        return;
    }
    if (viewController) {
        NSString *viewControllerString = NSStringFromClass([viewController class]);
        [viewControllerString writeToFile:_enteredViewControllerFile
                               atomically:NO
                                 encoding:NSUTF8StringEncoding
                                    error:nil];
    }
}

#pragma mark - class

+ (void)setAppCrashFlagForLastTimeLaunch
{
    @synchronized (self) {
        AppCrashedAtLastTimeLaunch = YES;
    }
}

+ (UIViewController*)correctTopViewControllerFor:(UIResponder*)responder
{
    UIResponder *topResponder = responder;
    for (; topResponder; topResponder = [topResponder nextResponder]) {
        if ([topResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)topResponder;
            while (viewController.parentViewController && viewController.parentViewController != viewController.navigationController && viewController.parentViewController != viewController.tabBarController) {
                viewController = viewController.parentViewController;
            }
            return viewController;
        }
    }
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] delegate].window rootViewController];
    }
    
    return (UIViewController*)topResponder;
}

+ (UIViewController *)correctTopmostViewController
{
    UIWindow * window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate window];
    }
    if (![window isKindOfClass:[UIView class]]) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    UIView *topView = window.subviews.lastObject;
    UIViewController *topController = [self correctTopViewControllerFor:topView];
    return topController;
}

@end
