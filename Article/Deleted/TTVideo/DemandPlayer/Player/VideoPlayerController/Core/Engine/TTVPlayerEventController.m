//
//  TTVPlayerEventController.m
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import "TTVPlayerEventController.h"
#import "TTAVMoviePlayerController.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerStateAction.h"
#import "TTVPlayerStateModel.h"
#import "TTVFluxDispatcher.h"
#import "TTVPlayerModel.h"
#import "NetworkUtilities.h"
#import "TTStringHelper.h"
#import "TTBaseMacro.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVideoEngine.h"
#import "TTVVideoURLParser.h"
#import "KVOController.h"
#import "TTVResolutionStore.h"
#import "TTVPlayerWatchTimer.h"
#import "TTVPlayerSettingUtility.h"
#import "TTVPlayerIdleController.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVVideoNetClient.h"

extern BOOL ttvs_playerImageScaleEnable(void);

static NSString *const kvideo_controller_error_domain = @"kvideo_player_controller_error_domain";
@interface TTVPlayerEventController () <TTVFluxStoreCallbackProtocol ,TTVideoEngineDataSource,TTVideoEngineDelegate,TTVideoEngineResolutionDelegate>

@property (nonatomic, strong)  TTVideoEngine *videoEngine;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, strong) TTVPlayerWatchTimer *watchTimer;

@end

@implementation TTVPlayerEventController

#pragma life cycle

- (instancetype)init{
    self = [super init];
    if (self) {
        _watchTimer = [[TTVPlayerWatchTimer alloc] init];
        BOOL playUseIp = [[[TTSettingsManager sharedManager] settingForKey:@"tt_play_use_ip" defaultValue:@NO freeze:NO] boolValue];
        [[self class] setEnableHTTPDNS:playUseIp];
    }
    return self;
}

- (void)setPlayerModel:(TTVPlayerModel *)playerModel
{
    if (_playerModel != playerModel) {
        _playerModel = playerModel;
        if (!isEmptyString(playerModel.urlString)) {
            self.requestUrl = playerModel.urlString;
        }else{
            self.requestUrl = [TTVVideoURLParser urlWithVideoID:self.playerModel.videoID categoryID:self.playerModel.categoryID itemId:self.playerModel.itemID adID:self.playerModel.adID sp:self.playerModel.sp base:_playerModel.urlBaseParameter];
        }
    }
}

- (void)readyToPlay
{
    [self ttv_setup];
}

- (void)dealloc {
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

#pragma mark - setup
+ (void)setEnableHTTPDNS:(BOOL)enableHTTPDNS
{
    [TTVideoEngine setHTTPDNSFirst:enableHTTPDNS];
}

- (void)ttv_setup {
    [_watchTimer reset];
    [_watchTimer endWatch];

    TTVideoEngineResolutionType lastResolution = [self ttv_changePalyerResolutionToEngineResolution:[TTVResolutionStore sharedInstance].lastResolution];
    TTVideoEngineVideoInfo *videoInfo = [[TTVideoEngineVideoInfo alloc] init];
    videoInfo.vid = self.playerModel.videoID;
    videoInfo.resolution = lastResolution;
    videoInfo.expire = self.playerModel.expirationTime;
    videoInfo.playInfo = [[TTVideoEnginePlayInfo alloc] initWithDictionary:self.playerModel.videoPlayInfo];
    
    [self.KVOController unobserve:self.videoEngine];
    [self.videoEngine.playerView removeFromSuperview];
    self.videoEngine = [[TTVideoEngine alloc] initWithOwnPlayer:self.playerModel.useOwnPlayer && [[UIDevice currentDevice].systemVersion floatValue] >= 8.0];
    self.videoEngine.netClient = [[TTVVideoNetClient alloc] init];
    if (ttvs_playerImageScaleEnable()) {
        self.videoEngine.imageScaleType = TTVideoEngineImageScaleTypeLanczos;
    }
    if ([TTVPlayerSettingUtility tt_play_image_enhancement]) {
        self.videoEngine.enhancementType = TTVideoEngineEnhancementTypeContrast;
    }
    [self.videoEngine setVideoInfo:videoInfo];
    self.videoEngine.playerView.userInteractionEnabled = YES;
    if (!isEmptyString(self.playerModel.localURL)) {
        self.playerStateStore.state.isUsingLocalURL = YES;
        [self.videoEngine setLocalURL:self.playerModel.localURL];
    }else{
        self.playerStateStore.state.isUsingLocalURL = NO;
        [self.videoEngine configResolution:lastResolution];
        [self.videoEngine setVideoID:self.playerModel.videoID];
    }
    self.videoEngine.dataSource = self;
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    [self ttv_kvo];
    [self ttv_beginObservePlayTime];
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.videoEngine keyPath:@keypath(self.videoEngine,duration) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.playerStateStore.state.duration = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
    }];
    [self.KVOController observe:self.videoEngine keyPath:@keypath(self.videoEngine,playableDuration) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.playerStateStore.state.playableTime = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        self.playerStateStore.state.cacheProgress = [self ttv_cacheProgress];
    }];
}

