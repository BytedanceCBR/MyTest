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
#import "TTVPlayerLogEvent.h"
#import "TTVPlayerAudioController.h"
#import "TTVVideoNetClient.h"
#import "TTVOwnPlayerPreloaderWrapper.h"
#import "TTVOwnPlayerCacheWrapper.h"
#import "TTVAudioActiveCenter.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "TTSettingsManager.h"

static NSString *const kvideo_controller_error_domain = @"kvideo_player_controller_error_domain";
static NSString *platformString;
@interface TTVPlayerEventController () <TTVFluxStoreCallbackProtocol ,TTVideoEngineDataSource,TTVideoEngineDelegate,TTVideoEngineResolutionDelegate>

@property (nonatomic, strong)  TTVideoEngine *videoEngine;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, strong) TTVPlayerWatchTimer *watchTimer;
@property(nonatomic, strong)TTVPlayerLogEvent *logEvent;
@property (nonatomic, strong) TTVAudioActiveCenter *activeCenter;
@property(nonatomic, copy)NSString *directVideoUrl;//直接可播放的视频url

@property (nonatomic, strong) NSMutableSet *retainTaskSet;
@end

@implementation TTVPlayerEventController

+ (NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)ttv_platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


#pragma life cycle

- (instancetype)init{
    self = [super init];
    if (self) {
        _useCache = YES;
        self.logEvent = [TTVPlayerLogEvent sharedInstance];
        _watchTimer = [[TTVPlayerWatchTimer alloc] init];
        _activeCenter = [[TTVAudioActiveCenter alloc] init];
        BOOL playUseIp = [[[TTSettingsManager sharedManager] settingForKey:@"tt_play_use_ip" defaultValue:@NO freeze:NO] boolValue];
        [[self class] setEnableHTTPDNS:playUseIp];
//        [[TTVPlayerAudioController sharedInstance] setCategory:AVAudioSessionCategoryPlayback];
    }
    return self;
}

- (void)setPlayerModel:(TTVPlayerModel *)playerModel
{
    if (_playerModel != playerModel) {
        _playerModel = playerModel;
        if (!isEmptyString(playerModel.urlString)) {
            self.directVideoUrl = playerModel.urlString;
        }else{
            self.requestUrl = [TTVVideoURLParser urlWithVideoID:self.playerModel.videoID categoryID:self.playerModel.categoryID itemId:self.playerModel.itemID adID:self.playerModel.adID sp:self.playerModel.sp base:nil];
        }
    }
}

- (void)readyToPlay
{
    _activeCenter.playerStateStore = _playerStateStore;
    [self ttv_setup];
}

