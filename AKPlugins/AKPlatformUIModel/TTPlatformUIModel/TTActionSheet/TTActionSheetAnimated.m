//
//  TTActionSheetAnimated.m
//  Article
//
//  Created by zhaoqin on 8/31/16.
//
//

#import "TTActionSheetAnimated.h"
#import "TTActionSheetConst.h"
#import "TTActionSheetTableController.h"
#import "TTDeviceHelper.h"
#import "TTActionSheetConst.h"
#import "TTDeviceUIUtils.h"

@interface TTActionSheetAnimated ()
@property (nonatomic, assign) TTActionSheetTransitionType type;
@end

@implementation TTActionSheetAnimated

+ (instancetype)transitionWithTransitionType:(TTActionSheetTransitionType)type {
    return [[TTActionSheetAnimated alloc] initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(TTActionSheetTransitionType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return TTActionSheetAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch (self.type) {
        case TTActionSheetTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
        case TTActionSheetTransitionTypeDismiss:
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
    
    TTActionSheetTableController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
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
        navRect.size.height = toViewController.viewHeight + TTActionSheetNavigationBarHeight;
        navRect.origin.y = screenHeight - navRect.size.height;
        toViewController.navigationController.view.frame = navRect;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
