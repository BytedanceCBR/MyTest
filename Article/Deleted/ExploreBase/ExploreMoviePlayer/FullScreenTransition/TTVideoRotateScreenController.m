//
//  TTVideoRotateScreenController.m
//  test_rotate
//
//  Created by xiangwu on 2016/12/18.
//  Copyright © 2016年 xiangwu. All rights reserved.
//

#import "TTVideoRotateScreenController.h"
#import "ExploreMovieView.h"
#import "ExploreCellBase.h"
#import "ExploreCellViewBase.h"
#import "SSViewControllerBase.h"
#import "Aspects.h"
#import "TTVVideoRotateScreenWindow.h"
#import <TTBaseLib/TTUIResponderHelper.h>

static NSTimeInterval kAnimDuration = 0.3;

@interface TTVideoRotateScreenController ()

@property (nonatomic, assign, readwrite) BOOL duringAnimation;
@property (nonatomic, assign, readwrite) BOOL inFullScreen;
@property (nonatomic, assign) BOOL fixFullScreenOnIOS8;

@property (nonatomic, strong) UIWindow *applicationDelegateWindow;
@property (nonatomic, strong) TTVVideoRotateScreenWindow *window;
@property (nonatomic, strong) id<AspectToken> aspectToken;

@property (nonatomic, weak) UIViewController *destVCForAutoHideHomeIndicator;
@property (nonatomic, strong) id<AspectToken> autoHideHomeIndicatorToken;

@end

@implementation TTVideoRotateScreenController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRotateView:(UIView<TTVideoRotateViewProtocol> *)rotateView {
    self = [super init];
    if (self) {
        _rotateView = rotateView;
        self.fixFullScreenOnIOS8 = [TTDeviceHelper OSVersionNumber] < 9;
        
        if (self.fixFullScreenOnIOS8) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
    }
    return self;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (self.inFullScreen) {
        [self.rotateView removeFromSuperview];
        self.window.rootViewController = nil;
        [self.window removeFromSuperview];
        self.window = nil;
        
        TTVVideoRotateScreenWindow *window = [[TTVVideoRotateScreenWindow alloc] initWithFrame:CGRectMake(0, 0, MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))];
        self.window = window;
        [window.rootViewController.view addSubview:self.rotateView];
        [window makeKeyAndVisible];
    }
}

#pragma mark - public method

- (void)enterFullScreen:(BOOL)animated completion:(void (^)())completion {
    if (self.fixFullScreenOnIOS8) {
        [self enterFullScreenBelowIOS9:animated completion:completion];
        return;
    }
    if (!self.rotateView) {
        return;
    }
    CGRect frameBeforeRotation = self.rotateView.frame;
    self.inFullScreen = YES;
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    CGRect originFrame = [self.rotateView.rotateSuperView convertRect:frameBeforeRotation toView:keyWindow];
    CGRect targetFrame = CGRectZero;
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.rotateView.frame = originFrame;
    UIInterfaceOrientation orientation;
    if (_enableRotate) {
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
    [self.rotateView removeFromSuperview];
    [keyWindow addSubview:self.rotateView];
    if (_enableRotate) {
        [self refreshStatusBarOrientation:orientation];
        transform = [self transformForRotationAngle];
    }
    self.duringAnimation = YES;
    [self ttv_transientAutoHideHomeIndicator];
    [UIView animateWithDuration:kAnimDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.frame = targetFrame;
        self.rotateView.center = keyWindow.center;
        self.rotateView.transform = transform;
    } completion:^(BOOL finished) {
        self.duringAnimation = NO;
        if (completion) {
            completion();
        }
    }];
}

