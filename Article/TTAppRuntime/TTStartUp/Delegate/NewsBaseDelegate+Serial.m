//
//  NewsBaseDelegate+Serial.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "NewsBaseDelegate+Serial.h"
#import "TTStartupSerialGroup.h"
#import "TTStartupTask.h"
#import "TTStartupDefine.h"

@implementation NewsBaseDelegate (Serial)

- (void)didFinishSerialLaunchingForApplication:(UIApplication *)application WithOptions:(NSDictionary *)options {
    TTStartupSerialGroup *group = [TTStartupSerialGroup serialGroup];
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
