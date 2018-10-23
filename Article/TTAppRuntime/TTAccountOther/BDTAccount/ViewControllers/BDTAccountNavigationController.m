//
//  BDTAccountNavigationController.m
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import "BDTAccountNavigationController.h"
#import <UIColor+TTThemeExtension.h>


@interface BDTAccountNavigationController ()

@end

@implementation BDTAccountNavigationController

- (TTAccountLoginAnimationDelegate *)animationDelegate
{
    if (!_animationDelegate) {
        _animationDelegate = [[TTAccountLoginAnimationDelegate alloc] init];
    }
    return _animationDelegate;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:nil toolbarClass:nil];
    if (self) {
        self.viewControllers = @[rootViewController];
        self.navigationBar.shadowImage = [[UIImage alloc] init];
        self.ttNavBarStyle = @"Image";
        self.view.clipsToBounds = YES;
        self.view.layer.cornerRadius = 5;
                self.animationDelegate.viewController = self;
        if ([TTNavigationController refactorNaviEnabled]) {
            rootViewController.ttNeedHideBottomLine = YES;
            rootViewController.ttNeedTopExpand = NO;
            rootViewController.ttNaviTranslucent = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground15];
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

- (void)dismissWithAnimation
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (CGFloat)topEdgeInsetScreenMargin
{
    return 20.f;
}

@end
