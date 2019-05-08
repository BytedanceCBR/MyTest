//
//  TTVPlayerControlView.m
//  Article
//
//  Created by panxiang on 2017/5/16.
//
//

#import "TTVPlayerControlView.h"
#import "TTVPlayerStateAction.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import "TTVPlayerStateStore.h"
#import <Masonry.h>
#import "UIButton+TTAdditions.h"
#import "TTMovieAdjustView.h"
#import "TTMovieBrightnessView.h"
#import "TTMoviePlayerControlSliderView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIViewAdditions.h"
#import "KVOController.h"
#import "TTVFluxDispatcher.h"
#import "TTVResolutionSelect.h"
#import "TTVResolutionStore.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "TTTrackerWrapper.h"
#import "TTVPlayerControlBottomView.h"

#define kControlViewAutoHiddenTime 2

static CGFloat kToolBarHeight;
extern BOOL ttvs_isDoubleTapForDiggEnabled(void);
extern NSString *ttv_getFormattedTimeStrOfPlay(NSTimeInterval playTimeInterval);

#define kShowDetailButtonW 60
#define kShowDetailButtonH 20
#define kShowDetailButtonGap 6

#define kVolumeStep 0.005f
#define kProgressStep 0.3f

typedef NS_ENUM(NSUInteger, ExploreMoviePlayerControlViewGestureType)
{
    ExploreMoviePlayerControlViewGestureTypeNone = 0,
    ExploreMoviePlayerControlViewGestureTypeVolume,
    ExploreMoviePlayerControlViewGestureTypeProgress,
    ExploreMoviePlayerControlViewGestureTypeBrightness,
};

static const CGFloat kTitleBarHeight = 120;
static const CGFloat kBottomBarHeight = 80;

@interface TTVPlayerControlView() <TTVPlayerControlBottomViewDelegate ,TTVResolutionSelectDelegate, UIGestureRecognizerDelegate>
{
    ExploreMoviePlayerControlViewGestureType _gestureType;
    CGFloat _progressAtTouchBegin;
    NSTimeInterval _currentWatchProgress;
    CFAbsoluteTime _lastTimeReportVolumeChanged;
    
    CGFloat _startVolume;
    CGFloat _startBrightness;
}

@property (nonatomic, strong) UIView *dimBackgrView;
@property (nonatomic, strong) TTMoviePlayerControlTopView *titleView;
@property (nonatomic, assign) CGFloat preVolume;
@property(nonatomic, strong)SSThemedButton * playButton;
//详情页播放时与playbutton行为一致，结束后，盖在结束页面，全屏时／列表页播放时隐藏 add:626
@property(nonatomic, strong)SSThemedButton * moreButton;
@property(nonatomic, strong)UISlider *volumeViewSlider;

