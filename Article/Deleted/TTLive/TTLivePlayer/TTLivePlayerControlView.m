//
//  TTLivePlayerControlView.m
//  Article
//
//  Created by matrixzk on 29/09/2017.
//

#import "TTLivePlayerControlView.h"

#import "SSThemed.h"
#import <MediaPlayer/MPVolumeView.h>
#import "TTVSettingsConfiguration.h"
#import "TTVPlayerOrientationController.h"
#import "TTVFullscreeenController.h"
#import "TTVAudioActiveCenter.h"
#import <TTAlphaThemedButton.h>
#import "TTChatroomMoviePlayerControlTipView.h"
#import "KVOController.h"
#import "TTMovieBrightnessView.h"


typedef NS_ENUM(NSUInteger, TTLivePlayerControlViewGestureType)
{
    TTLivePlayerControlViewGestureTypeNone = 0,
    TTLivePlayerControlViewGestureTypeVolume,
    TTLivePlayerControlViewGestureTypeBrightness,
};

static CGFloat kVolumeStep = 0.005f;
static NSTimeInterval kTimeIntervalOfControlViewAutoHide = 2;

static CGFloat kHeightOfBottomView = 80;

@interface TTLivePlayerControlView () <TTVOrientationDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TTAlphaThemedButton *fullScreenButton;
@property (nonatomic, strong) UISlider *volumeViewSlider;
@property (nonatomic, strong) TTAlphaThemedButton *playButton;
@property(nonatomic, strong) TTMovieBrightnessView *brightnessView;
@property (nonatomic, strong) TTChatroomMoviePlayerControlTipView *tipView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) TTLivePlayerControlViewGestureType gestureType;
@property (nonatomic, strong) TTVPlayerOrientationController *orientationController; // 新转屏
@property (nonatomic, strong) TTVFullscreeenController *fullscreeenController; // 旧转屏
@property (nonatomic, strong) TTVAudioActiveCenter *audioActiveCenter;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak) UIView *rotateTargetView;

@end


@implementation TTLivePlayerControlView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//NSLog(@">>>>>> TTLivePlayerControlView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame playerStateStore:(TTVPlayerStateStore *)playerStateStore rotateTargetView:(UIView *)rotateTargetView
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _playerStateStore = playerStateStore;
        _rotateTargetView = rotateTargetView;
        
        [self setupGestureRecognizer];
        [self setupSubviews];
        [self setupScreenRotationController];
        
        [_tipView showTipView:TTChatroomMoviePlayerControlViewTipTypeLoading];
        _playButton.hidden = YES;
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:kTimeIntervalOfControlViewAutoHide];
    }
    return self;
}

- (void)setupGestureRecognizer
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    _panGesture.enabled = NO;
    [self addGestureRecognizer:_panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)setupSubviews
{
    [self addTipView];
    [self addTopView];
    [self addBottomView];
    [self addPlayButton];
    [self addBrightnessView];
    [self configureVolumeView];
}

