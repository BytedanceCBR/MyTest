
//
//  ExploreMoviePlayerController.m
//  MyPlayer
//
//  Created by Zhang Leonardo on 15-3-2.
//  Copyright (c) 2015年 leonardo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SSMoviePlayerController.h"
#import "TTAVPlayerItemAccessLog.h"
#import "TTVAudioActiveCenter.h"

/**
 *  参数含义和统计逻辑见‘头条和段子视频上传播放质量统计文档’
 *  https://wiki.bytedance.com/pages/viewpage.action?pageId=22086850#id-头条和段子视频上传播放质量统计文档-播放质量统计
 */

@interface SSMoviePlayerController()
{
    /**
     *  是否播放过一帧
     */
    BOOL _ssIsShowedOneFrame;//不管有没有重播.

    /**
     *  是否取消播放
     */
    BOOL _ssIsPlayingCancelled;
    /**
     *  调整进度后记录缓冲结束继续播放的时间（此事件暂无法通过播放器通知获得，目前方法根据播放时间的变化来计算）
     */
    NSTimeInterval _ssSeekPlaybackTime;
    /**
     *  标记是否调整播放进度，正常播放后重置
     */
    BOOL _ssIsPlaybackTimeSeeked;
    /**
     *  标记是否缓冲的视频最后
     */
    BOOL _ssIsBufferReachEnd;
    BOOL _seekToEnd;
}

@property(nonatomic, strong)NSTimer * playbackTimer;
@property(nonatomic, assign, readwrite)NSTimeInterval playbackTime;
@property(nonatomic, assign, readwrite)BOOL           hasUserStopped;

@end

@implementation SSMoviePlayerController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playbackTimer invalidate];
    self.playbackTimer = nil;
    self.movieDelegate = nil;
}

- (void)doInitWithFrame:(CGRect)frame
{
    self.activeCenter = [[TTVAudioActiveCenter alloc] init];
    [self.activeCenter beactive];
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor blackColor];
    self.scalingMode = TTMovieScalingModeAspectFit;
}

- (void)prepareInit
{
    [self doInitWithFrame:self.frame];
}

- (void)moviePause
{
    [self.activeCenter deactive];
    [_playbackTimer invalidate];
    self.playbackTimer = nil;
    self.hasUserStopped = NO;
    [self pause];
    [self refreshPlayButton];
}

- (void)movieStop
{
    [self.activeCenter deactive];
    [_playbackTimer invalidate];
    self.playbackTimer = nil;
    self.hasUserStopped = YES;
    [self stop];
}

- (void)moviePlay
{
    [self.activeCenter beactive];
    // 解决贴片广告关闭转屏导致无法继续转屏的问题 modify by lijun
    [self performSelector:@selector(p_beginGeneratingDeviceOrientation) withObject:nil afterDelay:2.0];
    
    self.hasUserStopped = NO;
    [self play];
    [self effectivePlayTimer];
    [self refreshPlayButton];
}

- (void)sendSeekTrack
{
    if (_trackManager) {
        if (self.accessLog.events.count > 0) {
            TTAVPlayerItemAccessLogEvent * event = [self.accessLog.events firstObject];
            [_trackManager setMovieVideoURL:event.URI serverIP:event.serverAddress];
        }
        
        [_trackManager seekToTime:self.currentPlaybackTime cacheDuration:self.playableDuration];
    }
}

- (void)seekToProgress:(CGFloat)progress
{
    NSTimeInterval fromTime = self.currentPlaybackTime;
    if ([self isCustomPlayer]) {
        _seekToEnd = progress >= 100;
        WeakSelf;
        [self setCurrentPlaybackTime:self.duration * (progress / 100.f) complete:^(BOOL success) {
            StrongSelf;
            [self sendSeekTrack];
            _seekToEnd = NO;
        }];
    }
    else
    {
        self.currentPlaybackTime = self.duration * (progress / 100.f);
        [self sendSeekTrack];
    }

    // 拖动后如果需要缓冲，则需要重新计算帧显示时间
    if (self.currentPlaybackTime > self.playableDuration) {
        _ssIsPlaybackTimeSeeked = YES;
        _ssSeekPlaybackTime = -1.0f;
    }

    if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieController:seekToTime:fromTime:)]) {
        [_movieDelegate movieController:self seekToTime:self.currentPlaybackTime fromTime:fromTime];
    }
    
    [self effectivePlayTimer];
}

- (void)moviePlayContentForURL:(NSURL *)url
{
    _ssIsShowedOneFrame = NO;
    [self setContentURL:url];
    
    if (url) {
        [self prepareToPlay];
    }
}

- (void)reset
{
    self.playbackTime = 0;
    self.hasUserStopped = NO;
    [_playbackTimer invalidate];
    self.playbackTimer = nil;
}

- (void)cancelPlaying
{
    _ssIsPlayingCancelled = YES;
}

- (void)refreshPlayButton
{
    //overrides by subclass
}

- (void)refreshSlider
{
    //overrides by subclass
}

- (void)invalidatePlaybackTimer {
    [_playbackTimer invalidate];
    _playbackTimer = nil;
}

#pragma mark -- timer

