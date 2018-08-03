//
//  TTCustomAnimationNavigationController.m
//  Article
//
//  Created by 王双华 on 17/3/6.
//
//

#import "TTCustomAnimationNavigationController.h"

@interface TTCustomAnimationNavigationController ()

@end

@implementation TTCustomAnimationNavigationController

- (TTCustomAnimationDelegate *)animationDelegate
{
    if (!_animationDelegate) {
        _animationDelegate = [[TTCustomAnimationDelegate alloc] init];
    }
    return _animationDelegate;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController animationStyle:(TTCustomAnimationStyle)style {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.animationDelegate.viewController = self;
        self.animationDelegate.style = style;
    }
    return self;
}

- (void)setAnimationStyle:(TTCustomAnimationStyle)style
{
    self.animationDelegate.viewController = self;
    self.animationDelegate.style = style;
}

- (void)setTtNavBarStyle:(NSString *)ttNavBarStyle
{
    if (_useWhiteStyle) {
        [super setTtNavBarStyle:@"White"];
    } else {
        [super setTtNavBarStyle:ttNavBarStyle];
    }
}

@end
