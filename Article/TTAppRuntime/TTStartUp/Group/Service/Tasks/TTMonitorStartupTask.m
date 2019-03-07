//
//  TTMonitorStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTMonitorStartupTask.h"
#import "TTMonitor.h"
#import "TTInstallIDManager.h"
#import "TTDebugRealMonitorManager.h"
#import <TTNetBusiness/TTHttpsControlManager.h>
#import "NewsBaseDelegate.h"
#import "BSBacktraceLogger.h"
#import "TTWatchdogMonitorRecorder.h"
#import "TTMonitorConfiguration.h"
#import <Heimdallr/HMDInjectedInfo.h>
#import <Heimdallr/HMDConstants.h>
#import <TTTracker/TTTrackerSessionHandler.h>
#import <TTTracker/TTTrackerProxy.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <BDAgileLog.h>
#import "HMDLogUploader.h"
#import "BSBacktraceLogger.h"
#import "TTWatchdogMonitorRecorder.h"
#import "TTMonitorConfiguration.h"
#import <Heimdallr/Heimdallr.h>

static BOOL TTDebugrealInitialized = NO;
NSString * const TTDebugrealInitializedNotification = @"TTDebugrealInitializedNotification";

@implementation TTMonitorStartupTask

- (BOOL)isResident{
    return YES;
}

- (NSString *)taskIdentifier {
    return @"Monitor";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] settingMonitor];
    [self initApmMonitor];
    [self initALog];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchDogDidTrigered) name:TTWatchDogDidTrigeredNotification object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"tt_ios_arch_settings" defaultValue:@{} freeze:YES];
    if ([archSettings tt_boolValueForKey:@"alog_enable"]) {
        alog_close();
    }
}

- (void)watchDogDidTrigered
{
    NSMutableArray *framePointers = [NSMutableArray array];
    
    NSString *threadsStr = nil;
    if ([TTMonitorConfiguration queryIfEnabledForKey:@"upload_all_thread_stack"]) {
        threadsStr = [BSBacktraceLogger bs_backtraceOfAllThread];
    }else{
        threadsStr = [BSBacktraceLogger bs_backtraceOfMainThread];
    }
    
    if ([TTMonitorConfiguration queryIfEnabledForKey:@"upload_all_thread_stack"]) {
        NSArray *threads = [threadsStr componentsSeparatedByString:@"\n\n"];
        [threads enumerateObjectsUsingBlock:^(NSString* _Nonnull threadStr, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *stacks = [threadStr componentsSeparatedByString:@"\n"];
            [stacks enumerateObjectsUsingBlock:^(NSString*  _Nonnull funcStr, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *components = [funcStr componentsSeparatedByString:@" "];
                [components enumerateObjectsUsingBlock:^(NSString*  _Nonnull partStr, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([partStr hasPrefix:@"0x"]) {
                        unsigned long long result = 0;
                        NSScanner *scanner = [NSScanner scannerWithString:partStr];
                        [scanner scanHexLongLong:&result];
                        CLSStackFrame *frame = [CLSStackFrame stackFrameWithAddress:result];
                        [framePointers addObject:frame];
                        *stop = YES;
                    }
                }];
            }];
            CLSStackFrame *separator = [CLSStackFrame stackFrameWithAddress:0];
            //加两个0地址分割
            [framePointers addObject:separator];
            [framePointers addObject:separator];
        }];
    }else{
        NSArray *stacks = [threadsStr componentsSeparatedByString:@"\n"];
        [stacks enumerateObjectsUsingBlock:^(NSString*  _Nonnull funcStr, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *components = [funcStr componentsSeparatedByString:@" "];
            [components enumerateObjectsUsingBlock:^(NSString*  _Nonnull partStr, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([partStr hasPrefix:@"0x"]) {
                    unsigned long long result = 0;
                    NSScanner *scanner = [NSScanner scannerWithString:partStr];
                    [scanner scanHexLongLong:&result];
                    CLSStackFrame *frame = [CLSStackFrame stackFrameWithAddress:result];
                    [framePointers addObject:frame];
                    *stop = YES;
                }
            }];
        }];
    }
    [[Crashlytics sharedInstance] recordCustomExceptionName:@"watch_dog" reason:@"caton" frameArray:[framePointers copy]];
    [[TTMonitor shareManager] trackService:@"tt_caton_monitor" status:0 extra:nil];
}

/**
 *  设置监控相关逻辑
 */
