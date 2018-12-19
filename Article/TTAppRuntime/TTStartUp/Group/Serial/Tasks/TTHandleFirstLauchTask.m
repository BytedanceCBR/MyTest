//
//  TTHandleFirstLauchTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTHandleFirstLauchTask.h"
#import <TTAccountBusiness.h>
#import "SSCookieManager.h"
//#import "FRLogicManager.h"

@implementation TTHandleFirstLauchTask

- (NSString *)taskIdentifier {
    return @"HandleFirstLauch";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] handleFirstLaunchForCurrentVersion];
}

+ (void)handleFirstLaunchForCurrentVersion {
    if([TTSandBoxHelper isAPPFirstLaunch]) {
        SSLog(@"handle first launch");
        
        NSString *sessionKey = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_KEY_KEY];
        if(!isEmptyString(sessionKey)) {
            [TTAccountManager setIsLogin:YES];
            [SSCookieManager setSessionIDToCookie:sessionKey];
        }
        
       
        
//        [FRLogicManager cleanInVersionFirstLaunch];
    }
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[self class] handleFirstLaunchForCurrentVersion];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
     [TTSandBoxHelper setAppFirstLaunch];
}

@end