@property(nonatomic, strong)TTMovieAdjustView *adjustView;
@property(nonatomic, strong)TTMovieBrightnessView *brightnessView;
@property(nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property(nonatomic, strong)NSTimer *playbackControlViewTimer;
@property(nonatomic, strong)TTVResolutionSelect *resolutionSelect;
//@property(nonatomic, strong ,readonly)UIView <TTVPlayerControlBottomView, TTVPlayerContext> *bottomBarView;
@property(nonatomic, strong)ExploreMovieMiniSliderView * miniSlider;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *dummySingleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation TTVPlayerControlView
- (void)dealloc
{
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    _bottomBarView.delegate = nil;
    self.delegate = nil;
    if (_brightnessView.superview) {
        [_brightnessView removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _preVolume = -1;
        kToolBarHeight = [TTDeviceHelper isPadDevice] ? 50 : 45;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;

        //调节进度，声音相关
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.enabled = NO;
        [self addGestureRecognizer:_panGesture];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        self.singleTap = tapGesture;
        [self addGestureRecognizer:tapGesture];
        
        BOOL doubleTapForDiggEnabled = ttvs_isDoubleTapForDiggEnabled();
        if (doubleTapForDiggEnabled) {
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            doubleTap.numberOfTapsRequired = 2;
            self.doubleTap = doubleTap;
            doubleTap.delegate = self;
            [self addGestureRecognizer:doubleTap];
            [tapGesture requireGestureRecognizerToFail:doubleTap];
            
            UITapGestureRecognizer *dummySingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDummySingleTap:)];
            dummySingleTap.delegate = self;
            self.dummySingleTap = dummySingleTap;
            [self addGestureRecognizer:dummySingleTap];
        }
        
        _dimBackgrView = [[UIView alloc] initWithFrame:self.bounds];
        _dimBackgrView.backgroundColor = [UIColor clearColor];
        _dimBackgrView.userInteractionEnabled = NO;
        [self addSubview:_dimBackgrView];
        //顶部标题视图
        [self ttv_addTopView];
        
        //播放按钮
        [self ttv_addPlayButton];
        [self ttv_addAdjustView];
        [self p_configureVolumeView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

- (void)setDimAreaEdgeInsetsWhenFullScreen:(UIEdgeInsets)dimAreaEdgeInsetsWhenFullScreen {
    _dimAreaEdgeInsetsWhenFullScreen = dimAreaEdgeInsetsWhenFullScreen;
    self.dimBackgrView.frame = UIEdgeInsetsInsetRect(self.bounds, dimAreaEdgeInsetsWhenFullScreen);
    if (self.playerStateStore.state.isFullScreen && !self.playerStateStore.state.enableRotate && dimAreaEdgeInsetsWhenFullScreen.bottom < 0) {
        self.miniSlider.bottom = self.bounds.size.height;
    } else {
        self.miniSlider.bottom = self.bounds.size.height - dimAreaEdgeInsetsWhenFullScreen.bottom;
    }
    
    self.titleView.dimAreaEdgeInsetsWhenFullScreen = UIEdgeInsetsMake(dimAreaEdgeInsetsWhenFullScreen.top, dimAreaEdgeInsetsWhenFullScreen.left, 0, dimAreaEdgeInsetsWhenFullScreen.right);
    if ([self.bottomBarView respondsToSelector:@selector(setDimAreaEdgeInsetsWhenFullScreen:)]) {
        self.bottomBarView.dimAreaEdgeInsetsWhenFullScreen = UIEdgeInsetsMake(0, dimAreaEdgeInsetsWhenFullScreen.left, dimAreaEdgeInsetsWhenFullScreen.bottom, dimAreaEdgeInsetsWhenFullScreen.right);
    }
}

- (void)ttv_addTopView
{
    _titleView = [[TTMoviePlayerControlTopView alloc] initWithFrame:CGRectZero];
    _titleView.hidden = YES;
    [self addSubview:_titleView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [_titleView addGestureRecognizer:tapGesture];

    [_titleView.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_titleView.shareButton addTarget:self action:@selector(shareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_titleView.moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _titleView.backButton.hidden = YES;
    _titleView.shareButton.hidden = YES;
    _titleView.moreButton.hidden = YES;
}

- (void)ttv_addBottomBar
{
    if (!self.bottomBarView || !([self.bottomBarView conformsToProtocol:@protocol(TTVPlayerControlBottomView)] && [self.bottomBarView conformsToProtocol:@protocol(TTVPlayerContext)])) {
        _bottomBarView = [[TTVPlayerControlBottomView alloc] init];
    }
    _bottomBarView.playerStateStore = self.playerStateStore;
    [self addSubview:_bottomBarView];
    _bottomBarView.delegate = self;
    
    _miniSlider = [[ExploreMovieMiniSliderView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-2, self.bounds.size.width, 2)];
    _miniSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    _miniSlider.userInteractionEnabled = NO;
    [self addSubview:_miniSlider];
    _miniSlider.hidden = NO;
    _bottomBarView.hidden = YES;
    if (self.playButton) {
        [self bringSubviewToFront:self.playButton];
    }
}

- (void)ttv_addResolutionSelect
{
    if (!self.resolutionSelect) {
        self.resolutionSelect = [[TTVResolutionSelect alloc] init];
        self.resolutionSelect.bottomBarView = _bottomBarView;
        self.resolutionSelect.superView = self.superview; // 为了兼容特卖浮层 将层级上移
        self.resolutionSelect.delegate = self;
    }
}

- (void)ttv_addPlayButton
{
    self.playButton = [[SSThemedButton alloc] init];
    _playButton.backgroundColor = [UIColor clearColor];
    [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _playButton.hidden = YES;
    [self addSubview:_playButton];
    [self setPlaybuttonIsPlaying:NO];
}

- (void)ttv_addMoreButton
{
    [self.moreButton removeFromSuperview];
    self.moreButton = [[SSThemedButton alloc] init];
    _moreButton.backgroundColor = [UIColor clearColor];
    [_moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton setImage:[UIImage themedImageNamed:@"new_morewhite_titlebar"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage themedImageNamed:@"new_morewhite_titlebar"] forState:UIControlStateHighlighted];
    _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    _moreButton.hidden = YES;
    [self addSubview:_moreButton];
}


- (void)ttv_addAdjustView
{
    //调节亮度相关
    _brightnessView = [[TTMovieBrightnessView alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
    _brightnessView.hidden = YES;

    _adjustView = [[TTMovieAdjustView alloc] initWithFrame:CGRectMake(0, 0, 155, [TTMovieAdjustView heightWithMode:TTMovieAdjustViewModeFullScreen])];
    _adjustView.hidden = YES;
    [self addSubview:_adjustView];
}

- (void)ttv_orientationState
{
    if (self.playerStateStore.state.isFullScreen) {
        if (self.playerStateStore.state.isRotating) {//正在进入全屏动画状态
            if (!(self.bottomBarView.hidden || self.bottomBarView.alpha == 0)) {
                [self ttv_HiddenToAlpha:_titleView];
                _titleView.alpha = 1;
            }
        }
    }else{
        if (self.playerStateStore.state.isRotating) {//退出全屏动画状态
            if (!self.playerStateStore.state.showTitleInNonFullscreen) {
                _titleView.hidden = YES;
                [self setToolBarHidden:YES];
            }
            if (self.playerStateStore.state.titleBarViewAlwaysHide) {
                _titleView.hidden = YES;
                [self setToolBarHidden:YES];
            }
        }
    }
}

- (void)ttv_playbackState
{
    TTVVideoPlaybackState state = self.playerStateStore.state.playbackState;
    switch (state) {
        case TTVVideoPlaybackStateError:{
            self.playerStateStore.state.isDragging = NO;
            [self setPlaybuttonIsPlaying:NO];
            [self ttv_hiddenElement:YES];
        }
            break;
        case TTVVideoPlaybackStatePaused:{
            [self setPlaybuttonIsPlaying:NO];
        }
            break;
        case TTVVideoPlaybackStatePlaying:{
            [self setPlaybuttonIsPlaying:YES];
            [self ttv_restartTimer];
        }
            break;
        case TTVVideoPlaybackStateFinished:{
            self.playerStateStore.state.isDragging = NO;
            [self setPlaybuttonIsPlaying:NO];
            self.playButton.hidden = YES;
            [self ttv_hiddenElement:YES];
            self.moreButton.hidden = YES;
            if ([self isFullScreen] && !self.playerStateStore.state.disableExitFullScreenWhenPlayEnd) {
                // 原视频播放完成 如果贴片数据获取成功并且没有被展示过则不退出全屏
                [self fullScreenButtonClicked];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark kvo
- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self settingIsFullScreen:self.playerStateStore.state.isFullScreen];
        [self ttv_orientationState];
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self ttv_playbackState];
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (![self isDragging]) {
            [self ttv_refreshDurationLabel:self.duration currentPlaybackTime:self.currentPlaybackTime];
        }
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,watchedProgress) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self setWatchedProgress:[[change valueForKey:NSKeyValueChangeNewKey] longLongValue]];
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,cacheProgress) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self setCacheProgress:[[change valueForKey:NSKeyValueChangeNewKey] longLongValue]];
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,tipType) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVPlayerControlTipViewType value = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        if (value != TTVPlayerControlTipViewTypeNone && value != TTVPlayerControlTipViewTypeUnknow) {
            self.titleView.hidden = YES;
            self.bottomBarView.hidden = YES;
            self.dimBackgrView.backgroundColor = [UIColor clearColor];
            self.playButton.hidden = YES;
        }
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,showTitleInNonFullscreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (!self.playerStateStore.state.showTitleInNonFullscreen) {
            if (![self isFullScreen]) {
                self.titleView.hidden = YES;
            }
        }
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,enableRotate) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.brightnessView.enableRotate = self.playerStateStore.state.enableRotate;
    }];
    
}

- (void)ttv_refreshDurationLabel:(NSTimeInterval)duration currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    if (duration <= 0 || currentPlaybackTime < 0) {
        [self updateTimeLabel:@"00:00" durationLabel:@"00:00"];
        return;
    }
    if (currentPlaybackTime > duration) {
        currentPlaybackTime = duration;
    }
    [self updateTimeLabel:ttv_getFormattedTimeStrOfPlay(currentPlaybackTime) durationLabel:ttv_getFormattedTimeStrOfPlay(duration)];
}

- (void)ttv_hiddenTitleView:(BOOL)hidden
{
    self.titleView.hidden = hidden;
    if ([self shouldHiddenTtitle]) {
        self.titleView.hidden = hidden;
    }
}

- (BOOL)shouldHiddenTtitle
{
    if (!self.playerStateStore.state.showTitleInNonFullscreen && ![self isFullScreen]) {
        return YES;
    }
    if (self.playerStateStore.state.titleBarViewAlwaysHide) {
        return YES;
    }
    return NO;
}

- (void)ttv_hiddenElement:(BOOL)hidden
{
    if (![self isStopped]) {
        [self setToolBarHidden:hidden];
        self.playButton.hidden = hidden;
        [self ttv_hiddenTitleView:hidden];
    }
}

#pragma mark - event & gesture

- (void)bgButtonClicked{
    [self ttv_hiddenElement:!_bottomBarView.hidden];
}

- (void)backButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(controlViewBackButtonClicked:)]) {
        self.playerStateStore.state.isFullScreenButtonType = YES;
        [self.delegate controlViewBackButtonClicked:self];
    }
}