- (void)dealloc {
    // 不需要时释放缓存文件强引用(允许删除文件)
    for (NSNumber *task in self.retainTaskSet) {
        TTAVPreloader *preloader = [TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader;
        [preloader releaseFileForKey:[task longLongValue]];
    }
    [self.videoEngine removeTimeObserver];
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (void)releaseAysnc
{
    [self.videoEngine closeAysnc];
}

#pragma mark - setup
+ (void)setEnableHTTPDNS:(BOOL)enableHTTPDNS
{
    [TTVideoEngine setHTTPDNSFirst:enableHTTPDNS];
}

- (void)ttv_setup {
    for (NSNumber *task in self.retainTaskSet) {
        TTAVPreloader *preloader = [TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader;
        [preloader releaseFileForKey:[task longLongValue]];
    }
    [self.retainTaskSet removeAllObjects];
    [_watchTimer reset];
    [_watchTimer endWatch];
    [TTVResolutionStore sharedInstance].resolutionAlertClick = NO;
    if (TTNetworkWifiConnected()) {
        [TTVResolutionStore sharedInstance].forceSelected = NO;
    }
    TTVideoEngineResolutionType lastResolution = [self ttv_changePalyerResolutionToEngineResolution:[TTVResolutionStore sharedInstance].lastResolution];
    if ([TTVResolutionStore sharedInstance].forceSelected) {
        if (!TTNetworkWifiConnected()) {
            lastResolution = [self ttv_changePalyerResolutionToEngineResolution:[TTVResolutionStore sharedInstance].autoResolution];
        }
    }else{
        if (![TTVResolutionStore sharedInstance].userSelected) {
            if (TTNetworkWifiConnected()) {
                if (self.playerModel.defaultResolutionType != TTVPlayerResolutionTypeUnkown) {
                    lastResolution = [self ttv_changePalyerResolutionToEngineResolution:self.playerModel.defaultResolutionType];
                }else{
                    lastResolution = TTVideoEngineResolutionTypeAuto;
                }
            }
        }
    }
    TTVideoEngineVideoInfo *videoInfo = [[TTVideoEngineVideoInfo alloc] init];
    videoInfo.vid = self.playerModel.videoID;
    videoInfo.expire = self.playerModel.expirationTime;
    videoInfo.playInfo = [[TTVideoEnginePlayInfo alloc] initWithDictionary:self.playerModel.videoPlayInfo];
    
    [self.KVOController unobserve:self.videoEngine];
    [self.videoEngine.playerView removeFromSuperview];
    BOOL isOwn = self.playerModel.useOwnPlayer && [[UIDevice currentDevice].systemVersion floatValue] >= 8.0;
    if (!isEmptyString(self.playerModel.localURL)) {
        isOwn = NO;
    }
    self.videoEngine = [[TTVideoEngine alloc] initWithOwnPlayer:isOwn];
    self.videoEngine.resolutionServerControlEnabled = YES;
    self.videoEngine.h265Enabled = [[TTSettingsManager sharedManager] settingForKey:@"video_h265_enable" defaultValue:@(NO) freeze:NO];
    if (self.playerStateStore.state.enableSmothlySwitch) {
        self.videoEngine.smoothlySwitching = YES;
        self.videoEngine.smoothDelayedSeconds = 3;
    }
    self.videoEngine.netClient = [[TTVVideoNetClient alloc] init];
    
    BOOL hardDecoder = [[[TTSettingsManager sharedManager] settingForKey:@"tt_player_hard_decoder" defaultValue:@0 freeze:NO] boolValue];
    if (!platformString) {
        platformString = [[self class] ttv_platformString];
    }
    if ([platformString isEqualToString:@"Simulator"]) {
        hardDecoder = NO;
    }
    self.videoEngine.hardwareDecode = hardDecoder;
    if ([TTVPlayerSettingUtility ttvs_playerImageScaleEnable]) {
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
    }else if(!isEmptyString(self.directVideoUrl)){
        [self.videoEngine setDirectPlayURL:self.directVideoUrl];
    }else{
        self.playerStateStore.state.isUsingLocalURL = NO;
        [self.videoEngine configResolution:lastResolution completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
            self.playerStateStore.state.currentResolution = completeResolution;

        }];
        // 播放开始时增加缓存文件强引用(不允许删除文件)
        TTAVPreloader *preloader = [TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader;
        HandleType handler = [preloader getHandle:self.playerModel.videoID resolution:TTVOwnPlayerPreloaderDefaultResolution];
        if (![self.retainTaskSet containsObject:@(handler)]) {
            [self.retainTaskSet addObject:@(handler)];
            
            [preloader stopTask:handler];
            [preloader retainFileForKey:handler];
        }
        
        TTAVPreloaderItem *item = [preloader preloadItemForKey:handler];
        if (self.useCache && item) {
            self.playerStateStore.state.playingWithCache = item.filePath.length > 0;
            [self.videoEngine setPreloaderItem:item];
        } else {
            self.playerStateStore.state.playingWithCache = NO;
            [self.videoEngine setVideoID:self.playerModel.videoID];
        }
    }
    self.videoEngine.dataSource = self;
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    [self ttv_kvo];
}

- (void)openAutoModel
{
    if (self.videoEngine.supportedResolutionTypes.count > 0 || self.videoEngine.currentResolution == TTVideoEngineResolutionTypeSD) {
        [self.videoEngine configResolution:TTVideoEngineResolutionTypeAuto];
    }
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

- (void)suggestReduceResolution:(TTVideoEngine *)videoEngine
{
    if (self.playerModel.enableChangeResolutionAlert && self.playerStateStore.state.minResolution.integerValue < self.playerStateStore.state.currentResolution) {
        if (!self.playerStateStore.state.changeResolutionAlertShowed) {
            if (self.playerStateStore.state.supportedResolutionTypes.count > 1) {
                [self.playerStateStore sendAction:TTVPlayerEventTypePlaybackChangeToLowResolutionShow payload:nil];
                self.playerStateStore.state.changeResolutionAlertShowed = YES;
            }
        }
    }
}

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
    return TTVideoEngineResolutionTypeUnknown;
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
    return TTVPlayerResolutionTypeUnkown;
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
    [self.videoEngine addPeriodicTimeObserverForInterval:0.5 queue:dispatch_get_main_queue() usingBlock:^{
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

- (TTVideoEngineNetworkType)networkType
{
    if (TTNetworkWifiConnected()) {
        return TTVideoEngineNetworkTypeWifi;
    }
    return TTVideoEngineNetworkTypeNotWifi;
}

#pragma mark TTVideoEngineDelegate

- (void)ttv_videoEngineStoppedHasError:(BOOL)hasError
{
    self.playerStateStore.state.hasPlayed = NO;
    [self.videoEngine removeTimeObserver];
    if (hasError) {
        [self.watchTimer endWatch];
        [self saveCacheProgress];
        // 清空当前视频缓存
        if (!isEmptyString(self.playerModel.videoID)) {
            [[TTVOwnPlayerCacheWrapper sharedCache] clearCacheForVideoID:self.playerModel.videoID];
        }
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
    self.playerStateStore.state.minVideoSize = [videoEngine videoSizeForType:self.playerStateStore.state.minResolution];
    self.playerStateStore.state.supportedResolutionTypes = [self.videoEngine supportedResolutionTypes];
    self.playerStateStore.state.currentResolution = [self ttv_changeEngineResolutionToPalyerResolution:videoEngine.currentResolution];
    if (![TTVResolutionStore sharedInstance].userSelected || [TTVResolutionStore sharedInstance].forceSelected) {
        [TTVResolutionStore sharedInstance].autoResolution = self.playerStateStore.state.currentResolution;
    }
    [self openAutoModel];
    [self.playerStateStore sendAction:TTVPlayerEventTypeShowVideoFirstFrame payload:nil];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine
{
    if (self.videoEngine.playbackState != TTVideoEnginePlaybackStatePlaying) {
        [_activeCenter deactive];
    }
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
    if (self.videoEngine.currentPlaybackTime > self.playerStateStore.state.currentPlaybackTime) {
        self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    }
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
    if (self.videoEngine.currentPlaybackTime > self.playerStateStore.state.currentPlaybackTime) {
        self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
    }
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
    self.playerStateStore.state.isChangingResolution = YES;
    [self.videoEngine configResolution:[self ttv_changePalyerResolutionToEngineResolution:type] completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
        self.playerStateStore.state.currentPlaybackTime = self.videoEngine.currentPlaybackTime;
        self.playerStateStore.state.currentResolution = completeResolution;
        self.playerStateStore.state.resolutionState = success ? TTVResolutionStateEnd : TTVResolutionStateError;
    }];
}

- (void)setMuted:(BOOL)muted
{
    self.videoEngine.muted = muted;
}

- (void)playVideoFromPayload:(NSDictionary *)payload
{
    [self ttv_playVideoFromPayload:payload];
}

- (void)playVideo
{
    if (!self.videoEngine) {
        [self ttv_setup];
    }
    [self playVideoFromPayload:@{TTVPlayAction : TTVPlayActionDefault}];
}

- (void)ttv_playVideoFromPayload:(NSDictionary *)payload {
    TTVPlayerStateModel *stateModel = _playerStateStore.state;
    if (stateModel.playbackState == TTVVideoPlaybackStatePlaying) {
        return;
    }
    [self ttv_beginObservePlayTime];
    if (!self.playerStateStore.state.playerModel.mutedWhenStart) {
        if (!self.playerStateStore.state.muted) {
            [_activeCenter beactive];
        }
    }
    [self.videoEngine play];
    if (stateModel.playbackState == TTVideoEnginePlaybackStatePaused) {
        [self.playerStateStore sendAction:TTVPlayerEventTypePlayerResume payload:payload];
    }else{
        if (!self.playerStateStore.state.hasPlayed) {
            [self.playerStateStore sendAction:TTVPlayerEventTypePlayerBeginPlay payload:payload];

        }else{
            [self.playerStateStore sendAction:TTVPlayerEventTypePlayerResume payload:payload];
        }
    }
    self.playerStateStore.state.hasPlayed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVideoStartPlayNotificationForNightShift" object:self.playerModel.videoID ?: self];
}

- (void)pauseVideoFromPayload:(NSDictionary *)payload
{
    if (_playerStateStore.state.playbackState != TTVVideoPlaybackStatePaused && _playerStateStore.state.playbackState != TTVVideoPlaybackStateError && _playerStateStore.state.playbackState != TTVVideoPlaybackStateFinished && _playerStateStore.state.playbackState != TTVVideoPlaybackStateBreak) {
        [self.videoEngine pause];
        if (!self.playerStateStore.state.playerModel.mutedWhenStart) {
            if (!self.playerStateStore.state.muted) {
                [_activeCenter deactive];
            }
        }
        [self.playerStateStore sendAction:TTVPlayerEventTypePlayerPause payload:payload];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVideoPausePlayNotificationForNightShift" object:self.playerModel.videoID ?: self];
}

- (void)pauseVideo {
    [self pauseVideoFromPayload:@{TTVPauseAction : TTVPauseActionDefault}];
}

- (void)stopVideo {
    TTVPlayerStateModel *stateModel = _playerStateStore.state;
    if (stateModel.playbackState != TTVVideoPlaybackStateFinished && stateModel.playbackState != TTVVideoPlaybackStateBreak) {
        self.playerStateStore.state.hasPlayed = NO;
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
            NSMutableDictionary *dic = action.payload;
            if (!dic) {
                return;
            }
            NSNumber *number = [dic valueForKey:@"resolution_type"];
            if ([number isKindOfClass:[NSNumber class]]) {
                if ([number integerValue] == self.playerStateStore.state.currentResolution) {
                    self.playerStateStore.state.currentResolution = self.playerStateStore.state.currentResolution;//改变UI使用
                    return;
                }
                [self changeResolution:[number integerValue]];
            }
        }else if (action.actionType == TTVPlayerEventTypePlayerBeginPlay || action.actionType == TTVPlayerEventTypeRetry || action.actionType == TTVPlayerEventTypeFinishUIReplay) {
            [self.watchTimer reset];
            if (action.actionType == TTVPlayerEventTypeFinishUIReplay) {
                self.playerStateStore.state.changeResolutionAlertShowed = NO;
            }
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
    [[TTVPlayerCacheProgressController sharedInstance] cacheProgress:progress currentTime:self.playerStateStore.state.currentPlaybackTime VideoID:self.playerModel.videoID];
}

#pragma mark - fetch video

- (void)_showVideoFirstFrame {
    //seek到缓存的播放进度
    CGFloat progress = [[TTVPlayerCacheProgressController sharedInstance] progressForVideoID:self.playerModel.videoID];
    if (progress > 0 && progress < 100) {
        [self _seekVideoToProgress:progress / 100 autoSeek:YES complete:^(BOOL success) {
            if (success) {
                [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:self.playerModel.videoID];
            }
        }];
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
        _watchTimer.playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [_playerStateStore.state setPlayerWatchTimer:_watchTimer];
    }
}

@end
