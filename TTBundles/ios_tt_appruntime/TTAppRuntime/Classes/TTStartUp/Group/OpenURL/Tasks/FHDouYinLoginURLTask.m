//
//  FHDouYinLoginURLTask.m
//  TTAppRuntime
//
//  Created by bytedance on 2020/11/17.
//

#import "FHDouYinLoginURLTask.h"
#import "TTLaunchDefine.h"
#import <TTAccountSDK/TTAccount+PlatformAuthLogin.h>

DEC_TASK("FHDouYinLoginURLTask",FHTaskTypeOpenURL,TASK_PRIORITY_HIGH+4);

@implementation FHDouYinLoginURLTask

- (NSString *)taskIdentifier {
    return @"DouYinLoginOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL accountAuthResult = [TTAccount handleOpenURL:url];
    return accountAuthResult;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler {
    BOOL accountAuthResult = [TTAccount continueUserActivity:userActivity restorationHandler:restorationHandler];
    return accountAuthResult;
}

@end
