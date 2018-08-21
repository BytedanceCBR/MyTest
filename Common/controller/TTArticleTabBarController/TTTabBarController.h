//
//  TTTabBarController.h
//  TestUniversaliOS6
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

// 切换 Tab 后的通知，通知对象的 userInfo 描述当前选中的 index，@{@"index":@(selectedIndex)}
extern NSString * const kTTTabBarSelectedIndexChangedNotification;

@interface TTTabBarController : UITabBarController

@property (nonatomic,assign) NSUInteger lastSelectedIndex;

@property (nonatomic,assign) IBInspectable CGFloat tabbarHeight;

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)vc;

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion;

@end
