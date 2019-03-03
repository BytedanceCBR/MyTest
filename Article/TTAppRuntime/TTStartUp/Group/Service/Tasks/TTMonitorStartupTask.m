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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchDogDidTrigered) name:TTWatchDogDidTrigeredNotification object:nil];
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

@end
