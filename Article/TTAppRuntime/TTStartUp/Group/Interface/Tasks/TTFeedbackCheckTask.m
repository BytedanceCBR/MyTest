//
//  TTFeedbackCheckTask.m
//  Article
//
//  Created by fengyadong on 17/1/20.
//
//

#import "TTFeedbackCheckTask.h"
#import "NewFeedbackAlertManager.h"
#import "SSFeedbackManager.h"

@implementation TTFeedbackCheckTask

- (NSString *)taskIdentifier {
    return @"FeedbackCheck";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![SSCommonLogic shouldUseOptimisedLaunch]) {
            [[self class] addFeedbackLaunchCheck];
        }
    });
}

+ (void)addFeedbackLaunchCheck {
    [[NewFeedbackAlertManager alertManager] startAlert];
    if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestFeedbackKey]) {
        [[SSFeedbackManager shareInstance] checkHasNewFeedback];
        [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestFeedbackKey];
    }
}

@end