- (void)fullScreenButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(controlViewFullScreenButtonClicked:isFull:)]) {
        self.playerStateStore.state.isFullScreenButtonType = YES;
        [self.delegate controlViewFullScreenButtonClicked:self isFull:[self isFullScreen]];
    }
}

- (void)playButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(controlViewPlayButtonClicked:isPlay:)]) {
        [self.delegate controlViewPlayButtonClicked:self isPlay:[self isPlaying]];
    }
}

- (void)shareButtonClicked{
    if ([self.delegate respondsToSelector:@selector(controlViewPlayerShareButtonClicked:)]) {
        [self.delegate controlViewPlayerShareButtonClicked:self];
    }
}

- (void)moreButtonClicked{
    if ([self.delegate respondsToSelector:@selector(controlViewPlayerMoreButtonClicked:)]) {
        [self.delegate controlViewPlayerMoreButtonClicked:self];
    }
}

#pragma mark gesture

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint locationPoint = [gesture locationInView:self];
    CGPoint velocityPoint = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _startVolume = _volumeViewSlider.value;
            _startBrightness = [UIScreen mainScreen].brightness;
            _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
            _progressAtTouchBegin = _bottomBarView.watchedProgress;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (![self isFullScreen] && ![self isInDetail]) {
                _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
                return;
            }
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            if (_gestureType == ExploreMoviePlayerControlViewGestureTypeNone) {
                if (x < y) {
                    if (locationPoint.x < self.width / 2) {
                        _gestureType = ExploreMoviePlayerControlViewGestureTypeBrightness;
                    } else {
                        _gestureType = ExploreMoviePlayerControlViewGestureTypeVolume;
                    }
                } else if (x > y) {
                    _gestureType = ExploreMoviePlayerControlViewGestureTypeProgress;
                }
            }
            if (_gestureType == ExploreMoviePlayerControlViewGestureTypeVolume) {
                [self _changeVolume:translation];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeBrightness) {
                [self _changeBrightness:translation];
                if (_brightnessView.hidden) {
                    _brightnessView.hidden = NO;
                }
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeProgress) {

                if (!self.playerStateStore.state.sliderEnableDrag) {
                    _adjustView.hidden = YES;
                }
                if ([self duration] > 0) {
                    if (_adjustView.hidden) {
                        _adjustView.hidden = NO;
                        [self setToolBarHidden:YES];
                    }
                    _adjustView.totalTime = [self duration];
                    if (velocityPoint.x > 0) {
                        _progressAtTouchBegin += kProgressStep;
                    } else {
                        _progressAtTouchBegin -= kProgressStep;
                    }
                    [_adjustView setProgressPercentage:_progressAtTouchBegin/100 isIncrease:velocityPoint.x>0 type:TTMovieAdjustViewTypeProgress];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (![self isFullScreen] && ![self isInDetail]) {
                _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
            }
            if (_gestureType == ExploreMoviePlayerControlViewGestureTypeNone) {
                [self bgButtonClicked];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeVolume) {
                [self track:@"video" label:@"drag_volume" isVolume:YES];
                [self sendChangeVolumeTrack:NO];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeBrightness) {
                [self track:@"video" label:@"drag_light" isVolume:NO];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeProgress) {
                if (self.playerStateStore.state.sliderEnableDrag) {
                    [self track:@"video" label:@"drag_process" isVolume:NO];
                    _bottomBarView.watchedProgress = _progressAtTouchBegin;
                    [self bottomViewWatchedProgressChanged:_bottomBarView.watchedProgress cacedProgress:_bottomBarView.cacheProgress];
                }
            }
            _adjustView.hidden = YES;
            _brightnessView.hidden = YES;
            _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            _adjustView.hidden = YES;
            [UIView animateWithDuration:2.5 animations:^{
                _brightnessView.alpha = 0;
            } completion:^(BOOL finished) {
                _brightnessView.hidden = YES;
                _brightnessView.alpha = 1;
            }];
            _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
        }
            break;
        default:
            break;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    BOOL canTouch = YES;
    if ([self hasShowTipView]) {
        canTouch = NO;
    }
    if (self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeLoading && self.playerStateStore.state.showVideoFirstFrame) {
        canTouch = YES;
    }
    if (gesture.state == UIGestureRecognizerStateRecognized && canTouch) {
        [self bgButtonClicked];
        _adjustView.hidden = YES;
        _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
        [self.resolutionSelect hidden];
        [self.playerStateStore sendAction:TTVPlayerEventTypeControlViewClickScreen payload:nil];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
    [self.playerStateStore sendAction:TTVPlayerEventTypeControlViewDoubleClickScreen payload:nil];
}

- (void)handleDummySingleTap:(UITapGestureRecognizer *)gesture {
    // do nothing, just in order to cancel UITableView's touchBegin
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    if (gestureRecognizer == self.doubleTap && CGRectContainsPoint(self.playButton.frame, point)) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.dummySingleTap && (otherGestureRecognizer == self.singleTap || otherGestureRecognizer == self.doubleTap)) {
        return YES;
    }
    return NO;
}

