//
//  TTStartupDebugGroup.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//
#if INHOUSE
#import "TTStartupDebugGroup.h"
#import "TTNetworkStubTask.h"
#import "TTMemoryMonitorTask.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <TTBaseLib/TTSandBoxHelper.h>

@implementation TTStartupDebugGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupDebugGroup *)debugGroup {
    TTStartupDebugGroup *group = [[TTStartupDebugGroup alloc] init];
    
//    [group.tasks addObject:[[self class] debugStartupForType:TTDebugStartupTypeNetworkStub]];
    [group.tasks addObject:[[self class] debugStartupForType:TTDebugStartupTypeMemoryMonitor]];
    
    return group;
}

+ (TTStartupTask *)debugStartupForType:(TTDebugStartupType)type {
    switch (type) {
        case TTDebugStartupTypeNetworkStub:
            return [[TTNetworkStubTask alloc] init];
            break;
        case TTDebugStartupTypeMemoryMonitor:
            return [[TTMemoryMonitorTask alloc] init];
            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

#if INHOUSE

+ (void)checkShouldSimulateStartCrash
{
    if (![TTSandBoxHelper isInHouseApp]) {
        return;
    }

    BOOL shouldCrash = NO;
    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kTTShouldSimulateStartCrashKey"] mutableCopy];
    shouldCrash = [dic btd_boolValueForKey:@"shouldCrash"];
    if (shouldCrash) {
        NSInteger times = [[dic valueForKey:@"times"] integerValue];
        if (times < 5) {
            times++;
            [dic setObject:@(times) forKey:@"times"];
            [[NSUserDefaults standardUserDefaults] setValue:[dic copy] forKey:@"kTTShouldSimulateStartCrashKey"];
            NSArray * array = [NSArray array];
            NSLog(@"array=%@", array[3]);
        } else {
            [dic setObject:@(NO) forKey:@"shouldCrash"];
            [dic setObject:@(0) forKey:@"times"];
            [[NSUserDefaults standardUserDefaults] setValue:[dic copy] forKey:@"kTTShouldSimulateStartCrashKey"];
        }
        
    }
}
#endif

@end
#endif
