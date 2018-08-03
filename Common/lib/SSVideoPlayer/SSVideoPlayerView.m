//
//  VideoPlayerView.m
//  Video
//
//  Created by Kimi on 12-10-12.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//  
// 视频播放的函数调用顺序如下：
// prepareToPlay 准备player并开始第一次尝试播放
// loadNextPlayInfo对每一个playURLInfo尝试播放，如果已经到达最后一个info，返回值为NO，否则为YES
// redirectConn重定向得到最终可播放的播放地址(为兼容某些网站的播放问题)
// playAfterRedirectWithResponse
// 更具格式选择playMovieFile or playMovieStream
// playMovieForURL开始播放，添加对loadState和playBack的notification监听
// loadStateDidChange，更具loadState判断本次播放_playFailed
// 如果_playFailed，则loadNextPlayInfo
// 若loadNextPlayInfo返回NO，则提示播放失败，退出播放
//

#import <MediaPlayer/MediaPlayer.h>

#import "SSVideoPlayerView.h"
#import "SSImageView.h"
#import "TTIndicatorView.h"

#import "SSVideoConstants.h"
#import "SSVideoModel.h"
#import "SSVideoManager.h"
#import "ShareOne.h"
#import "AccountManager.h"
#import "SSAlertCenter.h"
#import "TTToolService.h"

#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"

#define ControlViewHight 44.f

@interface SSVideoPlayerView () <SSPlayControlViewDelegate, NSURLConnectionDataDelegate> {
    BOOL _playFailed;
    NSURLConnection *_redirectConn;
}

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) UIView *moviePlayerBaseView;
@property (nonatomic, retain) SSImageView *coverImage;
@property (nonatomic, retain) SSVideoModelPlayInfo *currentPlayInfo;
@property (nonatomic, retain) UIView *touchView;
@end

@implementation SSVideoPlayerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_moviePlayer stop];
    self.moviePlayer = nil;
    self.moviePlayerBaseView = nil;
    _controlView.delegate = nil;
    self.controlView = nil;

    [[SSAlertCenter defaultCenter] resumeAlertCenter];
    
    self.video = nil;
    self.trackEventName = nil;
    self.currentPlayInfo = nil;
    self.touchView = nil;
    
    [_redirectConn cancel];
    _redirectConn = nil;
}

- (id)initWithFrame:(CGRect)frame type:(VideoPlayerViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        [self loadView];
        [self registerNotifications];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:VideoPlayerViewTypeHalfscreen];
}

- (void)loadView
{
    self.moviePlayerBaseView = [[UIView alloc] initWithFrame:CGRectZero]; // movie player container
    _moviePlayerBaseView.backgroundColor = [UIColor clearColor];
    [self addSubview:_moviePlayerBaseView];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    _moviePlayer.view.frame = _moviePlayerBaseView.bounds;
    _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_moviePlayerBaseView addSubview:_moviePlayer.view];
    
    self.coverImage = [[SSImageView alloc] init];
    _coverImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _coverImage.backgroundColor = [UIColor clearColor];
    _coverImage.clipsToBounds = YES;
    _coverImage.imageContentMode = UIViewContentModeTop;
    //_coverImage.placeHolderView = [[[UIImageView alloc] initWithImage:
      //                          [UIImage themedImageNamed:@"pic_loading.png"]] autorelease];
    [_moviePlayer.view addSubview:_coverImage];
    
    self.controlView = [[SSPlayControlView alloc] initWithPlayer:_moviePlayer];
    _controlView.delegate = self;
    _controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _controlView.orientationLocked = orientationLocked();
    [self addSubview:_controlView];
    
    [self refreshUI];
    [self refreshPlayerViewBySSVideoPlayerViewControlViewPositionType];
        
    self.touchView = [[UIView alloc] initWithFrame:self.bounds];
    _touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _touchView.height = self.bounds.size.height - _controlView.frame.size.height;
    [self addSubview:_touchView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:_controlView
                                                                                 action:@selector(handleTapFrom:)];
    [_touchView addGestureRecognizer:singleTap];
}

#pragma mark - View Lifecycle

- (void)didAppear
{
    [super didAppear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_moviePlayer pause];
}

#pragma mark - getter&setter

- (void)setControlViewPositionType:(SSVideoPlayerViewControlViewPositionType)controlViewPositionType
{
    _controlViewPositionType = controlViewPositionType;
    [self refreshPlayerViewBySSVideoPlayerViewControlViewPositionType];
}

- (void)setTrackEventName:(NSString *)trackEventName
{
    _trackEventName = [trackEventName copy];
    
    if (_controlView) {
        _controlView.trackEventName = _trackEventName;
    }
}

