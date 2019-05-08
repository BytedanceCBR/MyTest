//
//  TTVExitFullscreenAnimatedTransitioning.m
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import "TTVExitFullscreenAnimatedTransitioning.h"
#import "TTVFullscreenViewController.h"
#import "TTDeviceHelper.h"


NSString *const TTVDidExitFullscreenNotification = @"TTVDidExitFullscreenNotification";

static const NSTimeInterval kFullScreenChangeAnimationTime = 0.3f;

@interface TTVExitFullscreenAnimatedTransitioning ()

@property (nonatomic, weak) UIView *movieView;
@property (nonatomic, weak) NSObject<TTVFullscreenPlayerProtocol> *controller;
@property (nonatomic, copy) TTVFullScreenExitFinished finishedBlock;


@end

@implementation TTVExitFullscreenAnimatedTransitioning

- (instancetype)initWithMovieView:(UIView *)movieView controller:(NSObject<TTVFullscreenPlayerProtocol> *)controller exitFinished:(TTVFullScreenExitFinished)finished{
    self = [super init];
    if (self) {
        _movieView = movieView;
        _controller = controller;
        self.finishedBlock = finished;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *dismissingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([dismissingViewController isKindOfClass:[TTVFullscreenViewController class]]) {
        TTVFullscreenViewController *fullscreenViewController = (TTVFullscreenViewController *)dismissingViewController;
        return fullscreenViewController.animatedDuringTransition ? kFullScreenChangeAnimationTime : 0.0;
    }
    return 0.0;
}

- (void)ttvAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *dismissingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *dismissingView = nil;
    {
        dismissingView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    }

    if (![dismissingViewController isKindOfClass:[TTVFullscreenViewController class]]) {
        [dismissingView removeFromSuperview];
        [transitionContext completeTransition:YES];
        return;
    }
    
    if (!dismissingViewController.isBeingDismissed) {
        [dismissingView removeFromSuperview];
        [transitionContext completeTransition:YES];
        return;
    }

    //如果当前movieView没有superview，说明这个movieView已经被调过removeFromSuperview，所以不应该再被加到原先位置了
    if (![self.movieView superview]){
        [dismissingView removeFromSuperview];
        [transitionContext completeTransition:YES];
        return;
    }
    
    CGRect smallMovieFrame = CGRectZero;
    BOOL canFindFatherView = NO;
    UIView <TTVFullscreenCellProtocol> *videoCell = nil;
    if (self.controller.hasMovieFatherCell) {
        if (self.controller.movieFatherCellTableView && self.controller.movieFatherCellIndexPath) {
            UITableViewCell *cell = [self.controller.movieFatherCellTableView cellForRowAtIndexPath:self.controller.movieFatherCellIndexPath]; // returns nil if cell is not visible or index path is out of range
            if ([cell conformsToProtocol:@protocol(TTVFullscreenCellProtocol)]) {
                videoCell = (UITableViewCell <TTVFullscreenCellProtocol> *)cell;
            }
            if ([videoCell isKindOfClass:[UIView class]]) {
                CGRect frame = [self movieViewFrame:videoCell];

                smallMovieFrame = [[transitionContext containerView] convertRect:frame fromView:videoCell];
                canFindFatherView = YES;
            }
        }
    }
    else {
        if (self.controller.movieFatherView) {
            smallMovieFrame = [[transitionContext containerView] convertRect:[self.controller getMovieInFatherViewFrame] fromView:self.controller.movieFatherView];
            canFindFatherView = YES;
        }
    }
    
    if (!canFindFatherView) {
        [dismissingView removeFromSuperview];
        [self.controller forceStoppingMovie];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
        [transitionContext completeTransition:YES];
        return;
    }
    BOOL isZeroFrame = smallMovieFrame.size.width <= 0 || smallMovieFrame.size.height <= 0;
    
    {
        if ([transitionContext isAnimated] && !isZeroFrame) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:YES] }];
            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                  delay:0.0
                                options:UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 dismissingView.transform = CGAffineTransformIdentity;
                                 dismissingView.frame = smallMovieFrame;
                             }
                             completion:^(BOOL finished) {
                                 [self restoreMovieWithCell:videoCell];
                                 [dismissingView removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                                 [self p_postExitFullScreenNoti];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kTTVPlayerIsOnRotateAnimation object:nil userInfo:@{@"isAnimating":[NSNumber numberWithBool:NO] }];
                             }];
        }
        else {
            dismissingView.transform = CGAffineTransformIdentity;
            dismissingView.frame = smallMovieFrame;
            [self restoreMovieWithCell:videoCell];
            [dismissingView removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self p_postExitFullScreenNoti];
        }
    }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ttvAnimateTransition:transitionContext];
    });
}

- (UIView *)ttv_playerSuperViewWithCell:(UIView <TTVFullscreenCellProtocol> *)cell
{
    if ([cell respondsToSelector:@selector(ttv_playerSuperView)]) {
        return [cell ttv_playerSuperView];
    }
    return nil;
}

- (CGRect)movieViewFrame:(UIView <TTVFullscreenCellProtocol> *)videoCell
{
    UIView *superView = [self ttv_playerSuperViewWithCell:videoCell];
    return [videoCell convertRect:superView.bounds fromView:superView];
}

- (void)restoreMovieWithCell:(UIView <TTVFullscreenCellProtocol> *)videoCell
{
    BOOL hasSuperView = NO;
    if (self.controller.hasMovieFatherCell) {
        UIView *superView = [self ttv_playerSuperViewWithCell:videoCell];
        if (superView) {
            [superView addSubview:self.movieView];
            [superView bringSubviewToFront:_movieView];
            self.movieView.frame = superView.bounds;
            hasSuperView = YES;
        }

    }
    else {
        if (self.controller.movieFatherView) {
            hasSuperView = YES;
        }
        self.movieView.frame = [self.controller getMovieInFatherViewFrame];
        [self.controller.movieFatherView addSubview:self.movieView];
    }
    if (!hasSuperView) {
        [self.controller forceStoppingMovie];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
    }
    if (self.finishedBlock) {
        self.finishedBlock();
    }
}

- (void)p_postExitFullScreenNoti {
    [[NSNotificationCenter defaultCenter] postNotificationName:TTVDidExitFullscreenNotification object:nil];
}

@end