- (void)setupScreenRotationController
{
    if (ttvs_isVideoNewRotateEnabled()) {
        _orientationController = [[TTVPlayerOrientationController alloc] init];
        _orientationController.delegate = self;
        _orientationController.playerStateStore = _playerStateStore;
        _orientationController.rotateView = _rotateTargetView;
    } else {
        _fullscreeenController = [[TTVFullscreeenController alloc] init];
        _fullscreeenController.delegate = self;
        _fullscreeenController.playerStateStore = _playerStateStore;
        _rotateTargetView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _fullscreeenController.rotateView = _rotateTargetView;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tipView.frame = self.bounds;
    
    [self refreshPlayButton];
    
    {
        // iPhone X 横屏适配
        CGFloat sideInset = MAX(self.tt_safeAreaInsets.left, self.tt_safeAreaInsets.right);
        _bottomView.frame = CGRectMake(sideInset, CGRectGetHeight(self.frame) - kHeightOfBottomView - self.tt_safeAreaInsets.bottom, CGRectGetWidth(self.frame) - 2*sideInset, kHeightOfBottomView + self.tt_safeAreaInsets.bottom);
        _topView.frame = CGRectMake(sideInset, 0, CGRectGetWidth(_bottomView.frame), CGRectGetHeight(_topView.frame));
    }
    
    if ([_brightnessView isIOS7IPad]) {
        _brightnessView.center = [_brightnessView currentCenterInIOS7IPad];
    } else {
        _brightnessView.centerX = _brightnessView.superview.width / 2;
        CGFloat diff = [self isFullScreen] ? 0 : 5;
        _brightnessView.centerY = _brightnessView.superview.height / 2 - diff;
    }
}

- (void)setLivePlayStatus:(TTLivePlayStatus)livePlayStatus
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _livePlayStatus = livePlayStatus;
        
        if (!self.playButton.hidden) {
            self.playButton.hidden = YES;
        }
        
        switch (_livePlayStatus) {
            case TTLivePlayStatusNotStarted: // 直播尚未开始
            {
                [self.tipView showTipView:TTChatroomMoviePlayerControlViewTipTypeLiveWaiting];
                self.tipView.hidden = NO;
            } break;
                
            case TTLivePlayStatusEnd: // 直播已经结束
            {
                [self.tipView showTipView:TTChatroomMoviePlayerControlViewTipTypeLiveOver];
                self.tipView.hidden = NO;
            } break;
                
            case TTLivePlayStatusLoading: // 加载中
            {
                [self.tipView showTipView:TTChatroomMoviePlayerControlViewTipTypeLoading];
                self.tipView.hidden = NO;
            } break;
                
            case TTLivePlayStatusPlaying:
            {
                self.tipView.hidden = YES;
                [self.tipView dismissTipViewAnimation];
            } break;
                
            case TTLivePlayStatusBreak: // 直播卡顿重试失败
            {
                [self.tipView showTipView:TTChatroomMoviePlayerControlViewTipTypeRetry];
                self.tipView.hidden = NO;
            } break;
                
            case TTLivePlayStatusFaild: // 直播失败
            {
                [self.tipView showTipView:TTChatroomMoviePlayerControlViewTipTypeFaild];
                self.tipView.hidden = NO;
            } break;
                
            default:
                break;
        }
    });
}


#pragma mark - Handle GestureRecognizer

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint locationPoint = [gestureRecognizer locationInView:self];
    CGPoint velocityPoint = [gestureRecognizer velocityInView:self];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _gestureType = TTLivePlayerControlViewGestureTypeNone;
        } break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            if (_gestureType == TTLivePlayerControlViewGestureTypeNone) {
                if (x < y) {
                    if (locationPoint.x < self.width / 2) {
                        _gestureType = TTLivePlayerControlViewGestureTypeBrightness;
                    } else {
                        _gestureType = TTLivePlayerControlViewGestureTypeVolume;
                    }
                }
            }
            if (_gestureType == TTLivePlayerControlViewGestureTypeVolume) {
                [self adjustVolume:(velocityPoint.y > 0 ? -kVolumeStep : kVolumeStep)];
                
            } else if (_gestureType == TTLivePlayerControlViewGestureTypeBrightness) {
                [self adjustBrightness:(velocityPoint.y > 0 ? -kVolumeStep : kVolumeStep)];
                if (_brightnessView.hidden) {
                    _brightnessView.hidden = NO;
                }
            }
        } break;
            
        case UIGestureRecognizerStateEnded:
        {
            _brightnessView.hidden = YES;
            _gestureType = TTLivePlayerControlViewGestureTypeNone;
        } break;
            
        case UIGestureRecognizerStateCancelled:
        {
            [UIView animateWithDuration:2.5 animations:^{
                _brightnessView.alpha = 0;
            } completion:^(BOOL finished) {
                _brightnessView.hidden = YES;
                _brightnessView.alpha = 1;
            }];
            _gestureType = TTLivePlayerControlViewGestureTypeNone;
        } break;
            
        default:
            break;
    }
}

- (void)handleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;
    
    _gestureType = TTLivePlayerControlViewGestureTypeNone;
    if (self.bottomView.hidden) {
        [self showControlViewAndAutoDismiss:!self.playButton.selected];
    } else {
        [self hideControlView];
    }
}


#pragma mark - Screen Rotation

- (void)exitFullScreenAnimated:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    [self setIsFullScreenState:NO];
    
    if (self.fullscreeenController) {
        [self.fullscreeenController exitFullScreen:animated completion:completion];
    } else {
        [self.orientationController exitFullScreen:animated completion:completion];
    }
}

- (void)enterFullScreenAnimated:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    [self setIsFullScreenState:YES];
    
    if (self.fullscreeenController) {
        [self.fullscreeenController enterFullScreen:animated completion:completion];
    } else {
        [self.orientationController enterFullScreen:animated completion:completion];
    }
}

