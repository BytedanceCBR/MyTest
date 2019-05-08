//
//  TTMovieLandscapeTransitionDelegate.m
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import "TTVEnterFullscreenAnimatedTransitioning.h"
#import "TTVFullscreenViewController.h"
#import "TTDeviceHelper.h"


NSString *const TTVPlayerDidEnterFullscreenNotification = @"TTVPlayerDidEnterFullscreenNotification";

static const NSTimeInterval kFullScreenChangeAnimationTime = 0.3f;

@interface TTVEnterFullscreenAnimatedTransitioning()

@property (nonatomic, weak) UIView *movieView;

@end


@implementation TTVEnterFullscreenAnimatedTransitioning

- (instancetype)initWithMovieView:(UIView *)movieView {
    self = [super init];
    if (self) {
        _movieView = movieView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *presentedViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([presentedViewController isKindOfClass:[TTVFullscreenViewController class]]) {
        TTVFullscreenViewController *fullscreenViewController = (TTVFullscreenViewController *)presentedViewController;
        return fullscreenViewController.animatedDuringTransition ? kFullScreenChangeAnimationTime : 0.0;
    }
    return 0.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *presentedViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (![presentedViewController isKindOfClass:[TTVFullscreenViewController class]]) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    if (!presentedViewController.isBeingPresented) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    TTVFullscreenViewController *fullscreenViewController = (TTVFullscreenViewController *)presentedViewController;
    CGRect smallMovieFrame = [[transitionContext containerView] convertRect:self.movieView.bounds fromView:self.movieView];

   {
        
        CGFloat rotationRadianBeforePresented = 0;
        CGRect presentedViewBoundsBeforePresented = self.movieView.bounds;
        CGPoint presentedViewCenterBeforePresented = CGPointMake(CGRectGetMidX(smallMovieFrame), CGRectGetMidY(smallMovieFrame));
        
        // 如果是从竖直转到横屏，则需要在转屏前先转一下presentedView
        if (fullscreenViewController.orientationBeforePresented == UIInterfaceOrientationPortrait
            && fullscreenViewController.orientationAfterPresented == UIInterfaceOrientationLandscapeLeft) {
            rotationRadianBeforePresented = M_PI_2;
        }
        else if (fullscreenViewController.orientationBeforePresented == UIInterfaceOrientationPortrait
                 && fullscreenViewController.orientationAfterPresented == UIInterfaceOrientationLandscapeRight) {
            rotationRadianBeforePresented = -M_PI_2;
        }
        
        presentedView.bounds = presentedViewBoundsBeforePresented;
        presentedView.transform = CGAffineTransformMakeRotation(rotationRadianBeforePresented);
        presentedView.center = presentedViewCenterBeforePresented;
        
        self.movieView.frame = presentedView.bounds;
        [presentedView addSubview:self.movieView];
        [[transitionContext containerView] addSubview:presentedView];
        
        CGRect presentedViewFinalFrame = [transitionContext finalFrameForViewController:fullscreenViewController];
        if ([transitionContext isAnimated]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:YES] }];
            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                  delay:0.0 options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 presentedView.transform = CGAffineTransformIdentity;
                                 presentedView.frame = presentedViewFinalFrame;
                             }
                             completion:^(BOOL finished) {
                                 [transitionContext completeTransition:YES];
                                 [self p_postEnterFullScreenNoti];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:NO] }];
                             }];
        }
        else {
            presentedView.transform = CGAffineTransformIdentity;
            presentedView.frame = presentedViewFinalFrame;
            [transitionContext completeTransition:YES];
            [self p_postEnterFullScreenNoti];
        }
    }
}

- (void)p_postEnterFullScreenNoti {
    [[NSNotificationCenter defaultCenter] postNotificationName:TTVPlayerDidEnterFullscreenNotification object:nil];
}

@end
