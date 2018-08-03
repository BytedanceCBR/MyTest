//
//  TTOOMMonitor.m
//  DemoTest
//
//  Created by ShaJie on 21/5/2017.
//  Copyright © 2017 bytedance. All rights reserved.
//

#import "TTOOMMonitor.h"
#include <sys/sysctl.h>
#import <UIKit/UIKit.h>

static NSString * const AppVersionKey   = @"AppVer";
static NSString * const OSVersionKey    = @"OSVer";

static NSString * const DebuggerEvent           = @"debugger";      // 开发在调试模式
static NSString * const ForcelyTerminationEvent = @"terminate";     // 用户强行退出了 App

static NSString * const OOMMonitorTerminationEventFileName      = @"OOMMonitorExitState.txt";
static NSString * const OOMMonitorAppLaunchStateFileName        = @"OOMMonitorAppLaunchState.plist";
static NSString * const OOMMonitorAppBackgroundStateFileName    = @"OOMDetectorBackgroundState.bool";


bool tt_oomMonitorIsApplicationAttachedToDebugger()
{
#ifdef DEBUG
    int  mib[4];
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    struct kinfo_proc info;
    info.kp_proc.p_flag = 0;
    
    size_t size = sizeof(info);
    int result = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    if(result == 0) {
        return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
    } else {
        return false;
    }
#else
    return false;
#endif
}

@interface TTOOMMonitor ()
{
    NSString * _stateDirectory;
    NSString * _terminationEventFile;
    NSString * _terminationEventFileContents;
    NSString * _backgroundStateFile;
    
    BOOL _appWasBackgroundedOnExit;
    BOOL _hasChecked; // 本次进程已经检查过上次终止类型
}

@end

@implementation TTOOMMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stateDirectory = [TTOOMMonitor oomMonitorStateDirectory];
        _terminationEventFile = [_stateDirectory stringByAppendingPathComponent:OOMMonitorTerminationEventFileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:_terminationEventFile]) {
            _terminationEventFileContents = [NSString stringWithContentsOfFile:_terminationEventFile
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:_terminationEventFile
                                                       error:nil];
        }
        
        if(tt_oomMonitorIsApplicationAttachedToDebugger()) {
            [self logTerminationEvent:DebuggerEvent];
        }
        
        _backgroundStateFile = [_stateDirectory stringByAppendingPathComponent:OOMMonitorAppBackgroundStateFileName];
        _appWasBackgroundedOnExit = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:_backgroundStateFile]) {
            [[NSFileManager defaultManager] removeItemAtPath:_backgroundStateFile error:nil];
            _appWasBackgroundedOnExit = YES;
        }
    }
    return self;
}


- (TTTerminationType)runCheckWithWhetherCrashDetected:(BOOL)crashDetected
{
    if (_hasChecked)
        return _lastTerminationType;
    _hasChecked = YES;
    
    NSDictionary *launchState = [self loadLastAppLaunchState];
    
    // 参考 https://code.facebook.com/posts/1146930688654547/reducing-fooms-in-the-facebook-ios-app/
    // OOM 检测步骤, 做了一些修改
    // 1. 从 AppUpdate 中再细分出一个 AppFirstInstall 用以区分首次安装后运行
    // 2. 去掉了对 intentionally quit （即 exit() 和 abort() ）的监控，因为代码里目前没有主动调用 exit()，而 abort() 会被 Crashlytics 当成 Crash 处理
    // 3. App 上次是否 Crash 由外部传入，monitor 本身不监控崩溃
    // 4. 增加是否是挂了 debugger 调试 App 的判断，减少开发调试过程频繁启动 App 对线上数据的影响
    
    TTTerminationType terminationType = TTTerminationTypeUnknown;
    if ([self checkAppLaunchAfterFirstInstall:launchState]) {
        terminationType = TTTerminationTypeAppLaunchAfterFirstInstall;
    } else if ([self checkAppUpdated:launchState]) {
        terminationType = TTTerminationTypeAppUpdate;
    } else if (crashDetected) {
        terminationType = TTTerminationTypeCrash;
    } else if ([_terminationEventFileContents isEqualToString:ForcelyTerminationEvent]) {
        terminationType = TTTerminationTypeForcelyTerminate;
    } else if ([self checkOsUpdate:launchState]) {
        terminationType = TTTerminationTypeOSUpdate;
    } else if ([_terminationEventFileContents isEqualToString:DebuggerEvent]) {
        terminationType = TTTerminationTypeDebugger;
    } else {
        if(_appWasBackgroundedOnExit) {
            terminationType = TTTerminationTypeBackgroundOOM;
        } else {
            terminationType = TTTerminationTypeForegroundOOM;
        }
    }
    
    _terminationEventFileContents = nil;
    
    _lastTerminationType = terminationType;
    
    // 更新 App 版本和系统版本的记录
    [self updateAppLaunchState];
    return _lastTerminationType;
}

#pragma mark - internal

- (NSDictionary *)loadLastAppLaunchState
{
    NSString * path = [_stateDirectory stringByAppendingPathComponent:OOMMonitorAppLaunchStateFileName];
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!dict)
        dict = [NSDictionary dictionary];
    return dict;
}

- (void)updateAppLaunchState
{
    NSString * path = [_stateDirectory stringByAppendingPathComponent:OOMMonitorAppLaunchStateFileName];
    NSDictionary * dict =
  @{AppVersionKey : [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey],
    OSVersionKey : [[UIDevice currentDevice] systemVersion]};
    [dict writeToFile:path atomically:YES];
}

- (BOOL)checkAppLaunchAfterFirstInstall:(NSDictionary*)launchState
{
    NSString *lastVersion = launchState[AppVersionKey];
    if(lastVersion == nil) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)checkAppUpdated:(NSDictionary*)launchState
{
    NSString *currentVersion =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *lastVersion = launchState[AppVersionKey];
    if(lastVersion == nil) {
        return NO;
    } else if([currentVersion isEqualToString:lastVersion]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkDidTerminate
{
    return [_terminationEventFileContents isEqualToString:ForcelyTerminationEvent];
}

- (BOOL)checkOsUpdate:(NSDictionary*)launchState
{
    NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
    NSString *lastVersion = launchState[OSVersionKey];
    
    if(lastVersion == nil) {
        return NO;
    } else if([currentVersion isEqualToString:lastVersion]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)logTerminationEvent:(NSString*)event
{
    [event writeToFile:_terminationEventFile
            atomically:NO
              encoding:NSUTF8StringEncoding
                 error:nil];
}

- (void)logApplicationForcelyTermination
{
    [self logTerminationEvent:ForcelyTerminationEvent];
}

- (void)logApplicationEnterBackground
{
    [@"" writeToFile:_backgroundStateFile
          atomically:NO
            encoding:NSUTF8StringEncoding
               error:nil];
    
}

- (void)logApplicationEnterForeground
{
    [[NSFileManager defaultManager] removeItemAtPath:_backgroundStateFile error:nil];
}

#pragma mark - Helper


+ (NSString *)oomMonitorStateDirectory
{
    NSString * cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString * stateDirectory = [cacheDirectory stringByAppendingPathComponent:@"com.bytedance.oommonitor"];
    
    BOOL isDirectory = NO;
    BOOL exists =
    [[NSFileManager defaultManager] fileExistsAtPath:stateDirectory
                                         isDirectory:&isDirectory];
    
    if (exists && !isDirectory)
    {
        [[NSFileManager defaultManager] removeItemAtPath:stateDirectory
                                                   error:nil];
        exists = NO;
    }
    
    if (!exists)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:stateDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return stateDirectory;
}



@end
