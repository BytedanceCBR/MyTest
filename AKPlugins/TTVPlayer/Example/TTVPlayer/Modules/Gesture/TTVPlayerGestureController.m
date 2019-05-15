//
//  TTVPlayerGestureController.m
//  Article
//
//  Created by liuty on 2017/1/8.
//
//

#import "TTVPlayerGestureController.h"
#import "TTVVolumeManager.h"
#import "TTVBrightnessManager.h"

#import <ReactiveObjC/ReactiveObjC.h>

#define kCancelThreshold 40

@interface TTVPlayerGestureController () <UIGestureRecognizerDelegate> {
    CGFloat _startVolume;
    CGFloat _startBrightness;
    CGFloat _startTime;
    CGPoint _lastTranslation;
}

@property (nonatomic, weak) UIView *controlView;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong, readwrite) TTVideoVolumeService *volumeService;
@property (nonatomic, strong, readwrite) TTVideoBrightnessService *brightnessService;
@property (nonatomic, strong, readwrite) TTPlayerProgressHUDView *progressView;

@property (nonatomic) TTVPlayerGestureDirection panDirection;
@property (nonatomic, assign) BOOL panStateChanged; // 标识pan手势是否发生changed
@property (nonatomic, assign, readwrite) BOOL progressSeeking;
@property (nonatomic, assign) BOOL fromProgress;

@end

@implementation TTVPlayerGestureController

- (void)dealloc {
    _singleTapGesture.delegate = nil;
    _doubleTapGesture.delegate = nil;
    _panGesture.delegate = nil;
    [_panGesture removeTarget:self action:nil];
    [_progressView removeFromSuperview];
}

- (instancetype)initWithPlayerControlView:(UIView *)controlView {
    self = [super init];
    if (self) {
        self.controlView = controlView;
        [self _buildGestures];
        [self _buildBindings];
        [self _addObserver];
    }
    return self;
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
    RAC(self.brightnessService, enableBrightnessView) = RACObserve(self, isFullScreen);
    @weakify(self);
    [RACObserve(self, isFullScreen) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        // 只有横屏全屏视频，才使用fullScreen样式
        if (!self.supportsPortaitFullScreen) {
            [[TTVVolumeManager shared] enableFullScreen:x.boolValue];
            [[TTVBrightnessManager shared] enableFullScreen:x.boolValue];
        }
        [[TTVVolumeManager shared] dismissVolumeView:0];
        [[TTVBrightnessManager shared] dismissBrightnessView:0];
    }];
}

- (void)_addObserver {
    @weakify(self);
    self.volumeService.volumeDidChange = ^(float volume, BOOL changedBySystemVolumeButton, BOOL shouldShowTips) {
        @strongify(self);
        if (self.controlView.window) {
            // 只显示当前播放器的音量调节view（TTVIDEOI-2606）
            
            if (shouldShowTips && ![TTVVolumeManager shared].enableCustomVolumeView) {
                [self.volumeService showAnimated:YES];
            }
            
            //system trigger, not user gesture trigger
            if (self.panGesture.state != UIGestureRecognizerStateChanged) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self.volumeService selector:@selector(dismiss) object:nil];
                [self.volumeService performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
            }
        }
        
        if (self.volumeDidChanged) {
            self.volumeDidChanged(volume ,changedBySystemVolumeButton);
        }
    };
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
    self.doubleTapGesture.enabled = enable;
}

- (void)enableProgressHub:(BOOL)enable {
    self.progressView.hidden = !enable;
}

- (void)cancelPanGesture {
    if (self.panGesture.enabled) {
        if (self.isProgressSeeking) {
            if (!self.isPlaybackEnded &&
                self.panDirection == TTVPlayerGestureDirectionHorizontal && self.seekingToProgress) {
                self.seekingToProgress(self.progressView.currentProgress, self.fromProgress, [self _panInCancelArea], YES);
            }
            [self _resetPanDirection];
            self.panGesture.enabled = NO;
            self.panGesture.enabled = YES;
        }
    }
}