#pragma mark TTVResolutionSelectDelegate
- (void)resolutionClickedWithType:(TTVPlayerResolutionType)type typeString:(NSString *)typeString
{
    
}
#pragma mark - toolbar

- (void)ttv_HiddenToAlpha:(UIView *)view
{
    if (view.hidden) {
        view.alpha = 0;
        view.hidden = NO;
    }
}

- (void)ttv_AlphaToHidden:(UIView *)view
{
    if (view.alpha == 0) {
        view.hidden = YES;
    }else{
        view.hidden = NO;
    }
}

- (void)ttv_restartTimer
{
    [_playbackControlViewTimer invalidate];
    self.playbackControlViewTimer = nil;

    self.playbackControlViewTimer = [NSTimer scheduledTimerWithTimeInterval:kControlViewAutoHiddenTime
                                                                     target:self
                                                                   selector:@selector(ttv_autoHiddenToolBar)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (void)ttv_autoHiddenToolBar
{
    if ([self isPlaying] && ![self isDragging]) {
        [self setToolBarHidden:YES];
        [self.resolutionSelect hidden];
    }
}


- (void)setToolBarHidden:(BOOL)hidden
{
    [self setToolBarHidden:hidden needAutoHide:YES];
}

- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide
{
    [self setToolBarHidden:hidden needAutoHide:needAutoHide animate:YES];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
}

- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide animate:(BOOL)animate
{
    if (self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeRetry) {//TTVPlayerControlTipViewTypeFinished?
        return;
    }
    CGFloat alpha = hidden ? 0 : 1;
    CGFloat playButtonAlpha = _playButton.hidden ? 0 : 1;

    if (self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeUnknow){
        playButtonAlpha = 0;
    }else if (self.playerStateStore.state.tipType != TTVPlayerControlTipViewTypeLoading) {
        playButtonAlpha = alpha;
    }
    [self ttv_HiddenToAlpha:_titleView];
    [self ttv_HiddenToAlpha:_bottomBarView];
    [self ttv_HiddenToAlpha:_miniSlider];
    [self ttv_HiddenToAlpha:_playButton];
    [self ttv_HiddenToAlpha:_moreButton];
    BOOL hiddenMore = !self.playerStateStore.state.isInDetail || self.playerStateStore.state.isFullScreen;
    if (hiddenMore) {
        _moreButton.alpha = 0;
    }
    dispatch_block_t excBlock = ^{
        if (![self shouldHiddenTtitle]) {
            _titleView.alpha = alpha;
            if ([self isFullScreen]) {
                [[UIApplication sharedApplication] setStatusBarHidden:(hidden ? 1 : !_titleView.showFullscreenStatusBar) withAnimation:UIStatusBarAnimationFade];
            }
        }
        self.playerStateStore.state.toolBarState = hidden ? TTVPlayerControlViewToolBarStateWillHidden : TTVPlayerControlViewToolBarStateWillShow;
        self.dimBackgrView.backgroundColor = hidden ? [UIColor clearColor] : [[UIColor blackColor] colorWithAlphaComponent:0.24];
        _bottomBarView.alpha = alpha;
        if (!hiddenMore) {
            _moreButton.alpha = alpha;
        }
        if (self.playerStateStore.state.tipType != TTVPlayerControlTipViewTypeLoading) {
            _playButton.alpha = playButtonAlpha;
        }
        if (_bottomBarView.alpha == 0) {
            _miniSlider.alpha = 1;
        }else{
            _miniSlider.alpha = 0;
        }
    };
    dispatch_block_t comBlock = ^{
        if (![self shouldHiddenTtitle]) {
            [self ttv_AlphaToHidden:_titleView];
        }
        [self ttv_AlphaToHidden:_bottomBarView];
        [self ttv_AlphaToHidden:_miniSlider];
        [self ttv_AlphaToHidden:_playButton];
        [self ttv_AlphaToHidden:_moreButton];
        
        self.playerStateStore.state.toolBarState = hidden ? TTVPlayerControlViewToolBarStateDidHidden : TTVPlayerControlViewToolBarStateDidShow;
    };

    if (animate) {
        [UIView animateWithDuration:0.35 animations:excBlock completion:^(BOOL finished) {
            comBlock();
        }];
    } else {
        excBlock();
        comBlock();
    }

    if ((!hidden && needAutoHide && [self isPlaying]) || !self.playerStateStore.state.showVideoFirstFrame) {
        [self ttv_restartTimer];
    }
}

#pragma mark -

- (BOOL)hasShowTipView
{
    if ([self tipType] == TTVPlayerControlTipViewTypeNone || [self tipType] == TTVPlayerControlTipViewTypeUnknow) {
        return NO;
    }
    return YES;
}

- (void)setIsDetail:(BOOL)isDetail
{
    _adjustView.mode = TTMovieAdjustViewModeFullScreen;
    [self setNeedsLayout];
}

/**
 playing代表正在播放 ,播放按钮的图案应该是暂停
 */
- (void)setPlaybuttonIsPlaying:(BOOL)playing
{
    UIImage *img;
    NSString *imageName;
    if (playing) {
        imageName = ([TTDeviceHelper isPadDevice] || [self isFullScreen]) ? @"FullPause" : @"Pause";
        [_playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    else {
        imageName = ([TTDeviceHelper isPadDevice] || [self isFullScreen]) ? @"FullPlay" : @"Play";
        [_playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    img = [UIImage imageNamed:imageName];
    _playButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    _playButton.center = CGPointMake(self.width / 2, self.height / 2);
}

- (void)settingIsFullScreen:(BOOL)isFullScreen
{
    _titleView.isFull = isFullScreen;
    _brightnessView.isFullScreen = isFullScreen;
    _moreButton.hidden = YES;
    if (isFullScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _panGesture.enabled = YES;
        });
    }else{
        _panGesture.enabled = NO;
    }
    if (isFullScreen) {
        [_brightnessView removeFromSuperview];
        [self addSubview:_brightnessView];
    } else {
        [_brightnessView removeFromSuperview];
        UIView *view = nil;
        if ([TTDeviceHelper OSVersionNumber] < 8.f) {
            view = [[[UIApplication sharedApplication] delegate] window];
        } else {
            view = [UIApplication sharedApplication].keyWindow;
        }
        [view addSubview:_brightnessView];
        if ([TTDeviceHelper OSVersionNumber] < 8.f && [TTDeviceHelper isPadDevice]) {
            _brightnessView.transform = [_brightnessView currentTransformInIOS7IPad];
        }
    }
    _adjustView.mode = TTMovieAdjustViewModeFullScreen;
    _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
    [self setPlaybuttonIsPlaying:[self isPlaying]];
}

#pragma mark bottom slider

- (void)setWatchedProgress:(CGFloat)watchedProgress
{
    if ([self isDragging]) {
        return;
    }
    if (isnan(watchedProgress) || watchedProgress == NAN) {
        return;
    }
    _bottomBarView.watchedProgress = watchedProgress;
    [_miniSlider setWatchedProgress:watchedProgress];
}

- (void)setCacheProgress:(CGFloat)cacheProgress
{
    if (isnan(cacheProgress) || cacheProgress == NAN) {
        return;
    }
    _bottomBarView.cacheProgress = cacheProgress;
    [_miniSlider setCacheProgress:cacheProgress];
}

- (void)updateTimeLabel:(NSString *)time durationLabel:(NSString *)duration
{
    [_bottomBarView updateWithCurTime:time totalTime:duration];
}

- (void)setVideoTitle:(NSString *)title{
    [_titleView setTitle:title];
    [self setNeedsLayout];
}

- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText {
    if (!playText) {
        playText = @"次播放";
    }
    [_titleView setWatchCount:[[TTBusinessManager formatPlayCount:watchCount] stringByAppendingString:playText]];
}

#pragma mark - layout

- (void)updateFrame {
    //titleView
    _titleView.frame = CGRectMake(0, 0, self.width, kTitleBarHeight);
    [_titleView updateFrame];
    _moreButton.width = 24;
    _moreButton.height = 24;
    _moreButton.right = self.width - 12;
    _moreButton.centerY = 24;
    _playButton.center = CGPointMake(self.width/2, self.height/2);
    _bottomBarView.frame = CGRectMake(0, self.height - kBottomBarHeight, self.width, kBottomBarHeight);
    [_bottomBarView updateFrame];

    //进度的布局
    _adjustView.height = [TTMovieAdjustView heightWithMode:TTMovieAdjustViewModeFullScreen];
    _adjustView.centerX = self.width / 2;
    _adjustView.centerY = self.height / 2;
    //亮度布局
    if ([_brightnessView isIOS7IPad]) {
        _brightnessView.center = [_brightnessView currentCenterInIOS7IPad];
    } else {
        _brightnessView.centerX = _brightnessView.superview.width / 2;
        CGFloat diff = [self isFullScreen] ? 0 : 5;
        _brightnessView.centerY = _brightnessView.superview.height / 2 - diff;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}


#pragma mark - TTMoviePlayerControlSliderViewDelegate

- (void)bottomViewWatchedProgressWillChange:(CGFloat)watchedProgress cacedProgress:(CGFloat)cacedProgress
{
    self.playerStateStore.state.isDragging = YES;
    _currentWatchProgress = watchedProgress;
    
    NSTimeInterval currentTime = self.playerStateStore.state.duration * (_currentWatchProgress / 100.f);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(currentTime),@"fromTime", nil];
    [self.playerStateStore sendAction:TTVPlayerEventTypeControlViewDragSliderTouchBegin payload:dic];
}

- (void)bottomViewWatchedProgressChanging:(CGFloat)watchedProgress cacedProgress:(CGFloat)cacedProgress
{
    [self ttv_refreshDurationLabel:[self duration] currentPlaybackTime:[self duration] * watchedProgress / 100];
}

- (void)bottomViewWatchedProgressChanged:(CGFloat)watchedProgress cacedProgress:(CGFloat)cacedProgress
{
    [self ttv_restartTimer];
    NSTimeInterval currentTime = self.playerStateStore.state.duration * (_currentWatchProgress / 100.f);
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlView:seekProgress:complete:)])
    {
        [self.delegate controlView:self seekProgress:watchedProgress / 100 complete:^(BOOL success) {
            self.playerStateStore.state.isDragging = NO;
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(currentTime),@"fromTime",@(self.playerStateStore.state.duration * (watchedProgress / 100.f)),@"toTime", nil];
            [self.playerStateStore sendAction:TTVPlayerEventTypeControlViewDragSlider payload:dic];
            
        }];
    }
}

