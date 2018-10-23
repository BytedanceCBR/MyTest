//
//  VideoPlayerView.m
//  Video
//
//  Created by Kimi on 12-10-12.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "VideoPlayerView.h"
#import "VideoSocialView.h"
#import "VideoDetailIntroView.h"
#import "SSLazyImageView.h"
#import "SSPlayControlView.h"

#import "VideoData.h"
#import "VideoDataUtil.h"
#import "VideoDownloadDataManager.h"
#import "VideoMainViewController.h"
#import "VideoActivityIndicatorView.h"
#import "VideoLocalServer.h"
#import "NetworkUtilities.h"
#import "VideoHistoryManager.h"
#import "SSAlertCenter.h"
#import "ShareOne.h"
#import "AccountManager.h"

@interface VideoPlayerView () <NSURLConnectionDataDelegate, SSPlayControlViewDelegate, VideoSocailViewDelegate, UIGestureRecognizerDelegate> {
    BOOL _playFailed;
}

@property (nonatomic, retain) VideoSocialView *socialView;
@property (nonatomic, retain) VideoDetailIntroView *introView;
@property (nonatomic, retain) NSURLConnection *redirectConn;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) SSLazyImageView *coverImage;
@property (nonatomic, retain) SSPlayControlView *controlView;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRight2;
@property (nonatomic, retain) UITapGestureRecognizer *labelSingleTap;

@end

@implementation VideoPlayerView

- (void)dealloc
{
    [_moviePlayer stop];
    
    [[SSAlertCenter defaultCenter] resumeAlertCenter];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_playFailed) {
        [[VideoDownloadDataManager sharedManager] videoFeedbackFailed:VideoFeedbackFailedTypePlayFailed video:_video];
    }
    _controlView.delegate = nil;
    
    self.delegate = nil;
    self.video = nil;
    self.trackEventName = nil;
    self.redirectConn = nil;
    self.socialView = nil;
    self.introView = nil;
    self.controlView = nil;
    self.moviePlayer = nil;
    self.swipeRight = nil;
    self.swipeRight2 = nil;
    self.labelSingleTap = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame type:(VideoPlayerViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportAuthorityViewPresent:)
                                                     name:kAuthorityViewPresentNotification
                                                   object:nil];
        
        self.moviePlayer = [[[MPMoviePlayerController alloc] init] autorelease];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        
        self.coverImage = [[[SSLazyImageView alloc] init] autorelease];
        _coverImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _coverImage.clipType = SSLazyImageViewClipTypeRemainTop;
        _coverImage.defaultView = [[[UIImageView alloc] initWithImage:
                                        [UIImage imageNamed:@"pic_loading.png"]] autorelease];
        
        self.socialView = [[[VideoSocialView alloc] initWithFrame:CGRectZero type:VideoSocialViewTypeHalfScreen] autorelease];
        _socialView.delegate = self;
        _socialView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_socialView];
        
        self.introView = [[[VideoDetailIntroView alloc] initWithFrame:CGRectZero type:VideoDetailIntroViewTypeHalfScreen] autorelease];
        _introView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_introView];
        
        self.swipeRight2 = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)] autorelease];
        _swipeRight2.numberOfTouchesRequired = 1;
        _swipeRight2.delegate = self;
        [_introView addGestureRecognizer:_swipeRight2];
        
        self.labelSingleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelSingleTap:)] autorelease];
        _labelSingleTap.numberOfTapsRequired = 1;
        _labelSingleTap.numberOfTouchesRequired = 1;
        _labelSingleTap.cancelsTouchesInView = NO;
        [_introView addGestureRecognizer:_labelSingleTap];
        
        self.controlView = [[[SSPlayControlView alloc] initWithPlayer:_moviePlayer] autorelease];
        _controlView.delegate = self;
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _controlView.orientationLocked = orientationLocked();
        [self addSubview:_controlView];
        
        self.swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)] autorelease];
        _swipeRight.numberOfTouchesRequired = 1;
        _swipeRight.delegate = self;
    }
    return self;
}

- (void)handleLabelSingleTap:(UITapGestureRecognizer *)recognizer
{
    [_controlView handleTapFrom:recognizer];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:VideoPlayerViewTypeHalfscreen];
}

