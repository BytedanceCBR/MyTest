//
//  TTMovieExitFullscreenAnimatedTransitioning.m
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import "TTMovieExitFullscreenAnimatedTransitioning.h"
#import "TTMovieFullscreenViewController.h"

#import "ExploreMovieView.h"
#import "TTVFeedListCell.h"

NSString *const TTMovieDidExitFullscreenNotification = @"TTMovieDidExitFullscreenNotification";

static const NSTimeInterval kFullScreenChangeAnimationTime = 0.3f;

@interface TTMovieExitFullscreenAnimatedTransitioning ()

@property (nonatomic, weak) UIView<TTMovieFullscreenProtocol> *movieView;

@end

@implementation TTMovieExitFullscreenAnimatedTransitioning

- (instancetype)initWithFullscreenMovieView:(UIView<TTMovieFullscreenProtocol> *)movieView {
    self = [super init];
    if (self) {
        _movieView = movieView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *dismissingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([dismissingViewController isKindOfClass:[TTMovieFullscreenViewController class]]) {
        TTMovieFullscreenViewController *fullscreenViewController = (TTMovieFullscreenViewController *)dismissingViewController;
        return fullscreenViewController.animatedDuringTransition ? kFullScreenChangeAnimationTime : 0.0;
    }
    return 0.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *dismissingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (![dismissingViewController isKindOfClass:[TTMovieFullscreenViewController class]]) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    if (!dismissingViewController.isBeingDismissed) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    UIView *dismissingView = nil;
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        dismissingView = dismissingViewController.view;
    }
    else {
        dismissingView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    }
    
    //如果当前movieView没有superview，说明这个movieView已经被调过removeFromSuperview，所以不应该再被加到原先位置了
    if (![self.movieView superview]) {
        [dismissingView removeFromSuperview];
        [transitionContext completeTransition:YES];
        return;
    }
    
    CGRect smallMovieFrame = CGRectZero;
    BOOL canFindFatherView = NO;
    id videoCell = nil;
    if (self.movieView.hasMovieFatherCell) {
        if (self.movieView.movieFatherCellTableView && self.movieView.movieFatherCellIndexPath) {
            UITableViewCell *cell = [self.movieView.movieFatherCellTableView cellForRowAtIndexPath:self.movieView.movieFatherCellIndexPath]; // returns nil if cell is not visible or index path is out of range
            if (cell &&  [cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [cell isKindOfClass:[ExploreCellBase class]]) {
                videoCell = (ExploreCellBase<ExploreMovieViewCellProtocol> *)cell;
                smallMovieFrame = [[transitionContext containerView] convertRect:[videoCell movieViewFrameRect] fromView:videoCell];
                canFindFatherView = YES;
            }
            
            if (cell && [cell isKindOfClass:[TTVFeedListCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                videoCell = (TTVFeedListCell<TTVFeedPlayMovie> *)cell;
                smallMovieFrame = [[transitionContext containerView] convertRect:[videoCell cell_movieViewFrameRect] fromView:videoCell];
                canFindFatherView = YES;
            }
        }
    }
    else {
        if (self.movieView.movieFatherView) {
            smallMovieFrame = [[transitionContext containerView] convertRect:self.movieView.movieInFatherViewFrame fromView:self.movieView.movieFatherView];
            canFindFatherView = YES;
        }
    }
    
    if (!canFindFatherView) {
        [dismissingView removeFromSuperview];
        [self.movieView forceStoppingMovie];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
        [transitionContext completeTransition:YES];
        return;
    }
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        /**
         *  iOS7中，需要自行将dismissingView转到与当前statusBar一致的方向上
         */
        UIInterfaceOrientation interfaceOrientationAfterDismissed = [[UIApplication sharedApplication] statusBarOrientation];
        CGFloat rotationRadianAfterDismissed = [TTMovieFullscreenViewController rotationRadianForInterfaceOrienationIniOS7:interfaceOrientationAfterDismissed];
        CGRect boundsAfterDismissed = CGRectZero;
        if (self.movieView.hasMovieFatherCell) {
            boundsAfterDismissed = CGRectMake(0, 0, CGRectGetWidth([videoCell movieViewFrameRect]), CGRectGetHeight([videoCell movieViewFrameRect]));
        }
        else {
            boundsAfterDismissed = CGRectMake(0, 0, CGRectGetWidth(self.movieView.movieInFatherViewFrame), CGRectGetHeight(self.movieView.movieInFatherViewFrame));
        }
        CGPoint centerAfterDismissed = CGPointMake(CGRectGetMidX(smallMovieFrame), CGRectGetMidY(smallMovieFrame));
        
        if ([transitionContext isAnimated]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:YES] }];
            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                  delay:0.0
                                options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 dismissingView.bounds = boundsAfterDismissed;
                                 dismissingView.transform = CGAffineTransformMakeRotation(rotationRadianAfterDismissed);
                                 dismissingView.center = centerAfterDismissed;
                             }
                             completion:^(BOOL finished) {
                                 if (self.movieView.hasMovieFatherCell) {
                                     if (videoCell && [videoCell isKindOfClass:[TTVFeedListCell class]] && [videoCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                                         self.movieView.frame = [videoCell cell_movieViewFrameRect];
                                         [videoCell cell_attachMovieView:self.movieView];
                                         
                                     } else if (videoCell &&  [videoCell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [videoCell isKindOfClass:[ExploreCellBase class]]) {
                                         
                                         self.movieView.frame = [videoCell movieViewFrameRect];
                                         [videoCell attachMovieView:(ExploreMovieView *)self.movieView];
                                     }
                                 }
                                 else {
                                     self.movieView.frame = self.movieView.movieInFatherViewFrame;
                                     [self.movieView.movieFatherView addSubview:self.movieView];
                                 }
                                 [dismissingView removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                                 [self p_postExitFullScreenNoti];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:NO] }];
                             }];
        }
        else {
            dismissingView.bounds = boundsAfterDismissed;
            dismissingView.transform = CGAffineTransformMakeRotation(rotationRadianAfterDismissed);
            dismissingView.center = centerAfterDismissed;
            if (self.movieView.hasMovieFatherCell) {
                if (videoCell && [videoCell isKindOfClass:[TTVFeedListCell class]] && [videoCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                    self.movieView.frame = [videoCell cell_movieViewFrameRect];
                    [videoCell cell_attachMovieView:self.movieView];
                    
                } else if (videoCell &&  [videoCell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [videoCell isKindOfClass:[ExploreCellBase class]]) {
                    
                    self.movieView.frame = [videoCell movieViewFrameRect];
                    [videoCell attachMovieView:(ExploreMovieView *)self.movieView];
                }
            }
            else {
                self.movieView.frame = self.movieView.movieInFatherViewFrame;
                [self.movieView.movieFatherView addSubview:self.movieView];
            }
            [dismissingView removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self p_postExitFullScreenNoti];
        }
    }
    else {
        
        
        
        if ([transitionContext isAnimated]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:YES] }];

            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                  delay:0.0
                                options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 dismissingView.transform = CGAffineTransformIdentity;
                                 dismissingView.frame = smallMovieFrame;
                             }
                             completion:^(BOOL finished) {
                                 if (self.movieView.hasMovieFatherCell) {
                                     if (videoCell && [videoCell isKindOfClass:[TTVFeedListCell class]] && [videoCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                                         self.movieView.frame = [videoCell cell_movieViewFrameRect];
                                         [videoCell cell_attachMovieView:self.movieView];
                                         
                                     } else if (videoCell &&  [videoCell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [videoCell isKindOfClass:[ExploreCellBase class]]) {
                                         
                                         self.movieView.frame = [videoCell movieViewFrameRect];
                                         [videoCell attachMovieView:(ExploreMovieView *)self.movieView];
                                     }
                                 }
                                 else {
                                     self.movieView.frame = self.movieView.movieInFatherViewFrame;
                                     [self.movieView.movieFatherView addSubview:self.movieView];
                                 }
                                 [dismissingView removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                                 [self p_postExitFullScreenNoti];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:NO] }];
                             }];
        }
        else {
            dismissingView.transform = CGAffineTransformIdentity;
            dismissingView.frame = smallMovieFrame;
            if (self.movieView.hasMovieFatherCell) {
                if (videoCell && [videoCell isKindOfClass:[TTVFeedListCell class]] && [videoCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                    self.movieView.frame = [videoCell cell_movieViewFrameRect];
                    [videoCell cell_attachMovieView:self.movieView];
                    
                } else if (videoCell &&  [videoCell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [videoCell isKindOfClass:[ExploreCellBase class]]) {
                    
                    self.movieView.frame = [videoCell movieViewFrameRect];
                    [videoCell attachMovieView:(ExploreMovieView *)self.movieView];
                }
            }
            else {
                self.movieView.frame = self.movieView.movieInFatherViewFrame;
                [self.movieView.movieFatherView addSubview:self.movieView];
            }
            [dismissingView removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self p_postExitFullScreenNoti];
        }
    }
}

- (void)p_postExitFullScreenNoti {
    [[NSNotificationCenter defaultCenter] postNotificationName:TTMovieDidExitFullscreenNotification object:nil];
}

@end
