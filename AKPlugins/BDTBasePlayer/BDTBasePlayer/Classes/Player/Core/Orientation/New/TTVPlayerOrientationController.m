//
//  TTVPlayerOrientationController.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerOrientationController.h"
#import "TTDeviceHelper.h"
#import "Aspects.h"
#import "TTVOrientationMonitor.h"
#import <TTBaseLib/TTUIResponderHelper.h>

static NSTimeInterval kAnimDuration = 0.3;
extern BOOL STATUS_BAR_ORIENTATION_MODIFY;
extern NSString *const TTVDidExitFullscreenNotification;

@interface TTVPlayerOrientationController ()<TTVOrientationMonitorDelegate>

@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, assign) CGRect rotateFrame;
@property (nonatomic, weak) UIView *rotateSuperView;

@property (nonatomic, weak) UITableView *baseTableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) UITableViewCell *cell;
@property (nonatomic, assign) BOOL scrollsToTop;
@property (nonatomic, strong) TTVOrientationMonitor *monitor;

@property (nonatomic, weak) UIViewController *destVCForAutoHideHomeIndicator;
@property (nonatomic, strong) id<AspectToken> autoHideHomeIndicatorToken;

@end

@implementation TTVPlayerOrientationController

#pragma mark - life cycle

- (void)dealloc
{

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _monitor = [[TTVOrientationMonitor alloc] init];
        _monitor.delegate = self;
    }
    return self;
}

- (UITableViewCell *)ttv_containerMovieViewCell {

    UIView *superView = self.rotateView;
    while (superView) {
        if ([superView isKindOfClass:[UITableViewCell class]])
            return (UITableViewCell *)superView;
        superView = superView.superview;
    }
    return nil;
}

- (UITableView *)ttv_containerMovieViewTableView {

    UIView *superView = self.rotateView.superview;
    while (superView) {
        if ([superView isKindOfClass:[UITableView class]])
            return (UITableView *)superView;
        superView = superView.superview;
    }
    return nil;
}


#pragma mark - public method

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        _playerStateStore = playerStateStore;
        _monitor.playerStateStore = playerStateStore;
    }
}

- (void)setRotateView:(UIView *)rotateView
{
    _rotateView = rotateView;
    _monitor.rotateView = rotateView;
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
    self.cell = [self ttv_containerMovieViewCell];
    self.baseTableView = [self ttv_containerMovieViewTableView];
    self.scrollsToTop = self.baseTableView.scrollsToTop;
    self.baseTableView.scrollsToTop = NO;
    self.indexPath = [self.baseTableView indexPathForCell:self.cell];
    self.rotateSuperView = self.rotateView.superview;
    self.rotateFrame = self.rotateView.frame;
    self.rotateSuperView.userInteractionEnabled = NO;
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rotateSuperView.userInteractionEnabled = YES;
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    });

    CGRect frameBeforeRotation = self.rotateView.frame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect originFrame = [self.rotateSuperView convertRect:frameBeforeRotation toView:keyWindow];
    CGRect targetFrame = CGRectZero;
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;

    if (self.playerStateStore.state.enableRotate && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        targetFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        UIDevice *device = [UIDevice currentDevice];
        if (device.orientation == UIDeviceOrientationLandscapeRight) {
            orientation = UIInterfaceOrientationLandscapeLeft;
        } else {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
        UIInterfaceOrientation curOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (curOrientation == orientation) {
            return;
        }
    } else {
        targetFrame = CGRectMake(0, 0, keyWindow.bounds.size.width, keyWindow.bounds.size.height);
        transform = CGAffineTransformMakeRotation(0);
    }
    if (self.playerStateStore.state.enableRotate && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        [self refreshStatusBarOrientation:orientation];
        transform = [self ttv_transformForRotationAngle];
    }
    [self.rotateView removeFromSuperview];
    if (self.rotateView) {
        self.rotateView.frame = originFrame;
        [keyWindow addSubview:self.rotateView];
    }
    self.playerStateStore.state.isRotating = YES;
    self.playerStateStore.state.isFullScreen = YES;
    [self ttv_transientAutoHideHomeIndicator];
    [UIView animateWithDuration:kAnimDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.frame = targetFrame;
        self.rotateView.center = keyWindow.center;
        self.rotateView.transform = transform;
    } completion:^(BOOL finished) {
        self.playerStateStore.state.isRotating = NO;
        if (completion) {
            completion(YES);
        }
    }];
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

    if ([TTDeviceHelper isPadDevice] && self.delegate && [self.delegate respondsToSelector:@selector(ttv_movieViewFrameAfterExitFullscreen)]) {
        CGRect result = [self.delegate ttv_movieViewFrameAfterExitFullscreen];
        if (!CGRectEqualToRect(result, CGRectZero)) {
            self.rotateFrame = result;
        }
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect targetFrame = CGRectZero;
    CGPoint center = CGPointZero;
    BOOL canFindSuperView = YES;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        canFindSuperView = NO;
        if (self.baseTableView && self.indexPath) {
            UITableViewCell *cell = [self.baseTableView cellForRowAtIndexPath:self.indexPath];
            if (cell) {
                targetFrame = [self.rotateSuperView convertRect:self.rotateFrame toView:keyWindow];
                canFindSuperView = YES;
            }
        } else if (self.rotateSuperView) {
            targetFrame = [self.rotateSuperView convertRect:self.rotateFrame toView:keyWindow];
            canFindSuperView = YES;
        }
    } else {
        targetFrame = [self.rotateSuperView convertRect:self.rotateFrame toView:keyWindow];
    }

    if (self.playerStateStore.state.enableRotate && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        CGRect tmpFrame = targetFrame;
        targetFrame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y, tmpFrame.size.height, tmpFrame.size.width);
        center = CGPointMake(tmpFrame.origin.x + tmpFrame.size.width / 2, tmpFrame.origin.y + tmpFrame.size.height / 2);
    } else {
        center = CGPointMake(targetFrame.origin.x + targetFrame.size.width / 2, targetFrame.origin.y + targetFrame.size.height / 2);
    }
    self.playerStateStore.state.isRotating = YES;
    self.playerStateStore.state.isFullScreen = NO;
    keyWindow.userInteractionEnabled = NO;
    [self ttv_removeTransientAutoHideHomeIndicator];
    [UIView animateWithDuration:kAnimDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.frame = targetFrame;
        self.rotateView.center = center;
        self.rotateView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        keyWindow.userInteractionEnabled = YES;
        self.baseTableView.scrollsToTop = self.scrollsToTop;
        self.rotateView.frame = self.rotateFrame;
        if (!canFindSuperView || self.rotateSuperView == nil) {
            [self.rotateView removeFromSuperview];
            if (_delegate && [_delegate respondsToSelector:@selector(forceVideoPlayerStop)]) {
                [_delegate forceVideoPlayerStop];
            }
        } else {
            [self.rotateSuperView addSubview:self.rotateView];
        }
        if (completion) {
            completion(YES);
        }
        if (self.playerStateStore.state.enableRotate && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
            [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
        }
        self.playerStateStore.state.isRotating = NO;
        [self p_postExitFullScreenNoti];
    }];
}

