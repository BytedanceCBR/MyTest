//
//  ExploreMoviePlayerControlView.m
//  MyPlayer
//
//  Created by Zhang Leonardo on 15-3-2.
//  Copyright (c) 2015年 leonardo. All rights reserved.
//

#import "ExploreMoviePlayerControlView.h"

#import "TTImageView.h"
#import "TTAlphaThemedButton.h"

#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>

#import "ExploreMovieMiniSliderView.h"
#import <Masonry.h>
#import "UIButton+TTAdditions.h"
#import "TTMovieAdjustView.h"
#import "TTMovieBrightnessView.h"
#import "TTMoviePlayerControlFinishAction.h"
#import "TTMoviePlayerControlFinishAdAction.h"
#import "TTMoviePlayerControlSliderView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"

#import "UIViewAdditions.h"
#import "TTFlowStatisticsManager.h"

#import "TTMoviePlayerControlFinishShareAction.h"
#import "TTVPalyerTrafficAlert.h"

#define kControlViewAutoHiddenTime 2

//#define kToolBarHeight ([TTDeviceHelper isPadDevice] ? 50 : ((self.videoPlayType == TTVideoPlayTypeLive) ? 40 : 45))
static CGFloat kToolBarHeight;

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

extern NSInteger ttvs_isVideoShowDirectShare(void);

@interface ExploreMoviePlayerControlView() <TTMoviePlayerControlSliderViewDelegate,UIGestureRecognizerDelegate>
{
    BOOL _touchScreenToExit;
    BOOL _isPlaying; //外部设置，此变量只记录状态，用于减少图片设置次数
    BOOL _isFullscreen;
    BOOL _isDetail; //是否在详情页
    BOOL _titleBarViewAlwaysHide;
    UIDeviceOrientation _lastOrientation;
    ExploreMoviePlayerControlViewGestureType _gestureType;
    CGFloat _progressAtTouchBegin;
    BOOL    _isActive;
    CFAbsoluteTime _lastTimeReportVolumeChanged;
}

@property (nonatomic, strong) TTMoviePlayerControlTopView *titleView;
@property (nonatomic, strong) UIView *dimBackgrView;

@property(nonatomic, strong)TTAlphaThemedButton * playButton;
@property (nonatomic, strong) SSThemedLabel  *liveTextLabel;//直播标签
@property (nonatomic, assign) TTVideoPlayType videoPlayType;

@property(nonatomic, assign)BOOL showTitleInNonFullscreen;

@property(nonatomic, assign)NSTimeInterval timeDuration;
@property(nonatomic, strong)NSTimer * playbackControlViewTimer;

@property(nonatomic, strong)UISlider *volumeViewSlider;

@property(nonatomic, strong)ExploreMovieMiniSliderView * miniSlider;
@property(nonatomic, strong)TTMovieAdjustView *adjustView;
@property(nonatomic, strong)TTMovieBrightnessView *brightnessView;

@property(nonatomic, strong)TTMoviePlayerControlFinishAdAction *finishAdAction; //广告播放结束页面相关操作
@property(nonatomic, strong)TTMoviePlayerControlFinishShareAction *shareAction; //非广告播放结束后，展示分享相关操作

@property(nonatomic, strong)UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) SSThemedLabel  *freeFlowTipLabel;//免流播放 tip

@end

@implementation ExploreMoviePlayerControlView
@synthesize delegate = _delegate;

