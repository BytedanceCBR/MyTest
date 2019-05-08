//
//  TTVOrientationMonitor.m
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import "TTVOrientationMonitor.h"
#import "TTDeviceHelper.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerView.h"
#import "BDPlayerObjManager.h"

@interface TTVOrientationMonitor ()
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, assign) BOOL isActive;
@end

@implementation TTVOrientationMonitor


- (instancetype)init {
    self = [super init];
    if (self) {
        self.isActive = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        if (![TTDeviceHelper isPadDevice]) {
            [self _beginOrientationMonitor];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (![TTDeviceHelper isPadDevice]) {
        [self _endOrientationMonitor];
    }
}


- (UIWindow *)ttv_mainWindow
{
    UIWindow *window = nil;
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (!window && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    return window;
}


- (BOOL)ttv_isTopMostView
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *w in windows) {
        // 分享
        Class cls = NSClassFromString(@"TTPanelControllerWindow");
        Class clsNew = NSClassFromString(@"TTNewPanelControllerWindow");
        if ((cls && [w isKindOfClass:cls] && (!w.hidden || [w isKeyWindow])) || (clsNew && [w isKindOfClass:clsNew] && (!w.hidden || [w isKeyWindow]))) {
            return NO;
        }
    }

    if ([[UIApplication sharedApplication].keyWindow isKindOfClass:NSClassFromString(@"TTVVideoRotateScreenWindow")]) {
        return YES;
    }
    UIWindow *keyWindow = [self ttv_mainWindow];

    CGPoint pt = [self.rotateView.superview convertPoint:self.rotateView.center toView:keyWindow];
    UIView *topView = [keyWindow hitTest:pt withEvent:nil];
    while (topView) {
        if ([topView isKindOfClass:[TTVPlayerView class]]) {
            return YES;
            break;
        }
        topView = topView.superview;
    }
    return NO;
}


- (void)orientationChanged:(NSNotification *)notification {
    id obj = notification.object;
    if (!self.isActive) {
        return;
    }
    if (![obj isKindOfClass:[UIDevice class]]) {
        return;
    }
    BOOL canRotate = [self ttv_isTopMostView] && self.playerStateStore.state.enableRotate && [BDPlayerObjManager isCanFullScreenFromOrientationMonitorChanged];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerCanRotate)]) {
        canRotate = [_delegate videoPlayerCanRotate] && canRotate;
    }
    if (!canRotate) {
        return;
    }

    if (self.playerStateStore.state.isRotating) {
        return;
    }
    UIDeviceOrientation orientation = [(UIDevice *)obj orientation];
    if (_lastOrientation == orientation || orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }
    _lastOrientation = orientation;
    //已转为横屏：
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        if (self.playerStateStore.state.isFullScreen) {
            if ([self.delegate respondsToSelector:@selector(changeRotationOfLandscape)]) {
                [self.delegate changeRotationOfLandscape];
            }
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(changeOrientationToFull:)]) {
                self.playerStateStore.state.isFullScreenButtonType = NO;
                [self.delegate changeOrientationToFull:YES];
            }
        }
    }
    //已转为竖屏：
    if (orientation == UIDeviceOrientationPortrait && self.playerStateStore.state.isFullScreen) {
        if (_delegate && [_delegate respondsToSelector:@selector(changeOrientationToFull:)]) {
            self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeGravity;
            [self.delegate changeOrientationToFull:NO];
        }
    }
}

#pragma mark - orientation notification

- (void)_beginOrientationMonitor {
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)_endOrientationMonitor {
    UIDevice *device = [UIDevice currentDevice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)ttv_ApplicationWillResignActiveNotification:(NSNotification *)notification
{
    self.isActive = NO;
}

- (void)ttv_ApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    self.isActive = YES;
}

@end

@implementation TTVOrientationStatus

- (BOOL)shouldRotateByCommonState {
    // 判断转屏有效性的 基础状态
    if (!self.rotateView ||
        self.playerStateStore.state.isRotating ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldRotateByPlayState { // 判断转屏有效性的 业务及播放相关状态

    if (self.playerStateStore.state.isFullScreen || self.playerStateStore.state.isRotating||
        self.playerStateStore.state.playbackState == TTVVideoPlaybackStateError) {
        return NO;
    }

    // 正在播放贴片时 原视频转屏有效
    if (self.playerStateStore.state.enableRotateWhenPlayEnd) {
        return YES;
    }

    if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished ||
        self.playerStateStore.state.playbackState == TTVVideoPlaybackStateBreak ||
        (self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeLoading && !self.playerStateStore.state.showVideoFirstFrame) ||
        self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeFinished) {

        return NO;
    }
    
    return YES;
}

@end
