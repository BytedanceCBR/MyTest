//
//  VideoControlView.m
//  Video
//
//  Created by Kimi on 12-10-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSPlayControlView.h"
#import "UIImageAdditions.h"

#define LeftPadding 10.f
#define RightPadding 7.f
#define TopPadding 10.f
#define BottomPadding 10.f

#define PlayButtonLeftMargin 10.f
#define PlaybackSliderLeftMargin 8.f
#define TimeLabelFontSize 10.f

@interface VideoPlayButton : UIButton
@property (nonatomic) BOOL pressed;
@end

@implementation VideoPlayButton

- (void)setPressed:(BOOL)pressed
{
    _pressed = pressed;
    if (pressed) {
        [self setImage:[UIImage imageNamed:@"pause_player"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"pause_player_press"] forState:UIControlStateHighlighted];
    }
    else {
        [self setImage:[UIImage imageNamed:@"play_player"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"play_player_press"] forState:UIControlStateHighlighted];
    }
}

@end


@interface VideoFullscreenButton : UIButton
@property (nonatomic) BOOL pressed;
@end

@implementation VideoFullscreenButton

- (void)setPressed:(BOOL)pressed
{
    _pressed = pressed;
    if (pressed) {
        [self setImage:[UIImage imageNamed:@"halficon_player"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"halficon_player_press"] forState:UIControlStateHighlighted];
    }
    else {
        [self setImage:[UIImage imageNamed:@"fullicon_player"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"fullicon_player_press"] forState:UIControlStateHighlighted];
    }
}

@end


@interface SSPlayControlView () {
    BOOL _sliding;
    BOOL _hasPlay;
    BOOL _loading;
}

@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UILabel *loadingLabel;

@property (nonatomic, retain) VideoPlayButton *playButton;
@property (nonatomic, retain) UISlider *playbackSlider;
@property (nonatomic, retain) VideoFullscreenButton *fullscreenButton;
@property (nonatomic, retain) UILabel *remainTimeLabel;
@property (nonatomic, retain) UILabel *elapsedTimeLabel;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) MPMoviePlayerController *player;
@property (nonatomic, retain) NSTimer *playbackTimer;
@property (nonatomic, retain) NSTimer *controlsTimer;

@end

@implementation SSPlayControlView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    
    self.trackEventName = nil;
    self.loadingView = nil;
    self.playButton = nil;
    self.playbackSlider = nil;
    self.fullscreenButton = nil;
    self.remainTimeLabel = nil;
    self.elapsedTimeLabel = nil;
    self.backgroundView = nil;
    self.player = nil;
    self.playbackTimer = nil;
    self.controlsTimer = nil;
    [super dealloc];
}