- (void)didAppear
{
    [super didAppear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_moviePlayer pause];
}

#pragma mark - public

- (void)setTrackEventName:(NSString *)trackEventName
{
    [_trackEventName release];
    _trackEventName = [trackEventName copy];
    
    if (_socialView.trackEventName) {
        _socialView.trackEventName = _trackEventName;
    }
    if (_controlView) {
        _controlView.trackEventName = _trackEventName;
    }
}

#pragma mark - Actions

- (void)reportDidBecomeActive:(NSNotification *)notification
{
    
}

- (void)reportWillResignActive:(NSNotification *)notification
{
    [_moviePlayer pause];
}

- (void)reportAuthorityViewPresent:(NSNotification *)notification
{
    [_moviePlayer pause];
    [_controlView displayControl:@YES];
}

#pragma mark - SSPlayControlViewDelegate

- (void)playControlView:(SSPlayControlView *)playControl didHideControl:(BOOL)hide
{
    if (hide) {
        _socialView.alpha = 0.0;
        _introView.alpha = 0.0;
    }
    else {
        _socialView.alpha = 1.0;
        _introView.alpha = 1.0;
    }
}

- (void)firstPlayInPlayControlView:(SSPlayControlView *)playControl
{
    _coverImage.hidden = YES;
    [_controlView performSelector:@selector(displayControl:) withObject:@NO afterDelay:2.f];
    
    [[VideoHistoryManager sharedManager] addHistory:_video];
}

- (void)playControlView:(SSPlayControlView *)playControl didChangeFullscreen:(BOOL)fullscreen
{
    _type = fullscreen ? VideoPlayerViewTypeFullscreen : VideoPlayerViewTypeHalfscreen;
    
    _socialView.type = fullscreen ? VideoSocialViewTypeFullScreen : VideoSocialViewTypeHalfScreen;
    _introView.type = fullscreen ? VideoDetailIntroViewTypeFullScreen : VideoDetailIntroViewTypeHalfScreen;
    _controlView.type = fullscreen ? SSPlayControlViewTypeFullscreen : SSPlayControlViewTypeHalfscreen;
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerView:didChangeFullscreen:)]) {
        [_delegate videoPlayerView:self didChangeFullscreen:fullscreen];
    }
}

- (void)playControlView:(SSPlayControlView *)playControl didChangePlaybackState:(MPMoviePlaybackState)state
{
    switch (state) {
        case MPMoviePlaybackStatePlaying:
        {
            if (_coverImage.hidden == NO) {
                _coverImage.hidden = YES;
            }
            [[SSAlertCenter defaultCenter] pauseAlertCenter];
            [UIApplication sharedApplication].idleTimerDisabled = YES;  // 不允许自动锁屏
        }
            break;
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStateInterrupted:
        {
            [[SSAlertCenter defaultCenter] resumeAlertCenter];
            [UIApplication sharedApplication].idleTimerDisabled = NO;  // 允许自动锁屏
        }
            break;
    }
}

- (void)playControlView:(SSPlayControlView *)playControl playbackDidFinishForReason:(int)reason
{
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        _coverImage.hidden = NO;
    }
}

#pragma mark - public

- (void)setVideo:(VideoData *)video
{
    [_video release];
    _video = [video retain];
    
    if (_video) {
        [_coverImage setNetImageUrl:_video.coverImageURL];
        _socialView.videoData = _video;
        _introView.videoData = _video;
    }
}

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    CGPoint tmpCenter;
    
    _coverImage.frame = tmpFrame;
    
    tmpFrame.size.height = VideoSocialViewHeight;
    _socialView.frame = tmpFrame;
    
    tmpFrame.origin.y = CGRectGetMaxY(_socialView.frame);
    tmpFrame.size.width = 320.f;
    tmpFrame.size.height = 92.f;
    _introView.frame = tmpFrame;
    
    if (_type == VideoPlayerViewTypeFullscreen) {
        tmpCenter = _introView.center;
        tmpCenter.x = vFrame.size.width/2;
        tmpCenter.y = CGRectGetMaxY(_socialView.frame) + 10.f + _introView.frame.size.height/2;
        _introView.center = tmpCenter;
    }
    
    CGFloat controlViewHeight = 44.f;
    tmpFrame.origin.y = vFrame.size.height - controlViewHeight;
    tmpFrame.size.width = vFrame.size.width;
    tmpFrame.size.height = controlViewHeight;
    _controlView.frame = tmpFrame;
    
    [_socialView refreshUI];
    [_introView refreshUI];
    [_controlView refreshUI];
}