- (void)bottomViewFullScreenButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(controlViewFullScreenButtonClicked:isFull:)]) {
        self.playerStateStore.state.isFullScreenButtonType = YES;
        [self.delegate controlViewFullScreenButtonClicked:self isFull:[self isFullScreen]];
    }
}

- (void)bottomViewResolutionButtonClicked
{
    [self.resolutionSelect showWithBottom:self.height - 40];
    [self ttv_restartTimer];
}

#pragma mark - adjust

- (void)p_configureVolumeView {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)updateVolumeValue:(CGFloat)value {
    value = ceilf(value / 0.0625f) * 0.0625f; // 0.0625是音量实体按键调节一次的值
    
    // iOS 11下如果频繁设置volumeSlider的值会导致机器崩溃，所以这里做一个频控
    if (_preVolume < 0) {
        _preVolume = value;
    } else {
        if (_preVolume == value) return;
        _preVolume = value;
    }
    
    //value from 0 to 1
    [_volumeViewSlider setValue:value animated:NO];
    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)_changeVolume:(CGPoint)translation {
    if (!self || self.height == 0) return;
    
    CGFloat normalizedY = -translation.y / self.height;
    CGFloat newVolume = _startVolume + normalizedY;
    [self updateVolumeValue:newVolume];
}

