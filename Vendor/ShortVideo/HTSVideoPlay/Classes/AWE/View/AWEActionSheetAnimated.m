//
//  TTActionSheetAnimated.m
//  Article
//
//  Created by zhaoqin on 8/31/16.
//
//
#import "TTDeviceHelper.h"
#import "AWEActionSheetAnimated.h"
#import "AWEActionSheetConst.h"
#import "AWEActionSheetTableController.h"

@interface AWEActionSheetAnimated ()
@property (nonatomic, assign) AWEActionSheetTransitionType type;
@end

@implementation AWEActionSheetAnimated

+ (instancetype)transitionWithTransitionType:(AWEActionSheetTransitionType)type {
    return [[AWEActionSheetAnimated alloc] initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(AWEActionSheetTransitionType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return AWEActionSheetAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch (self.type) {
        case AWEActionSheetTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
        case AWEActionSheetTransitionTypeDismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    //下一级viewController
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //当前viewController
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect navRect = fromViewController.navigationController.view.frame;
    navRect.origin.y += navRect.size.height;
    fromViewController.navigationController.view.frame = navRect;
    
    fromViewController.navigationController.view.alpha = 1.0f;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect navRect = toViewController.navigationController.view.frame;
        navRect.origin.y -= navRect.size.height;
        toViewController.navigationController.view.frame = navRect;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    AWEActionSheetTableController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect navRect = fromViewController.navigationController.view.frame;
    navRect.origin.y += navRect.size.height;
    fromViewController.navigationController.view.frame = navRect;
    
    fromViewController.navigationController.view.alpha = 1.0f;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat temp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = temp;
        }
        
        CGRect navRect = fromViewController.navigationController.view.frame;
        navRect.size.height = toViewController.viewHeight + 54;
        navRect.origin.y = screenHeight - navRect.size.height;
        toViewController.navigationController.view.frame = navRect;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