- (void)prepareToPlay
{
    if ((!SSNetworkConnected() && [_video.downloadDataStatus intValue] != VideoDownloadDataStatusHasDownload)) {
        [[VideoActivityIndicatorView sharedView] showWithMessage:@"没有网络连接" duration:0.5f];
    }
    else if ([_video.downloadDataStatus intValue] == VideoDownloadDataStatusDeadLink) {
        [[VideoActivityIndicatorView sharedView] showWithMessage:@"视频已下架" duration:0.5f];
    }
    else if ([_video.downloadDataStatus intValue] == VideoDownloadDataStatusNoDownloadURL) {
        [[VideoActivityIndicatorView sharedView] showWithMessage:@"此视频在iphone上不能播放" duration:0.5f];
    }
    else {
        if (!SSNetworkWifiConnected() && notWifiAlertOn() && ![_video.userDownloaded boolValue]) {
            CGFloat duration = 2.f;
            [[VideoActivityIndicatorView sharedView] showWithMessage:@"移动网络下,观看在线视频将消耗较多流量" duration:duration];
        }
        
        if (![_video.hasRead boolValue] && [_video.downloadDataStatus intValue] == VideoDownloadDataStatusHasDownload) {
            _video.hasRead = [NSNumber numberWithBool:YES];
            [[SSModelManager sharedManager] save:nil];
        }
        
        BOOL wifiConnected = SSNetworkWifiConnected();
        if ([_video.downloadDataStatus intValue] == VideoDownloadDataStatusHasDownload) {   // play local
            
            if ([VideoLocalServer localServer].isRunning == NO) {
                [[VideoLocalServer localServer] startLocalServer];
            }
            
            if (_video.localURL) {
                if ([_video.format isEqualToString:VideoDataFormatM3U8]) {
                    [self playMovieStream:[NSURL URLWithString:_video.localURL]];
                }
                else if ([_video.format isEqualToString:VideoDataFormatMP4]) {
                    [self playMovieFile:[NSURL URLWithString:_video.localURL]];
                }
            }
            
            trackEvent([SSCommon appName], _trackEventName, wifiConnected ? @"play_download_wifi" : @"play_download_non_wifi");
        }
        else {  // play remote
            if ([_video.downloadURL length] > 0) {
                
                NSMutableString *playerURLString = [[[SSCommon customURLStringFromString:_video.downloadURL] mutableCopy] autorelease];
                [playerURLString appendString:@"&action=play"];
                if ([[AccountManager sharedManager] loggedIn]) {
                    [playerURLString appendFormat:@"&session_key=%@", [[AccountManager sharedManager] sessionKey]];
                }
                
                self.redirectConn = [NSURLConnection connectionWithRequest:
                                     [NSURLRequest requestWithURL:[NSURL URLWithString:[playerURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] delegate:self];
            }
            
            trackEvent([SSCommon appName], _trackEventName, wifiConnected ? @"play_online_wifi" : @"play_online_non_wifi");
        }
    }
}

- (void)pause
{
    [_moviePlayer pause];
}

- (void)resume
{
    [_moviePlayer play];
}

#pragma mark - Actions

- (void)handleSwipeRightGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerView:handleSwipeRightGesture:)]) {
        [_delegate videoPlayerView:self handleSwipeRightGesture:recognizer];
    }
}

- (void)playBackDidFinish:(NSNotification *)notification
{
    SSLog(@"play back did finished:%@", notification.userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoMainPlayingNotification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                                           forKey:kVideoMainPlayingNotificationPlayingKey]];
    
    if (_playFailed) {
        [[VideoActivityIndicatorView sharedView] showWithMessage:@"数据无法加载,请稍后重试" duration:2.f];
    }
}

