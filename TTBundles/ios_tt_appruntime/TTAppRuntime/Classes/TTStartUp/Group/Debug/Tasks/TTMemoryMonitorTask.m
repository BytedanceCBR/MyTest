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
//#if INHOUSE
//#import "TTDebugAssistant.h"
//#endif

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
      //  [TTMemoryMonitor showMemoryMonitor];
//#if INHOUSE
//        [TTDebugAssistant show];
//#endif
    }
}

@end
