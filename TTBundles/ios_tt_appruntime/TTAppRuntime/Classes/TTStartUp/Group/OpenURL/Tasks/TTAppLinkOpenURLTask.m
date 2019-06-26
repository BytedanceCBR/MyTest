//
//  TTAppLinkOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTAppLinkOpenURLTask.h"
#import "TTAppLinkManager.h"
#import <TTArticleBase/ExploreLogicSetting.h>
#import "TTLaunchDefine.h"

DEC_TASK("TTAppLinkOpenURLTask",FHTaskTypeOpenURL,TASK_PRIORITY_HIGH+3);

@implementation TTAppLinkOpenURLTask

- (NSString *)taskIdentifier {
    return @"AppLinkOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[TTAppLinkManager sharedInstance] handOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    isShareToPlatformEnterBackground = NO;
}

@end
