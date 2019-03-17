//
//  TTFabricSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTFabricSDKRegister.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "NewsBaseDelegate.h"
#import "TTInstallIDManager.h"
#import "revision.h"

#import <TTNetBusiness/TTHttpsControlManager.h>
#import "TTTrackerUtil.h"
#import "TTAppLogExceptionResponseModel.h"
#import <TTAccountBusiness.h>
#import "TTAccountTestSettings.h"
#import "TTSettingsManager.h"

static NSString *const kTTFabricLaunchCrashKey = @"kTTFabricLaunchCrashKey";

@implementation TTFabricSDKRegister

- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    return [SSCommonLogic crashlyticsCrashReportEnable];
}

- (NSString *)taskIdentifier {
    return @"FabricSDKRegister";
}

- (BOOL)isResident {
    return YES;
}
- (BOOL)isConcurrent {
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue];
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [self registerCrashlyticsSDK];
    [[self class] addOneCrashCount];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self class] clearCrashCount];
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[self class] clearCrashCount];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[self class] clearCrashCount];
}

- (void)registerCrashlyticsSDK {
    //crashlytics
    if (!CrashlyticsKit.delegate) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CrashlyticsKit setDelegate:self];

            [Fabric with:@[CrashlyticsKit]];
            
            [Crashlytics startWithAPIKey:@"d13f09fbde51ffb610b5ebcfe8e9b399c791783a"];
            
            if (!isEmptyString([[TTInstallIDManager sharedInstance] deviceID])) {
                [[Crashlytics sharedInstance] setUserIdentifier:[[TTInstallIDManager sharedInstance] deviceID]];
                [[Crashlytics sharedInstance] setObjectValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
            }
            
            if (!isEmptyString([TTAccountManager userID])) {
                [[Crashlytics sharedInstance] setUserName:[TTAccountManager userID]];
                [[Crashlytics sharedInstance] setObjectValue:[TTAccountManager userID] forKey:@"user_id"];
            }
            [[Crashlytics sharedInstance] setObjectValue:@([TTAccountTestSettings threadSafeSupported]) forKey:@"account_thread_safe"];
            
            NSString * channel = [TTSandBoxHelper getCurrentChannel];
            if (!isEmptyString(channel)) {
                [[Crashlytics sharedInstance] setObjectValue:channel forKey:@"channel"];
            }
            NSString * buildTime = [NSString stringWithFormat:@"%s %s", __DATE__ ,__TIME__];
            if (!isEmptyString(buildTime)) {
                [[Crashlytics sharedInstance] setObjectValue:buildTime forKey:@"build_time"];
            }
            
            if (BuildRev) {
                NSString *buildRevison = [NSString stringWithFormat:@"%s", BuildRev];
                [[Crashlytics sharedInstance] setObjectValue:buildRevison forKey:@"revision"];
            }
        });
    }
}

#pragma mark -- Crashlytics Delegate
- (void)crashlyticsDidDetectReportForLastExecution:(CLSReport *)report completionHandler:(void (^)(BOOL submit))completionHandler {
    
    // oom 检测需要由外部告知上次进程启动是否发生了 crash
    [TTMonitor setAppCrashFlagForLastTimeLaunch];
    
    NSMutableDictionary *devLogParams = [[NSMutableDictionary alloc] init];
    [devLogParams setValue:report.identifier forKey:@"sessionID"];
    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"Crash" params:devLogParams];
    
    //把crash 告知我们后台
    [[self class ] startSendExceptionInfoWithOutLog];
    
    BOOL isLaunchCrash = [[self class] currentCrashCount] > 0;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"install_id"];
    [params setValue:@(isLaunchCrash) forKey:@"is_launch_crash"];
    
    NSString *interval = [NSString stringWithFormat:@"%f",CFAbsoluteTimeGetCurrent() - SharedAppDelegate.startTime];
    [params setValue:interval forKey:@"launch_interval"];
    [TTTrackerWrapper eventV3:@"toutiao_crash" params:[params copy]];
    
    if (isLaunchCrash) {
        [report setObjectValue:@"tt_launch_crash_happen" forKey:@"is_launch_crash_happen"];
    }
    
    completionHandler(YES);
}

+ (void)startSendExceptionInfoWithOutLog {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [CommonURLSetting exceptionURLString];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding :NSUTF8StringEncoding];
        urlString = [[TTHttpsControlManager sharedInstance_tt] transferedURLFrom:[NSURL URLWithString:urlString]].absoluteString;
        
        NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [postDict addEntriesFromDictionary:[TTTrackerUtil onTheFlyParameter]];

        NSMutableDictionary * headerDict = [NSMutableDictionary dictionaryWithCapacity:10];
        [headerDict setValue:@"application/json; encoding=utf-8" forKey:@"Content-Type"];
        [headerDict setValue:@"application/json" forKey:@"Accept"];
        
        NSDictionary *responseDict = [[TTNetworkManager shareInstance]
                                      synchronizedRequstForURL:urlString
                                      method:@"POST"
                                      headerField:headerDict
                                      jsonObjParams:postDict
                                      needCommonParams:YES
                                      needResponse:YES];
        NSError *modelError;
        TTAppLogExceptionResponseModel *model;
        NSDictionary *result = [responseDict objectForKey:@"result"];
        if (result){
            model = [[TTAppLogExceptionResponseModel alloc] initWithDictionary:result error:&modelError];
        }
    });
}

+ (NSInteger)currentCrashCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:kTTFabricLaunchCrashKey];
    return count;
}

+ (void)addOneCrashCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:kTTFabricLaunchCrashKey];
    [defaults setInteger:count + 1 forKey:kTTFabricLaunchCrashKey];
    [defaults synchronize];
}

+ (void)clearCrashCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:kTTFabricLaunchCrashKey];
    [defaults synchronize];
}

@end
