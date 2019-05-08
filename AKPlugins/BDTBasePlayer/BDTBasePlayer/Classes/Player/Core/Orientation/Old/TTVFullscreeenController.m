//
//  TTVFullscreeenController.m
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import "TTVFullscreeenController.h"
#import "TTVFullscreenViewController.h"
#import "TTVEnterFullscreenAnimatedTransitioning.h"
#import "TTVExitFullscreenAnimatedTransitioning.h"
#import "TTDeviceHelper.h"
#import "TTVPlayerStateStore.h"
#import <StoreKit/StoreKit.h>
#import "TTVOrientationMonitor.h"
#import "UIViewController+TTVHiritageSearch.h"
#import "TTUIResponderHelper.h"

@interface TTVFullscreeenController ()<UIViewControllerTransitioningDelegate,TTVOrientationMonitorDelegate>
@property (nonatomic, strong) TTVFullscreenViewController *fullscreenViewController;
@property(nonatomic, weak) UITableView *movieFatherCellTableView;
@property(nonatomic, copy) NSIndexPath *movieFatherCellIndexPath;
@property(nonatomic, assign) BOOL hasMovieFatherCell;
@property(nonatomic, weak) UIView *movieFatherView;
@property(nonatomic, assign) CGRect movieSuperViewFrame;
@property(nonatomic, assign) BOOL scrollsToTop;
@property(nonatomic, strong) TTVOrientationMonitor *monitor;
@end

@implementation TTVFullscreeenController

- (void)dealloc
{

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _monitor = [[TTVOrientationMonitor alloc] init];
        _monitor.delegate = self;
    }
    return self;
}

- (void)setRotateView:(UIView *)rotateView
{
    _rotateView = rotateView;
    _monitor.rotateView = rotateView;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        _playerStateStore = playerStateStore;
        _monitor.playerStateStore = playerStateStore;
    }
}

+ (UIViewController *)ttmu_currentViewController {
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self ttmu_findBestViewController:viewController];
}

+ (UIViewController *)ttmu_findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self ttmu_findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self ttmu_findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self ttmu_findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self ttmu_findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIInterfaceOrientation)fullscreenOrientation
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeRight;
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

- (UITableViewCell *)containerMovieViewCell {
    UIView *superView = self.rotateView;
    while (superView) {
        if ([superView isKindOfClass:[UITableViewCell class]]){
            return (UITableViewCell *)superView;
        }
        superView = superView.superview;
    }
    return nil;
}

- (UITableView *)containerMovieViewTableView {

    UIView *superView = self.rotateView;
    while (superView) {
        if ([superView isKindOfClass:[UITableView class]]){
            return (UITableView *)superView;
        }
        superView = superView.superview;
    }
    return nil;
}

- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    TTVOrientationStatus *status = [[TTVOrientationStatus alloc] init];
    status.rotateView = self.rotateView;
    status.playerStateStore = self.playerStateStore;

    NSTimeInterval timeDiff = self.playerStateStore.state.duration - self.playerStateStore.state.currentPlaybackTime;
    if (![status shouldRotateByCommonState] ||
        ![status shouldRotateByPlayState] ||
        self.playerStateStore.state.isShowingTrafficAlert ||
        (timeDiff <= 0.5 && timeDiff >0)) {
        if (completion) {
            completion(NO);
        }
        return;
    }

    dispatch_block_t enterBlock = ^ {
        UITableViewCell *containerMovieViewCell = [self containerMovieViewCell];
        if (containerMovieViewCell) {
            self.hasMovieFatherCell = YES;
            self.movieFatherCellTableView = [self containerMovieViewTableView];
            self.scrollsToTop = self.movieFatherCellTableView.scrollsToTop;
            self.movieFatherCellTableView.scrollsToTop = NO;

            NSIndexPath *indexPath = [self.movieFatherCellTableView indexPathForCell:containerMovieViewCell];
            self.movieFatherCellIndexPath = indexPath;
        }
        else {
            self.movieFatherView = self.rotateView.superview;
            self.hasMovieFatherCell = NO;
            self.movieSuperViewFrame = self.movieFatherView.frame;
        }

        UIViewController *topMost = [TTUIResponderHelper correctTopViewControllerFor:self.rotateView];
        UIInterfaceOrientation orientationBeforePresented = topMost.interfaceOrientation;
        UIInterfaceOrientation orientationAfterPresented = topMost.interfaceOrientation;
        UIInterfaceOrientationMask supportedOriendtation = UIInterfaceOrientationMaskAll;
        if (![TTDeviceHelper isPadDevice]) {
            if (self.playerStateStore.state.enableRotate) {
                supportedOriendtation = UIInterfaceOrientationMaskLandscape;
                orientationAfterPresented = [self fullscreenOrientation];
            }
            else {
                supportedOriendtation = UIInterfaceOrientationMaskPortrait;
            }
        }

        TTVFullscreenViewController *fullscreenViewController = [[TTVFullscreenViewController alloc] initWithOrientationBeforePresented:orientationBeforePresented orientationAfterPresented:orientationAfterPresented supportedOrientations:supportedOriendtation];
        fullscreenViewController.transitioningDelegate = self;
        if ([TTDeviceHelper OSVersionNumber] < 8.0) {
            fullscreenViewController.modalPresentationStyle = UIModalPresentationCustom;
        }
        else {
            fullscreenViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        fullscreenViewController.animatedDuringTransition = animated;
        self.playerStateStore.state.isRotating = YES;
        self.playerStateStore.state.isFullScreen = YES;
        [topMost presentViewController:fullscreenViewController animated:YES completion:^{
            self.playerStateStore.state.isRotating = NO;
            if (completion) {
                completion(YES);
            }
            if (self.playerStateStore.state.isRotating) {
                //iOS8上，在presentViewController的completionBlock中dismiss，会crash
                //http://stackoverflow.com/questions/25762466/trying-to-dismiss-the-presentation-controller-while-transitioning-already
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self exitFullScreen:YES completion:nil];
                });
            }
        }];
        self.fullscreenViewController = fullscreenViewController;
    };

    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [[self class] ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                enterBlock();
            }];
        } else {
            enterBlock();
        }
    } else {
        enterBlock();
    }
}

