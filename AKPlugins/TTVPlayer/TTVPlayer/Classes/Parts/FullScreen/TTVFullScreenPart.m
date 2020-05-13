//
//  TTVFullScreenPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/11.
//

#import "TTVFullScreenPart.h"
#import "TTVPlayer.h"
#import "TTVFullScreenReducer.h"
#import "TTVLandscapeFullScreenViewController.h"

@interface TTVFullScreenPart ()
@property (nonatomic, strong) RotateAnimator* customAnimator;

@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, assign) BOOL isTransitioning;
//@property (nonatomic, assign) BOOL blockMonitoring;
//@property (nonatomic, assign) UIDeviceOrientation lastDeviceOrientation;



@end

@implementation TTVFullScreenPart

@synthesize playerStore, player, playerAction;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TTVReduxStateObserver
- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    // 如果状态发生了变化
    if (newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen) {
        if (newState.fullScreenState.isFullScreen) {
            [self rotateToLandscapeFullScreenVideo];
            self.fullButton.currentToggledStatus = TTVToggledButtonStatus_Toggled;
        }
        else {
            [self rotateToInlineScreenVideo];
            self.fullButton.currentToggledStatus = TTVToggledButtonStatus_Normal;
        }
    }
    
    // 设置监控杆旋转
    if (newState.fullScreenState.enableAutoRotate != lastState.fullScreenState.enableAutoRotate) {
        if (newState.fullScreenState.enableAutoRotate) {
            [self _beginMonitorDeviceOrientationChange];
        }
        else {
            [self _endMonitorDeviceOrientationChange];
        }
    }
}

- (void)subscribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    TTVFullScreenReducer * fullscreenReducer = [[TTVFullScreenReducer alloc] init];
    [self.playerStore setSubReducer:fullscreenReducer forKey:@"TTVFullScreenReducer"];
    if ([self state].fullScreenState.enableAutoRotate) {
        [self _beginMonitorDeviceOrientationChange];
    }
}

- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    [self _endMonitorDeviceOrientationChange];
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

#pragma mark - TTVPlayerPartProtocol
- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Full;
}

- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_FullToggledButton) {
        return self.fullButton;
    }
    return nil;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_FullToggledButton) {
        self.fullButton = (UIView<TTVToggledButtonProtocol> *)controlView;
        self.fullButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -8, -20, -30);
        // 设置默认 action, 但是外界可能没实现这个 action
        BOOL shouldImplementTouchupInsideBlock;
        if (![self.fullButton respondsToSelector:@selector(setAction:forStatus:)]
            && ![self.fullButton respondsToSelector:@selector(actionForStatus:)]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        else if (![self.fullButton actionForStatus:TTVToggledButtonStatus_Normal] || ![self.fullButton actionForStatus:TTVToggledButtonStatus_Toggled]){
            shouldImplementTouchupInsideBlock = YES;
        }
        if (shouldImplementTouchupInsideBlock) {
            @weakify(self);
            self.fullButton.didToggledButtonTouchUpInside = ^{
                @strongify(self);
                if (self.fullButton.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                    [self.playerAction actionForKey:TTVPlayerActionType_RotateToLandscapeFullScreen];
                }
                else {
                     [self.playerAction actionForKey:TTVPlayerActionType_RotateToInlineScreen];
                }
            };
        }
    }
}

/// 移除所有的 view
- (void)removeAllControlView {
    [self.fullButton removeFromSuperview];
}

#pragma mark - rotate
-(void)rotateToLandscapeFullScreenVideo{
    self.isTransitioning = YES;
    TTVLandscapeFullScreenViewController * horizontallyVideoVC = [[TTVLandscapeFullScreenViewController alloc] init];
    horizontallyVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    horizontallyVideoVC.transitioningDelegate = self.customAnimator;
    self.customAnimator.frameBeforePresent = self.customAnimator.rotateView?self.customAnimator.rotateView.frame:self.player.view.frame;

    // find top vc
    UIViewController * topVC = [TTVPlayerUtility lm_topmostViewController];
    [topVC presentViewController:horizontallyVideoVC animated:YES completion:^{
        Debug_NSLog(@"presentViewController执行完毕，有的时候控制器切换如果有视频在播放可能会有顿，可在执行前和完成之后做一些暂停开始的处理");
        // 全屏
        self.isTransitioning = NO;

    }];
    
    __weak typeof(self) weakSelf = self;
    horizontallyVideoVC.didDismiss = ^(){
        
    };
}

- (void)rotateToInlineScreenVideo {
    self.isTransitioning = YES;
    UIViewController * topVC = [TTVPlayerUtility lm_topmostViewController];
    @weakify(self)
    [topVC dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        Debug_NSLog(@"dismissViewController执行完毕，有的时候控制器切换如果有视频在播放可能会有顿，可在执行前和完成之后做一些暂停开始的处理");
        self.isTransitioning = NO;
    }];
}

- (RotateAnimator *)customAnimator {
    if (!_customAnimator) {
        _customAnimator = [[RotateAnimator alloc] initWithRotateViewTag:self.player.view.tag playerVC:self.player];
    }
    return _customAnimator;
}

- (void)_beginMonitorDeviceOrientationChange {
    if (self.isMonitoring) return;
    self.isMonitoring = YES;
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)_endMonitorDeviceOrientationChange {
    if (!self.isMonitoring) return;
    self.isMonitoring = NO;
    UIDevice *device = [UIDevice currentDevice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)_orientationChanged:(NSNotification *)notification {
    //    if (self.isTransitioning || !self.enableFullScreen || self.blockMonitoring) return;
    if (self.isTransitioning) {
        return;
    }
    UIDevice* device = notification.object;
    UIDeviceOrientation deviceOrientation = device.orientation;
    
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft ||
        deviceOrientation == UIDeviceOrientationLandscapeRight) {
        [self.playerStore dispatch:[self.playerAction actionForKey:TTVPlayerActionType_RotateToLandscapeFullScreen]];
    }
    else if (deviceOrientation == UIDeviceOrientationPortrait){
        [self.playerStore dispatch:[self.playerAction actionForKey:TTVPlayerActionType_RotateToInlineScreen]];
    }
}

//- (void)setRotateView:(UIView *)rotateView {
//    _rotateView = rotateView;
//    self.customAnimator.rotateView = rotateView;
//}
@end