#pragma mark -
#pragma mark delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
//        NSLog(@"pan = %s",__FUNCTION__);
        // 全屏时默认支持所有手势
        TTVPlayerGestureDirection supportedDirection = TTVPlayerGestureDirectionAll;//self.isFullScreen ? TTVPlayerGestureDirectionAll : self.panDirection;
        // 不支持任何手势
        if (TTVPlayerGestureDirectionUnknown == supportedDirection) {
            return NO;
        }
        // 起始位置
        CGPoint startPoint = [self.panGesture locationInView:self.panGesture.view];
        BOOL startInTopArea = startPoint.y < 30;
        if (startInTopArea) return NO;
        // 方向
        CGPoint velocity = [self.panGesture velocityInView:self.panGesture.view];
        TTVPlayerGestureDirection direction = [self _gestureDirectionInVelocity:velocity];
        switch (direction) {
            case TTVPlayerGestureDirectionHorizontal:
                return supportedDirection & TTVPlayerGestureDirectionHorizontal;
                break;
            case TTVPlayerGestureDirectionVertical:
                return supportedDirection & TTVPlayerGestureDirectionVertical;
                break;
            default:
                return YES;
                break;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    NSLog(@"touchview = %@",touch.view);
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

- (void)pan:(UIPanGestureRecognizer *)pan {
    self.isFullScreen = YES;
    UIGestureRecognizerState state = pan.state;
    NSLog(@"pan = %@",pan);
    CGPoint translation = [pan translationInView:self.controlView];
    static BOOL touchRight = YES; // pan手势是否在屏幕右半边
    static BOOL swipeGestureChecking = NO; // swipe手势是否正在检测
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            swipeGestureChecking = YES;
            self.panStateChanged = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_dismissIfNeeded) object:nil];
            touchRight = [pan locationInView:self.controlView].x > self.controlView.width / 2;
            
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongSelf;
                swipeGestureChecking = NO;
                [self _updateStartVolume:[TTVVolumeManager shared].currentVolume];
                [self _updateStartBrightness:[TTVBrightnessManager shared].currentBrightness];
                [self _updateStartTime:self.currentPlayingTime];
            });
        }
            break;
        case UIGestureRecognizerStateChanged:
            if (!swipeGestureChecking) {
                [self _determineGestureDirectionWithTranslation:translation];
                [self _determineActionWithTranslation:translation touchAtRight:touchRight];
                self.panStateChanged = YES;
            }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (!swipeGestureChecking) {
                [self _endProgressSeeking];
                [self _resetPanDirection];
                [self _dismissIfNeeded];
            } else {
                [self _swipeProgressSeekingForVelocity:[pan velocityInView:self.controlView]];
                [self _resetPanDirection];
                [self performSelector:@selector(_dismissIfNeeded) withObject:nil afterDelay:.6f];
            }
            swipeGestureChecking = NO;
            
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark private methods

- (void)_determineGestureDirectionWithTranslation:(CGPoint)translation {
    TTVPlayerGestureDirection direction = [self _gestureDirectionInTranslation:translation];
    if (self.panDirection == TTVPlayerGestureDirectionUnknown) {
        self.panDirection = direction;
    }
}

- (void)_resetPanDirection {
    self.panDirection = TTVPlayerGestureDirectionUnknown;
}

- (void)_updateStartVolume:(CGFloat)volume {
    _startVolume = volume;
}

- (void)_updateStartBrightness:(CGFloat)brightness {
    _startBrightness = brightness;
}

- (void)_updateStartTime:(CGFloat)time {
    _startTime = time;
    CGFloat fromProgress = 0;
    if (self.duration > 0) {
        fromProgress = _startTime / self.duration;
    }
    self.fromProgress = fromProgress;
}

- (TTVPlayerGestureDirection)_gestureDirectionInVelocity:(CGPoint)velocity {
    double x = fabs(velocity.x);
    double y = fabs(velocity.y);
    return x > y ? TTVPlayerGestureDirectionHorizontal : TTVPlayerGestureDirectionVertical;
}

- (TTVPlayerGestureDirection)_gestureDirectionInTranslation:(CGPoint)translation {
    TTVPlayerGestureDirection direction = TTVPlayerGestureDirectionUnknown;
    if (translation.x == 0) direction = TTVPlayerGestureDirectionVertical;
    
    double radian = atan(fabs(translation.y) / fabs(translation.x));
    double angle = radian / M_PI * 180;
    
    if (angle >= 0 && angle <= 45) {
        direction = TTVPlayerGestureDirectionHorizontal;
    } else if (angle > 70 && angle <= 90) {
        direction = TTVPlayerGestureDirectionVertical;
    }
    return direction;
}

