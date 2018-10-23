//
//  TTFetchBadgeTask.m
//  Article
//
//  Created by fengyadong on 17/1/20.
//
//

#import "TTFetchBadgeTask.h"
#import "ArticleBadgeManager.h"
//#import "TTFollowWebViewController.h"
#import "TTNotificationCenterDelegate.h"
#import "TTLaunchTracer.h"
@implementation TTFetchBadgeTask

- (NSString *)taskIdentifier {
    return @"FetchBadge";
}

- (BOOL)isResident {
    return YES;
}

- (BOOL)isClearBadgeBugfixRollback {
    // 开关云控降低风险，下一版没问题就去掉
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTClearBadgeBugfixRollback"];
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        wrapperTrackEvent(@"apn", @"badge");
        [[TTLaunchTracer shareInstance] setBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber];
    }
    [[ArticleBadgeManager shareManger] startFetch];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //放在后台去清红点 -- 5.8.9 nick
    // 清红点不清系统通知的 workaround
    [self clearAppBadgeAndNotificationCenter];
}

//- (void)applicationWillTerminate:(UIApplication *)application {
//    [TTFollowWebViewController setCanShowFollowTip:NO];
//}

- (void)clearAppBadgeAndNotificationCenter {
    // 大于等于 11 且回退开关未开启才使用新 API
    if ([TTDeviceHelper OSVersionNumber] >= 11.0 && ![self isClearBadgeBugfixRollback]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        [[TTNotificationCenterDelegate sharedNotificationCenterDelegate] sendClearBadgeNotification];
#pragma clang diagnostic pop
    } else {
        // iOS 10 及以下，或者开关回退了，仍然采用旧方法清红点
        UILocalNotification *local = [[UILocalNotification alloc] init];
        local.applicationIconBadgeNumber = -1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:local];
    }
}

@end
