//
//  AllAppDelegate.m
//  All
//
//  Created by Tianhang Yu on 12-7-15.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "AllAppDelegate.h"
#import "VideoNavViewController.h"
#import "VideoMainViewController.h"
#import "DownloadTest.h"
#import "FeedbackViewController.h"
#import "VideoPlayViewController.h"
#import "VideoLocalServer.h"

@interface AllAppDelegate () <FeedbackViewControllerDelegate>

@property (nonatomic, retain) VideoMainViewController *mainViewController;

@end


@implementation AllAppDelegate

@synthesize mainViewController = _mainViewController;

- (void)dealloc
{
    self.mainViewController = nil;
    [super dealloc];
}

- (NSString *)appKey
{
    return @"5028d65e52701544e00000e5";
}

- (NSString *)umTrackAppKey
{
    return @"8fa58b661bd8856e7c0bf14a6577c93a";
}

- (NSString *)weixinAppID
{
    return @"wx6ef66e5970a2f287";
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    self.mainViewController = [[[VideoMainViewController alloc] init] autorelease];
//    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:_mainViewController] autorelease];
    VideoNavViewController *nav = [[[VideoNavViewController alloc] initWithRootViewController:_mainViewController] autorelease];
    nav.navigationBarHidden = YES;
    
    self.window.rootViewController = nav;
    
    [super handleApplicationLaunchOptionRemoteNotification:launchOptions];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [super applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [super applicationWillResignActive:application];
    
    if ([VideoLocalServer localServer].isRunning) {
        [[VideoLocalServer localServer] stop:YES];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
    
    if (![VideoLocalServer localServer].isRunning) {
        [[VideoLocalServer localServer] startLocalServer];
    }
}

#pragma mark - AppInitDelegate

- (void)showFeedbackViewController
{
    [super showFeedbackViewController];
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    
    if(nav) {
        FeedbackViewController * controller = [[FeedbackViewController alloc] init];
        controller.delegate = self;
        [nav pushViewController:controller animated:YES];
        [controller release];
    }
}

#pragma mark - FeedbackViewControllerDelegate

- (void)feedbackViewControllerCancelled:(FeedbackViewController *)controller
{
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav popViewControllerAnimated:YES];
}

@end