- (id)initWithPlayer:(MPMoviePlayerController *)player type:(SSPlayControlViewType)type
{
    self = [super init];
    if (self) {
        self.player = player;
        _type = type;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieDurationAvailable:)
                                                     name:MPMovieDurationAvailableNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerPlaybackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerPlaybackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerLoadStateDidChange:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage centerStrechedImageNamed:@"toolbg_player"]] autorelease];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.5;
        [self addSubview:_backgroundView];
        
        self.loadingView = [[[UIView alloc] init] autorelease];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        _indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [_indicator startAnimating];
        self.loadingLabel = [[[UILabel alloc] init] autorelease];
        _loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        _loadingLabel.text = @"正在加载...";
        _loadingLabel.font = ChineseFontWithSize(12.f);
        _loadingLabel.textColor = [UIColor whiteColor];
        _loadingLabel.backgroundColor = [UIColor clearColor];
        [_loadingView addSubview:_indicator];
        [_loadingView addSubview:_loadingLabel];
        [self addSubview:_loadingView];
        
        self.playButton = [VideoPlayButton buttonWithType:UIButtonTypeCustom];
        _playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [_playButton setImage:[UIImage imageNamed:@"play_player"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"play_player_press"] forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(handlePlayAndPauseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
        
        self.fullscreenButton = [VideoFullscreenButton buttonWithType:UIButtonTypeCustom];
        _fullscreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_fullscreenButton setImage:[UIImage imageNamed:@"fullicon_player"] forState:UIControlStateNormal];
        [_fullscreenButton setImage:[UIImage imageNamed:@"fullicon_player_press"] forState:UIControlStateHighlighted];
        [_fullscreenButton addTarget:self action:@selector(handleFullscreenButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fullscreenButton];
        
        self.playbackSlider = [[[UISlider alloc] init] autorelease];
        _playbackSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_playbackSlider setThumbImage:[UIImage imageNamed:@"progressbutton_player"] forState:UIControlStateNormal];
        [_playbackSlider addTarget:self action:@selector(playbackSliderMoved:) forControlEvents:UIControlEventValueChanged];
        [_playbackSlider addTarget:self action:@selector(playbackSliderDone:) forControlEvents:UIControlEventTouchUpInside];
        [_playbackSlider addTarget:self action:@selector(playbackSliderDone:) forControlEvents:UIControlEventTouchUpOutside];
        UIImage *strechLeftTrack = [UIImage imageNamed:@"progressbarblue_player"];
        strechLeftTrack = [strechLeftTrack stretchableImageWithLeftCapWidth:strechLeftTrack.size.width/2 topCapHeight:strechLeftTrack.size.height/2];
        UIImage *strechRightTrack = [UIImage imageNamed:@"progressbarbg_player"];
        strechRightTrack = [strechRightTrack stretchableImageWithLeftCapWidth:strechRightTrack.size.width/2 topCapHeight:strechRightTrack.size.height/2];
        [_playbackSlider setMinimumTrackImage:strechLeftTrack forState:UIControlStateNormal];
        [_playbackSlider setMaximumTrackImage:strechRightTrack forState:UIControlStateNormal];
        [self addSubview:_playbackSlider];
        
        self.remainTimeLabel = [[[UILabel alloc] init] autorelease];
        _remainTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _remainTimeLabel.backgroundColor = [UIColor clearColor];
        _remainTimeLabel.textColor = [UIColor whiteColor];
        _remainTimeLabel.textAlignment = UITextAlignmentRight;
        _remainTimeLabel.font = ChineseFontWithSize(TimeLabelFontSize);
        [self addSubview:_remainTimeLabel];
        
        self.elapsedTimeLabel = [[[UILabel alloc] init] autorelease];
        _elapsedTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _elapsedTimeLabel.backgroundColor = [UIColor clearColor];
        _elapsedTimeLabel.textColor = [UIColor whiteColor];
        _elapsedTimeLabel.font = ChineseFontWithSize(TimeLabelFontSize);
        [self addSubview:_elapsedTimeLabel];
        
        [self displayLoadingView:YES];
    }
    return self;
}

- (id)initWithPlayer:(MPMoviePlayerController *)player
{
    return [self initWithPlayer:player type:SSPlayControlViewTypeHalfscreen];
}

#pragma mark - public

- (void)setType:(SSPlayControlViewType)type
{
    if (_type != type) {
        _type = type;
        
        if (_type == SSPlayControlViewTypeHalfscreen) {
            _fullscreenButton.pressed = NO;
        }
        else {
            _fullscreenButton.pressed = YES;
        }
    }
}