#pragma mark private methods

- (TTVideoEngineResolutionType)ttv_changePalyerResolutionToEngineResolution:(TTVPlayerResolutionType)origin
{
    switch (origin) {
        case TTVPlayerResolutionTypeUnkown:
            return TTVideoEngineResolutionTypeUnknown;
            break;
        case TTVPlayerResolutionTypeSD:
            return TTVideoEngineResolutionTypeSD;
            break;
        case TTVPlayerResolutionTypeHD:
            return TTVideoEngineResolutionTypeHD;
            break;
        case TTVPlayerResolutionTypeFullHD:
            return TTVideoEngineResolutionTypeFullHD;
            break;
        case TTVPlayerResolutionTypeAuto:
            return TTVideoEngineResolutionTypeAuto;
            break;
        default:
            break;
    }
}

- (TTVPlayerResolutionType)ttv_changeEngineResolutionToPalyerResolution:(TTVideoEngineResolutionType)origin
{
    switch (origin) {
        case TTVideoEngineResolutionTypeUnknown:
            return TTVPlayerResolutionTypeUnkown;
            break;
        case TTVideoEngineResolutionTypeSD:
            return TTVPlayerResolutionTypeSD;
            break;
        case TTVideoEngineResolutionTypeHD:
            return TTVPlayerResolutionTypeHD;
            break;
        case TTVideoEngineResolutionTypeFullHD:
            return TTVPlayerResolutionTypeFullHD;
            break;
        case TTVideoEngineResolutionTypeAuto:
            return TTVPlayerResolutionTypeAuto;
            break;
        default:
            break;
    }
}

- (void)ttv_setWatchProgress
{
    if (![self ttv_isvalidNumber:self.videoEngine.currentPlaybackTime]) {
        return;
    }
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    self.playerStateStore.state.watchedProgress = [self ttv_progress];
}