- (void)sendChangeVolumeTrack:(BOOL)isSystem
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:isSystem ? @"system": @"button" forKey:@"drag_type"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"notfullscreen" forKey:@"fullscreen"];
    [dic setValue:[self.playerStateStore.state ttv_position] forKey:@"position"];
    [dic addEntriesFromDictionary:self.playerStateStore.state.playerModel.commonExtra];
    [TTTrackerWrapper eventV3:@"drag_volume_bar" params:dic isDoubleSending:YES];
}

- (void)volumeChanged:(NSNotification *)notification
{
    if (_gestureType != ExploreMoviePlayerControlViewGestureTypeVolume) {
        // 防止短时间内收到大量 AVSystemController_SystemVolumeDidChangeNotification 通知
        // 频繁调用 Tracker 造成崩溃问题 (1 秒内高达 80 次，1 分钟达到 1200 次)
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (currentTime - _lastTimeReportVolumeChanged > 1.0) {
            [self sendChangeVolumeTrack:YES];
            [self track:@"video" label:@"drag_volume_system" isVolume:YES];
            _lastTimeReportVolumeChanged = currentTime;
        }
    }
}

- (void)_changeBrightness:(CGPoint)translation {
    if (!self || self.height == 0) return;
    
    CGFloat normalizedY = -translation.y / self.height;
    CGFloat newBrightness = _startBrightness + normalizedY;
    
    CGFloat validValue = MIN(MAX(0.0f, newBrightness), 1.0f);
    [[UIScreen mainScreen] setBrightness:validValue];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
            case TTVPlayerEventTypeControlViewHiddenToolBar:
        {
            if ([action.payload isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)action.payload;
                [self setToolBarHidden:[[dic valueForKey:@"hidden"] boolValue] needAutoHide:[[dic valueForKey:@"autoHidden"] boolValue]];
            }
        }
            break;
            
            case TTVPlayerEventTypeFinishUIShow:{
                _playButton.hidden = YES;
                [self setToolBarHidden:YES];
        }
            break;
        case TTVPlayerEventTypePlayerResume:{
            //容错,以防万一播放的时候没有被隐藏
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kControlViewAutoHiddenTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!_bottomBarView.hidden && [self isPlaying]) {
                    [self ttv_restartTimer];
                }
            });
        }
            break;
        case TTVPlayerEventTypePlayerStop:{
            [_playbackControlViewTimer invalidate];
            self.playbackControlViewTimer = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark - umeng statistic

- (void)track:(NSString *)event label:(NSString *)label isVolume:(BOOL)isVolume {
    if ([self isFullScreen]) {
        label = [NSString stringWithFormat:@"fullscreen_%@", label];
    } else {
        if (isVolume) {
            if ([self isInDetail]) {
                label = [NSString stringWithFormat:@"detail_%@", label];
            } else {
                label = [NSString stringWithFormat:@"list_%@", label];
            }
        }
    }
    ttTrackEvent(event, label);
}

#pragma mark - getter & setter

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
        if (self.playerStateStore.state.playerModel.playerShowShareMore > 0) {
            [self ttv_addMoreButton];
        }
        self.titleView.shouldShowShareMore = playerStateStore.state.playerModel.playerShowShareMore;
        
        [self ttv_addBottomBar];
        _bottomBarView.playerStateStore = self.playerStateStore;
        
        [self ttv_addResolutionSelect];
        self.resolutionSelect.playerStateStore = self.playerStateStore;
        self.resolutionSelect.enableResolution = self.playerStateStore.state.playerModel.enableResolution;
        _miniSlider.playerStateStore = self.playerStateStore;
        [self bringSubviewToFront:self.playButton];
        _brightnessView.enableRotate = self.playerStateStore.state.enableRotate;
    }
}

