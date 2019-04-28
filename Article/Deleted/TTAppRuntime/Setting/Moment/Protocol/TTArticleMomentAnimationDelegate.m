//
//  TTArticleMomentAnimationDelegate.m
//  Article
//
//  Created by zhaoqin on 26/12/2016.
//
//

#import "TTArticleMomentAnimationDelegate.h"

static UITapGestureRecognizer *tt_tapGestureRecognizer = nil;
// MARK: - TTMomentAnimationDelegate 代理

@interface TTArticleMomentAnimationDelegate ()
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@end

@implementation TTArticleMomentAnimationDelegate

- (void)setViewController:(UINavigationController *)viewController {
    _viewController = viewController;
    if (_viewController != nil) {
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ttAnimationPan:)];
//        [_viewController.view addGestureRecognizer:_panRecognizer];
//        _viewController.transitioningDelegate = self;
//        _viewController.delegate = self;
    }
}

- (void)addGesture {
    [self.viewController.view addGestureRecognizer:self.panRecognizer];
}

- (void)removeGesture {
    [self.viewController.view removeGestureRecognizer:self.panRecognizer];
}

+ (UITapGestureRecognizer *)tapGestureRecognizer {
    return tt_tapGestureRecognizer;
}

+ (void)setTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    tt_tapGestureRecognizer = tapGestureRecognizer;
}

+ (instancetype)shareDelegate {
    static TTArticleMomentAnimationDelegate *ttMomentAnimationDelegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ttMomentAnimationDelegate = [[TTArticleMomentAnimationDelegate alloc] init];
    });
    return ttMomentAnimationDelegate;
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
    return [[TTMomentPresentAnimation alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[TTMomentDismissAnimation alloc] init];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactionController;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    switch (operation) {
            case UINavigationControllerOperationPush:
            return [[TTMomentPushAnimation alloc] init];
            break;
            case UINavigationControllerOperationPop:
            return [[TTMomentPopAnimation alloc] init];
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

// MARK: - TTMomentPresentAnimation present动画
@implementation TTMomentPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect startFrame = bounds;
    
    startFrame.origin.y = bounds.size.height;
    toViewController.view.frame = startFrame;
    
    CGRect endFrame = startFrame;
    endFrame.origin.y = 0;
    
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]  delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^() {
        toViewController.view.frame = endFrame;
        fromViewController.view.transform = CGAffineTransformMakeScale(0.91, 0.91);
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [containerView insertSubview:fromViewController.view belowSubview:toViewController.view];
            [TTArticleMomentAnimationDelegate setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:toViewController action:NSSelectorFromString(@"dismissWithAnimation")]];
            fromViewController.view.userInteractionEnabled = YES;
            [fromViewController.view addGestureRecognizer:[TTArticleMomentAnimationDelegate tapGestureRecognizer]];
        }
    }];
}

@end

//# MARK: - TTMomentDismissAnimation dismiss动画
@implementation TTMomentDismissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewController.view.centerY = fromViewController.view.center.y + fromViewController.view.frame.size.height;
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            [toViewController.view removeGestureRecognizer:[TTArticleMomentAnimationDelegate tapGestureRecognizer]];
            TTArticleMomentAnimationDelegate.tapGestureRecognizer = nil;
        }
    }];
}

@end

// MARK: - TTMomentPushAnimation push动画
@implementation TTMomentPushAnimation

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

// MARK: - TTMomentPopAnimation pop动画
@implementation TTMomentPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect bounds = fromViewController.view.bounds;
    
//    fromViewController.ttHideNavigationBar = YES;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(-bounds.size.width, 0);
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(bounds.size.width, 0);
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
//        toViewController.ttHideNavigationBar = NO;
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