- (void)refreshUI
{
    /* maybe this time we havn't got duration and time yet */
    
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    CGPoint tmpCenter;
    
    _backgroundView.frame = tmpFrame;
    _loadingView.frame = tmpFrame;
    
    [_loadingLabel sizeToFit];
    _indicator.center = CGPointMake(tmpFrame.size.width/2 - 43.f, tmpFrame.size.height/2);
    _loadingLabel.center = CGPointMake(CGRectGetMaxX(_indicator.frame) + 10.f + _loadingLabel.frame.size.width/2, _indicator.center.y);
    
    tmpFrame.origin.x = LeftPadding;
    tmpFrame.size.width = vFrame.size.height;
    tmpFrame.size.height = vFrame.size.height;
    _playButton.frame = tmpFrame;
    
    CGFloat timeLabelWidth = 44.f;
    CGFloat timeLabelHeight = 10.f;
    
    if (_type == SSPlayControlViewTypeHalfscreen) {
        
        tmpFrame.origin.x = CGRectGetMaxX(_playButton.frame) + PlayButtonLeftMargin;
        tmpFrame.origin.y = TopPadding;
        tmpFrame.size.height = 14.f;
        tmpFrame.size.width = 192.f;
        _playbackSlider.frame = tmpFrame;
        
        CGFloat slideBottomMargin = 3.f;
        
        tmpFrame.origin.x = CGRectGetMinX(_playbackSlider.frame) + 1.f;
        tmpFrame.origin.y = CGRectGetMaxY(_playbackSlider.frame) + slideBottomMargin;
        tmpFrame.size.width = timeLabelWidth;
        tmpFrame.size.height = timeLabelHeight;
        _elapsedTimeLabel.frame = tmpFrame;
        
        _remainTimeLabel.textAlignment = UITextAlignmentRight;
        tmpFrame.origin.x = CGRectGetMaxX(_playbackSlider.frame) - tmpFrame.size.width - 1.f;
        tmpFrame.size.width = timeLabelWidth;
        tmpFrame.size.height = timeLabelHeight;
        _remainTimeLabel.frame = tmpFrame;
        
        tmpFrame.origin.x = CGRectGetMaxX(_playbackSlider.frame) + PlaybackSliderLeftMargin;
        tmpFrame.origin.y = 0.f;
        tmpFrame.size.width = vFrame.size.height;
        tmpFrame.size.height = vFrame.size.height;
        _fullscreenButton.frame = tmpFrame;
    }
    else {
        tmpFrame.origin.x = CGRectGetMaxX(_playButton.frame) + PlayButtonLeftMargin;
        tmpFrame.size.width = timeLabelWidth;
        tmpFrame.size.height = timeLabelHeight;
        _elapsedTimeLabel.frame = tmpFrame;
        
        tmpCenter = _elapsedTimeLabel.center;
        tmpCenter.y = vFrame.size.height/2;
        _elapsedTimeLabel.center = tmpCenter;
        
        CGFloat sliderRightMargin = 10.f;
        
        tmpFrame.size.height = 14.f;
        tmpFrame.size.width = 300;
        _playbackSlider.frame = tmpFrame;
        
        tmpCenter = _playbackSlider.center;
        tmpCenter.x = vFrame.size.width/2 + 5;
        tmpCenter.y = vFrame.size.height/2;
        _playbackSlider.center = tmpCenter;
        
        _remainTimeLabel.textAlignment = UITextAlignmentLeft;
        
        tmpFrame.origin.x = CGRectGetMaxX(_playbackSlider.frame) + sliderRightMargin;
        tmpFrame.size.width = timeLabelWidth;
        tmpFrame.size.height = timeLabelHeight;
        _remainTimeLabel.frame = tmpFrame;
        
        tmpCenter = _remainTimeLabel.center;
        tmpCenter.y = vFrame.size.height/2;
        _remainTimeLabel.center = tmpCenter;
        
        tmpFrame.origin.x = vFrame.size.width - 7.f - vFrame.size.height;
        tmpFrame.origin.y = 0.f;
        tmpFrame.size.width = vFrame.size.height;
        tmpFrame.size.height = vFrame.size.height;
        _fullscreenButton.frame = tmpFrame;
    }
}

- (void)setPlayer:(MPMoviePlayerController *)player
{
    [_player release];
    _player = [player retain];
    
    if (_player) {
        UIView *touchView = [[[UIView alloc] init] autorelease];
        touchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_player.view addSubview:touchView];
        
        UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)] autorelease];
        [tapRecognizer setNumberOfTapsRequired:1];
        [touchView addGestureRecognizer:tapRecognizer];
    }
}

#pragma mark - private

- (void)displayLoadingView:(BOOL)display
{
    if (display) {
        if (!_loading) {
            [_indicator startAnimating];
            
            _loadingView.hidden = NO;
            _playButton.hidden = YES;
            _playbackSlider.hidden = YES;
            _fullscreenButton.hidden = YES;
            _remainTimeLabel.hidden = YES;
            _elapsedTimeLabel.hidden = YES;
            
            _loading = YES;
        }
    }
    else {
        if (_loading) {
            [_indicator stopAnimating];
            
            _loadingView.hidden = YES;
            _playButton.hidden = NO;
            _playbackSlider.hidden = NO;
            _fullscreenButton.hidden = NO;
            _remainTimeLabel.hidden = NO;
            _elapsedTimeLabel.hidden = NO;
            
            _loading = NO;
        }
    }
}