- (void)effectivePlayTimer
{
    [self invalidatePlaybackTimer];
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                          target:self
                                                        selector:@selector(updatePlaybackTime:)
                                                        userInfo:nil
                                                         repeats:YES];
    if (_playbackTimer) {
        [[NSRunLoop currentRunLoop] addTimer:_playbackTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updatePlaybackTime:(NSTimer *)timer
{
    NSTimeInterval duration = self.duration;
    NSTimeInterval currentPlaybackTime = self.currentPlaybackTime;
    if (duration == NAN || duration <= 0 || currentPlaybackTime == NAN || currentPlaybackTime < 0) {
        return;
    }
    
    if (currentPlaybackTime != 0) {
        _playbackTime = currentPlaybackTime;
    }
    
    [self refreshSlider];
    
    if (!_ssIsBufferReachEnd && _trackManager && (self.playableDuration + 1) >= self.duration) {
        [_trackManager movieBufferDidReachEnd];
        _ssIsBufferReachEnd = YES;
    }
    
    // 计算拖动进度条后的实际seektime
    if (_ssIsPlaybackTimeSeeked) {
        if (_ssSeekPlaybackTime <= 0) {
            _ssSeekPlaybackTime = currentPlaybackTime;
        }
        
        if (currentPlaybackTime > _ssSeekPlaybackTime && !_seekToEnd) {
            _ssIsPlaybackTimeSeeked = NO;
        }
    }
}

#pragma mark -- notification

- (BOOL)hasErrorWithUserInfo:(NSDictionary *)userInfo
{
    return [[userInfo objectForKey:TTMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == TTMovieFinishReasonPlaybackError;
}

- (void)player:(NSObject <TTPlayer> *)player playbackStateDidChange:(TTMoviePlaybackState)playbackState
{
    [super player:player playbackStateDidChange:playbackState];
    if (playbackState == TTMoviePlaybackStatePlaying) {
        [self.activeCenter beactive];
    }else if(playbackState == TTMoviePlaybackStatePaused || playbackState == TTMoviePlaybackStateStopped || playbackState == TTMoviePlaybackStateError || playbackState == TTMoviePlaybackStateInterrupted){
        [self.activeCenter deactive];
    }
    if (!_ssIsShowedOneFrame && self.playbackState == TTMoviePlaybackStatePlaying) {
        _ssIsShowedOneFrame = YES;

        if (_trackManager) {
            [_trackManager showedOnceFrame];
        }

        if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieControllerShowedOneFrame:)]) {
            [_movieDelegate movieControllerShowedOneFrame:self];
        }
    }

    [self refreshPlayButton];
}

- (void)player:(NSObject <TTPlayer> *)player loadStateDidChange:(TTMovieLoadState)loadState
{
    [super player:player loadStateDidChange:loadState];
    if (_ssIsPlayingCancelled) {
        return;
    }

    if ((self.loadState & TTMovieLoadStateStalled) != 0) {
        if (_trackManager && _ssIsShowedOneFrame) {
            [_trackManager movieStalled];
        }

        if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieControllerMovieStalled:)]) {
            [_movieDelegate movieControllerMovieStalled:self];
        }
    }
    else if ((self.loadState & TTMovieLoadStatePlayable) != 0) {
        if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieControllerMoviePlayable:)]) {
            [_movieDelegate movieControllerMoviePlayable:self];
        }
        if ([self isCustomPlayer]) {
            [self refreshPlayButton];
        }
    }
}

- (void)playerIsPrepareToPlay:(NSObject <TTPlayer> *)player
{
    [super playerIsPrepareToPlay:player];
    if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieControllerPlaybackPrepareToPlay:)]) {
        [_movieDelegate movieControllerPlaybackPrepareToPlay:self];
    }
}

- (void)playerBeforePrepareToPlay:(NSObject <TTPlayer> *)player
{
    [super playerBeforePrepareToPlay:player];
}

- (void)player:(NSObject <TTPlayer> *)player playbackDidFinish:(NSDictionary *)reason
{
    [self.activeCenter deactive];
    _ssIsShowedOneFrame = NO;
    [super player:player playbackDidFinish:reason];
    BOOL hasError = [self hasErrorWithUserInfo:reason];
    if (_trackManager) {
        if (self.accessLog.events.count > 0) {
            TTAVPlayerItemAccessLogEvent *event = [self.accessLog.events firstObject];
            [_trackManager setMovieVideoURL:event.URI serverIP:event.serverAddress];
        }

        if (hasError) {
            NSError *error = [reason objectForKey:@"error"];
            if (![error isKindOfClass:[NSError class]]) {
                error = nil;
            }
            [_trackManager movieFinishError:error currentPlaybackTime:self.currentPlaybackTime];
        }
    }

    if (hasError)
    {
        if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieController:playbackHasError:)]) {
            [_movieDelegate movieController:self playbackHasError:[reason objectForKey:@"error"]];
        }
    }
    else
    {
        if (_movieDelegate && [_movieDelegate respondsToSelector:@selector(movieControllerPlaybackDidFinish:)]) {
            [_movieDelegate movieControllerPlaybackDidFinish:self];
        }
    }
}

- (void)p_beginGeneratingDeviceOrientation {
    
    UIDevice *device = [UIDevice currentDevice];
    
    if (![device isGeneratingDeviceOrientationNotifications]) {
        [device beginGeneratingDeviceOrientationNotifications];
    }

}
@end
