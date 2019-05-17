//
//  TTVPlayerGestureManager
//  Article
//
//  Created by lisa on 2018/1/28.
//
//

#import "TTVPlayerGestureManager.h"

#define kCancelThreshold 40

@interface TTVPlayerGestureManager () <UIGestureRecognizerDelegate> {
//    CGFloat _startVolume;
//    CGFloat _startBrightness;
    CGFloat _startTime;
    CGPoint _lastTranslation;
}

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

//@property (nonatomic, strong, readwrite) TTVideoVolumeService *volumeService;
//@property (nonatomic, strong, readwrite) TTVideoBrightnessService *brightnessService;

@property (nonatomic) TTVPlayerPanGestureDirection panDirection;
@property (nonatomic, assign) BOOL panStateChanged; // 标识pan手势是否发生changed


@end

@implementation TTVPlayerGestureManager

- (void)dealloc {
    _singleTapGesture.delegate = nil;
    _doubleTapGesture.delegate = nil;
    _panGesture.delegate = nil;
    [_panGesture removeTarget:self action:nil];
}

- (instancetype)initWithPlayerControlView:(UIView*)controlView {
    self = [super init];
    if (self) {
        self.controlView = controlView;
        self.supportedPanDirection = TTVPlayerPanGestureDirection_All;
//        [self _addObserver];
//        [self addObserver:self forKeyPath:@"supportedPanDirection" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"supportedPanDirection"]) {
//        NSLog(@"supportedPanDirection %d", self.supportedPanDirection);
//    }
//}

- (void)setControlView:(UIView *)controlView {
    _controlView = controlView;
    [self _buildGestures];
//    [self _buildBindings];
}

- (void)_buildGestures {
    [self.controlView addGestureRecognizer:self.singleTapGesture];
    [self.controlView addGestureRecognizer:self.panGesture];
//    if (self.videoPlayerDoubleTapEnable) {
        [self.controlView addGestureRecognizer:self.doubleTapGesture];
        [self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
        self.singleTapGesture.delaysTouchesBegan = YES;
//    }
}

- (void)_buildBindings {
//    RAC(self.brightnessService, enableBrightnessView) = RACObserve(self, isFullScreen);
//    @weakify(self);
//    [RACObserve(self, isFullScreen) subscribeNext:^(NSNumber *x) {
//        @strongify(self);
//        // 只有横屏全屏视频，才使用fullScreen样式
//        if (!self.supportsPortaitFullScreen) {
//            [[TTVVolumeManager shared] enableFullScreen:x.boolValue];
//            [[TTVBrightnessManager shared] enableFullScreen:x.boolValue];
//        }
//        [[TTVVolumeManager shared] dismissVolumeView:0];
//        [[TTVBrightnessManager shared] dismissBrightnessView:0];
//    }];
}

- (void)_addObserver {
//    @weakify(self);
//    self.volumeService.volumeDidChange = ^(float volume, BOOL changedBySystemVolumeButton, BOOL shouldShowTips) {
//        @strongify(self);
//        if (self.controlView.window) {
//            // 只显示当前播放器的音量调节view（TTVIDEOI-2606）
//
//            if (shouldShowTips && ![TTVVolumeManager shared].enableCustomVolumeView) {
//                [self.volumeService showAnimated:YES];
//            }
//
//            //system trigger, not user gesture trigger
//            if (self.panGesture.state != UIGestureRecognizerStateChanged) {
//                [NSObject cancelPreviousPerformRequestsWithTarget:self.volumeService selector:@selector(dismiss) object:nil];
//                [self.volumeService performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
//            }
//        }
//
//        if (self.volumeDidChanged) {
//            self.volumeDidChanged(volume ,changedBySystemVolumeButton);
//        }
//    };
}

#pragma mark -
#pragma mark public methods

- (void)enablePanGestures:(BOOL)enable {
    enable = enable && !self.isLocked;
    self.panGesture.enabled = enable;
}

- (void)enableSingleTapGesture:(BOOL)enable {
    self.singleTapGesture.enabled = enable;
}

- (void)enableDoubleTapGesture:(BOOL)enable {
//    self.doubleTapGesture.enabled = enable;
}
- (void)removeAllGesture {
    [self.controlView removeGestureRecognizer:self.singleTapGesture];
    [self.controlView removeGestureRecognizer:self.doubleTapGesture];
    [self.controlView removeGestureRecognizer:self.panGesture];
}

#pragma mark -
#pragma mark delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
//        NSLog(@"pan = %s",__FUNCTION__);
        // 全屏时默认支持所有手势 TODO?????
//        TTVPlayerPanGestureDirection supportedPanDirection = TTVPlayerPanGestureDirection_All;//self.controlView.isFullScreen ? TTVPlayerPanGestureDirection_All : self.panDirection;
        // 不支持任何手势
        if (TTVPlayerPanGestureDirection_Unknown == self.supportedPanDirection) {
            return NO;
        }
        // 起始位置
        CGPoint startPoint = [self.panGesture locationInView:self.panGesture.view];
        BOOL startInTopArea = startPoint.y < 30;
        if (startInTopArea) return NO;
        // 方向
        CGPoint velocity = [self.panGesture velocityInView:self.panGesture.view];
        TTVPlayerPanGestureDirection direction = [self _gestureDirectionInVelocity:velocity];
        switch (direction) {
            case TTVPlayerPanGestureDirection_Horizontal:
                return self.supportedPanDirection & TTVPlayerPanGestureDirection_Horizontal;
                break;
            case TTVPlayerPanGestureDirection_Vertical:
//
//                NSLog(@"TTVPlayerPanGestureDirection_Vertical%d,%d,%d,%d", self.supportedPanDirection & TTVPlayerPanGestureDirection_Vertical,TTVPlayerPanGestureDirection_Vertical,TTVPlayerPanGestureDirection_Horizontal,TTVPlayerPanGestureDirection_All);
//                NSLog(@"TTVPlayerPanGestureDirection_Vertical%d", self.supportedPanDirection | TTVPlayerPanGestureDirection_Vertical);
                return self.supportedPanDirection & TTVPlayerPanGestureDirection_Vertical;
                break;
            default:
                return YES;
                break;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"touchview = %@",touch.view);
    if (gestureRecognizer == self.doubleTapGesture && [touch.view isKindOfClass:[UIControl class]]) {
        if (self.controlShowingBySingleTap) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 为了fix右滑返回手势和播放器手势同时响应bug
    if (gestureRecognizer == self.panGesture && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [[otherGestureRecognizer.view nextResponder] isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark gesture methods

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapClick) {
        self.singleTapClick();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.doubleTapClick) {
        self.doubleTapClick();
    }
}

- (void)pan:(UIPanGestureRecognizer *)panRecognizer {
    UIGestureRecognizerState state = panRecognizer.state;
//    NSLog(@"pan = %@",panRecognizer);
    CGPoint translation = [panRecognizer translationInView:self.controlView];
    static BOOL touchRight = YES; // pan手势是否在屏幕右半边
    static BOOL swipeGestureChecking = NO; // swipe手势是否正在检测
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            // 识别为 pan 手势
            if (self.pan) {
                self.pan(panRecognizer, self.controlView, self.panDirection, NO);
            }
            
            swipeGestureChecking = YES;
            self.panStateChanged = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_dismissIfNeeded) object:nil];
            touchRight = [panRecognizer locationInView:self.controlView].x > self.controlView.width / 2;

            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongSelf;
                swipeGestureChecking = NO;
//                [self _updateStartVolume:[TTVVolumeManager shared].currentVolume];
//                [self _updateStartBrightness:[TTVBrightnessManager shared].currentBrightness];
            });
        }
            break;
        case UIGestureRecognizerStateChanged:
            if (!swipeGestureChecking) {
                [self _determineGestureDirectionWithTranslation:translation];
//                [self _determineActionWithTranslation:translation touchAtRight:touchRight];
                self.panStateChanged = YES;
                if (self.pan) {
                    self.pan(panRecognizer, self.controlView, self.panDirection, NO);
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (!swipeGestureChecking) {
                if (self.pan) {
                    self.pan(panRecognizer, self.controlView, self.panDirection, NO);
                }
                [self _resetPanDirection];
               
            } else {

                if (self.pan) {
                    self.pan(panRecognizer, self.controlView, self.panDirection, YES);
                }
                [self _resetPanDirection];
            }
            swipeGestureChecking = NO;
            
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark private methods
// 这样不会有问题么？TODO
- (void)_determineGestureDirectionWithTranslation:(CGPoint)translation {
    TTVPlayerPanGestureDirection direction = [self _gestureDirectionInTranslation:translation];
    if (self.panDirection == TTVPlayerPanGestureDirection_Unknown) {
        self.panDirection = direction;
    }
}

- (void)_resetPanDirection {
    self.panDirection = TTVPlayerPanGestureDirection_Unknown;
}

//- (void)_updateStartVolume:(CGFloat)volume {
//    _startVolume = volume;
//}
//
//- (void)_updateStartBrightness:(CGFloat)brightness {
//    _startBrightness = brightness;
//}


- (TTVPlayerPanGestureDirection)_gestureDirectionInVelocity:(CGPoint)velocity {
    double x = fabs(velocity.x);
    double y = fabs(velocity.y);
    return x > y ? TTVPlayerPanGestureDirection_Horizontal : TTVPlayerPanGestureDirection_Vertical;
}

- (TTVPlayerPanGestureDirection)_gestureDirectionInTranslation:(CGPoint)translation {
    TTVPlayerPanGestureDirection direction = TTVPlayerPanGestureDirection_Unknown;
    if (translation.x == 0) direction = TTVPlayerPanGestureDirection_Vertical;
    
    double radian = atan(fabs(translation.y) / fabs(translation.x));
    double angle = radian / M_PI * 180;
    
    if (angle >= 0 && angle <= 45) {
        direction = TTVPlayerPanGestureDirection_Horizontal;
    } else if (angle > 70 && angle <= 90) {
        direction = TTVPlayerPanGestureDirection_Vertical;
    }
    return direction;
}

- (void)_determineActionWithTranslation:(CGPoint)translation touchAtRight:(BOOL)touchRight {

//    switch (self.panDirection) {
//        case TTVPlayerPanGestureDirection_Horizontal:
//            [self _changeProgress:translation];
//            break;
//        case TTVPlayerPanGestureDirection_Vertical:
//            if (touchRight) {
//                [self _changeVolume:translation];
//            } else {
//                if ([TTDeviceHelper OSVersionNumber] < 9) {
//                    // 在iOS8的时候，由于全屏的时候播放器右半边hitTest无效，所以决定只保留调节音量的手势操作
//                    [self _changeVolume:translation];
//                } else {
//                    [self _changeBrightness:translation];
//                }
//            }
//            break;
//        default:
//            break;
//    }
}

- (BOOL)_panInCancelArea {
    CGPoint location = [self.panGesture locationInView:self.controlView];
    CGFloat leftArea = kCancelThreshold;
    CGFloat rightArea = self.controlView.width - kCancelThreshold;
    if (location.x < leftArea || location.x > rightArea) {
        return YES;
    }
    return NO;
}


//#pragma mark -
//#pragma mark Volume control
//
//- (void)_changeVolume:(CGPoint)translation {
//    if (!self.controlView || self.controlView.height == 0) return;
//
//    CGFloat normalizedY = -translation.y / self.controlView.height;
//    CGFloat newVolume = _startVolume + normalizedY;
//    [self.volumeService updateVolumeValue:newVolume];
//    [[TTVVolumeManager shared] updateVolumeValue:newVolume];
//    if (!self.panStateChanged) {
//        if (self.changeVolumeClick) {
//            self.changeVolumeClick();
//        }
//    }
//}
//
//#pragma mark -
//#pragma mark Brightness control
//
//- (void)_changeBrightness:(CGPoint)translation {
//    if (!self.controlView || self.controlView.height == 0) return;
//
//    CGFloat normalizedY = -translation.y / self.controlView.height;
//    CGFloat newBrightness = _startBrightness + normalizedY;
//    if (self.changeBrightnessClick) {
//        self.changeBrightnessClick(self.panStateChanged);
//        [[TTVBrightnessManager shared] updateBrightnessValue:newBrightness];
//
//        if (!self.panStateChanged) {
//            if (self.changeBrightnessClick) {
//                self.changeBrightnessClick();
//            }
//        }
//    }
//}


#pragma mark -
#pragma mark getters

- (UITapGestureRecognizer *)singleTapGesture {
    if (!_singleTapGesture) {
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTapGesture.delegate = self;
    }
    return _singleTapGesture;
}

- (UITapGestureRecognizer *)doubleTapGesture {
    if (!_doubleTapGesture) {
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        _doubleTapGesture.numberOfTapsRequired = 2;
        _doubleTapGesture.delegate = self;
    }
    return _doubleTapGesture;
    
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

//- (TTVideoVolumeService *)volumeService {
//    if (!_volumeService) {
//        _volumeService = [[TTVideoVolumeService alloc] init];
//    }
//    return _volumeService;
//}
//
//- (TTVideoBrightnessService *)brightnessService {
//    if (!_brightnessService) {
//        _brightnessService = [[TTVideoBrightnessService alloc] init];
//    }
//    return _brightnessService;
//}


@end


    