- (void)exitFullScreen:(BOOL)animated completion:(void (^)())completion {
    if (self.fixFullScreenOnIOS8) {
        [self exitFullScreenBelowIOS9:animated completion:completion];
        return;
    }
    if (!self.rotateView) {
        return;
    }
    self.inFullScreen = NO;
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    CGRect targetFrame = CGRectZero;
    CGPoint center = CGPointZero;
    BOOL canFindSuperView = YES;
    ExploreCellBase<ExploreMovieViewCellProtocol> *videoCell = nil;
    if ([TTDeviceHelper isPadDevice]) {
        canFindSuperView = NO;
        if (self.rotateView.baseTableView && self.rotateView.indexPath) {
            UITableViewCell *cell = [self.rotateView.baseTableView cellForRowAtIndexPath:self.rotateView.indexPath];
            if (cell && [cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [cell isKindOfClass:[ExploreCellBase class]]) {
                videoCell = (ExploreCellBase<ExploreMovieViewCellProtocol> *)cell;
                targetFrame = [videoCell convertRect:[videoCell movieViewFrameRect] toView:keyWindow];
                canFindSuperView = YES;
            }
        } else if (self.rotateView.rotateSuperView) {
            targetFrame = [self.rotateView.rotateSuperView convertRect:self.rotateView.rotateViewRect toView:keyWindow];
            canFindSuperView = YES;
        }
    } else {
        targetFrame = [self.rotateView.rotateSuperView convertRect:self.rotateView.rotateViewRect toView:keyWindow];
    }
    if (_enableRotate) {
        CGRect tmpFrame = targetFrame;
        targetFrame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y, tmpFrame.size.height, tmpFrame.size.width);
        center = CGPointMake(tmpFrame.origin.x + tmpFrame.size.width / 2, tmpFrame.origin.y + tmpFrame.size.height / 2);
        [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
    } else {
        center = CGPointMake(targetFrame.origin.x + targetFrame.size.width / 2, targetFrame.origin.y + targetFrame.size.height / 2);
    }
    
    self.duringAnimation = YES;
    [self ttv_removeTransientAutoHideHomeIndicator];
    [UIView animateWithDuration:kAnimDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.frame = targetFrame;
        self.rotateView.center = center;
        self.rotateView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.duringAnimation = NO;
        
        if (!canFindSuperView) {
            [self.rotateView removeFromSuperview];
            [self.rotateView forceStop];
            self.rotateView = nil;
            if (completion) {
                completion();
            }
            return ;
        }
        if ([TTDeviceHelper isPadDevice] && self.rotateView.indexPath && self.rotateView.baseTableView) {
            self.rotateView.frame = [videoCell movieViewFrameRect];
            [videoCell attachMovieView:(ExploreMovieView *)self.rotateView];
        } else {
            self.rotateView.frame = self.rotateView.rotateViewRect;
            [self.rotateView.rotateSuperView addSubview:self.rotateView];
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)changeRotationOfLandscape {
    
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
    
    CGAffineTransform transform = [self transformForRotationAngle];
    self.duringAnimation = YES;
    UIView *backView = [[UIView alloc] initWithFrame:self.rotateView.frame];
    backView.backgroundColor = [UIColor blackColor];
    [self.rotateView.superview insertSubview:backView belowSubview:self.rotateView];
    [UIView animateWithDuration:kAnimDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.transform = transform;
    } completion:^(BOOL finished) {
        self.duringAnimation = NO;
        [backView removeFromSuperview];
    }];
}

#pragma mark - 转屏方案五

- (void)enterFullScreenBelowIOS9:(BOOL)animated completion:(void (^)())completion {
    if (!self.rotateView) {
        return;
    }
    CGRect frameBeforeRotation = self.rotateView.frame;
    self.inFullScreen = YES;
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    self.applicationDelegateWindow = [UIApplication sharedApplication].keyWindow;
    CGFloat screenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat screenHeight = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.aspectToken = [keyWindow aspect_hookSelector:@selector(setFrame:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight);
        [invocation setArgument:&frame atIndex:2];
        [invocation retainArguments];
    }error:nil];
    
    CGRect originFrame = [self.rotateView.rotateSuperView convertRect:frameBeforeRotation toView:keyWindow];
    CGRect targetFrame = CGRectZero;
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.rotateView.frame = originFrame;
    UIInterfaceOrientation orientation;
    if (_enableRotate) {
        targetFrame = CGRectMake(0, 0, screenHeight, screenWidth);
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
    [self.rotateView removeFromSuperview];
    
    TTVVideoRotateScreenWindow *window = [[TTVVideoRotateScreenWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.window = window;
    [window.rootViewController.view addSubview:self.rotateView];
    [window makeKeyAndVisible];
    
    if (_enableRotate) {
        [self refreshStatusBarOrientation:orientation];
        transform = [self transformForRotationAngle];
    }
    self.duringAnimation = YES;
    [UIView animateWithDuration:(animated ? kAnimDuration : 0) delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.frame = targetFrame;
        self.rotateView.center = window.center;
        self.rotateView.transform = transform;
    } completion:^(BOOL finished) {
        self.duringAnimation = NO;
        [UIViewController attemptRotationToDeviceOrientation];
        [self refreshStatusBarOrientation:orientation];
        if (completion) {
            completion();
        }
    }];
}

- (void)exitFullScreenBelowIOS9:(BOOL)animated completion:(void (^)())completion {
    if (!self.rotateView) {
        return;
    }
    self.inFullScreen = NO;
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    CGRect targetFrame = CGRectZero;
    CGPoint center = CGPointZero;
    BOOL canFindSuperView = YES;
    ExploreCellBase<ExploreMovieViewCellProtocol> *videoCell = nil;
    if ([TTDeviceHelper isPadDevice]) {
        canFindSuperView = NO;
        if (self.rotateView.baseTableView && self.rotateView.indexPath) {
            UITableViewCell *cell = [self.rotateView.baseTableView cellForRowAtIndexPath:self.rotateView.indexPath];
            if (cell && [cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [cell isKindOfClass:[ExploreCellBase class]]) {
                videoCell = (ExploreCellBase<ExploreMovieViewCellProtocol> *)cell;
                targetFrame = [videoCell convertRect:[videoCell movieViewFrameRect] toView:keyWindow];
                canFindSuperView = YES;
            }
        } else if (self.rotateView.rotateSuperView) {
            targetFrame = [self.rotateView.rotateSuperView convertRect:self.rotateView.rotateViewRect toView:keyWindow];
            canFindSuperView = YES;
        }
    } else {
        targetFrame = [self.rotateView.rotateSuperView convertRect:self.rotateView.rotateViewRect toView:keyWindow];
    }
    if (_enableRotate) {
        CGRect tmpFrame = targetFrame;
        targetFrame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y, tmpFrame.size.height, tmpFrame.size.width);
        center = CGPointMake(tmpFrame.origin.x + tmpFrame.size.width / 2, tmpFrame.origin.y + tmpFrame.size.height / 2);
        [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
    } else {
        center = CGPointMake(targetFrame.origin.x + targetFrame.size.width / 2, targetFrame.origin.y + targetFrame.size.height / 2);
    }
    
    self.duringAnimation = YES;
    [UIView animateWithDuration:(animated ? kAnimDuration : 0) delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.rotateView.frame = targetFrame;
        self.rotateView.center = center;
        self.rotateView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.duringAnimation = NO;
        [UIViewController attemptRotationToDeviceOrientation];
        [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
        
        if (!canFindSuperView) {
            [self.rotateView removeFromSuperview];
            [self.rotateView forceStop];
            self.rotateView = nil;
            if (completion) {
                completion();
            }
            return ;
        }
        if ([TTDeviceHelper isPadDevice] && self.rotateView.indexPath && self.rotateView.baseTableView) {
            self.rotateView.frame = [videoCell movieViewFrameRect];
            [videoCell attachMovieView:(ExploreMovieView *)self.rotateView];
        } else {
            self.rotateView.frame = self.rotateView.rotateViewRect;
            [self.rotateView.rotateSuperView addSubview:self.rotateView];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.window.rootViewController = nil;
            [self.window removeFromSuperview];
            self.window = nil;
            [self.applicationDelegateWindow makeKeyAndVisible];
            [self.aspectToken remove];
        });
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - private method

- (CGAffineTransform)transformForRotationAngle {
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
        UIViewController *destViewController = [TTUIResponderHelper correctTopViewControllerFor:self.rotateView.rotateSuperView];
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

@end
