//
//  TSVTabManager.m
//  Article
//
//  Created by 邱鑫玥 on 2017/9/26.
//

#import "TSVTabManager.h"
#import "TSVMonitorManager.h"
#import "TTHTSTabViewController.h"
#import "TSVStartupTabManager.h"
#import "TSVTabViewController.h"
#import "SSCommonLogic.h"
#import "TTTabBarManager.h"

@interface TSVTabManager()

@property (nonatomic, assign, readwrite) BOOL inShortVideoTab;

@end

@implementation TSVTabManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static TSVTabManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TSVTabManager alloc] init];
    });
    return manager;
}

#pragma mark -
- (void)enterOrLeaveShortVideoTabWithLastViewController:(UIViewController *)lastViewController currentViewController:(UIViewController *)currentViewController
{
    if (lastViewController == currentViewController) {
        return;
    }
    
    if ([self isShortVideoTabForViewController:lastViewController]) {
        self.inShortVideoTab = NO;
        [[TSVMonitorManager sharedManager] didLeaveShortVideoTab];
        [TSVStartupTabManager sharedManager].inShortVideoTabViewController = NO;
    } else if ([self isShortVideoTabForViewController:currentViewController]) {
        self.inShortVideoTab = YES;
        [[TSVMonitorManager sharedManager] didEnterShortVideoTab];
        [TSVStartupTabManager sharedManager].inShortVideoTabViewController = YES;
    }
}

- (BOOL)isShortVideoTabForViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[TTHTSTabViewController class]] || [viewController isKindOfClass:[TSVTabViewController class]]) {
        return YES;
    }
    return NO;
}

- (NSInteger)indexOfShortVideoTab
{
    if ([[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:kTTTabHTSTabKey]) {
        return [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabHTSTabKey];
    }
    return NSNotFound;
}


@end
