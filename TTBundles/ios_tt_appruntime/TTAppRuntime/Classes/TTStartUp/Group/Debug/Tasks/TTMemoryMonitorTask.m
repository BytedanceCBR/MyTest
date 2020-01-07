//
//  TTMemoryMonitorTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTMemoryMonitorTask.h"
#import "TTInstallIDManager.h"
#import "TTMemoryMonitor.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#if INHOUSE
#import "TTDebugAssistant.h"
#endif
#import "TTLaunchDefine.h"

DEC_TASK("TTMemoryMonitorTask",FHTaskTypeDebug,TASK_PRIORITY_HIGH+1);

@implementation TTMemoryMonitorTask

- (NSString *)taskIdentifier {
    return @"MemoryTask";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"kTTAppMemoryMonitorKey"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kTTAppMemoryMonitorKey"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kTTAppMemoryMonitorKey"]) {
        if ([TTSandBoxHelper isInHouseApp]) {
#if INHOUSE
            [TTDebugAssistant show];
#endif
        }
    }
}

@end
