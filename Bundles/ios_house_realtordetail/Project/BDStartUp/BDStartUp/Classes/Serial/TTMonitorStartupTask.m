//
//  TTMonitorStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTMonitorStartupTask.h"
#import "BDStartUpManager.h"

#if BD_TTMonitor
#import "TTMonitor.h"
#import "TTWatchdogMonitorRecorder.h"
#endif

NSString * const TTDebugrealInitializedNotification = @"TTDebugrealInitializedNotification";

@implementation TTMonitorStartupTask

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
#if BD_TTMonitor
    // [[TTMonitor shareManager] setUrlTransformBlock:^(NSURL * url){
    //     return [[[TTHttpsControlManager sharedInstance_tt] transferedURLFrom:url] copy];
    // }];
    
    // [[TTMonitor shareManager] startWithAppkey:[SharedAppDelegate appKey] paramsBlock:^NSDictionary *{
    //     return @{}
    // }];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTDebugrealInitializedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchDogDidTrigered) name:TTWatchDogDidTrigeredNotification object:nil];
#endif
}

- (void)watchDogDidTrigered
{
    
}

@end

