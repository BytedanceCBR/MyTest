//
//  TTStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTStartupTask.h"
#import "TTStartupDefine.h"
#import "TTStartupTasksTracker.h"

NSString *const TTStartupProtectPrefix = @"TTStartupProtect";
NSString *const AbnormalTaskIdentifier = @"abnormal_task_identifier";

@implementation TTStartupTask

- (instancetype)init {
    if (self = [super init]) {
        if ([SSCommonLogic isNewLaunchOptimizeEnabled]) {
            NSString *key = [TTStartupProtectPrefix stringByAppendingString:[self taskIdentifier]];
            if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
                [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:key];
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{[TTStartupProtectPrefix stringByAppendingString:[self taskIdentifier]]:@(YES)}];
        }
    }
    return self;
}

- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)isNormal {
    return YES;
//    //修复版本有一个TTSparkRescue的方法
//    return [[NSUserDefaults standardUserDefaults] boolForKey: [TTStartupProtectPrefix stringByAppendingString:[self taskIdentifier]]];
}


- (BOOL)isResident {
    return NO;
}

- (NSString *)taskIdentifier {
    return @"StartupTask";
}

- (void)startAndTrackWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    TTOneDevLog *devLog = [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:[NSString stringWithFormat:@"%@_begin", [self taskIdentifier]] params:@{@"thread" : @([[[NSThread currentThread] valueForKeyPath:@"private.seqNum"] integerValue])}];
    int64_t start = [NSObject currentUnixTime];
    [self startWithApplication:application options:launchOptions];
    int64_t end = [NSObject currentUnixTime];
    double millisecond = [NSObject machTimeToSecs:(end - start)] * 1000;
    [[TTStartupTasksTracker sharedTracker] trackStartupTaskInItsThread:[self taskIdentifier] withInterval:millisecond];
    [[TTStartupTasksTracker sharedTracker] removeInitializeDevLog:devLog];
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    //to be overrided
}

- (void)cleanIfNeeded {
    //to be overrided
}

- (void)setTaskNormal:(BOOL)isNormal {
    [[NSUserDefaults standardUserDefaults] setBool:isNormal forKey:[TTStartupProtectPrefix stringByAppendingString:[self taskIdentifier]]];
    if (!isNormal) {
        [[NSUserDefaults standardUserDefaults] setObject:[self taskIdentifier] forKey:AbnormalTaskIdentifier];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:AbnormalTaskIdentifier];
    }
}

- (BOOL)isConcurrent {
    return NO;
}

@end