- (CGRect)getMovieInFatherViewFrame
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttv_movieViewFrameAfterExitFullscreen)]) {
        CGRect result = [self.delegate ttv_movieViewFrameAfterExitFullscreen];
        if (!CGRectEqualToRect(result, CGRectZero) && !CGRectIsNull(result)) {
            return result;
        }
    }
    return self.movieSuperViewFrame;
}

- (void)doneExitFullScreenWithCompletion:(TTVPlayerOrientationCompletion)completion
{
    self.playerStateStore.state.isRotating = NO;
    self.hasMovieFatherCell = NO;
    self.movieFatherCellTableView = nil;
    self.movieFatherCellIndexPath = nil;
    self.movieFatherView = nil;
    self.movieSuperViewFrame = CGRectZero;
    if (completion) {
        completion(YES);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.movieFatherCellTableView.scrollsToTop = self.scrollsToTop;
    });
}

- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    TTVOrientationStatus *status = [[TTVOrientationStatus alloc] init];
    status.rotateView = self.rotateView;
    status.playerStateStore = self.playerStateStore;
    if (![status shouldRotateByCommonState] || !self.playerStateStore.state.isFullScreen) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    self.playerStateStore.state.isRotating = YES;
    self.playerStateStore.state.isFullScreen = NO;
    self.fullscreenViewController.animatedDuringTransition = animated;
    [self.fullscreenViewController dismissViewControllerAnimated:YES completion:^{
        [self doneExitFullScreenWithCompletion:completion];
    }];
    // https://jira.bytedance.com/browse/XWTT-8607 原因：animated为NO的时候，completion block不调用
    // 如果dismiss的completion不调用的时候，需要清理下状态
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (self.playerStateStore.state.isRotating) {
//            exitFullScreenBlock();
//        }
//    });

    if (animated) {
        if (![TTDeviceHelper isPadDevice]) {
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            } completion:nil];
        }
    }
    else {
    }

}


#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:[TTVFullscreenViewController class]]) {
        return [[TTVEnterFullscreenAnimatedTransitioning alloc] initWithMovieView:self.rotateView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[TTVFullscreenViewController class]]) {
        @weakify(self);
        TTVExitFullscreenAnimatedTransitioning *transition = [[TTVExitFullscreenAnimatedTransitioning alloc] initWithMovieView:self.rotateView controller:self exitFinished:^{
            @strongify(self);
            if (self.playerStateStore.state.isRotating) {
                [self doneExitFullScreenWithCompletion:^(BOOL finished) {
                    
                }];
            }
        }];
        return transition;
    }
    return nil;
}

#pragma mark - TTFullscreenMovieViewProtocol
- (void)forceStoppingMovie {
    //    [self stopMovie];
}


#pragma mark TTVOrientationMonitorDelegate

- (void)changeOrientationToFull:(BOOL)isFull
{
    if (isFull) {
        [self enterFullScreen:YES completion:^(BOOL finished) {
        }];
    }else{
        [self exitFullScreen:YES completion:^(BOOL finished) {
        }];
    }
}

- (void)changeRotationOfLandscape
{

}

- (BOOL)videoPlayerCanRotate
{
    if (self.rotateView && [self.delegate respondsToSelector:@selector(videoPlayerCanRotate)]) {
        return [_delegate videoPlayerCanRotate];
    }
    return NO;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    switch (action.actionType) {
        case TTVPlayerEventTypePlayerStop:
            break;

        default:
            break;
    }
}

@end
