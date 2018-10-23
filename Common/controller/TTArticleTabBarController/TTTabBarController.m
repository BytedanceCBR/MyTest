//
//  TTTabBarController.m
//  TestUniversaliOS6
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTTabBarController.h"
#import "UITabBarController+TabbarConfig.h"
#import "TTThemeManager.h"
#import "TTTabbar.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>

NSString * const kTTTabBarSelectedIndexChangedNotification = @"kTTTabBarSelectedIndexChangedNotification";

@interface TTTabBarController () <UITabBarControllerDelegate>

@end

@implementation TTTabBarController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 接管delegate
    self.delegate = self;
    UIEdgeInsets safeInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets;
    self.tabbarHeight = [TTDeviceHelper isIPhoneXDevice] ? (safeInset.bottom + 49.f) : 49.f;

    //[self initTabbarBadge];
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    if (CGAffineTransformIsIdentity(self.view.transform)) {
//        UIEdgeInsets safeInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets;
//        self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - self.tabbarHeight - safeInset.bottom, self.view.frame.size.width, self.tabbarHeight + safeInset.bottom);
//    }
//}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)vc
{
    if(self.lastSelectedIndex != self.selectedIndex) {
        (((TTTabbar *)self.tabBar).tabItems)[self.lastSelectedIndex].ttBadgeView.badgeViewStyle = (((TTTabbar *)self.tabBar).tabItems)[self.lastSelectedIndex].ttBadgeView.lastBadgeViewStyle;
        (((TTTabbar *)self.tabBar).tabItems)[self.selectedIndex].ttBadgeView.badgeViewStyle = TTBadgeNumberViewStyleDefaultWithBorder;
        self.lastSelectedIndex = self.selectedIndex;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTTabBarSelectedIndexChangedNotification object:nil userInfo:@{@"index":@(self.selectedIndex)}];
    } else {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)vc popToRootViewControllerAnimated:YES];
        }
    }
}

// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return;
    
    // get a frame calculation ready
    CGRect frame = self.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion(finished);
        }
        
    }];
    
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}
@end
