//
//  TTAccountLoginAnimation.m
//  TTAccountLogin
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTAccountLoginAnimation.h"
#import <UIViewAdditions.h>
#import <TTDeviceHelper.h>
#import <objc/runtime.h>



static UIView *snapshotViewFromView(UIView *sourceView)
{
    if (sourceView.superview && sourceView.window && ([TTDeviceHelper OSVersionNumber] >= 8)) {
        UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, YES, [UIScreen mainScreen].scale);
        // afterScreenUpdates:YES会导致页面H5动画不流畅
        [sourceView drawViewHierarchyInRect:sourceView.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:sourceView.bounds];
        imageView.image = image;
        return imageView;
    }
    // afterScreenUpdates:YES会导致页面H5动画不流畅
    UIView *snapshotView = [sourceView snapshotViewAfterScreenUpdates:NO];
    return snapshotView;
}



@interface UIView (AccountUISnapshotView)

@property (nonatomic, strong) UIView *account_snapchatView;
@property (nonatomic, strong) UIView *account_dim_backView;

@end

@implementation UIView (AccountUISnapshotView)

- (void)setAccount_snapchatView:(UIView *)view
{
    objc_setAssociatedObject(self, @selector(account_snapchatView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)account_snapchatView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAccount_dim_backView:(UIView *)view
{
    objc_setAssociatedObject(self, @selector(account_dim_backView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)account_dim_backView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end



static UITapGestureRecognizer *tt_tapGestureRecognizer = nil;

@implementation TTAccountLoginAnimationDelegate

+ (instancetype)sharedDelegate
{
    static TTAccountLoginAnimationDelegate *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[TTAccountLoginAnimationDelegate alloc] init];
    });
    return sharedInst;
}

- (void)setViewController:(UINavigationController *)viewController
{
    _viewController = viewController;
    if (_viewController != nil) {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ttAnimationPan:)];
        [_viewController.view addGestureRecognizer:panRecognizer];
        _viewController.transitioningDelegate = self;
        _viewController.delegate = self;
    }
}

+ (UITapGestureRecognizer *)tapGestureRecognizer
{
    return tt_tapGestureRecognizer;
}

+ (void)setTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    tt_tapGestureRecognizer = tapGestureRecognizer;
}

