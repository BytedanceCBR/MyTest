//
//  TTRNKitNavViewController.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/8.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRNKitNavViewController.h"

@interface TTRNKitNavViewController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation TTRNKitNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[self.navigationBar subviews] firstObject] setAlpha:0];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 11.0) {//针对iOS11的导航栏进行适配
        NSArray <UIView *> *subViews = [self.navigationBar subviews];
        if (subViews.count > 2) {
            [[subViews objectAtIndex:1] setAlpha:0];
            subViews[2].backgroundColor = [UIColor clearColor];
            for (UIView *view in subViews[0].subviews) {
                [view setAlpha:0];
            }
        }
        self.navigationBar.shadowImage = [[UIImage alloc]init];
        [self.navigationBar setBackgroundImage : [[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationBar.translucent = YES;
    
    __weak TTRNKitNavViewController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self setNavigationBarHidden:NO animated:NO];
    return [super popViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES ){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [self setNavigationBarHidden:NO animated:NO];
    [super pushViewController:viewController animated:animated];
}
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES ){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [self setNavigationBarHidden:NO animated:NO];
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [self setNavigationBarHidden:NO animated:NO];
    return [super popToViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}
#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( gestureRecognizer == self.interactivePopGestureRecognizer ){
        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0] ){
            return NO;
        }
    }
    [self setNavigationBarHidden:NO animated:NO];
    return YES;
}

@end
