//
//  TTAccountNavigationController.m
//  Article
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTAccountNavigationController.h"
#import "TTAccountNavigationBar.h"

@implementation TTAccountNavigationController

- (TTLoginAnimationDelegate *)animationDelegate {
    if (_animationDelegate == nil) {
        _animationDelegate = [[TTLoginAnimationDelegate alloc] init];
    }
    return _animationDelegate;
}

//var originFrame: CGRect!

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    if ([TTNavigationController refactorNaviEnabled]) {
        viewController.ttNeedHideBottomLine = YES;
        viewController.ttNeedTopExpand = NO;
        viewController.ttNaviTranslucent = YES;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.view.frame;
    frame.origin.y = 20;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - 10;
    self.view.frame = frame;
}

- (void)dismissWithAnimation {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
