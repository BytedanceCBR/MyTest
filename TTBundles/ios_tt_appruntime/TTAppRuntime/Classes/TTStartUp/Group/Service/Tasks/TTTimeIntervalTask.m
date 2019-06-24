//
//  TTTimeIntervalTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTTimeIntervalTask.h"
#import "SSCommonLogic.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTTimeIntervalTask",FHTaskTypeService,TASK_PRIORITY_HIGH+4);

@implementation TTTimeIntervalTask

- (NSString *)taskIdentifier {
    return @"TimeInterval";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
//    if (![SSCommonLogic shouldUseOptimisedLaunch]) {
//        if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestCheckVersionKey]) {
//            [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestCheckVersionKey];
//        }
//    }
}

@end
