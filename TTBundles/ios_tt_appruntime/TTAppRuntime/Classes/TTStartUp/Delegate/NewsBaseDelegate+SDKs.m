//
//  NewsBaseDelegate+SDKs.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "NewsBaseDelegate+SDKs.h"
#import "TTStartupSDKsGroup.h"
#import "NewsBaseDelegate.h"
#import "TTStartupDefine.h"

@implementation NewsBaseDelegate (SDKs)

- (void)didFinishSDKsLaunchingForApplication:(UIApplication *)application WithOptions:(NSDictionary *)options {
    TTStartupSDKsGroup *group = [TTStartupSDKsGroup SDKsRegisterGroup];
    [group.tasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj shouldExecuteForApplication:application options:options]) {
            //是否支持多线程
            if ([group isConcurrent] || [obj isConcurrent]) {
                dispatch_async(self.barrierQueue, ^{
                    [obj startAndTrackWithApplication:application options:options];
                });
            } else {
//                if ([obj isNormal]) {
                    [obj setTaskNormal:NO];
                    [obj startAndTrackWithApplication:application options:options];
                    [obj setTaskNormal:YES];
//                } else {
//                    [obj cleanIfNeeded];
//                }
            }
            [SharedAppDelegate trackCurrentIntervalInMainThreadWithTag:[obj taskIdentifier]];
        }
        [self addResidentTaskIfNeeded:obj];
    }];
}

@end
