//
//  TTModalInsideNavigationController.m
//  Article
//
//  Created by muhuai on 2017/4/7.
//
//

#import "TTModalInsideNavigationController.h"
#import "TTModalWrapController.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>

@interface TTModalInsideNavigationController ()<TTModalWrapControllerDelegate>

@end

@implementation TTModalInsideNavigationController

//var originFrame: CGRect!

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        rootViewController.ttNeedHideBottomLine = NO;
        rootViewController.ttNeedTopExpand = NO;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *containerVC;
    //如果viewController没有实现@protocol TTModalWrapControllerProtocol 则尝试用 上一层navi打开
    if ([viewController conformsToProtocol:@protocol(TTModalWrapControllerProtocol) ]) {
        containerVC = [[TTModalWrapController alloc] initWithController:(UIViewController<TTModalWrapControllerProtocol> *)viewController];
        TTModalControllerTitleView *titleView = ((TTModalWrapController *)containerVC).titleView;
        if ([viewController respondsToSelector:@selector(leftBarItemStyle)]) {
            titleView.type = [(UIViewController<TTModalWrapControllerProtocol> *)viewController leftBarItemStyle];
        } else {
            titleView.type = self.viewControllers.count? TTModalControllerTitleTypeOnlyBack: TTModalControllerTitleTypeOnlyClose;
        }
        if ([viewController respondsToSelector:@selector(hiddenTitleViewBottomLineInModalContainer)]) {
            titleView.hiddenBottomLine = [(UIViewController<TTModalWrapControllerProtocol> *)viewController hiddenTitleViewBottomLineInModalContainer];
        }
        
        ((TTModalWrapController *)containerVC).delegate = self;
        [super pushViewController:containerVC animated:animated];
        containerVC.ttNeedHideBottomLine = NO;
        containerVC.ttNeedTopExpand = NO;
        return;
    }
    
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:animated];
        return;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count > 1) {
        return [super popViewControllerAnimated:animated];
    } else {
        [self modalWrapController:self closeButtonOnClick:nil];
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(6.f, 6.f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
}

- (void)modalWrapController:(TTModalWrapController *)controller backButtonOnClick:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)modalWrapController:(TTModalWrapController *)controller closeButtonOnClick:(id)sender {
    if ([self.modalNavigationDelegate respondsToSelector:@selector(modalInsideNavigationController:closeButtonOnClick:)]) {
        [self.modalNavigationDelegate modalInsideNavigationController:self closeButtonOnClick:sender];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)modalWrapController:(TTModalWrapController *)controller panAtPercent:(CGFloat)percent {
    if ([self.modalNavigationDelegate respondsToSelector:@selector(modalInsideNavigationController:panAtPercent:)]) {
        [self.modalNavigationDelegate modalInsideNavigationController:self panAtPercent:percent];
    }
}
@end