- (void)displayControl:(NSNumber*)display
{
    if (([display boolValue] && self.alpha == 0)||(![display boolValue] && self.alpha == 1)) {
        
        if ([display boolValue]) {
            self.alpha = 1.f;
        }
        else {
            self.alpha = 0.f;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(playControlView:didHideControl:)]) {
            [_delegate playControlView:self didHideControl:self.alpha == 0];
        }
    }
}

- (void)displayFullscreen:(BOOL)display
{
    _fullscreenButton.pressed = display;
    
    if (!display) {
        [self displayControl:@YES];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(playControlView:didChangeFullscreen:)]) {
        [_delegate playControlView:self didChangeFullscreen:_fullscreenButton.pressed];
    }
}

#pragma mark - Actions

- (void)reportDeviceOrientationDidChange:(NSNotification *)notification
{
    if (!_orientationLocked) {
        UIInterfaceOrientation currentInterfaceOrientation = [[UIDevice currentDevice] orientation];
        if (currentInterfaceOrientation == UIInterfaceOrientationPortrait && _fullscreenButton.pressed) {
            [self displayFullscreen:NO];
        }
        else if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) && !_fullscreenButton.pressed) {
            [self displayFullscreen:YES];
        }
        
        trackEvent([SSCommon appName], _trackEventName, @"auto_rotate");
    }
}

- (void)reportDidBecomeActive:(NSNotification *)notification
{
    [self displayControl:@YES];
}

- (void)reportWillResignActive:(NSNotification *)notification
{
    _player.shouldAutoplay = NO;
    [self displayControl:@YES];
}

- (void)handleFullscreenButton:(id)sender
{
    [self displayFullscreen:!_fullscreenButton.pressed];
    trackEvent([SSCommon appName], _trackEventName, _fullscreenButton.pressed ? @"fullscreen_button" : @"halfscreen_button");
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    if (!_loading) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        
        // 如果当前状态为隐藏则应显示controls
        [self displayControl:[NSNumber numberWithBool:(self.alpha == 0)]];
        
        [UIView commitAnimations];
        [self setControlsTimer];
    }
}

- (void)setControlsTimer
{
    if (_controlsTimer) {
        [_controlsTimer invalidate];
        [_controlsTimer release];
        _controlsTimer = nil;
    }
    
    self.controlsTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_controlsTimer forMode:NSDefaultRunLoopMode];
}

- (void)handleControlsTimer:(NSTimer *)timer
{
    [self removeControls];
    [_controlsTimer release];
    _controlsTimer = nil;
}

- (void)removeControls
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    self.alpha = 0.f;
    
    if (_delegate && [_delegate respondsToSelector:@selector(playControlView:didHideControl:)]) {
        [_delegate playControlView:self didHideControl:YES];
    }
   
    [UIView commitAnimations];
}

- (void)playbackSliderMoved:(UISlider *)sender
{
    if (_player.playbackState != MPMoviePlaybackStatePaused) {
        [_player pause];
    }
    _player.currentPlaybackTime = sender.value;
    
    _elapsedTimeLabel.text = [NSString stringWithFormat:@"%@", [self makeStringFromDuration:(int)sender.value]];
    _remainTimeLabel.text = [NSString stringWithFormat:@"-%@", [self makeStringFromDuration:(int)(_player.duration - sender.value) + 1]];
    _sliding = YES;
    
    if ([_player playbackState] == MPMoviePlaybackStatePlaying) {
        [self setControlsTimer];
    }
}

- (void)playbackSliderDone:(UISlider *)sender
{
    _sliding = NO;
    if (_player.playbackState != MPMoviePlaybackStatePlaying) {
        [self displayLoadingView:YES];
        [_player play];
    }
}