- (void)ttv_beginObservePlayTime {
    [self.videoEngine removeTimeObserver];
    //如果停止了播放，会失去回调，手动更新到当前进度
    [self ttv_setWatchProgress];
    @weakify(self);
    [self.videoEngine addPeriodicTimeObserverForInterval:0.1 queue:dispatch_get_main_queue() usingBlock:^{
        @strongify(self);
        if (self) {
            [self ttv_setWatchProgress];
            if (self.videoEngine.playbackState == TTVideoEnginePlaybackStatePlaying && [[TTVPlayerIdleController sharedInstance] isLock]) {
                [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
            }
        }
    }];
}

#pragma mark TTVideoEngineDataSource
- (NSString *)apiForFetcher
{
    return self.requestUrl;
}

#pragma mark TTVideoEngineDelegate

- (void)ttv_videoEngineStoppedHasError:(BOOL)hasError
{
    if (hasError) {
        [self.watchTimer endWatch];
        [self saveCacheProgress];
    }else{
        [self.watchTimer endWatch];
        if (self.playerStateStore.state.duration > 0 && self.playerStateStore.state.currentPlaybackTime + 2 > self.playerStateStore.state.duration) {//播放结束了就不要cache播放进度了
            self.playerStateStore.state.playbackState = TTVVideoPlaybackStateFinished;
            [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:self.playerModel.videoID];
        }else{
            self.playerStateStore.state.playbackState = TTVVideoPlaybackStateBreak;
            [self saveCacheProgress];
        }
    }
}


/**
 playbackState loadingState 都会重试,不能拿来做最终失败的UI暂时时机
 最终的成功和失败都通过
 - (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState
- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState
 来判断
 */
- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState
{
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    switch (playbackState) {
        case TTVideoEnginePlaybackStateError:
            [self.watchTimer endWatch];
            break;
        case TTVideoEnginePlaybackStatePaused:
            [self.watchTimer endWatch];
            self.playerStateStore.state.playbackState = TTVVideoPlaybackStatePaused;
            break;
        case TTVideoEnginePlaybackStatePlaying:
            [self.watchTimer startWatch];
            self.playerStateStore.state.playbackState = TTVVideoPlaybackStatePlaying;
            break;
        case TTVideoEnginePlaybackStateStopped:
            [self.watchTimer endWatch];
            break;
        default:
            break;
    }
    [self saveCacheProgress];
    [self.playerStateStore sendAction:TTVPlayerEventTypePlaybackStateChanged payload:nil];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState
{
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    switch (loadState) {
        case TTVideoEngineLoadStateUnknown:
            self.playerStateStore.state.loadingState = TTVPlayerLoadStateStalled;
            break;
        case TTVideoEngineLoadStateError:
            self.playerStateStore.state.loadingState = TTVPlayerLoadStateStalled;
            break;
        case TTVideoEngineLoadStateStalled:
            self.playerStateStore.state.loadingState = TTVPlayerLoadStateStalled;
            break;
        case TTVideoEngineLoadStatePlayable:
            self.playerStateStore.state.loadingState = TTVPlayerLoadStatePlayable;
            break;
        default:
            self.playerStateStore.state.loadingState = TTVPlayerLoadStateStalled;
            break;
    }
    [self.playerStateStore sendAction:TTVPlayerEventTypeLoadStateChanged payload:nil];
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine
{
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    [self.watchTimer startWatch];
    self.playerStateStore.state.showVideoFirstFrame = YES;
    self.playerStateStore.state.videoSize = videoEngine.videoSize;
    self.playerStateStore.state.currentResolution = [self ttv_changeEngineResolutionToPalyerResolution:videoEngine.currentResolution];
    self.playerStateStore.state.supportedResolutionTypes = [self.videoEngine supportedResolutionTypes];
    [self.playerStateStore sendAction:TTVPlayerEventTypeShowVideoFirstFrame payload:nil];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(NSError *)error
{
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    [self ttv_videoEngineStoppedHasError:error != nil];
    if (error) {
        [self.playerStateStore sendAction:TTVPlayerEventTypeEncounterError payload:nil];
        self.playerStateStore.state.playbackState = TTVVideoPlaybackStateError;
    }else{
        [self.playerStateStore sendAction:TTVPlayerEventTypeFinished payload:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVideoFinishPlayNotificationForNightShift" object:self.playerModel.videoID ?: self];
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine
{
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    [self ttv_videoEngineStoppedHasError:NO];
    [self.playerStateStore sendAction:TTVPlayerEventTypeFinishedBecauseUserStopped payload:nil];
}

/*
 NOTE
 videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status 和
 videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(NSError *)error
 不会同时调用
 */

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status
{
    self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    [self ttv_videoEngineStoppedHasError:status > 0];
    if (status > 0) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(status),@"errorCode",nil];
        [self.playerStateStore sendAction:TTVPlayerEventTypeEncounterError payload:dic];
        self.playerStateStore.state.playbackState = TTVVideoPlaybackStateError;
    }
}

#pragma mark - user event

- (void)changeResolution:(TTVPlayerResolutionType)type
{
    self.playerStateStore.state.resolutionState = TTVResolutionStateChanging;
    [self.videoEngine configResolution:[self ttv_changePalyerResolutionToEngineResolution:type] completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
        self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
        if (success) {
            self.playerStateStore.state.currentResolution = type;
        }
        self.playerStateStore.state.resolutionState = success ? TTVResolutionStateEnd : TTVResolutionStateError;
    }];
}

- (void)setMuted:(BOOL)muted
{
    self.videoEngine.muted = muted;
}

- (void)playVideoFrom:(TTVPlayAction)action
{
    [self ttv_playVideoFrom:action];
}

- (void)playVideo
{
    if (!self.videoEngine) {
        [self ttv_setup];
    }
    [self playVideoFrom:TTVPlayActionDefault];
}

- (void)ttv_playVideoFrom:(TTVPlayAction)action {
    TTVPlayerStateModel *stateModel = _playerStateStore.state;
    if (stateModel.playbackState == TTVVideoPlaybackStatePlaying) {
        return;
    }
    [self.videoEngine play];
    if (stateModel.playbackState == TTVideoEnginePlaybackStatePaused) {
        [self.playerStateStore sendAction:TTVPlayerEventTypePlayerResume payload:nil];
    }else{
        if (!self.playerStateStore.state.hasPlayed) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[NSNumber numberWithInteger:action] forKey:@"from"];
            [self.playerStateStore sendAction:TTVPlayerEventTypePlayerPlay payload:dic];

        }else{
            [self.playerStateStore sendAction:TTVPlayerEventTypePlayerResume payload:nil];
        }
    }
    self.playerStateStore.state.hasPlayed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVideoStartPlayNotificationForNightShift" object:self.playerModel.videoID ?: self];
}

- (void)pauseVideoFrom:(TTVPauseAction)action
{
    if (_playerStateStore.state.playbackState != TTVVideoPlaybackStatePaused && _playerStateStore.state.playbackState != TTVVideoPlaybackStateError && _playerStateStore.state.playbackState != TTVVideoPlaybackStateFinished && _playerStateStore.state.playbackState != TTVVideoPlaybackStateBreak) {
        [self.videoEngine pause];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@(action) forKey:@"action"];
        [self.playerStateStore sendAction:TTVPlayerEventTypePlayerPause payload:dic];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVideoPausePlayNotificationForNightShift" object:self.playerModel.videoID ?: self];
}

- (void)pauseVideo {
    [self pauseVideoFrom:TTVPauseActionDefault];
}

- (void)stopVideo {
    TTVPlayerStateModel *stateModel = _playerStateStore.state;
    if (stateModel.playbackState != TTVVideoPlaybackStateFinished && stateModel.playbackState != TTVVideoPlaybackStateBreak) {
        [self.videoEngine stop];
        [self.playerStateStore sendAction:TTVPlayerEventTypePlayerStop payload:nil];
    }
}

- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised {
    [self _seekVideoToProgress:progress autoSeek:NO complete:finised];
}

- (void)_seekVideoToProgress:(CGFloat)progress autoSeek:(BOOL)autoSeek complete:(void(^)(BOOL success))finised {
    [self.playerStateStore sendAction:TTVPlayerEventTypePlayerSeekBegin payload:nil];
    __weak typeof(self) wself = self;
    [self.videoEngine setCurrentPlaybackTime:progress * self.videoEngine.duration complete:^(BOOL success) {
        __strong typeof(wself) self = wself;
        self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
        [self.playerStateStore sendAction:TTVPlayerEventTypePlayerSeekEnd payload:nil];
        if (finised) {
            finised(success);
        }
    }];
}

#pragma mark - flux

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(id)state {
    if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    if ([action isKindOfClass:[TTVPlayerStateAction class]]) {
        if (action.actionType == TTVPlayerEventTypeShowVideoFirstFrame) {
            [self _showVideoFirstFrame];
        } else if (action.actionType == TTVPlayerEventTypeSwitchResolution) {
            NSNumber *number = action.payload;
            if ([number isKindOfClass:[NSNumber class]]) {
                [self changeResolution:[number integerValue]];
            }
        }else if (action.actionType == TTVPlayerEventTypePlayerPlay || action.actionType == TTVPlayerEventTypeRetry || action.actionType == TTVPlayerEventTypeFinishUIReplay) {
            [self.watchTimer reset];
        }
    }
}

#pragma mark - cache progress

- (void)saveCacheProgress {
    CGFloat progress = self.playerStateStore.state.watchedProgress;
    if (progress <= 0 || progress >= 100) {
        return;
    }
    if (self.playerStateStore.state.currentPlaybackTime + 2 >= self.playerStateStore.state.duration) {
        return;
    }
    [[TTVPlayerCacheProgressController sharedInstance] cacheProgress:progress forVideoID:self.playerModel.videoID];
}

#pragma mark - fetch video

- (void)_showVideoFirstFrame {
    //seek到缓存的播放进度
    CGFloat progress = [[TTVPlayerCacheProgressController sharedInstance] progressForVideoID:self.playerModel.videoID];
    if (progress > 0 && progress < 100) {
        [self _seekVideoToProgress:progress / 100 autoSeek:YES complete:^(BOOL success) {

        }];
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:self.playerModel.videoID];
    }
}

#pragma mark - readonly

- (UIView *)playerLayer
{
    return self.videoEngine.playerView;
}

- (NSTimeInterval)watchDuration
{
    return _videoEngine.durationWatched;
}

#pragma mark - utility

- (BOOL)ttv_isvalidNumber:(NSTimeInterval)number
{
    return !isnan(number) && number != NAN;
}

- (CGFloat)ttv_progress {
    NSTimeInterval currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    NSTimeInterval duration = self.videoEngine.duration;
    if (![self ttv_isvalidNumber:currentPlaybackTime] ||
        ![self ttv_isvalidNumber:duration] ||
        currentPlaybackTime < 0 || duration <= 0) {
        return 0;
    }
    return currentPlaybackTime * 100 / duration;
}

- (CGFloat)ttv_cacheProgress {
    NSTimeInterval cacheTime = self.videoEngine.playableDuration;
    NSTimeInterval duration = self.videoEngine.duration;

    if (![self ttv_isvalidNumber:cacheTime] ||
        ![self ttv_isvalidNumber:duration] ||
        cacheTime < 0 || duration <= 0) {
        return 0;
    }
    return cacheTime * 100 / duration;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore {
    if (_playerStateStore != playerStateStore) {
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [_playerStateStore.state setPlayerWatchTimer:_watchTimer];
    }
}

@end