- (void)setVideo:(SSVideoModel *)video
{
    if (video != _video) {
        _video = video;
    }
    
    if (_video) {
        if (video.coverImageURL != nil) {
            [_coverImage setImageWithURLString:_video.coverImageURL placeholderImage:[UIImage themedImageNamed:@"pic_loading.png"]];
        }
    }
}

#pragma mark - update ui

- (void)refreshPlayerViewBySSVideoPlayerViewControlViewPositionType
{
    if (_controlViewPositionType == SSVideoPlayerViewControlViewInnerBottom) {
        _moviePlayerBaseView.frame = self.bounds;
    }
    else if (_controlViewPositionType == SSVideoPlayerViewControlViewBottom) {
        _moviePlayerBaseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - ControlViewHight);
    }
    _moviePlayer.view.frame = _moviePlayerBaseView.bounds;
}

#pragma mark - public

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    _coverImage.frame = tmpFrame;
    _coverImage.center = CGPointMake(_coverImage.frame.size.width / 2.f, _coverImage.frame.size.height / 2.f);
    
    CGFloat controlViewHeight = ControlViewHight;
    tmpFrame.origin.y = vFrame.size.height - controlViewHeight;
    tmpFrame.size.width = vFrame.size.width;
    tmpFrame.size.height = controlViewHeight;
    _controlView.frame = tmpFrame;
    [_controlView refreshUI];
}

- (void)prepareToPlay
{
    if (!SSNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        if (_delegate && [_delegate performSelector:@selector(videoPlayerViewPlayFailed:)]) {
            [_delegate videoPlayerViewPlayFailed:self];
        }
    }
    else {
        if (!SSNetworkWifiConnected() && notWifiAlertOn()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"移动网络下,观看在线视频将消耗较多流量" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        
        [self loadNextPlayInfo];
        BOOL wifiConnected = SSNetworkWifiConnected();
        ssTrackEvent(_trackEventName, wifiConnected ? @"play_online_wifi" : @"play_online_non_wifi");
    }
}

- (BOOL)isCurrentPlayFailed
{
    return _playFailed;
}

- (void)pause
{
    [_moviePlayer pause];
}

- (void)resume
{
    [_moviePlayer play];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshPlayerViewBySSVideoPlayerViewControlViewPositionType];
}

#pragma mark - application notifications

- (void)registerNotifications
{
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
}

- (void)reportDidBecomeActive:(NSNotification *)notification
{
    // do nothing   
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

#pragma mark - private

- (BOOL)loadNextPlayInfo
{
    if([_video.playURLInfos lastObject] == _currentPlayInfo) {
        return NO;
    }
    
    self.currentPlayInfo = [_video nextPlayInfo:_currentPlayInfo];
    if ([_video.playURLInfos indexOfObject:_currentPlayInfo] > 0) {
//#warning debug code
//        _currentPlayInfo.playURL = @"http://v0.pstatp.com/20130315/34/16872091600997723-2.m3u8";
        [self rebuildView];
    }
    
    NSMutableString *playerURLString = [[TTToolService customURLStringFromString:_currentPlayInfo.playURL] mutableCopy];
    [playerURLString appendString:@"&action=play"];

    NSURL *redictConnURL = [TTStringHelper URLWithURLString:playerURLString];
    [_redirectConn cancel];
    _redirectConn = nil;
    
    NSMutableURLRequest *tRequest = [NSMutableURLRequest requestWithURL:redictConnURL];
    for (NSString *tKey in _currentPlayInfo.headers.allKeys) {
        [tRequest setValue:[_currentPlayInfo.headers objectForKey:tKey] forHTTPHeaderField:tKey];
    }
    _redirectConn = [[NSURLConnection alloc ] initWithRequest:tRequest delegate:self startImmediately:YES];
    return YES;
}

- (void)rebuildView
{
    [_moviePlayer.view removeFromSuperview];
    [_coverImage removeFromSuperview];
    [_controlView removeFromSuperview];
    [_touchView removeFromSuperview];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    _moviePlayer.view.frame = _moviePlayerBaseView.bounds;
    _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_moviePlayerBaseView addSubview:_moviePlayer.view];
    
    self.coverImage = [[SSImageView alloc] init];
    _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _coverImage.backgroundColor = [UIColor clearColor];
    _coverImage.clipsToBounds = YES;
    _coverImage.imageContentMode = UIViewContentModeTop;

    [_moviePlayer.view addSubview:_coverImage];
    
    self.controlView = [[SSPlayControlView alloc] initWithPlayer:_moviePlayer];
    _controlView.delegate = self;
    _controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _controlView.orientationLocked = orientationLocked();
    [self addSubview:_controlView];
    
    [self refreshUI];
    [self refreshPlayerViewBySSVideoPlayerViewControlViewPositionType];
    
    self.touchView = [[UIView alloc] initWithFrame:self.bounds];
    _touchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _touchView.height = self.bounds.size.height - _controlView.frame.size.height;
    [self addSubview:_touchView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:_controlView
                                                                                 action:@selector(handleTapFrom:)];
    [_touchView addGestureRecognizer:singleTap];
}

