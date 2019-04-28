//
//  TTVBackgroundManager.m
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import "TTVBackgroundManager.h"
#import "TTVPlayerStateBackgroundPrivate.h"
#import "TTVBackgroundTracker.h"
#import "NetworkUtilities.h"

@interface TTVBackgroundManager()
@property (nonatomic ,strong)NSObject <TTVPlayerTracker> *tracker;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL pausedByAudioInterruption;
@property (nonatomic) BOOL autoPaused;
@property (nonatomic, assign) NSTimeInterval lastResignActiveTime;
@end

@implementation TTVBackgroundManager
@synthesize store = _store, playerStore = _playerStore;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isActive = YES;
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
        
        
        
    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeClickResolutionDegrade]) {
            }
        }];
        [self ttvl_observer];
        self.tracker = [[TTVBackgroundTracker alloc] init];
    }
}

- (BOOL)isActive {
    return _isActive && [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
}

- (void)_willResignActive:(NSNotification *)notification {
    if ((self.store.player.readyForRender && self.store.player.playbackState == TTVideoEnginePlaybackStatePlaying) || !self.store.player.readyForRender || self.store.state.resolution.resolutionSwitching) {
        self.autoPaused = YES;
        [self.store.player pause];
    }
    
    self.isActive = NO;
    if (self.pausedByAudioInterruption) {
        self.pausedByAudioInterruption = NO;
    }
    
    self.lastResignActiveTime = [[NSDate date] timeIntervalSince1970];
}

- (void)_didBecomeActive:(NSNotification *)notification {
    if (self.isAllowPlayWhenDidBecomeActive && (self.autoPaused || self.store.state.netMonitor.pausingBycellularNetwork) && (self.store.player.playbackState == TTVideoEnginePlaybackStatePaused || self.store.player.loadState == TTVideoEngineLoadStateUnknown)) {
        if ([[NSDate date] timeIntervalSince1970] - self.lastResignActiveTime < 60 * 15) {
            if (self.autoPaused) {
                if ([self.delegate respondsToSelector:@selector(playerViewControllerShouldPlay)]) {
                    if ([self.delegate playerViewControllerShouldPlay]) {
                        if (!isEmptyString(self.store.player.videoID)) {
                            [self.store.player resume];
                        }
                    }
                }else{
                    if (!isEmptyString(self.store.player.videoID)) {
                        [self.store.player resume];
                    }
                }
            } else if (self.store.state.netMonitor.pausingBycellularNetwork) {
                BOOL connectedAndWifi = TTNetworkWifiConnected() && TTNetworkConnected();
                if (connectedAndWifi) {
                    if ([self.delegate respondsToSelector:@selector(playerViewControllerShouldPlay)]) {
                        if (
                            [self.delegate playerViewControllerShouldPlay]) {
                            if (!isEmptyString(self.store.player.videoID)) {
                                [self.store.player resume];
                            }
                        }
                    }else{
                        if (!isEmptyString(self.store.player.videoID)) {
                            [self.store.player resume];
                        }
                    }
                }
            }
        }
        
        self.autoPaused = NO;
    }
    self.isActive = YES;
}

- (void)_audioSessionRouteChangeNotification:(NSNotification *)notification
{
    if (!self.isActive) return;
    
    NSDictionary *dic = notification.userInfo;
    int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        //耳机拔出，则暂停
        if (self.store.player.playbackState == TTVideoEnginePlaybackStatePlaying) {
            self.autoPaused = YES;
            [self.store.player pause];
        }
    } else if (changeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        //耳机插入
        if (self.autoPaused) {
            self.autoPaused = NO;
            [self.store.player resume];
        }
    }
}

- (void)_audioSessionInterruptionNotification:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    int interruptionPhase = [dic[AVAudioSessionInterruptionTypeKey] intValue];
    
    if (interruptionPhase == AVAudioSessionInterruptionTypeBegan) {
        // 当前播放声音被打断 开始
        if (self.store.player.playbackState == TTVideoEnginePlaybackStatePlaying) {
            self.autoPaused = YES;
            self.pausedByAudioInterruption = YES;
            [self.store.player pause];
        }
    } else if (interruptionPhase == AVAudioSessionInterruptionTypeEnded) {
        //  当前播放声音被打断 结束
        if (self.autoPaused && self.pausedByAudioInterruption) {
            self.autoPaused = NO;
            [self.store.player resume];
        }
    }
}

- (void)ttvl_observer
{
   
}


- (void)setTracker:(NSObject<TTVPlayerTracker> *)tracker
{
    if (_tracker != tracker) {
        _tracker = tracker;
        _tracker.store = self.store;
    }
}

- (void)customTracker:(NSObject <TTVPlayerTracker> *)tracker
{
    self.tracker = tracker;
}
@end


@implementation TTVPlayer (Background)

- (TTVBackgroundManager *)resolutionManager;
{
    return nil;
//    return [self partManagerFromClass:[TTVBackgroundManager class]];
}

@end