- (void)setIsFullScreenState:(BOOL)isFullScreen
{
    if (self.playerStateStore.state.isFullScreen == isFullScreen) return;

    self.topView.hidden = YES;
    self.fullScreenButton.selected = isFullScreen;
    self.tipView.isFullScreen = isFullScreen;
    [self hideControlView];
    
    if (isFullScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _panGesture.enabled = YES;
        });
    } else {
        _panGesture.enabled = NO;
    }
}

- (BOOL)isFullScreen
{
    return self.playerStateStore.state.isFullScreen;
}


#pragma mark - TTVOrientationDelegate

- (void)forceVideoPlayerStop
{
}

- (BOOL)videoPlayerCanRotate
{
    BOOL shouldRotate = NO;
    if ([self.delegate respondsToSelector:@selector(ttlivePlayerViewShouldRotate)]) {
        shouldRotate = [self.delegate ttlivePlayerViewShouldRotate];
    }
    return !self.playerStateStore.state.isRotating && shouldRotate;
}


#pragma mark - UI

- (void)hideControlView
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = self.playButton.alpha = self.topView.alpha = 0;
        !self.controlViewHiddenAnimationBlock ? : self.controlViewHiddenAnimationBlock(YES);
    } completion:^(BOOL finished) {
        self.bottomView.hidden = self.playButton.hidden = self.topView.hidden = YES;
    }];
}

- (void)showControlViewAndAutoDismiss:(BOOL)autoDismiss
{
//    if (!self.tipView.hidden &&
//        (TTLivePlayStatusBreak == self.livePlayStatus || TTLivePlayStatusFaild == self.livePlayStatus || TTLivePlayStatusEnd == self.livePlayStatus)) {
//        return;
//    }
    
    if (!self.bottomView.hidden) {
        if (!autoDismiss) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self];
        }
        return;
    }
    
    self.bottomView.alpha = self.playButton.alpha = self.topView.alpha = 0;
    self.bottomView.hidden = self.topView.hidden = NO;
    self.playButton.hidden = !self.tipView.hidden;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = self.playButton.alpha = 1;
        if (self.playerStateStore.state.isFullScreen) {
            self.topView.alpha = 1;
        }
        !self.controlViewHiddenAnimationBlock ? : self.controlViewHiddenAnimationBlock(NO);
    } completion:^(BOOL finished) {
        if (autoDismiss) {
            [self performSelector:@selector(hideControlView) withObject:nil afterDelay:kTimeIntervalOfControlViewAutoHide];
        }
    }];
}

- (void)clickPlayButtonWhenLiveIsPlaying:(BOOL)isPlaying
{
    if (isPlaying) {
        self.playButton.selected = YES;
        [self showControlViewAndAutoDismiss:NO];
    } else {
        self.playButton.selected = NO;
        [self showControlViewAndAutoDismiss:YES];
    }
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (void)refreshPlayButton
{
    [_playButton setImage:[UIImage imageNamed:([TTDeviceHelper isPadDevice] || [self isFullScreen]) ? @"FullPause" : @"Pause"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:([TTDeviceHelper isPadDevice] || [self isFullScreen]) ? @"FullPlay" : @"Play"] forState:UIControlStateSelected];
}

- (void)addPlayButton
{
    if (_playButton) return;
    
    _playButton = [[TTAlphaThemedButton alloc] init];
    _playButton.backgroundColor = [UIColor clearColor];
    _playButton.enableHighlightAnim = NO;
    _playButton.hidden = YES;
    WeakSelf;
    [_playButton addTarget:self withActionBlock:^{
        StrongSelf;
        BOOL isPlaying = !self.playButton.isSelected;
        if ([self.delegate respondsToSelector:@selector(ttlivePlayerControlViewPlayButtonDidPressed:isPlaying:)]) {
            [self.delegate ttlivePlayerControlViewPlayButtonDidPressed:self isPlaying:isPlaying];
        }
        
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
        if (!isPlaying) {
            [self performSelector:@selector(hideControlView)
                       withObject:nil
                       afterDelay:kTimeIntervalOfControlViewAutoHide];
        }
        self.playButton.selected = !self.playButton.selected;
    } forControlEvent:UIControlEventTouchUpInside];
    [self refreshPlayButton];
    [self addSubview:_playButton];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)addTopView
{
    if (_topView) return;
    
    _topView = [UIView new];
    _topView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 120);
    _topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_topView];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopShadow"]];
    bgImgView.userInteractionEnabled = YES;
    [_topView addSubview:bgImgView];
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topView);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"white_lefterbackicon_titlebar"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(12, 30, 24, 24);
    backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -26, -84);
    WeakSelf;
    [backButton addTarget:self withActionBlock:^{
        StrongSelf;
        [self exitFullScreenAnimated:YES completion:^(BOOL finished) {}];
    } forControlEvent:UIControlEventTouchUpInside];
    [_topView addSubview:backButton];
    
    
    _titleLabel = [UILabel new];
    _titleLabel.centerY = backButton.centerY;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:19];
    _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
    _titleLabel.numberOfLines = 2;
    [_topView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backButton.mas_right).offset(5);
        make.right.equalTo(_topView.mas_right).offset(-5);
        make.centerY.equalTo(backButton);
    }];
    
    _topView.hidden = YES;
}