#pragma mark - private method

- (CGAffineTransform)ttv_transformForRotationAngle {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

- (void)refreshStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation {
    STATUS_BAR_ORIENTATION_MODIFY = YES;
    id<AspectToken> aspectToken = [UIViewController aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        BOOL result = NO;
        [[info originalInvocation] setReturnValue:&result];
    }error:nil];
    NSArray *windowsArray = [UIApplication sharedApplication].windows;
    NSMutableArray *tokenArray = [[NSMutableArray alloc] initWithCapacity:windowsArray.count];
    for (UIWindow *window in windowsArray) {
        id<AspectToken> token = [window.rootViewController aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
            BOOL result = NO;
            [[info originalInvocation] setReturnValue:&result];
        }error:nil];
        if (token) {
            [tokenArray addObject:token];
        }
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:NO];
    if (aspectToken) {
        [aspectToken remove];
    }
    for (id<AspectToken> token in tokenArray) {
        [token remove];
    }
    STATUS_BAR_ORIENTATION_MODIFY = NO;
}

- (void)ttv_transientAutoHideHomeIndicator {
    if (@available(iOS 11.0, *)) {
        UIViewController *destViewController = [TTUIResponderHelper correctTopViewControllerFor:self.rotateSuperView];
        // iOS 11 GM版本没有homeIndicator相关的api
        if (![destViewController respondsToSelector:@selector(childViewControllerForHomeIndicatorAutoHidden)]) {
            return;
        }
        while (YES) {
            if ([destViewController childViewControllerForHomeIndicatorAutoHidden]) {
                destViewController = [destViewController childViewControllerForHomeIndicatorAutoHidden];
            } else {
                break;
            }
        }
        self.destVCForAutoHideHomeIndicator = destViewController;
        if (![self.destVCForAutoHideHomeIndicator respondsToSelector:@selector(prefersHomeIndicatorAutoHidden)] || ![self.destVCForAutoHideHomeIndicator respondsToSelector:@selector(setNeedsUpdateOfHomeIndicatorAutoHidden)]) {
            return;
        }
        self.autoHideHomeIndicatorToken = [self.destVCForAutoHideHomeIndicator aspect_hookSelector:@selector(prefersHomeIndicatorAutoHidden) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
            BOOL result = YES;
            [[info originalInvocation] setReturnValue:&result];
        }error:nil];
        [self.destVCForAutoHideHomeIndicator setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

- (void)ttv_removeTransientAutoHideHomeIndicator {
    if (@available(iOS 11.0, *)) {
        [self.autoHideHomeIndicatorToken remove];
        if (![self.destVCForAutoHideHomeIndicator respondsToSelector:@selector(setNeedsUpdateOfHomeIndicatorAutoHidden)]) {
            return;
        }
        [self.destVCForAutoHideHomeIndicator setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
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
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        orientation = UIInterfaceOrientationLandscapeLeft;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        orientation = UIInterfaceOrientationLandscapeRight;
    }
    if (orientation == UIInterfaceOrientationUnknown) {
        return;
    }

    [self refreshStatusBarOrientation:orientation];

    CGAffineTransform transform = [self ttv_transformForRotationAngle];
    self.playerStateStore.state.isRotating = YES;
    self.playerStateStore.state.isFullScreen = YES;
    UIView *backView = [[UIView alloc] initWithFrame:self.rotateView.frame];
    backView.backgroundColor = [UIColor blackColor];
    [self.rotateView.superview insertSubview:backView belowSubview:self.rotateView];
    [UIView animateWithDuration:kAnimDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.transform = transform;
    } completion:^(BOOL finished) {
        self.playerStateStore.state.isRotating = NO;
        [backView removeFromSuperview];
    }];
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
    
}

- (void)p_postExitFullScreenNoti {
    [[NSNotificationCenter defaultCenter] postNotificationName:TTVDidExitFullscreenNotification object:self.playerStateStore.state.playerModel];
}

@end
