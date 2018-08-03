//
//  TTAccountNavigationController.m
//  TTAccountLogin
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTAccountNavigationController.h"
#import "TTAccountNavigationBar.h"
#import <TTDeviceHelper.h>



@implementation TTAccountNavigationController

- (TTAccountLoginAnimationDelegate *)animationDelegate
{
    if (!_animationDelegate) {
        _animationDelegate = [[TTAccountLoginAnimationDelegate alloc] init];
    }
    return _animationDelegate;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:[TTAccountNavigationBar class] toolbarClass:nil];
    if (self) {
        self.viewControllers = @[rootViewController];
        self.animationDelegate.viewController = self;
        self.navigationBar.shadowImage = [[UIImage alloc] init];
        self.ttNavBarStyle = @"Image";
        self.view.clipsToBounds = YES;
        self.view.layer.cornerRadius = 5;
        if ([TTNavigationController refactorNaviEnabled]) {
            rootViewController.ttNeedHideBottomLine = YES;
            rootViewController.ttNeedTopExpand = NO;
            rootViewController.ttNaviTranslucent = YES;
        }
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    if ([TTNavigationController refactorNaviEnabled]) {
        viewController.ttNeedHideBottomLine = YES;
        viewController.ttNeedTopExpand = NO;
        viewController.ttNaviTranslucent = YES;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat additionalSafeInsetTop = [self.class heightToScreenTopMargin];
    if ([TTDeviceHelper OSVersionNumber] >= 11.0f &&
        [self respondsToSelector:@selector(additionalSafeAreaInsets)]) {
        if ([TTDeviceHelper isIPhoneXDevice]) {
            additionalSafeInsetTop = 44.f;
        }
    }
    
    CGRect frame = self.view.frame;
    frame.origin.y = additionalSafeInsetTop;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - (additionalSafeInsetTop - 10.f);
    self.view.frame = frame;
}

- (void)dismissWithAnimation
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  导航栏距离屏幕上边缘的间距
 */
+ (CGFloat)heightToScreenTopMargin
{
    return 20.f;
}

@end