- (NSTimeInterval)duration{
    return self.playerStateStore.state.duration;
}

- (NSTimeInterval)currentPlaybackTime{
    return self.playerStateStore.state.currentPlaybackTime;
}

- (NSTimeInterval)playableTime{
    return self.playerStateStore.state.playableTime;
}

- (NSTimeInterval)watchDuration{
    return self.playerStateStore.state.totalWatchTime;
}

- (CGFloat)watchedProgress{
    return self.playerStateStore.state.watchedProgress;
}

- (CGFloat)cacheProgress{
    return self.playerStateStore.state.cacheProgress;
}

- (BOOL)isFullScreen{
    return self.playerStateStore.state.isFullScreen;
}

- (BOOL)isInDetail{
    return self.playerStateStore.state.isInDetail;
}

- (BOOL)isPlaying{
    return self.playerStateStore.state.playbackState == TTVVideoPlaybackStatePlaying;
}

- (BOOL)isDragging{
    return self.playerStateStore.state.isDragging;
}

- (BOOL)isStopped{
    return self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished || self.playerStateStore.state.playbackState == TTVVideoPlaybackStateBreak;
}

- (BOOL)titleBarViewAlwaysHide{
    return self.playerStateStore.state.titleBarViewAlwaysHide;
}

- (TTVPlayerControlTipViewType)tipType
{
    return self.playerStateStore.state.tipType;
}

@end