- (void)playMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    if (_moviePlayer) {
        [_moviePlayer setContentURL:movieURL];
        [_moviePlayer setMovieSourceType:sourceType];
        [_moviePlayer setShouldAutoplay:YES];
        
        _playFailed = YES;
        [_moviePlayer prepareToPlay];
        
        UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)) {
            [_controlView displayFullscreen:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoMainPlayingNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                                               forKey:kVideoMainPlayingNotificationPlayingKey]];
    }
}

- (void)playMovieFile:(NSURL *)movieFileURL
{
    [self playMovieForURL:movieFileURL sourceType:MPMovieSourceTypeFile];
}

- (void)playMovieStream:(NSURL *)movieFileURL
{
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    [self playMovieForURL:movieFileURL sourceType:movieSourceType];
}

- (void)handleHeaderField:(NSHTTPURLResponse *)response
{
    NSDictionary *headerFields = [response allHeaderFields];
    
    NSLog(@"header:%@\n for url:%@\n", headerFields, _currentPlayInfo.playURL);
    
    NSString *ffContentType = [headerFields objectForKey:VideoDownloadURLHeaderFFContentType];
    if ([ffContentType isEqualToString:VideoDownloadURLHeaderFFContentTypeMP4]
        && ![_currentPlayInfo.videoFormat isEqualToString:VideoDataFormatMP4])
    {
        _currentPlayInfo.videoFormat = VideoDataFormatMP4;
        SSLog(@"format change to mp4");
    }
    else if ([ffContentType isEqualToString:VideoDownloadURLHeaderFFContentTypeM3U8]
             && ![_currentPlayInfo.videoFormat isEqualToString:VideoDataFormatM3U8])
    {
        _currentPlayInfo.videoFormat = VideoDataFormatM3U8;
        SSLog(@"format change to m3u8");
    }
}

- (void)playAfterRedirectWithResponse:(NSURLResponse *)response
{
    if ([_currentPlayInfo.videoFormat isEqualToString:VideoDataFormatM3U8]) {
        [self playMovieStream:[response URL]];
    }
    else if ([_currentPlayInfo.videoFormat isEqualToString:VideoDataFormatMP4]) {
        [self playMovieFile:[response URL]];
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response) {
        NSMutableURLRequest *redirectRequest = [request mutableCopy]; // original request
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

#pragma mark - SSPlayControlViewDelegate

- (void)playControlView:(SSPlayControlView *)playControl didHideControl:(BOOL)hide
{
    // could put update ui code here
}

- (void)firstPlayInPlayControlView:(SSPlayControlView *)playControl
{
    _coverImage.hidden = YES;
    [_controlView performSelector:@selector(displayControl:) withObject:@NO afterDelay:2.f];
}

- (void)playControlView:(SSPlayControlView *)playControl didChangeFullscreen:(BOOL)fullscreen
{
    _type = fullscreen ? VideoPlayerViewTypeFullscreen : VideoPlayerViewTypeHalfscreen;
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
        default:
            break;
    }
}

- (void)playControlView:(SSPlayControlView *)playControl didChangeLoadState:(MPMovieLoadState)state
{
    MPMovieLoadState loadState = _moviePlayer.loadState;
    if (loadState & MPMovieLoadStateUnknown) {
        _playFailed = YES;
    }
    else {
        _playFailed = NO;
    }
}

- (void)playControlView:(SSPlayControlView *)playControl playbackDidFinishForReason:(int)reason
{
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        _coverImage.hidden = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoMainPlayingNotification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                                           forKey:kVideoMainPlayingNotificationPlayingKey]];
    
    if (_playFailed) {
        [[SSVideoManager sharedManager] videoPlayFailedFeedback:_video playInfo:_currentPlayInfo];
        
        if (![self loadNextPlayInfo]) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"数据无法加载,请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerViewPlayFailed:)]) {
                [_delegate videoPlayerViewPlayFailed:self];
            }
        }
    }
}
@end
