//
//  TTFabricSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTFabricSDKRegister.h"
#import "NewsBaseDelegate.h"
#import "TTInstallIDManager.h"
//#import "revision.h"

#import <TTNetBusiness/TTHttpsControlManager.h>
#import "TTTrackerUtil.h"
#import "TTAppLogExceptionResponseModel.h"
#import "TTAccountBusiness.h"
#import "TTAccountTestSettings.h"
#import "TTSettingsManager.h"
#import "SSCommonLogic.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#import "CommonURLSetting.h"
#import "TTLaunchDefine.h"
#import "BDDYCClient.h"

static NSString *const kTTFabricLaunchCrashKey = @"kTTFabricLaunchCrashKey";

extern const char *build_rev();

DEC_TASK("TTFabricSDKRegister",FHTaskTypeSerial,TASK_PRIORITY_HIGH+3);

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
    [self registerDynamicSDK];
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

- (void)registerDynamicSDK
{
    [BDDYCClient start];
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
