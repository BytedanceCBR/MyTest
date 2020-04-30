//
//  TTAppDelegate.m
//  TTABManager
//
//  Created by highlystuff on 07/17/2017.
//  Copyright (c) 2017 highlystuff. All rights reserved.
//

#import "TTAppDelegate.h"
#import <TTABManagerUtil.h>
#import <TTABManager.h>

@implementation TTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"%@",[TTABManagerUtil readABJSON]);
    
//    TTABManager *manager = [TTABManager new];
//    
//    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
//    
//    dispatch_queue_t queue = dispatch_queue_create("parallel", DISPATCH_QUEUE_CONCURRENT);
//    for (int i = 0; i < 10000; i++) {
//        dispatch_async(queue, ^{
//            manager.abFeatureStr = [NSString stringWithFormat:@"abFeature%d",i];
//            NSLog(@"--- %d", i);
//        });
//        dispatch_async(queue, ^{
//            NSLog(@"目前abFeatureString是%@",manager.abFeatureStr);
//        });
//    }
//    dispatch_barrier_async(queue, ^{
//        CFTimeInterval interval = CFAbsoluteTimeGetCurrent() - start;
//        NSLog(@"总耗时：%f",interval);
//    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