- (void)playerPlaybackStateDidChange:(NSNotification *)notification
{
    if ([_player playbackState] == MPMoviePlaybackStatePaused) {
        _playButton.pressed = NO;
        [self displayControl:@YES];
        [self removeUpdatePlaybackTimer];
    }
    else if ([_player playbackState] == MPMoviePlaybackStatePlaying) {
        _playButton.pressed = YES;
        [self displayLoadingView:NO];
        
        if (!_hasPlay) {
            _hasPlay = YES;
            if (_delegate && [_delegate respondsToSelector:@selector(firstPlayInPlayControlView:)]) {
                [_delegate firstPlayInPlayControlView:self];
            }
        }
        
        [self setControlsTimer];
        [self setUpdatePlaybackTimer];
    }
    else if ([_player playbackState] == MPMoviePlaybackStateStopped) {
        _playButton.pressed = YES;
        [self displayControl:@YES];
        [self removeUpdatePlaybackTimer];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(playControlView:didChangePlaybackState:)]) {
        [_delegate playControlView:self didChangePlaybackState:[_player playbackState]];
    }
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification
{
    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if ([reason intValue] == MPMovieFinishReasonPlaybackEnded) {
        if (_fullscreenButton.pressed) {
            [self displayFullscreen:NO];
        }
        
        _playbackSlider.value = 0;
        _player.currentPlaybackTime = 0;
        _elapsedTimeLabel.text = [NSString stringWithFormat:@"%@", [self makeStringFromDuration:0]];
        _remainTimeLabel.text = [NSString stringWithFormat:@"-%@", [self makeStringFromDuration:(int)_player.duration]];
        
        [_player stop];
        _playButton.pressed = NO;
        
        _hasPlay = NO;
    }
    else {
        [self displayLoadingView:NO];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(playControlView:playbackDidFinishForReason:)]) {
          [_delegate playControlView:self playbackDidFinishForReason:reason.intValue];
    }
}

- (void)playerLoadStateDidChange:(NSNotification *)notification
{
    
}

- (void)removeUpdatePlaybackTimer
{
    if (_playbackTimer) {
        [_playbackTimer invalidate];
        [_playbackTimer release];
        _playbackTimer = nil;
    }
}

- (void)setUpdatePlaybackTimer
{
    if (_playbackTimer == nil) {
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                                              target:self
                                                            selector:@selector(updatePlaybackTime:)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (NSString *)makeStringFromDuration:(int)duration
{
    int hours = duration / (60*60);
    int minutes = (duration % (60*60)) / 60;
    int seconds = (duration % (60*60)) % 60;
    
    hours = MAX(hours, 0);
    minutes = MAX(minutes, 0);
    seconds = MAX(seconds, 0);
    
    NSString *ret = nil;
    if (hours > 0) {
        ret = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else {
        ret = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    return ret;
}

- (void)movieDurationAvailable:(NSNotification *)notification
{
    float playbacktime = _player.currentPlaybackTime;
    float duration = _player.duration;
    
    _elapsedTimeLabel.text = [NSString stringWithFormat:@"%@", [self makeStringFromDuration:(int)playbacktime]];
    _remainTimeLabel.text = [NSString stringWithFormat:@"-%@", [self makeStringFromDuration:(int)(duration - playbacktime) + 1]];
    
    _playbackSlider.minimumValue = 0.f;
    _playbackSlider.maximumValue = [_player duration];
    _playbackSlider.value = playbacktime;
    
    if (_player.shouldAutoplay) {
        _playButton.pressed = YES;
    }
}

- (void)updatePlaybackTime:(NSTimer *)timer
{
    if (!_sliding) {
        
        float playbacktime = _player.currentPlaybackTime;
        float duration = _player.duration;
        
        _elapsedTimeLabel.text = [self makeStringFromDuration:(int)playbacktime];
        _remainTimeLabel.text = [NSString stringWithFormat:@"-%@", [self makeStringFromDuration:(int)(duration - playbacktime) + 1]];
        
        _playbackSlider.value = playbacktime;
    }
}

- (void)handlePlayAndPauseButton:(id)sender
{
    VideoPlayButton *button = sender;
    if (button.pressed) {
        button.pressed = NO;
        
        [_player pause];
        [_controlsTimer invalidate];
        [_controlsTimer release];
        _controlsTimer = nil;
        
        [self displayLoadingView:NO];
        trackEvent([SSCommon appName], _trackEventName, @"pause_button");
    }
    else {
        [self displayLoadingView:YES];
        
        button.pressed = YES;
        [_player play];
        
        [self performSelector:@selector(displayControl:) withObject:@NO afterDelay:2];
        
        trackEvent([SSCommon appName], _trackEventName, @"play_button");
    }
}

@end
