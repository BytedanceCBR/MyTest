//
//  NewsBaseDelegate+UI.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "NewsBaseDelegate+UI.h"
#import "TTStartupUIGroup.h"
#import "TTStartupTask.h"
#import "TTStartupDefine.h"

@implementation NewsBaseDelegate (UI)

- (void)didFinishUILaunchingForApplication:(UIApplication *)application WithOptions:(NSDictionary *)options {
    TTStartupUIGroup *group = [TTStartupUIGroup UIGroup];
    [group.tasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj shouldExecuteForApplication:application options:options]) {
            if ([group isConcurrent]) {
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

- (void)didFinishWebviewLaunchingForApplication:(UIApplication *)application WithOptions:(NSDictionary *)options {
    TTStartupUIGroup *group = [TTStartupUIGroup webviewGroup];
    [group.tasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj shouldExecuteForApplication:application options:options]) {
            if ([group isConcurrent]) {
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
