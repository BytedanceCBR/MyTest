//
//  VideoControlView.m
//  Video
//
//  Created by Kimi on 12-10-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSPlayControlView.h"
#import "UIImage+TTThemeExtension.h"
 
#import "TTDeviceHelper.h"

#define LeftPadding 10.f
#define RightPadding 10.f
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
        [self setImage:[UIImage themedImageNamed:@"pause_player.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage themedImageNamed:@"pause_player_press.png"] forState:UIControlStateHighlighted];
    }
    else {
        [self setImage:[UIImage themedImageNamed:@"play_player.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage themedImageNamed:@"play_player_press.png"] forState:UIControlStateHighlighted];
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
        [self setImage:[UIImage themedImageNamed:@"halficon_player.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage themedImageNamed:@"halficon_player_press.png"] forState:UIControlStateHighlighted];
    }
    else {
        [self setImage:[UIImage themedImageNamed:@"fullicon_player.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage themedImageNamed:@"fullicon_player_press.png"] forState:UIControlStateHighlighted];
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
}

- (id)initWithPlayer:(MPMoviePlayerController *)player type:(SSPlayControlViewType)type
{
    self = [super init];
    if (self) {
        _noFullScreenButtonFlag = NO;
        _type = type;
        self.player = player;
        
        [self registerNotifications];
        
        [self loadView];
        [self displayLoadingView:YES];
    }
    return self;
}

- (id)initWithPlayer:(MPMoviePlayerController *)player
{
    return [self initWithPlayer:player type:SSPlayControlViewTypeHalfscreen];
}

- (void)loadView
{
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"toolbg_player.png"]];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.5;
    [self addSubview:_backgroundView];
    
    self.loadingView = [[UIView alloc] init];
    _loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [_indicator startAnimating];
    self.loadingLabel = [[UILabel alloc] init];
    _loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    _loadingLabel.text = NSLocalizedString(@"正在加载...", nil);
    _loadingLabel.font = [UIFont systemFontOfSize:12.f];
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.backgroundColor = [UIColor clearColor];
    [_loadingView addSubview:_indicator];
    [_loadingView addSubview:_loadingLabel];
    [self addSubview:_loadingView];
    
    self.playButton = [VideoPlayButton buttonWithType:UIButtonTypeCustom];
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [_playButton setImage:[UIImage themedImageNamed:@"play_player.png"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage themedImageNamed:@"play_player_press.png"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(handlePlayAndPauseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    
    self.fullscreenButton = [VideoFullscreenButton buttonWithType:UIButtonTypeCustom];
    _fullscreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_fullscreenButton setImage:[UIImage themedImageNamed:@"fullicon_player.png"] forState:UIControlStateNormal];
    [_fullscreenButton setImage:[UIImage themedImageNamed:@"fullicon_player_press.png"] forState:UIControlStateHighlighted];
    [_fullscreenButton addTarget:self action:@selector(handleFullscreenButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!_noFullScreenButtonFlag) {
        [self addSubview:_fullscreenButton];
    }
    
    self.playbackSlider = [[UISlider alloc] init];
    _playbackSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_playbackSlider setThumbImage:[UIImage themedImageNamed:@"progressbutton_player.png"] forState:UIControlStateNormal];
    [_playbackSlider addTarget:self action:@selector(playbackSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [_playbackSlider addTarget:self action:@selector(playbackSliderDone:) forControlEvents:UIControlEventTouchUpInside];
    [_playbackSlider addTarget:self action:@selector(playbackSliderDone:) forControlEvents:UIControlEventTouchUpOutside];
    UIImage *strechLeftTrack = [UIImage themedImageNamed:@"progressbarblue_player.png"];
    strechLeftTrack = [strechLeftTrack stretchableImageWithLeftCapWidth:strechLeftTrack.size.width/2 topCapHeight:strechLeftTrack.size.height/2];
    UIImage *strechRightTrack = [UIImage themedImageNamed:@"progressbarbg_player.png"];
    strechRightTrack = [strechRightTrack stretchableImageWithLeftCapWidth:strechRightTrack.size.width/2 topCapHeight:strechRightTrack.size.height/2];
    [_playbackSlider setMinimumTrackImage:strechLeftTrack forState:UIControlStateNormal];
    [_playbackSlider setMaximumTrackImage:strechRightTrack forState:UIControlStateNormal];
    [self addSubview:_playbackSlider];
    
    self.remainTimeLabel = [[UILabel alloc] init];
    _remainTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _remainTimeLabel.backgroundColor = [UIColor clearColor];
    _remainTimeLabel.textColor = [UIColor whiteColor];
    _remainTimeLabel.textAlignment = NSTextAlignmentRight;
    _remainTimeLabel.font = [UIFont systemFontOfSize:TimeLabelFontSize];
    [self addSubview:_remainTimeLabel];
    
    self.elapsedTimeLabel = [[UILabel alloc] init];
    _elapsedTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _elapsedTimeLabel.backgroundColor = [UIColor clearColor];
    _elapsedTimeLabel.textColor = [UIColor whiteColor];
    _elapsedTimeLabel.font = [UIFont systemFontOfSize:TimeLabelFontSize];
    [self addSubview:_elapsedTimeLabel];
}

#pragma mark - notifications

- (void)registerNotifications
{
    // movie player notifications
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
    
    // application notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
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

- (void)playerLoadStateDidChange:(NSNotification *)notification
{
    MPMovieLoadState loadState = _player.loadState;
    if (_delegate && [_delegate respondsToSelector:@selector(playControlView:didChangeLoadState:)]) {
        [_delegate playControlView:self didChangeLoadState:loadState];
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

- (void)reportDeviceOrientationDidChange:(NSNotification *)notification
{
    if (!_orientationLocked) {
        UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (![TTDeviceHelper isPadDevice]) {
            if (currentInterfaceOrientation == UIInterfaceOrientationPortrait && _fullscreenButton.pressed) {
                [self displayFullscreen:NO];
            }
            else if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) && !_fullscreenButton.pressed) {
                [self displayFullscreen:YES];
            }
        }
        else {
            if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) && !_fullscreenButton.pressed) {
                [self displayFullscreen:YES];
            }
            else {
                [self displayFullscreen:NO];
            }
        }
        
        
        ssTrackEvent(_trackEventName, @"auto_rotate");
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

#pragma mark - getter&setter

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

- (void)setNoFullScreenButtonFlag:(BOOL)noFullScreenButtonFlag
{
    if (noFullScreenButtonFlag) {
        [_fullscreenButton removeFromSuperview];
    }
    else {
        if (_fullscreenButton.superview == nil) {
            [self addSubview:_fullscreenButton];
        }
    }
}

- (void)setControlsTimer
{
    if (_controlsTimer) {
        [_controlsTimer invalidate];
        _controlsTimer = nil;
    }
    
    self.controlsTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_controlsTimer forMode:NSDefaultRunLoopMode];
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

- (void)removeUpdatePlaybackTimer
{
    if (_playbackTimer) {
        [_playbackTimer invalidate];
        _playbackTimer = nil;
    }
}

#pragma mark - Actions

- (void)handleFullscreenButton:(id)sender
{
    [self displayFullscreen:!_fullscreenButton.pressed];
    ssTrackEvent(_trackEventName, _fullscreenButton.pressed ? @"fullscreen_button" : @"halfscreen_button");
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

- (void)handleControlsTimer:(NSTimer *)timer
{
    [self removeControls];
    _controlsTimer = nil;
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
        _controlsTimer = nil;
        
        [self displayLoadingView:NO];
        ssTrackEvent(_trackEventName, @"pause_button");
    }
    else {
        [self displayLoadingView:YES];
        
        button.pressed = YES;
        [_player play];
        
        [self performSelector:@selector(displayControl:) withObject:@NO afterDelay:2];
        
        ssTrackEvent(_trackEventName, @"play_button");
    }
}

#pragma mark - public

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
        tmpFrame.size.width = self.frame.size.width - tmpFrame.origin.x - vFrame.size.height - PlaybackSliderLeftMargin - RightPadding;
        _playbackSlider.frame = tmpFrame;
        
        CGFloat slideBottomMargin = 3.f;
        
        tmpFrame.origin.x = CGRectGetMinX(_playbackSlider.frame) + 1.f;
        tmpFrame.origin.y = CGRectGetMaxY(_playbackSlider.frame) + slideBottomMargin;
        tmpFrame.size.width = timeLabelWidth;
        tmpFrame.size.height = timeLabelHeight;
        _elapsedTimeLabel.frame = tmpFrame;
        
        _remainTimeLabel.textAlignment = NSTextAlignmentRight;
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
        
        tmpFrame.size.height = 14.f;
        tmpFrame.size.width = self.frame.size.width - CGRectGetMaxX(_elapsedTimeLabel.frame) * 2 - PlaybackSliderLeftMargin * 2;
        tmpFrame.origin.x = CGRectGetMaxX(_elapsedTimeLabel.frame) + PlaybackSliderLeftMargin;
        tmpFrame.origin.y = (self.frame.size.height - 14.f) / 2.f;
        _playbackSlider.frame = tmpFrame;
        
        _remainTimeLabel.textAlignment = NSTextAlignmentRight;
        
        tmpFrame.origin.x = CGRectGetMaxX(_playbackSlider.frame) + PlaybackSliderLeftMargin;
        tmpFrame.origin.y = (self.frame.size.height - timeLabelHeight) / 2.f;
        tmpFrame.size.width = timeLabelWidth;
        tmpFrame.size.height = timeLabelHeight;
        _remainTimeLabel.frame = tmpFrame;
        
        tmpFrame.origin.x = vFrame.size.width - 7.f - vFrame.size.height;
        tmpFrame.origin.y = 0.f;
        tmpFrame.size.width = vFrame.size.height;
        tmpFrame.size.height = vFrame.size.height;
        _fullscreenButton.frame = tmpFrame;
    }
}

#pragma mark - private

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
@end
