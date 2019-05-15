//
//  NewsBaseDelegate+Interface.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "NewsBaseDelegate+Interface.h"
#import "TTStartupInterfaceGroup.h"
#import "TTStartupTask.h"
#import "TTStartupDefine.h"

@implementation NewsBaseDelegate (Interface)

- (void)didFinishInterfaceLaunchingForApplication:(UIApplication *)application WithOptions:(NSDictionary *)options {
    TTStartupInterfaceGroup *group = [TTStartupInterfaceGroup interfaceGroup];
    [group.tasks enumerateObjectsUsingBlock:^(TTStartupTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj shouldExecuteForApplication:application options:options]) {
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