- (void)ttAnimationPan:(UIPanGestureRecognizer *)recognizer
{
    CGFloat progress = [recognizer translationInView:recognizer.view].y / recognizer.view.frame.size.height;
    if (progress > 1) { progress = 1; }
    if (progress < 0) { progress = 0; }
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        [self.interactionController updateInteractiveTransition:progress];
    } else if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled) {
        CGFloat vy = [recognizer velocityInView:recognizer.view].y;
        BOOL complete = ((vy > -100 && progress > 0.3) || vy > 500);
        if (complete) {
            [self.interactionController finishInteractiveTransition];
        } else {
            [self.interactionController cancelInteractiveTransition];
        }
        self.interactionController = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TTAccountLoginPresentAnimation *loginPresentAnimation = [[TTAccountLoginPresentAnimation alloc] init];
    if (self.type != TTAccountLoginPresentAnimationTypeDefault) {
        loginPresentAnimation.type = self.type;
    }
    return [[TTAccountLoginPresentAnimation alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[TTAccountLoginDismissAnimation alloc] init];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactionController;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    switch (operation) {
        case UINavigationControllerOperationPush:
            return [[TTAccountLoginPushAnimation alloc] init];
            break;
        case UINavigationControllerOperationPop:
            return [[TTAccountLoginPopAnimation alloc] init];
            break;
        case UINavigationControllerOperationNone:
            break;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactionController;
}

@end



@implementation TTAccountLoginPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect startFrame = bounds;
    CGFloat additionalSafeInsetTop = 20;
    
    if ([TTDeviceHelper OSVersionNumber] >= 11.0f &&
        [fromViewController.view respondsToSelector:@selector(safeAreaInsets)]) {
        additionalSafeInsetTop = fromViewController.view.safeAreaInsets.top;
    }
    
    startFrame.origin.y = bounds.size.height + (additionalSafeInsetTop - 10);
    startFrame.size.height -= (additionalSafeInsetTop - 10);
    toViewController.view.frame = startFrame;
    
    CGRect endFrame = startFrame;
    endFrame.origin.y = additionalSafeInsetTop;
    
    UIView *containerView = nil;
    if ([TTDeviceHelper OSVersionNumber] >= 8.0f) {
        containerView = [transitionContext containerView];
        if ([containerView isKindOfClass:[UIView class]]) {
            [containerView addSubview:toViewController.view];
        }
    }
    
    UIView *dimBackView = containerView.account_dim_backView;
    if (!dimBackView) {
        dimBackView = [[UIView alloc] initWithFrame:fromViewController.view.bounds];
        dimBackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    dimBackView.alpha = 0;
    [containerView insertSubview:dimBackView belowSubview:toViewController.view];
    containerView.account_dim_backView = dimBackView;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]  delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^() {
        dimBackView.alpha = 1;
        toViewController.view.frame = endFrame;
        fromViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            UIView *fromView = snapshotViewFromView(fromViewController.view) ? : fromViewController.view;
            [transitionContext completeTransition:YES];
            
            if ([containerView isKindOfClass:[UIView class]]) {
                containerView.account_snapchatView = fromView;
                [containerView insertSubview:fromView belowSubview:containerView.account_dim_backView];
            }
            
            [TTAccountLoginAnimationDelegate setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:toViewController action:NSSelectorFromString(@"dismissWithAnimation")]];
            fromViewController.view.userInteractionEnabled = YES;
            [fromViewController.view addGestureRecognizer:[TTAccountLoginAnimationDelegate tapGestureRecognizer]];
        }
    }];
}

@end




@implementation TTAccountLoginDismissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = nil;
    if ([TTDeviceHelper OSVersionNumber] >= 8.0f) {
        containerView = [transitionContext containerView];
        if ([containerView isKindOfClass:[UIView class]]) {
            [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        }
        [containerView insertSubview:containerView.account_dim_backView belowSubview:fromViewController.view];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewController.view.centerY = fromViewController.view.center.y + fromViewController.view.frame.size.height;
        toViewController.view.transform = CGAffineTransformIdentity;
        containerView.account_dim_backView.alpha = 0;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
            [toViewController.view removeFromSuperview];
        } else {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
            [containerView.account_snapchatView removeFromSuperview];
            [containerView.account_dim_backView removeFromSuperview];
            [toViewController.view removeGestureRecognizer:[TTAccountLoginAnimationDelegate tapGestureRecognizer]];
            TTAccountLoginAnimationDelegate.tapGestureRecognizer = nil;
        }
    }];
}

@end



@implementation TTAccountLoginPushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect bounds = fromViewController.view.bounds;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(bounds.size.width, 0);
    
    UIView *containerView = nil;
    if ([TTDeviceHelper OSVersionNumber] >= 8.0f) {
        containerView = [transitionContext containerView];
        if ([containerView isKindOfClass:[UIView class]]) {
            [containerView addSubview:toViewController.view];
        }
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(-bounds.size.width, 0);
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
            fromViewController.view.transform = CGAffineTransformIdentity;
        }
    }];
}

@end



@implementation TTAccountLoginPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect bounds = fromViewController.view.bounds;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(-bounds.size.width, 0);
    
    if ([TTDeviceHelper OSVersionNumber] >= 8.0f) {
        UIView *containerView = [transitionContext containerView];
        if ([containerView isKindOfClass:[UIView class]]) {
            [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        }
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(bounds.size.width, 0);
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
            fromViewController.view.transform = CGAffineTransformIdentity;
        }
    }];
}

@end
