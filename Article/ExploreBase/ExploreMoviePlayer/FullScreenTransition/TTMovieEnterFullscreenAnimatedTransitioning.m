//
//  TTMovieLandscapeTransitionDelegate.m
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import "TTMovieEnterFullscreenAnimatedTransitioning.h"
#import "TTMovieFullscreenViewController.h"



NSString *const TTMovieDidEnterFullscreenNotification = @"TTMovieDidEnterFullscreenNotification";

static const NSTimeInterval kFullScreenChangeAnimationTime = 0.3f;

@interface TTMovieEnterFullscreenAnimatedTransitioning()

@property (nonatomic, weak) UIView<TTMovieFullscreenProtocol> *smallMovieView;

@end


@implementation TTMovieEnterFullscreenAnimatedTransitioning

- (instancetype)initWithSmallMovieView:(UIView<TTMovieFullscreenProtocol> *)movieView {
    self = [super init];
    if (self) {
        _smallMovieView = movieView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *presentedViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([presentedViewController isKindOfClass:[TTMovieFullscreenViewController class]]) {
        TTMovieFullscreenViewController *fullscreenViewController = (TTMovieFullscreenViewController *)presentedViewController;
        return fullscreenViewController.animatedDuringTransition ? kFullScreenChangeAnimationTime : 0.0;
    }
    return 0.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *presentedViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (![presentedViewController isKindOfClass:[TTMovieFullscreenViewController class]]) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    if (!presentedViewController.isBeingPresented) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    UIView *presentedView = nil;
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        presentedView = presentedViewController.view;
    }
    else {
        presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    
    TTMovieFullscreenViewController *fullscreenViewController = (TTMovieFullscreenViewController *)presentedViewController;
    CGRect smallMovieFrame = [[transitionContext containerView] convertRect:self.smallMovieView.bounds fromView:self.smallMovieView];
    fullscreenViewController.exploreMovieView = self.smallMovieView;
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        /**
         *  iOS7中，屏幕旋转后，window.size不会变化，整个presentedView需要手工旋转
         */
        CGFloat rotationRadianBeforePresented = [TTMovieFullscreenViewController rotationRadianForInterfaceOrienationIniOS7:fullscreenViewController.orientationBeforePresented];
        CGFloat rotationRadianAfterPresented = [TTMovieFullscreenViewController rotationRadianForInterfaceOrienationIniOS7:fullscreenViewController.orientationAfterPresented];
        
        CGRect presentedViewBoundsBeforePresented = self.smallMovieView.bounds;
        CGRect presentedViewBoundsAfterPresented = [TTMovieFullscreenViewController windowBoundsForInterfaceOrientationIniOS7:fullscreenViewController.orientationAfterPresented];
        
        CGPoint centerBeforePresented = CGPointMake(CGRectGetMidX(smallMovieFrame), CGRectGetMidY(smallMovieFrame));
        CGPoint centerAfterPresented = [transitionContext containerView].center;
        
        presentedView.bounds = presentedViewBoundsBeforePresented;
        presentedView.transform = CGAffineTransformMakeRotation(rotationRadianBeforePresented);
        presentedView.center = centerBeforePresented;
        
        self.smallMovieView.frame = presentedView.bounds;
        [presentedView addSubview:self.smallMovieView];
        [[transitionContext containerView] addSubview:presentedView];
        
        if ([transitionContext isAnimated]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:YES] }];
            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                  delay:0.0
                                options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 presentedView.bounds = presentedViewBoundsAfterPresented;
                                 presentedView.transform = CGAffineTransformMakeRotation(rotationRadianAfterPresented);
                                 presentedView.center = centerAfterPresented;
                             }
                             completion:^(BOOL finished) {
                                 [transitionContext completeTransition:YES];
                                 [self p_postEnterFullScreenNoti];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:NO]}];
                             }];
        }
        else {
            presentedView.bounds = presentedViewBoundsAfterPresented;
            presentedView.transform = CGAffineTransformMakeRotation(rotationRadianAfterPresented);
            presentedView.center = centerAfterPresented;
            [transitionContext completeTransition:YES];
            [self p_postEnterFullScreenNoti];
        }
    }
    else {
        
        CGFloat rotationRadianBeforePresented = 0;
        CGRect presentedViewBoundsBeforePresented = self.smallMovieView.bounds;
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
        
        self.smallMovieView.frame = presentedView.bounds;
        [presentedView addSubview:self.smallMovieView];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:TTMovieDidEnterFullscreenNotification object:nil];
}

@end