- (void)addBottomView
{
    if (_bottomView) return;
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kHeightOfBottomView, CGRectGetWidth(self.frame), kHeightOfBottomView)];
    _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_bottomView];
    
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomShadow"]];
    bgImgView.frame = _bottomView.bounds;
    bgImgView.userInteractionEnabled = YES;
    bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_bottomView addSubview:bgImgView];
    
    
    CGFloat kHeight = 40;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_bottomView.frame) - kHeight, CGRectGetWidth(self.frame), kHeight)];
    bgView.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground5] colorWithAlphaComponent:0.7];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [_bottomView addSubview:bgView];
    
    
    _fullScreenButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    [_bottomView addSubview:_fullScreenButton];
    _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -22, -12, -14);
    UIImage *img = [UIImage imageNamed:@"Fullscreen"];
    [_fullScreenButton setImage:img forState:UIControlStateNormal];
    [_fullScreenButton setImage:[UIImage imageNamed:@"Fullscreen_exit"] forState:UIControlStateSelected];
    [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bgImgView.mas_right).offset(-14);
        make.centerY.equalTo(@(bgImgView.center.y - 20));
        make.size.mas_equalTo(img.size);
    }];
    WeakSelf;
    [_fullScreenButton addTarget:self withActionBlock:^{
        StrongSelf;
        if (self.playerStateStore.state.isFullScreen) {
            [self exitFullScreenAnimated:YES completion:^(BOOL finished) {}];
        } else {
            [self enterFullScreenAnimated:YES completion:^(BOOL finished) {}];
        }
    } forControlEvent:UIControlEventTouchUpInside];
}

- (void)addTipView
{
    if (_tipView) return;
    
    _tipView = [TTChatroomMoviePlayerControlTipView new];
    _tipView.videoType = TTChatroomVideoTypeLive;
    _tipView.movieControlView = self;
    [self addSubview:_tipView];
    WeakSelf;
    [_tipView.retryButtonWord addTarget:self withActionBlock:^{
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(ttlivePlayerControlViewRetryButtonDidPressed:)]) {
            [self.delegate ttlivePlayerControlViewRetryButtonDidPressed:self];
        }
    } forControlEvent:UIControlEventTouchUpInside];
}

- (void)addBrightnessView
{
    if (_brightnessView) return;
    
     _brightnessView = [[TTMovieBrightnessView alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
    _brightnessView.hidden = YES;
    [self addSubview:_brightnessView];
}

- (void)setStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView
{
    if (!statusView || !numOfParticipantsView) return;
    
    [_bottomView addSubview:statusView];
    [_bottomView addSubview:numOfParticipantsView];
    
    CGFloat kPadding = 14;
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomView.mas_left).offset(kPadding);
        make.centerY.equalTo(_fullScreenButton);
    }];
    [numOfParticipantsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(statusView.mas_right).offset(kPadding);
        make.centerY.equalTo(_fullScreenButton);
    }];
}


#pragma mark - Volume & ScreenBrightness

- (void)configureVolumeView
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)adjustVolume:(CGFloat)step
{
    float systemVolume = _volumeViewSlider.value;
    systemVolume += step;
    [_volumeViewSlider setValue:systemVolume animated:NO];
    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)adjustBrightness:(CGFloat)step
{
    CGFloat curBrightness = [UIScreen mainScreen].brightness;
    CGFloat afterBrightness = curBrightness + step;
    if (afterBrightness < 0) {
        afterBrightness = 0;
    }
    if (afterBrightness > 1) {
        afterBrightness = 1;
    }
    [UIScreen mainScreen].brightness = afterBrightness;
}

@end
