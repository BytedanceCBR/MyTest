//
//  UINavigationController+NavigationBarConfig.m
//  TestUniversaliOS6
//
//  Created by yuxin on 3/26/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "UINavigationController+NavigationBarConfig.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import "TTThemeManager.h"

@import ObjectiveC;

@interface UINavigationController ()

@property (nonatomic, copy) NSString * ttNavBarStyle;


@end

@implementation UINavigationController (NavigationBarConfig)


- (NSString*)ttDefaultNavBarStyle {
    
    return (NSString*)objc_getAssociatedObject(self, @selector(ttDefaultNavBarStyle));
}

- (void)setTtDefaultNavBarStyle:(NSString *)ttNavBarStyle {
    
    objc_setAssociatedObject(self, @selector(ttDefaultNavBarStyle),ttNavBarStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)ttNavBarStyle {
    
    return (NSString*)objc_getAssociatedObject(self, @selector(ttNavBarStyle));
}

- (void)setTtNavBarStyle:(NSString *)ttNavBarStyle {
    
    objc_setAssociatedObject(self, @selector(ttNavBarStyle),ttNavBarStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self tt_configNavBarWithTheme:ttNavBarStyle];

}

- (BOOL)isPop {
    
    return [(NSNumber*)objc_getAssociatedObject(self, @selector(isPop)) boolValue];
}

- (void)setIsPop:(BOOL)isPop{
    
    objc_setAssociatedObject(self, @selector(isPop),@(isPop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)tt_reloadTheme
{
    [self tt_configNavBarWithTheme:self.ttNavBarStyle];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        if (self.topViewController.view.window) {
            if (self.topViewController.ttStatusBarStyle) {
                [[UIApplication sharedApplication] setStatusBarStyle:self.topViewController.ttStatusBarStyle animated:YES];
            }
            else {
                [[UIApplication sharedApplication] setStatusBarStyle:[[TTThemeManager sharedInstance_tt] statusBarStyle] animated:YES];

            }
            
        }
    }
    
    
}

- (void)tt_configNavBarWithTheme:(NSString *)style
{
    self.navigationBar.translucent =  YES;
    
    if (!style) {
        if (self.ttDefaultNavBarStyle) {
            style = self.ttDefaultNavBarStyle;
        }
        else
            return;
    }
    
    //title 的文字颜色
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16],NSForegroundColorAttributeName: [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@",style]] ?: [UIColor blackColor]};
    
  
        
    //如果是背景图 就用图 否则用颜色
    if (![style isEqualToString:@"Image"] && [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]]) {
        
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];

        if (!self.isPop) {
            [self.navigationBar setBarTintColor: [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]]];

            //这个是左右控件 如果是plain text的，把文本颜色改成我们需要的
            [self.navigationBar setTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@",style]] ?: [UIColor blackColor]];
            
        }
        else {
            [[self transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

                [self.navigationBar setBarTintColor: [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]] ?: [UIColor whiteColor]];
                
                //这个是左右控件 如果是plain text的，把文本颜色改成我们需要的
                [self.navigationBar setTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@",style]] ?: [UIColor blackColor]];
                
                
            } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
                if (![context isCancelled]) {
                    [self.navigationBar setBarTintColor: [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]] ?: [UIColor whiteColor]];
                    
                    //这个是左右控件 如果是plain text的，把文本颜色改成我们需要的
                    [self.navigationBar setTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@",style]] ?: [UIColor blackColor]];
                }
               
                
            }];

        }
    }
    else{
        
        [self.navigationBar setBarTintColor:nil];
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];

        if([style isEqualToString:@"Image"]) {
            if ([UIImage tt_themedImageForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]]) {
            
                [self.navigationBar setBackgroundImage:[UIImage tt_themedImageForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]] forBarMetrics:UIBarMetricsDefault];
            }
        }

    }

    
   
}

@end
