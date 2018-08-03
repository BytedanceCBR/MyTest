//
//  TTLoginAnimation.m
//  Article
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTLoginAnimation.h"

static UITapGestureRecognizer *tt_tapGestureRecognizer = nil;
// MARK: - TTLoginAnimationDelegate 代理
@implementation TTLoginAnimationDelegate

- (void)setViewController:(UINavigationController *)viewController {
    _viewController = viewController;
    if (_viewController != nil) {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ttAnimationPan:)];
        [_viewController.view addGestureRecognizer:panRecognizer];
        _viewController.transitioningDelegate = self;
        _viewController.delegate = self;
    }
}

+ (UITapGestureRecognizer *)tapGestureRecognizer {
    return tt_tapGestureRecognizer;
}

+ (void)setTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    tt_tapGestureRecognizer = tapGestureRecognizer;
}

+ (instancetype)shareDelegate {
    static TTLoginAnimationDelegate *ttLoginAnimationDelegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ttLoginAnimationDelegate = [[TTLoginAnimationDelegate alloc] init];
    });
    return ttLoginAnimationDelegate;
}

- (void)ttAnimationPan:(UIPanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].y / recognizer.view.height;
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

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    TTLoginPresentAnimation *loginPresentAnimation = [[TTLoginPresentAnimation alloc] init];
    if (self.type != TTLoginPresentTypeDefault) {
        loginPresentAnimation.type = self.type;
    }
    return [[TTLoginPresentAnimation alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[TTLoginDismissAnimation alloc] init];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactionController;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    switch (operation) {
        case UINavigationControllerOperationPush:
            return [[TTLoginPushAnimation alloc] init];
            break;
        case UINavigationControllerOperationPop:
            return [[TTLoginPopAnimation alloc] init];
            break;
        case UINavigationControllerOperationNone:
            break;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return self.interactionController;
}

@end

@interface TTLoginPresentAnimation()
@end
// MARK: - TTLoginPresentAnimation present动画
@implementation TTLoginPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect startFrame = bounds;
    CGFloat heightToTopMargin = 20.f;
    
    startFrame.origin.y = bounds.size.height + (heightToTopMargin - 10);
    startFrame.size.height -= (heightToTopMargin - 10);
    toViewController.view.frame = startFrame;
    
    CGRect endFrame = startFrame;
    endFrame.origin.y = heightToTopMargin;
    
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]  delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^() {
        toViewController.view.frame = endFrame;
        fromViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [containerView insertSubview:fromViewController.view belowSubview:toViewController.view];
            [TTLoginAnimationDelegate setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:toViewController action:NSSelectorFromString(@"dismissWithAnimation")]];
            fromViewController.view.userInteractionEnabled = YES;
            [fromViewController.view addGestureRecognizer:[TTLoginAnimationDelegate tapGestureRecognizer]];
        }
    }];
}

@end

// MARK: - TTLoginDismissAnimation dismiss动画
@implementation TTLoginDismissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewController.view.centerY = fromViewController.view.center.y + fromViewController.view.frame.size.height;
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
            [toViewController.view removeGestureRecognizer:[TTLoginAnimationDelegate tapGestureRecognizer]];
            TTLoginAnimationDelegate.tapGestureRecognizer = nil;
        }
    }];
}

@end

// MARK: - TTLoginPushAnimation push动画
@implementation TTLoginPushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect bounds = fromViewController.view.bounds;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(bounds.size.width, 0);
    [containerView addSubview:toViewController.view];
    
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

// MARK: - TTLoginPopAnimation pop动画
@implementation TTLoginPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect bounds = fromViewController.view.bounds;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(-bounds.size.width, 0);
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
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
