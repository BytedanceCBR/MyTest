//
//  TTAppAlertStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTAppAlertStartupTask.h"
#import "AppAlertManager.h"
#import "NewsBaseDelegate.h"
#import "NewsBaseDelegate.h"

@implementation TTAppAlertStartupTask

- (BOOL)isResident {
    return YES;
}

- (NSString *)taskIdentifier {
    return @"AppAlert";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AppAlertManager alertManager] startAlertWithTopViewController:[SharedAppDelegate appTopNavigationController]];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestAppAlertKey]) {
        [[AppAlertManager alertManager] startAlertWithTopViewController:[SharedAppDelegate appTopNavigationController]];
        [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestAppAlertKey];
    }
}

@end
