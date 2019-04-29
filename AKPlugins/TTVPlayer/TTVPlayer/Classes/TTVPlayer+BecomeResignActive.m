//
//  TTVPlayer+BecomeResignActive.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/23.
//

#import "TTVPlayer+BecomeResignActive.h"
#import "TTVPlayer+Engine.h"
#import "NetworkUtilities.h"
#import <objc/runtime.h>
#import "TTVAudioSessionManager.h"

@interface TTVPlayer ()
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL pausedByAudioInterruption;
@property (nonatomic) BOOL autoPaused;
@property (nonatomic) NSTimeInterval lastResignActiveTime;
@end

@implementation TTVPlayer (BecomeResignActive)

#pragma mark - background
- (void)addBackgroundObserver {
    
    self.isActive = YES;
    //    self.isAllowPlayWhenDidBecomeActive = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_audioSessionRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_audioSessionInterruptionNotification:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

}

- (void)_willResignActive:(NSNotification *)notification {
    if (!self.supportBackgroundPlayback && ((self.readyForDisplay && self.playbackState == TTVPlaybackState_Playing) ||
                                            !self.readyForDisplay))
        //        self.store.state.resolution.resolutionSwitching) { // TODO
    {
        self.autoPaused = YES;
        [self pause];
    }
    
    self.isActive = NO;
    if (self.pausedByAudioInterruption) {
        self.pausedByAudioInterruption = NO;
    }
    
    self.lastResignActiveTime = [[NSDate date] timeIntervalSince1970];
}

- (void)_didBecomeActive:(NSNotification *)notification {
    if (/*self.isAllowPlayWhenDidBecomeActive && */(self.autoPaused || [self storeState].networkState.pausingBycellularNetwork) && (self.playbackState == TTVPlaybackState_Paused || self.loadState == TTVPlayerLoadState_Unknown)) {
        if ([[NSDate date] timeIntervalSince1970] - self.lastResignActiveTime < 60 * 15) {
            if (self.autoPaused) {
                if (!isEmptyString(self.videoID)) {
                    [self resume];
                }
            }
            else if ([self storeState].networkState.pausingBycellularNetwork) {
                BOOL connectedAndWifi = TTNetworkWifiConnected() && TTNetworkConnected();
                if (connectedAndWifi) {
                    if (!isEmptyString(self.videoID)) {
                        [self resume];
                    }
                }
            }
        }
        
        self.autoPaused = NO;
    }
    self.isActive = YES;
}

- (void)_audioSessionRouteChangeNotification:(NSNotification *)notification {
    if (!self.isActive && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) return;

    NSDictionary *dic = notification.userInfo;
    int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];

    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        //耳机拔出，则暂停
        if (self.playbackState == TTVideoEnginePlaybackStatePlaying) {
            self.autoPaused = YES;
            [self pause];
        }
    } else if (changeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        //耳机插入
        if (self.autoPaused) {
            self.autoPaused = NO;
            [self resume];
        }
    }
}

- (void)_audioSessionInterruptionNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    int interruptionPhase = [dic[AVAudioSessionInterruptionTypeKey] intValue];

    if (interruptionPhase == AVAudioSessionInterruptionTypeBegan) {
        // 当前播放声音被打断 开始
        if (self.playbackState == TTVideoEnginePlaybackStatePlaying) {
            self.autoPaused = YES;
            self.pausedByAudioInterruption = YES;
            [self pause];
        }
    } else if (interruptionPhase == AVAudioSessionInterruptionTypeEnded) {
        //  当前播放声音被打断 结束
        if (self.autoPaused && self.pausedByAudioInterruption) {
            self.autoPaused = NO;
            [self resume];
        }
    }
}

- (TTVPlayerState *)storeState {
    return (TTVPlayerState *)self.playerStore.state;
}
#pragma mark - getters & setters
- (BOOL)isActive {
    return [objc_getAssociatedObject(self, @selector(isActive)) boolValue];
}
- (void)setIsActive:(BOOL)isActive {
    objc_setAssociatedObject(self, @selector(isActive), @(isActive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)pausedByAudioInterruption {
    return [objc_getAssociatedObject(self, @selector(pausedByAudioInterruption)) boolValue];
}
- (void)setPausedByAudioInterruption:(BOOL)pausedByAudioInterruption {
    objc_setAssociatedObject(self, @selector(pausedByAudioInterruption), @(pausedByAudioInterruption), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)autoPaused {
    return [objc_getAssociatedObject(self, @selector(autoPaused)) boolValue];
}
- (void)setAutoPaused:(BOOL)autoPaused {
    objc_setAssociatedObject(self, @selector(autoPaused), @(autoPaused), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSTimeInterval)lastResignActiveTime {
    return [objc_getAssociatedObject(self, @selector(lastResignActiveTime)) doubleValue];
}
- (void)setLastResignActiveTime:(NSTimeInterval)lastResignActiveTime {
    objc_setAssociatedObject(self, @selector(lastResignActiveTime), @(lastResignActiveTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)supportBackgroundPlayback {
    return [objc_getAssociatedObject(self, @selector(supportBackgroundPlayback)) boolValue];
}
- (void)setSupportBackgroundPlayback:(BOOL)supportBackgroundPlayback {
    objc_setAssociatedObject(self, @selector(supportBackgroundPlayback), @(supportBackgroundPlayback), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