+ (void)settingMonitor
{
    [self registerTransferService];
    [[TTMonitor shareManager] startWithAppkey:[SharedAppDelegate appKey] paramsBlock:^NSDictionary *{
        NSMutableDictionary * paramsDict = [[NSMutableDictionary alloc] init];
        [paramsDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        [paramsDict setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"install_id"];
        return [paramsDict copy];
    }];
    if ([SSCommonLogic enableDebugRealMonitor]) {
        [[TTDebugRealMonitorManager sharedManager] start];
    }
    
    TTDebugrealInitialized = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTDebugrealInitializedNotification object:nil];
}

+ (BOOL)debugrealInitialized {
    return TTDebugrealInitialized;
}

+ (void)registerTransferService{
    [[TTMonitor shareManager] setUrlTransformBlock:^(NSURL * url){
        return [[[TTHttpsControlManager sharedInstance_tt] transferedURLFrom:url] copy];
    }];
}


#pragma mark - apm init
// 初始化 APM 监控
- (void)initApmMonitor{
    NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"tt_lite_ios_arch_settings" defaultValue:@{} freeze:YES];
    if ([archSettings tt_boolValueForKey:@"apm_enable"]) {
        [self setupAPMModule];
    }
}

- (void)initALog {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [directory stringByAppendingPathComponent:@"alog"];
    
#if DEBUG
    // Debug下默认开启ALog
    alog_open_default([path UTF8String], "BDALog");
    alog_set_log_level(kLevelAll);
    alog_set_console_log(true);
    [[HMDLogUploader sharedInstance] uploadAlogIfCrashed];
#else
    NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"tt_lite_ios_arch_settings" defaultValue:@{} freeze:YES];
    if ([archSettings tt_boolValueForKey:@"alog_enable"]) {
        alog_open_default([path UTF8String], "BDALog");
        int level = [archSettings tt_intValueForKey:@"alog_level"];
        if (level == kLevelAll
            || level == kLevelVerbose
            || level == kLevelDebug
            || level == kLevelInfo
            || level == kLevelWarn
            || level == kLevelError
            || level == kLevelFatal
            || level == kLevelNone) {
            alog_set_log_level(level);
        }
        else {
            alog_set_log_level(kLevelNone); //如果下发异常，则默认为None
        }
        [[HMDLogUploader sharedInstance] uploadAlogIfCrashed];
    }
#endif
}

- (void)setupAPMModule{
    
    HMDInjectedInfo *injectedInfo = [HMDInjectedInfo defaultInfo];
    injectedInfo.appID = [TTSandBoxHelper ssAppID];
    injectedInfo.appName = [TTSandBoxHelper appName];
    injectedInfo.channel = [TTSandBoxHelper getCurrentChannel];
    injectedInfo.deviceID = [TTInstallIDManager sharedInstance].deviceID;
    injectedInfo.installID = [TTInstallIDManager sharedInstance].installID;
    injectedInfo.userID = [[TTAccount sharedAccount] userIdString];
    injectedInfo.userName = [[[TTAccount sharedAccount] user] name];
    injectedInfo.commonParams = [TTNetworkManager shareInstance].commonParams;
    injectedInfo.sessionID = [TTTrackerSessionHandler sharedHandler].sessionID;
    injectedInfo.buildInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BuildInfo"];
    
    [[Heimdallr shared] setupWithInjectedInfo:injectedInfo];
    
    // 保证 sessionID 唯一
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionIDDidChanged:) name:kTrackerCleanerWillStartCleanNotification object:nil];
}

- (void)sessionIDDidChanged:(NSNotification *)noti {
    if ([[noti.userInfo objectForKey:kTrackerCleanerWillStartCleanFromTypeKey] integerValue] == TTTrackerCleanerStartCleanFromAppWillEnterForground) {
        [HMDInjectedInfo defaultInfo].sessionID = [TTTrackerSessionHandler sharedHandler].sessionID;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TTNetworkMonitorSwitchDelegate

- (BOOL)shouldIgnoreNetworkForTTMonitor {
    //如果APM的kHMDModuleNetworkTracker功能开启，则TTMonitor不开启api_all，api_error，image_monitor在内的网络监控
    NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"tt_lite_ios_arch_settings" defaultValue:@{} freeze:YES];
    if ([archSettings tt_boolValueForKey:@"apm_enable"]) {
        if ([[Heimdallr shared] isModuleWorkingForName:kHMDModuleNetworkTracker]) {
            return YES;
        }
    }
    return NO;
}

@end