- (void)loadStateDidChange:(NSNotification *)notification
{
    MPMovieLoadState loadState = _moviePlayer.loadState;
    if (loadState & MPMovieLoadStateUnknown) {
        _playFailed = YES;
    }
    else {
        _playFailed = NO;
    }
}

#pragma mark - private

- (void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    if (_moviePlayer) {

        if ([_video.downloadDataStatus intValue] == VideoDownloadDataStatusHasDownload || SSNetworkWifiConnected()) {
            _moviePlayer.shouldAutoplay = YES;
        }
        else {
            _moviePlayer.shouldAutoplay = NO;
        }
        
        [_moviePlayer setContentURL:movieURL];
        [_moviePlayer setMovieSourceType:sourceType];
        
        _moviePlayer.view.frame = self.bounds;
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_moviePlayer.view];
        [_moviePlayer.view addSubview:_coverImage];
        
        [_moviePlayer.view addGestureRecognizer:_swipeRight];
        
        [self bringSubviewToFront:_socialView];
        [self bringSubviewToFront:_introView];
        [self bringSubviewToFront:_controlView];
        
        _playFailed = YES;
        [_moviePlayer prepareToPlay];
        
        UIInterfaceOrientation currentInterfaceOrientation = [[UIDevice currentDevice] orientation];
        if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)) {
            [_controlView displayFullscreen:YES];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:_moviePlayer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoMainPlayingNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                                               forKey:kVideoMainPlayingNotificationPlayingKey]];
    }
}

- (void)playMovieFile:(NSURL *)movieFileURL
{
    [self createAndPlayMovieForURL:movieFileURL sourceType:MPMovieSourceTypeFile];
}

- (void)playMovieStream:(NSURL *)movieFileURL
{
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
//    if ([[movieFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//        movieSourceType = MPMovieSourceTypeStreaming;
//    }
    [self createAndPlayMovieForURL:movieFileURL sourceType:movieSourceType];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _swipeRight && _controlView.alpha != 1.f) {
        CGPoint location = [touch locationInView:self];
        return location.y < CGRectGetMaxY(_introView.frame);
    }
    
    return YES;
}

#pragma mark - VideoSocialViewDelegate

- (void)videoSocialView:(VideoSocialView *)socialView didClickedBackButton:(UIButton *)backButton
{
    _type = VideoPlayerViewTypeHalfscreen;
    
    _socialView.type = VideoSocialViewTypeHalfScreen;
    _introView.type = VideoDetailIntroViewTypeHalfScreen;
    _controlView.type = SSPlayControlViewTypeHalfscreen;
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerView:didChangeFullscreen:)]) {
        [_delegate videoPlayerView:self didChangeFullscreen:NO];
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)handleHeaderField:(NSHTTPURLResponse *)response
{
    NSDictionary *headerFields = [response allHeaderFields];
    NSString *ffContentType = [headerFields objectForKey:VideoDownloadURLHeaderFFContentType];
    if ([ffContentType isEqualToString:VideoDownloadURLHeaderFFContentTypeMP4]
        && ![_video.format isEqualToString:VideoDataFormatMP4])
    {
        _video.format = VideoDataFormatMP4;
        [[SSModelManager sharedManager] save:nil];
        SSLog(@"format change to mp4");
    }
    else if ([ffContentType isEqualToString:VideoDownloadURLHeaderFFContentTypeM3U8]
             && ![_video.format isEqualToString:VideoDataFormatM3U8])
    {
        _video.format = VideoDataFormatM3U8;
        [[SSModelManager sharedManager] save:nil];
        SSLog(@"format change to m3u8");
    }
}

- (void)playAfterRedirectWithResponse:(NSURLResponse *)response
{
    if ([_video.format isEqualToString:VideoDataFormatM3U8]) {
        [self playMovieStream:[response URL]];
    }
    else if ([_video.format isEqualToString:VideoDataFormatMP4]) {
        [self playMovieFile:[response URL]];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response) {
        NSMutableURLRequest *redirectRequest = [[request mutableCopy] autorelease]; // original request
        [self handleHeaderField:(NSHTTPURLResponse *)response];
        [redirectRequest setURL:[request URL]];
        
        return redirectRequest;
    }
    else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self playAfterRedirectWithResponse:response];
    [connection cancel];
}

@end