- (void)dealloc
{
    if (![TTDeviceHelper isPadDevice]) {
        [self endMonitorDeviceOrientationChange];
    }
    
    self.alwaysShowDetailButton = NO;
    
    _bottomBarView.slider.delegate = nil;
    _liveBottomBarView.slider.delegate = nil;
    self.delegate = nil;
    [_playbackControlViewTimer invalidate];
    self.playbackControlViewTimer = nil;
    if (_brightnessView.superview) {
        [_brightnessView removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame videoType:(TTVideoPlayType)type;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        _dimBackgrView = [[UIView alloc] initWithFrame:self.bounds];
        _dimBackgrView.backgroundColor = [UIColor clearColor];
        [self addSubview:_dimBackgrView];

        self.videoPlayType = type;
        kToolBarHeight = [TTDeviceHelper isPadDevice] ? 50 : ((self.videoPlayType == TTVideoPlayTypeLive) ? 40 : 45);
        
        _touchScreenToExit = NO;
        
        self.backgroundColor = [UIColor clearColor];
        if (![TTDeviceHelper isPadDevice]) {
            [self beginMonitorDeviceOrientationChange];
        }
        
        _isActive = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        //封面图
        self.logoView = [[TTImageView alloc] initWithFrame:self.bounds];
        _logoView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        [self addSubview:_logoView];
        
        //播放结束相关
        _finishAction = [[TTMoviePlayerControlFinishAction alloc] initWithBaseView:self];
        [_finishAction.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_finishAction.replayButton addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_finishAction.prePlayBtn addTarget:self action:@selector(prePlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_finishAction.moreButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //广告播放结束相关

        _finishAdAction = [[TTMoviePlayerControlFinishAdAction alloc] initWithBaseView:self];
        
        NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
        if (isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3) {
            _shareAction = [[TTMoviePlayerControlFinishShareAction alloc] initWithBaseView:self];
            [_shareAction.replayBtn addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_shareAction.moreButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            WeakSelf;
            _shareAction.shareClicked = ^(NSString *activityType){
                StrongSelf;
                [self shareItemClicked:activityType];
            };
        }
        //顶部标题视图
        _titleView = [[TTMoviePlayerControlTopView alloc] initWithFrame:CGRectZero];
        _titleBarViewAlwaysHide = NO;
        [self addSubview:_titleView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [_titleView addGestureRecognizer:tapGesture];
        
        [_titleView.backButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView.moreButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView.shareButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //直播
        if ([self isLiveVideo]) {
            _liveBottomBarView = [[TTMoviePlayerControlLiveBottomView alloc] init];
            [self addSubview:_liveBottomBarView];
            [_liveBottomBarView.fullScreenButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dummy)];
//            tapGesture.delegate = self;
            [_liveBottomBarView.toolView addGestureRecognizer:tapGesture];
            _liveBottomBarView.slider.delegate = self;
        }
        //点播
        else {
            _bottomBarView = [[TTMoviePlayerControlBottomView alloc] init];
            [self addSubview:_bottomBarView];
            [_bottomBarView.fullScreenButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dummy)];
            tapGesture.delegate = self;
            [_bottomBarView.toolView addGestureRecognizer:tapGesture];
            _bottomBarView.slider.delegate = self;
            [_bottomBarView.resolutionButton addTarget:self action:@selector(resolutionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [_bottomBarView.prePlayBtn addTarget:self action:@selector(prePlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            _miniSlider = [[ExploreMovieMiniSliderView alloc] initWithFrame:CGRectMake(0, frame.size.height-2, frame.size.width, 2)];
            _miniSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            _miniSlider.userInteractionEnabled = NO;
            [self addSubview:_miniSlider];
            _miniSlider.alpha = 0;
        }
        
        //播放按钮
        UIImage *img = [UIImage themedImageNamed:[TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play"];
        self.playButton = [[TTAlphaThemedButton alloc] init];
        _playButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        _playButton.backgroundColor = [UIColor clearColor];
        [_playButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.enableHighlightAnim = NO;
        [self addSubview:_playButton];
        
        //提示重新加载按钮
        _tipView = [[ExploreMoviePlayerControlTipView alloc] init];
        _tipView.movieControlView = self;
        _tipView.center = CGPointMake(self.width / 2, self.height / 2);
        [self insertSubview:_tipView belowSubview:_titleView];
        [_tipView.retryButton addTarget:self action:@selector(retryButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        self.freeFlowTipLabel = [[SSThemedLabel alloc] init];
        _freeFlowTipLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _freeFlowTipLabel.font = [UIFont systemFontOfSize:12.f];
        _freeFlowTipLabel.text = @"免流量加载中";
        [_freeFlowTipLabel sizeToFit];
        [self insertSubview:_freeFlowTipLabel belowSubview:_titleView];
        _freeFlowTipLabel.hidden = YES;
        
        //调节亮度相关
        _brightnessView = [[TTMovieBrightnessView alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _brightnessView.hidden = YES;
        
        [self setIsFullScreen:_isFullscreen];
        
        //后续操作
        
        [self setIsPlaying:NO force:YES];
        [self hideLogoView];
        
        //调节进度，声音相关
        _isDetail = NO;
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.enabled = NO;
        [self addGestureRecognizer:_panGesture];
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        _adjustView = [[TTMovieAdjustView alloc] initWithFrame:CGRectMake(0, 0, 155, [TTMovieAdjustView heightWithMode:TTMovieAdjustViewModeFullScreen])];
        _adjustView.hidden = YES;
        [self addSubview:_adjustView];
        
        [self p_configureVolumeView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

- (void)setDimAreaEdgeInsetsWhenFullScreen:(UIEdgeInsets)dimAreaEdgeInsetsWhenFullScreen {
    _dimAreaEdgeInsetsWhenFullScreen = dimAreaEdgeInsetsWhenFullScreen;
    self.dimBackgrView.frame = UIEdgeInsetsInsetRect(self.bounds, dimAreaEdgeInsetsWhenFullScreen);
    self.miniSlider.bottom = self.bounds.size.height - dimAreaEdgeInsetsWhenFullScreen.bottom;
    _titleView.dimAreaEdgeInsetsWhenFullScreen = dimAreaEdgeInsetsWhenFullScreen;
    _bottomBarView.dimAreaEdgeInsetsWhenFullScreen = dimAreaEdgeInsetsWhenFullScreen;
}

- (void)reuse
{
    [self setIsPlaying:NO force:YES];
    [self setWatchedProgress:0];
}

- (void)setAlwaysShowDetailButton:(BOOL)alwaysShowDetailButton
{
    if (_alwaysShowDetailButton != alwaysShowDetailButton) {
        _alwaysShowDetailButton = alwaysShowDetailButton;
    }
}

- (void)hideFullscreenStatusBar:(BOOL)hide {
    if (hide) {
        _titleView.showFullscreenStatusBar = NO;
    }
}

- (void)hideTitleBarView:(BOOL)hide
{
    _titleBarViewAlwaysHide = hide;
    self.titleView.hidden = hide;
}

- (BOOL)toolBarViewHidden
{
    if ([self isLiveVideo]) {
        if (_liveBottomBarView.alpha == 0 || _liveBottomBarView.hidden) {
            return YES;
        }
        return NO;
    }
    if (_bottomBarView.alpha == 0 || _bottomBarView.hidden) {
        return YES;
    }
    return NO;
}

- (void)touchScreenToExit:(BOOL)touch
{
    _touchScreenToExit = touch;
    //改变toolbar结构
    [self.playButton removeFromSuperview];
    [_bottomBarView.toolView addSubview:_playButton];
    _bottomBarView.playButton = _playButton;
    _bottomBarView.playButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -14, -12, -22);
    _bottomBarView.fullScreenButton.hidden = YES;
    [self hideTitleBarView:touch];
    [self setNeedsLayout];
}

- (void)showPlayButtonOnly
{
    for (UIView * subView in self.subviews) {
        subView.hidden = (subView != _playButton);
    }
}

#pragma mark - event & gesture

- (void)dummy
{
    if ([self hasShowTipView]) {
        return;
    }
    if (!_logoView.hidden) {
        [self buttonClicked:_playButton];
        
        if (!_hasFinished) {
            if (_touchScreenToExit) {
                [self setToolBarHidden:NO];
            }
            else {
                [self setToolBarHidden:YES];
            }
        }
    }
}

- (void)bgButtonClicked
{
    dispatch_block_t block = ^ {
        if ([self isLiveVideo]) {
            [self setToolBarHidden:!(_liveBottomBarView.alpha == 0)];
        }
        else {
            [self setToolBarHidden:!(_bottomBarView.alpha == 0)];
        }
    };
    if (!_logoView.hidden) {
        if (!self.hasFinished) {
            if (_tipView.tipType == ExploreMoviePlayerControlViewTipTypeLoading) {
                block();
            } else {
                [self buttonClicked:_playButton];
                if (_touchScreenToExit) {
                    [self setToolBarHidden:NO];
                }
                else {
                    [self setToolBarHidden:YES];
                }
            }
        }
    } else {
        if (!self.hasFinished) {
            if (_touchScreenToExit) {
                [self buttonClicked:_titleView.backButton];
            }
            else {
                block();
            }
        }
    }
}

- (void)retryButtonClicked
{
    if (_delegate && [_delegate respondsToSelector:@selector(controlViewRetryButtonClicked:)]) {
        [_delegate controlViewRetryButtonClicked:self];
    }
}

- (void)buttonClicked:(id)sender
{
    if (sender == _bottomBarView.fullScreenButton || sender == _liveBottomBarView.fullScreenButton || sender == _titleView.backButton) {
        if (_delegate && [_delegate respondsToSelector:@selector(controlViewFullScreenButtonClicked:)]) {
            if ([_delegate respondsToSelector:@selector(setIsFullScreenButtonAction:)]) {
                if (sender == _bottomBarView.fullScreenButton || sender == _liveBottomBarView.fullScreenButton) {
                    [_delegate setIsFullScreenButtonAction:YES];
                } else {
                    [_delegate setIsFullScreenButtonAction:NO];
                }
            }
            [_delegate controlViewFullScreenButtonClicked:self];
        }
    } else if (sender == _playButton && !_hasFinished) {
        BOOL replay = NO;
        if (_isPlaying) {
            if (!_logoView.hidden) {
                [self hideLogoView];
                replay = YES;
            }
        }
        if (_delegate && [_delegate respondsToSelector:@selector(controlViewPlayButtonClicked:replay:)]) {
            [_delegate controlViewPlayButtonClicked:self replay:replay];
        }
    } else if (sender == _titleView.moreButton || sender == _finishAction.moreButton || sender == _shareAction.moreButton){
        if (_delegate && [_delegate respondsToSelector:@selector(controlViewMoreButtonClicked:)]) {
            [_delegate controlViewMoreButtonClicked:self];
        }

    } else if (sender == _titleView.shareButton){
        if (_delegate && [_delegate respondsToSelector:@selector(controlViewShareButtonClicked:)]) {
            [_delegate controlViewShareButtonClicked:self];
        }
    }
    // 1.视频暂停时不自动隐藏底栏
    // 2.视频播放结束显示查看详情时不自动隐藏底栏
    if (_isPlaying) {
        if (![_playbackControlViewTimer isValid]) {
            [self restartTimer];
        }
    } else {
        if (_playbackControlViewTimer) {
            [_playbackControlViewTimer invalidate];
            _playbackControlViewTimer = nil;
        }
    }
}

- (void)shareButtonClicked:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(controlViewShareButtonClicked:)]) {
        [_delegate controlViewShareButtonClicked:self];
    }
}

- (void)shareItemClicked:(NSString *)activityType{
    
    if (_delegate && [_delegate respondsToSelector:@selector(controlViewShareActionClicked:withActivityType:)]) {
        [_delegate controlViewShareActionClicked:self withActivityType:activityType];
    }
}

- (void)replayButtonClicked:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(controlViewPlayButtonClicked:replay:)]) {
        [_delegate controlViewPlayButtonClicked:self replay:YES];
    }
    if (self.shareAction) {
        [self.shareAction refreshShareItemButtons];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint locationPoint = [gesture locationInView:self];
    CGPoint velocityPoint = [gesture velocityInView:self];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
            if (self.videoPlayType == TTVideoPlayTypeLivePlayback) {
                _progressAtTouchBegin = _liveBottomBarView.slider.watchedProgress;
            } else {
                _progressAtTouchBegin = _bottomBarView.slider.watchedProgress;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (!_isFullscreen && !_isDetail) {
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
                [self volumeAdd:(velocityPoint.y > 0 ? -kVolumeStep : kVolumeStep)];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeBrightness) {
                [self brightnessAdd:(velocityPoint.y > 0 ? -kVolumeStep : kVolumeStep)];
                if (_brightnessView.hidden) {
                    _brightnessView.hidden = NO;
                }
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeProgress) {
                if (self.videoPlayType == TTVideoPlayTypeLive) {
                    return;
                }
                if (self.videoPlayType == TTVideoPlayTypeLivePlayback) {
                    if (!_liveBottomBarView.slider.enableDrag) {
                        _adjustView.hidden = YES;
                    }
                } else {
                    if (!_bottomBarView.slider.enableDrag) {
                        _adjustView.hidden = YES;
                    }
                }
                if (self.timeDuration > 0) {
                    if (_adjustView.hidden) {
                        _adjustView.hidden = NO;
                        [self setToolBarHidden:!_touchScreenToExit];
                    }
                    _adjustView.totalTime = self.timeDuration;
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
            if (!_isFullscreen && !_isDetail) {
                _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
            }
            if (_gestureType == ExploreMoviePlayerControlViewGestureTypeNone) {
                [self bgButtonClicked];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeVolume) {
                [self track:@"video" label:@"drag_volume" isVolume:YES];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeBrightness) {
                [self track:@"video" label:@"drag_light" isVolume:NO];
            } else if (_gestureType == ExploreMoviePlayerControlViewGestureTypeProgress) {
                if (self.videoPlayType == TTVideoPlayTypeLivePlayback) {
                    if (_liveBottomBarView.slider.enableDrag) {
                        [self track:@"video" label:@"drag_process" isVolume:NO];
                        _liveBottomBarView.slider.watchedProgress = _progressAtTouchBegin;
                        [self sliderWatchedProgressChanged:_liveBottomBarView.slider];
                    }
                } else {
                    if (_bottomBarView.slider.enableDrag) {
                        [self track:@"video" label:@"drag_process" isVolume:NO];
                        _bottomBarView.slider.watchedProgress = _progressAtTouchBegin;
                        [self sliderWatchedProgressChanged:_bottomBarView.slider];
                    }
                }
            }
            _adjustView.hidden = YES;
            _brightnessView.hidden = YES;
            _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
            if ([self.delegate respondsToSelector:@selector(controlView:touchesEnded:withEvent:)]) {
                [self.delegate controlView:self touchesEnded:nil withEvent:nil];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            _adjustView.hidden = YES;
            [UIView animateWithDuration:2.5 animations:^{
                _brightnessView.alpha = 0;
            } completion:^(BOOL finished) {
                _brightnessView.hidden = YES;
            }];
            _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
        }
            break;
        default:
            break;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    if ([self hasShowTipView] && _tipView.tipType != ExploreMoviePlayerControlViewTipTypeLoading) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self bgButtonClicked];
        _adjustView.hidden = YES;
        _gestureType = ExploreMoviePlayerControlViewGestureTypeNone;
        if ([self.delegate respondsToSelector:@selector(controlView:touchesEnded:withEvent:)]) {
            [self.delegate controlView:self touchesEnded:nil withEvent:nil];
        }
    }
}

- (void)prePlayBtnClicked:(UIButton *)sender {
    
    if ([_delegate respondsToSelector:@selector(controlViewPrePlayButtonClicked:)]) {
        
        [_delegate controlViewPrePlayButtonClicked:self];
    }
}

#pragma mark - resolution

- (void)setResolutionString:(NSString *)resolutionString
{
    _resolutionString = resolutionString;
    _bottomBarView.resolutionString = resolutionString;
}

- (void)setEnableResulutionButtonClicked:(BOOL)enableResulutionButtonClicked
{
    _enableResulutionButtonClicked = enableResulutionButtonClicked;
    _bottomBarView.enableResolutionClicked = enableResulutionButtonClicked;
}

- (void)resolutionButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(controlViewResolutionButtonClicked:)]) {
        [self.delegate controlViewResolutionButtonClicked:self];
    }
    [self restartTimer];
}

#pragma mark - toolbar

- (BOOL)hasTipType
{
    return [_tipView hasTipType];
}

- (void)setToolBarHidden:(BOOL)hidden
{
    if (_touchScreenToExit) {
        [self setToolBarHidden:NO needAutoHide:NO];
    }
    else {
        [self setToolBarHidden:hidden needAutoHide:YES];
    }
}

- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide
{
    [self setToolBarHidden:hidden needAutoHide:needAutoHide animate:YES];
}

- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide animate:(BOOL)animate
{
    [self setToolBarHidden:hidden needAutoHide:needAutoHide needChangeTitleBarView:YES animate:animate];
}

- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide needChangeTitleBarView:(BOOL)needChangeTitleBarView animate:(BOOL)animate
{
    BOOL hasFirstFrame = NO;
    if ([self.delegate respondsToSelector:@selector(movieHasFirstFrame)]) {
        hasFirstFrame = [self.delegate movieHasFirstFrame];
    }
    if (!hasFirstFrame) {
        return;
    }
    if ([self hasShowTipView] && _tipView.tipType == ExploreMoviePlayerControlViewTipTypeRetry) {
        return;
    }
    
    dispatch_block_t excBlock = ^{
        if (needChangeTitleBarView) {
            _titleView.alpha = hidden ? 0 : 1;
            if (_isFullscreen) {
                [[UIApplication sharedApplication] setStatusBarHidden:(hidden ? 1 : !_titleView.showFullscreenStatusBar) withAnimation:UIStatusBarAnimationFade];
            }
        }
        self.dimBackgrView.backgroundColor = hidden ? [UIColor clearColor] : [[UIColor blackColor] colorWithAlphaComponent:0.24];
        _bottomBarView.alpha = hidden ? 0 : 1;
        _liveBottomBarView.alpha = hidden ? 0 : 1;
        if (_tipView.tipType != ExploreMoviePlayerControlViewTipTypeLoading) {
            _playButton.alpha = hidden ? 0 : 1;
        }
        _miniSlider.alpha = hidden ? 1 : 0;
        
        if (self.toolBarHiddenBlock) {
            self.toolBarHiddenBlock(hidden);
        }
    };
    dispatch_block_t comBlock = ^{
        if (!hidden && [self.delegate respondsToSelector:@selector(controlView:didAppear:)]) {
            [self.delegate controlView:self didAppear:YES];
        }
    };
    if (animate) {
        [UIView animateWithDuration:0.35 animations:excBlock completion:^(BOOL finished) {
            comBlock();
        }];
    } else {
        excBlock();
        comBlock();
    }

    if (hidden && self.delegate && [self.delegate respondsToSelector:@selector(controlViewWillDisappear:)]) {
        [self.delegate controlViewWillDisappear:self];
    }
    
    [_playbackControlViewTimer invalidate];
    self.playbackControlViewTimer = nil;
    
    if (!hidden && needAutoHide && _isPlaying) {
        self.playbackControlViewTimer = [NSTimer scheduledTimerWithTimeInterval:kControlViewAutoHiddenTime
                                                                         target:self
                                                                       selector:@selector(firePlaybackControlViewTimer)
                                                                       userInfo:nil
                                                                        repeats:NO];
    }
}

#pragma mark -

- (void)restartTimer
{
    [_playbackControlViewTimer invalidate];
    self.playbackControlViewTimer = nil;
    
    self.playbackControlViewTimer = [NSTimer scheduledTimerWithTimeInterval:kControlViewAutoHiddenTime
                                                                         target:self
                                                                       selector:@selector(firePlaybackControlViewTimer)
                                                                       userInfo:nil
                                                                        repeats:NO];
}

- (void)firePlaybackControlViewTimer
{
    if (_isPlaying) {
        if (_touchScreenToExit) {
            [self setToolBarHidden:NO];
        }
        else {
           [self setToolBarHidden:YES];
        }
    }
}

- (ExploreMoviePlayerControlViewTipType)tipViewType
{
    return [_tipView tipType];
}

- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type
{
    [self showTipView:type andTipString:nil];
}

- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type andTipString:(NSString *)tipString
{
    if (_hasFinished) {
        return;
    }
    _tipView.hidden = NO;
    if ([self isLiveVideo]) {
        if (!_liveBottomBarView.hidden && _liveBottomBarView.alpha > 0) {
            _playButton.alpha = 0;
        }
    } else {
        _titleView.alpha = 0;
        if (!_bottomBarView.hidden && _bottomBarView.alpha > 0) {
            _playButton.alpha = 0;
        }
    }
    [_tipView showTipView:type andTipString:tipString];
    
    if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowLoadingTip] &&
        type == ExploreMoviePlayerControlViewTipTypeLoading) {
        
        _freeFlowTipLabel.hidden = NO;
        [self updateFrame];
    } else {
        _freeFlowTipLabel.hidden = YES;
    }
}

- (BOOL)hasShowTipView
{
    if (!_tipView.hidden && _tipView.alpha) {
        return YES;
    }
    return NO;
}

- (void)hideTipView
{
    _freeFlowTipLabel.hidden = YES;
    
    if (_tipView && !_tipView.hidden) {
        _tipView.hidden = YES;
        [_tipView showTipView:ExploreMoviePlayerControlViewTipTypeNotAssign];
        [_tipView dismissTipViewAnimation];
        if ([self isLiveVideo]) {
            if (!_liveBottomBarView.hidden && _liveBottomBarView.alpha > 0) {
                _playButton.alpha = 1;
            }
        } else {
            if (!_bottomBarView.hidden && _bottomBarView.alpha > 0) {
                _playButton.alpha = 1;
            }
        }
    }
}

- (void)setIsPlaying:(BOOL)playing
{
    [self setIsPlaying:playing force:NO];
}

- (void)setIsPlaying:(BOOL)playing force:(BOOL)force
{
    [self p_refreshUI:NO];
    if (!force && _isPlaying == playing) {
        return;
    }
    // 视频继续播放时自动隐藏之前显示的toolbar
    BOOL flag = NO;
    if ([self isLiveVideo]) {
        flag = _liveBottomBarView.alpha > 0;
    } else {
        flag = _bottomBarView.alpha > 0;
    }
    if (!_isPlaying && playing && flag) {
        if (![_playbackControlViewTimer isValid]) {
            [self restartTimer];
        }
    }
    _isPlaying = playing;
    [self setPlaybuttonImageWith:playing];
}

- (void)setIsDetail:(BOOL)isDetail
{
    _isDetail = isDetail;
    self.shareAction.isIndetail = isDetail;
    self.finishAdAction.isIndetail = isDetail;
    _adjustView.mode = TTMovieAdjustViewModeFullScreen;
    [self setNeedsLayout];
}

- (void)setPlaybuttonImageWith:(BOOL)playing
{
    UIImage *img;
    NSString *imageName;
    if (playing) {
        imageName = ([TTDeviceHelper isPadDevice] || _isFullscreen) ? @"FullPause" : @"Pause";
        imageName = _touchScreenToExit ? @"chatroom_pause_video" : imageName;
        [_playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    else {
        imageName = ([TTDeviceHelper isPadDevice] || _isFullscreen) ? @"FullPlay" : @"Play";
        imageName = _touchScreenToExit ? @"chatroom_play_video" : imageName;
        [_playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    img = [UIImage imageNamed:imageName];
    _playButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    if (!_touchScreenToExit) {
        _playButton.center = CGPointMake(self.width / 2, self.height / 2);
    } else {
        [_bottomBarView updateFrame];
        [_liveBottomBarView updateFrame];
    }
}

- (void)setIsFullScreen:(BOOL)fullScreen
{
    _isFullscreen = fullScreen;
    _titleView.isFull = fullScreen;
    _bottomBarView.isFull = fullScreen;
    _liveBottomBarView.isFull = fullScreen;
    _tipView.isFullScreen = fullScreen;
    _panGesture.enabled = fullScreen;
    if (_isFullscreen) {
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
    [self setPlaybuttonImageWith:_isPlaying];
    [_finishAction setIsFullMode:fullScreen];
}

- (void)setShouldShowShareMore:(NSInteger)shouldShowShareMore{
    _shouldShowShareMore = shouldShowShareMore;
    self.titleView.shouldShowShareMore = shouldShowShareMore;
}

- (void)finishPlaying
{
    [self p_refreshUI:YES];
}

- (void)p_refreshUI:(BOOL)hasFinished {
    self.hasFinished = hasFinished;
    self.playButton.hidden = hasFinished;
    if (hasFinished) {
        _panGesture.enabled = NO;
        [self setToolBarHidden:YES needAutoHide:YES animate:NO];
    } else {
        _panGesture.enabled = _isFullscreen;
    }

    if (_finishAdAction.isAd) {
        [_finishAction refreshSubViews:NO];
        [_finishAdAction refreshSubView:hasFinished];
        
    } else {
        if ([_shareAction.shareItemButtons count] > 0 && self.isVideoBusiness) {
            [_shareAction refreshSubViews:hasFinished];
            [_finishAction refreshSubViews:NO];
        }else{
            [_finishAction refreshSubViews:hasFinished];
            [_shareAction refreshSubViews:NO];
        }
        [_finishAdAction refreshSubView:NO];
    }
}

- (void)showLoadingWithTitleBar
{
    _titleView.alpha = 1;
    _liveBottomBarView.alpha = 0;
    _bottomBarView.alpha = 0;
    _playButton.alpha = 0;
    [self showTipView:ExploreMoviePlayerControlViewTipTypeLoading];
}

- (void)setTotalTime:(NSTimeInterval)total {
    _timeDuration = total;
}

- (void)setWatchedProgress:(CGFloat)progress
{
    if (isnan(progress) || progress == NAN) {
        return;
    }
    _bottomBarView.slider.watchedProgress = progress;
    _liveBottomBarView.slider.watchedProgress = progress;
    [_miniSlider setWatchedProgress:progress];
}

- (void)setCacheProgress:(CGFloat)progress
{
    if (isnan(progress) || progress == NAN) {
        return;
    }
    _bottomBarView.slider.cacheProgress = progress;
    _liveBottomBarView.slider.cacheProgress = progress;
    [_miniSlider setCacheProgress:progress];
}

- (void)updateTimeLabel:(NSString *)time durationLabel:(NSString *)duration
{
    [_bottomBarView updateWithCurTime:time totalTime:duration];
    [_liveBottomBarView updateWithCurTime:time totalTime:duration];
}

- (void)enableSlider {
    _bottomBarView.slider.enableDrag = YES;
    _liveBottomBarView.slider.enableDrag = YES;
}

- (void)disbleSlider {
    _bottomBarView.slider.enableDrag = NO;
    _liveBottomBarView.slider.enableDrag = NO;
}

- (void)setHiddenMiniSliderView:(BOOL)hidden
{
    _miniSlider.hidden = hidden;
}

- (void)setVideoTitle:(NSString *)title fontSizeStyle:(TTVideoTitleFontStyle)style showInNonFullscreenMode:(BOOL)bShow {
    [_titleView setTitle:title];
    self.showTitleInNonFullscreen = bShow;
    [self setNeedsLayout];
}

- (void)setVideoPlayTimes:(NSInteger)playTimes {    
    _titleView.playTimesLabel.text = [[TTBusinessManager formatPlayCount:playTimes] stringByAppendingString:@"次播放"];
    [_titleView.playTimesLabel sizeToFit];
}
- (void)setVideoPlayTimesText:(NSString *)playCountText
{
    _titleView.playTimesLabel.text = playCountText;
    [_titleView.playTimesLabel sizeToFit];
}


- (void)showLogoView:(BOOL)showDetailButton {
    _logoView.hidden = NO;
    if (_hasFinished) {
        [self setToolBarHidden:YES needAutoHide:NO needChangeTitleBarView:YES animate:YES];
    } else {
        [self setToolBarHidden:NO needAutoHide:NO];
    }
}

- (void)hideLogoView {
    _logoView.hidden = YES;
}

- (UIView *)toolBar
{
    if ([self isLiveVideo]) {
        return _liveBottomBarView;
    }
    return _bottomBarView;
}

- (void)refreshSliderFrame
{
    [_bottomBarView updateFrame];
    [_liveBottomBarView updateFrame];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    _isActive = NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    _isActive = YES;
}

#pragma mark - layout

- (void)updateFrame {
    //titleView
    _titleView.frame = CGRectMake(0, 0, self.width, kTitleBarHeight);
    [_titleView updateFrame];
    _playButton.center = CGPointMake(self.width/2, self.height/2);
    _bottomBarView.frame = CGRectMake(0, self.height - kBottomBarHeight, self.width, kBottomBarHeight);
    [_bottomBarView updateFrame];
    _liveBottomBarView.frame = CGRectMake(0, self.height - kBottomBarHeight, self.width, kBottomBarHeight);
    [_liveBottomBarView updateFrame];

    if (_isFullscreen) {
        if (!_titleBarViewAlwaysHide) {
            self.titleView.hidden = NO;
        }
    } else {
        if (!_titleBarViewAlwaysHide) {
            self.finishAction.moreButton.hidden = !(!self.showTitleInNonFullscreen && self.shouldShowShareMore);
            self.titleView.titleLabel.hidden = !self.showTitleInNonFullscreen;
            self.titleView.playTimesLabel.hidden = !self.showTitleInNonFullscreen;
            self.titleView.moreButton.hidden = !(!self.showTitleInNonFullscreen && self.shouldShowShareMore);
            self.shareAction.moreButton.hidden = !(!self.showTitleInNonFullscreen && self.shouldShowShareMore);
        }
    }
    
    //封面图布局
    _logoView.frame = self.bounds;
    //提示页面布局
    _tipView.width = 140;
    _tipView.height = 40;
    _tipView.centerX = self.width / 2;
    _tipView.centerY = self.height / 2;
    //进度的布局
    _adjustView.height = [TTMovieAdjustView heightWithMode:TTMovieAdjustViewModeFullScreen];
    _adjustView.centerX = self.width / 2;
    _adjustView.centerY = self.height / 2;
    //亮度布局
    if ([_brightnessView isIOS7IPad]) {
        _brightnessView.center = [_brightnessView currentCenterInIOS7IPad];
    } else {
        _brightnessView.centerX = _brightnessView.superview.width / 2;
        CGFloat diff = _isFullscreen ? 0 : 5;
        _brightnessView.centerY = _brightnessView.superview.height / 2 - diff;
    }
    //播放结束时页面的view的布局
    [_finishAction layoutSubviews];
    [_finishAdAction layoutSubviews];
    [_shareAction layoutSubviews];
    
    _freeFlowTipLabel.top = (_isFullscreen) ? _tipView.bottom + 12.f: _tipView.bottom + 4.f;
    _freeFlowTipLabel.centerX = _tipView.centerX;
}

- (void)enablePrePlayBtn:(BOOL)enable isFromFinishAtion:(BOOL)isFrom {
    
    if (isFrom) {
        _finishAction.prePlayBtn.enabled = enable;
        _finishAction.prePlayBtn.hidden = (!enable || _isFullscreen);
        
    } else {
        _bottomBarView.prePlayBtn.enabled = enable;
        [_bottomBarView updateFrame];
    }
}

- (void)updateFinishActionItemsFrameWithBannerHeight:(CGFloat)height {
    
    [_finishAction updateFinishActionItemsFrameWithBannerHeight:height];
}

- (void)updateFinishShareActionItemsFrameWithBannerHeight:(CGFloat)height {
    
    [_shareAction updateFinishActionItemsFrameWithBannerHeight:height];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_forbidLayout) {
        return;
    }
    [self updateFrame];
}


//嘉聊
- (void)reLayoutToolBar4ReplayVideoOfLiveRoom
{
    [_liveBottomBarView updateReplay];
}

//嘉聊
- (void)resetToolBar4LiveVideoWithStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView
{
    [_liveBottomBarView updateLiveWithStatusView:statusView numOfParticipantsView:numOfParticipantsView];
}

#pragma mark - 

- (BOOL)hasAdButton {
    if ([_delegate respondsToSelector:@selector(shouldControlViewHaveAdButton)] && [_delegate shouldControlViewHaveAdButton]) {
        return YES;
    }
    return NO;
}

#pragma mark - TTMoviePlayerControlSliderViewDelegate

- (void)sliderWatchedProgressWillChange:(TTMoviePlayerControlSliderView *)slider {
    [_playbackControlViewTimer invalidate];
    self.playbackControlViewTimer = nil;
}

- (void)sliderWatchedProgressChanging:(TTMoviePlayerControlSliderView *)slider {
    if (_delegate && [_delegate respondsToSelector:@selector(controlView:changeCurrentPlaybackTime:totalTime:)]) {
        [_delegate controlView:self changeCurrentPlaybackTime:_timeDuration*slider.watchedProgress/100 totalTime:_timeDuration];
    }
}

- (void)sliderWatchedProgressChanged:(TTMoviePlayerControlSliderView *)slider {
    if (!_logoView.hidden) {
        [self hideLogoView];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(controlView:seekProgress:)]) {
        [_delegate controlView:self seekProgress:slider.watchedProgress];
    }
    [self restartTimer];
}

#pragma mark - rotate fullscreen

- (void)beginMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:device];
}

- (void)endMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    //是否要响应旋转
    if (!_isActive) {
        return;
    }
    BOOL canRotate = YES;
    if ([_delegate respondsToSelector:@selector(controlViewCanRotate)]) {
        canRotate = [_delegate controlViewCanRotate];
    }
    
    if (!canRotate) {
        return;
    }

    id obj = notification.object;
    if ([obj isKindOfClass:[UIDevice class]]) {
        UIDeviceOrientation ori = [(UIDevice *)obj orientation];

        if (_lastOrientation == ori || ori == UIDeviceOrientationFaceUp || ori == UIDeviceOrientationFaceDown || ori == UIDeviceOrientationUnknown) {
            return;
        }
        
        _lastOrientation = ori;
        
        //已转为横屏：
        if (ori == UIDeviceOrientationLandscapeLeft ||
             ori == UIDeviceOrientationLandscapeRight) {
            //_lastOrientation = o;
            if (_isFullscreen) {
                if ([_delegate respondsToSelector:@selector(controlViewFullScreenLandscapeLeftRightRotate)]) {
                    [_delegate controlViewFullScreenLandscapeLeftRightRotate];
                }
            } else {
                if ([self isLiveVideo]) {
                    [self buttonClicked:_liveBottomBarView.fullScreenButton];
                } else {
                    [self buttonClicked:_bottomBarView.fullScreenButton];
                }
            }
        }
        
        //已转为竖屏：如果当前是全屏，则变为竖屏时则自动恢复到非全屏
        if ((ori == UIDeviceOrientationPortrait)
            && _isFullscreen) {
            if ([self isLiveVideo]) {
                [self buttonClicked:_liveBottomBarView.fullScreenButton];
            } else {
                [self buttonClicked:_bottomBarView.fullScreenButton];
            }
        }
    }
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

- (void)volumeAdd:(CGFloat)step {
    float systemVolume = _volumeViewSlider.value;
    systemVolume += step;
    [_volumeViewSlider setValue:systemVolume animated:NO];
    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)volumeChanged:(NSNotification *)notification
{
    if (_gestureType != ExploreMoviePlayerControlViewGestureTypeVolume) {
        // 防止短时间内收到大量 AVSystemController_SystemVolumeDidChangeNotification 通知
        // 频繁调用 Tracker 造成崩溃问题 (1 秒内高达 80 次，1 分钟达到 1200 次)
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (currentTime - _lastTimeReportVolumeChanged > 3.0) {
            [self track:@"video" label:@"drag_volume_system" isVolume:YES];
            _lastTimeReportVolumeChanged = currentTime;
        }
    }
}

- (void)brightnessAdd:(CGFloat)step {
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

#pragma mark -

- (void)applicationDidEnterBackground
{
    BOOL shouldPause = YES;
    if ([_delegate respondsToSelector:@selector(controlViewShouldPauseWhenEnterForeground)]) {
        shouldPause = [_delegate controlViewShouldPauseWhenEnterForeground];
    }
    
    if (!shouldPause) {
        return;
    }
    
    if (_isPlaying) {
        [self.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    if (!_hasFinished) {
        [self setToolBarHidden:NO needAutoHide:_isPlaying];
    }
}

#pragma mark - umeng statistic

- (void)track:(NSString *)event label:(NSString *)label isVolume:(BOOL)isVolume {
    if (_isFullscreen) {
        label = [NSString stringWithFormat:@"fullscreen_%@", label];
    } else {
        if (isVolume) {
            if (_isDetail) {
                label = [NSString stringWithFormat:@"detail_%@", label];
            } else {
                label = [NSString stringWithFormat:@"list_%@", label];
            }
        }
    }
    wrapperTrackEvent(event, label);
}

#pragma mark - finish ad

- (void)configureFinishAd:(ExploreOrderedData *)data
{
    [_finishAdAction setData:data];
}

#pragma mark - getter & setter

- (BOOL)isLiveVideo {
    return self.videoPlayType == TTVideoPlayTypeLive || self.videoPlayType == TTVideoPlayTypeLivePlayback;
}

- (void)setForbidLayout:(BOOL)forbidLayout {
    _forbidLayout = forbidLayout;
    self.tipView.forbidLayout = forbidLayout;
}

- (void)setEnableResolution:(BOOL)enableResolution {
    _enableResolution = enableResolution;
    _bottomBarView.enableResolution = enableResolution;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.titleView.shareButton] || [touch.view isDescendantOfView: self.titleView.moreButton] || [touch.view isDescendantOfView:self.playButton] || [touch.view isDescendantOfView:self.finishAction.shareButton] || [touch.view isDescendantOfView:_finishAction.moreButton]) {
        return NO;
    }
    return YES;
}

@end