- (void)_determineActionWithTranslation:(CGPoint)translation touchAtRight:(BOOL)touchRight {
    switch (self.panDirection) {
        case TTVPlayerGestureDirectionHorizontal:
            [self _changeProgress:translation];
            break;
        case TTVPlayerGestureDirectionVertical:
            if (touchRight) {
                [self _changeVolume:translation];
            } else {
                if ([TTDeviceHelper OSVersionNumber] < 9) {
                    // 在iOS8的时候，由于全屏的时候播放器右半边hitTest无效，所以决定只保留调节音量的手势操作
                    [self _changeVolume:translation];
                } else {
                    [self _changeBrightness:translation];
                }
            }
            break;
        default:
            break;
    }
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

- (void)_dismissIfNeeded {
    [self setProgressViewShow:NO];
}

- (void)setProgressHubShow:(BOOL)show {
    [self setProgressViewShow:show];
}

- (void)setProgressViewShow:(BOOL)show {
    show = YES;
    if (show) {
        self.progressView.frame = CGRectMake(100, 100, 100, 100);//self.controlView.frame;
        [self.progressView show];
    } else {
        [self.progressView dismiss];
    }
    if (self.ProgressViewShowBlock) {
        self.ProgressViewShowBlock(show);
    }
}

#pragma mark -
#pragma mark Volume control

- (void)_changeVolume:(CGPoint)translation {
    if (!self.controlView || self.controlView.height == 0) return;
    
    CGFloat normalizedY = -translation.y / self.controlView.height;
    CGFloat newVolume = _startVolume + normalizedY;
    [self.volumeService updateVolumeValue:newVolume];
    [[TTVVolumeManager shared] updateVolumeValue:newVolume];
    if (!self.panStateChanged) {
        if (self.changeVolumeClick) {
            self.changeVolumeClick();
        }
    }
}

#pragma mark -
#pragma mark Brightness control

- (void)_changeBrightness:(CGPoint)translation {
    if (!self.controlView || self.controlView.height == 0) return;
    
    CGFloat normalizedY = -translation.y / self.controlView.height;
    CGFloat newBrightness = _startBrightness + normalizedY;
    if (self.changeBrightnessClick) {
        self.changeBrightnessClick(self.panStateChanged);
        [[TTVBrightnessManager shared] updateBrightnessValue:newBrightness];
        
        if (!self.panStateChanged) {
            if (self.changeBrightnessClick) {
                self.changeBrightnessClick();
            }
        }
    }
}

#pragma mark -
#pragma mark Progress control

- (void)_changeProgress:(CGPoint)translation {
    if (!self.isNoneFullScreenPlayerGestureEnabled) {
        if (!self.isFullScreen) {
            [self.progressView dismiss];
            return;
        }
    }
    self.progressSeeking = YES;
    
    if (!self.controlView || self.controlView.height == 0) return;
    
    //拖动规则：超过threshold的视频：滑动全屏 = 时长的一半；低于threshold：滑动全屏 = 时长
    CGFloat threshold = 10 * 60;//10min
    CGFloat maxSeekingTime = self.duration <= threshold ? self.duration : (self.duration - threshold) * .2f + threshold;
    CGFloat validWidth = (self.controlView.width - kCancelThreshold * 2) * 0.8;
    CGFloat normalizedX = translation.x / validWidth * maxSeekingTime;
    CGFloat progress = (_startTime + normalizedX) / self.duration;
    
    self.progressView.totalTime = self.duration;
    [self setProgressViewShow:YES];
    [self.progressView updateProgress:progress];
    if (translation.x > _lastTranslation.x) {
        [self.progressView setForward:YES];
    } else if (translation.x < _lastTranslation.x) {
        [self.progressView setForward:NO];
    }
    
    self.progressView.showCancel = [self _panInCancelArea];
    
    _lastTranslation = translation;
    
    if (self.seekingToProgress) {
        self.seekingToProgress(progress, self.fromProgress , [self _panInCancelArea], NO);
    }
}

- (void)_endProgressSeeking {
    self.progressSeeking = NO;
    if (!self.isPlaybackEnded &&
        self.panDirection == TTVPlayerGestureDirectionHorizontal) {
        if (self.seekingToProgress) {
            self.seekingToProgress(self.progressView.currentProgress, self.fromProgress, [self _panInCancelArea], YES);
        }
    }
}

- (void)_swipeProgressSeekingForVelocity:(CGPoint)velocity {
    if (fabs(velocity.x) > fabs(velocity.y) && fabs(velocity.x) > 500) {
        CGFloat progress = .0f;
        if (velocity.x > 0) {
            progress = MIN(1.f, (self.currentPlayingTime + 10.f) / self.duration);
            [self.progressView setForward:YES];
        } else if (velocity.x < 0) {
            progress = MAX(.0f, (self.currentPlayingTime - 10.f) / self.duration);
            [self.progressView setForward:NO];
        }
        self.progressView.totalTime = self.duration;
        [self setProgressViewShow:YES];
        [self.progressView updateProgress:progress];
        CGFloat fromProgress = 0;
        if (self.duration > 0) {
            fromProgress = _startTime / self.duration;
        }
        
        if (self.swipeProgressSeeking){
            self.swipeProgressSeeking(fromProgress,self.progressView.currentProgress);
        };
    }
}

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

- (TTVideoVolumeService *)volumeService {
    if (!_volumeService) {
        _volumeService = [[TTVideoVolumeService alloc] init];
    }
    return _volumeService;
}

- (TTVideoBrightnessService *)brightnessService {
    if (!_brightnessService) {
        _brightnessService = [[TTVideoBrightnessService alloc] init];
    }
    return _brightnessService;
}

- (TTPlayerProgressHUDView *)progressView {
    if (!_progressView) {
        _progressView = [[TTPlayerProgressHUDView alloc] init];
        [self.controlView addSubview:_progressView];
        _progressView.center = self.controlView.center;
    }
    return _progressView;
}

@end


    
