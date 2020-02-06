//
//  TTVPlayer+Engine.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/14.
//

#import "TTVPlayer+Engine.h"
#if __has_include(<TTVideoEngineHeader.h>)
#import <TTVideoEngineHeader.h>
#else
#import "TTVideoEngine.h"
#endif
#import "TTVPlayer+CacheProgress.h"
#import "TTVPlaybackTime.h"
#import "TTVPlaybackTimePrivate.h"
#import "TTVURLService.h"
#import "TTVIdleTimeService.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "TTVPlayerEnvironmentContext.h"
#import "TTVPlayFinishStatus.h"
#import <objc/runtime.h>

static NSString *platformString;

@interface TTVPlayer (Engine)<TTVideoEngineDelegate, TTVideoEngineDataSource, TTVideoEngineResolutionDelegate>

@property (nonatomic, strong) TTVideoEngine         *videoEngine;   // 包装了 videoEngine
@property (nonatomic, copy)   NSString              *videoID;
@property (nonatomic, assign) NSInteger             playStateVirtualStack; // 播放/暂停 状态堆栈
@property (nonatomic, strong) TTVPlaybackTime       *playbackTime;
@property (nonatomic, strong) TTVPlayFinishStatus   *finishStatus; //// 结束状态: nil 就是没结束，如果!nil 就是结束了
@property (nonatomic, assign) BOOL                  isLocalVideo;
@property (nonatomic, copy)   NSString              *host;
@property (nonatomic, copy)   NSDictionary          *commonParameters;
@property (nonatomic, copy) dispatch_block_t        customTimeBlock;
@property (nonatomic, copy) dispatch_block_t        innerTimeBlock;
@property (nonatomic)         NSTimeInterval        playbackTimeInterval;
@property (nonatomic, getter=isFirstCallPlay) BOOL  firstCallPlay;
@property (nonatomic, assign) BOOL                  isSeeking;
@property (nonatomic, copy)   NSString              *businessToken;  // businesstoken对应ptoken,决定视频带不带水印，加不加密
@property (nonatomic, copy) NSString                *authToken;      //authToken是老版获取播放地址的鉴权参数
@property (nonatomic, copy) NSString                *playAuthToken;  //playAuthToken是新版获取播放地址的鉴权参数
@property (nonatomic, assign) BOOL                  readyForDisplay;

@end

@implementation TTVPlayer (Engine)

//@dynamic netClient;
//@dynamic loadState, shouldPlay, state;
//@dynamic currentResolution, playbackSpeed, volume, muted, looping;


// 因为他代理了TTVPlayerVideoEnginePrivate 好多属性，所以需要转发代理
// 感觉应该常用的还是可以写出来 TOOD???
- (id)forwardingTargetForSelector:(SEL)aSelector {
    //    Debug_NSLog(@"selector = %@ ", NSStringFromSelector(aSelector));
    if ([self respondsToSelector:@selector(aSelector)]) {
        return self;
    }
    if ([self.videoEngine respondsToSelector:aSelector]) {
        return self.videoEngine;
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature * sig = [super methodSignatureForSelector:aSelector];
    if (sig == nil && [self.videoEngine respondsToSelector:aSelector]) {
        return [self.videoEngine methodSignatureForSelector:aSelector];
    }
    return sig;
}

#pragma mark - ****************** core 内核播放相关功能 **********************
- (void)deallocEngine {
    [self.videoEngine removeTimeObserver];
    [self stop];
}

- (void)initializeEngineWithOwnPlayer:(BOOL)isOwnPlayer {
    self.videoEngine = [[TTVideoEngine alloc] initWithOwnPlayer:isOwnPlayer];
    self.playbackTime = [[TTVPlaybackTime alloc] initWithTTVPlayerTimeAdaptor:(NSObject<TTVPlayerTimeAdaptor> *)self.videoEngine];
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    self.videoEngine.dataSource = self;
    self.firstCallPlay = YES;
    self.playbackTimeInterval = 0.5;
    
    // 设置缓存为 YES
//    [self setOptions:@{@(VEKKeyCacheCacheEnable_BOOL):@(YES)}];
    self.videoEngine.cacheEnable = YES;
    
    [TTVideoEngine setIgnoreAudioInterruption:YES];
    // audio
    self.enableAudioSession = YES;
}

- (void)play {
    if (self.firstCallPlay) {
        self.firstCallPlay = NO;
        // 从头开始播放
        if (self.startPlayFromLastestCache && self.finishStatus == nil) {
            NSString *videoID = self.videoID;
            TTVProgressContext *cachedContext = [self cachedContextForKey:videoID];
            NSTimeInterval startTime = [cachedContext.playbackTime doubleValue];
//            [self.videoEngine setOptions:@{@(VEKKeyPlayerStartTime_CGFloat):@(startTime)}];
            self.videoEngine.startTime = startTime;
        }

        TTVPlayerAction * action = [[TTVPlayerAction alloc] initWithPlayer:self];
        [self.playerStore dispatch:[action startPlayAction]];
    }
    self.finishStatus = nil;
    [self.videoEngine play];
}

- (void)resume {
    self.playStateVirtualStack --;
    if (self.playStateVirtualStack < 0 || [self.videoEngine shouldPlay]) {
        self.playStateVirtualStack = 0;
    }
    if (self.playStateVirtualStack == 0) {
        [self play];
    }
}

- (void)pause {
    [self cacheProgress];
    TTVPlaybackState state = (TTVPlaybackState)self.videoEngine.playbackState;
    // 状态校正 1 : pause时 播放状态 手动清空栈 初始化
    if (state == TTVPlaybackState_Playing || [self.videoEngine shouldPlay]) {
        self.playStateVirtualStack = 0;
    }
    // 状态校正 2 : pause时 栈空 & 不是播放状态 手动入栈一次
    if (state != TTVPlaybackState_Playing && ![self.videoEngine shouldPlay] &&
        self.playStateVirtualStack == 0) {
        self.playStateVirtualStack = 1;
    }
    self.playStateVirtualStack ++;
    [self.videoEngine pause];
}

- (void)stop {
    [self cacheProgress];
    [self.videoEngine stop];
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime complete:(void(^)(BOOL success))finished {
    // 当播放结束的时候，拖动进度条，重新起播
    if (self.supportSeekAfterPlayerFinish) {
        if (self.finishStatus && self.playbackState == TTVPlaybackState_Stopped) {
            self.videoEngine.startTime = currentPlaybackTime;
            [self play];
            if (finished) {
                finished(YES);
            }
            return;
        }
    }
    
    // 播放过程中，设置进度条进度
    @weakify(self);
    self.isSeeking = YES;
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_Seeking_Start]];
    if ([self.delegate respondsToSelector:@selector(playerDidStartSeeking:)]) {
        [self.delegate playerDidStartSeeking:self];
    }
    
    [self.videoEngine setCurrentPlaybackTime:currentPlaybackTime complete:^(BOOL success) {
        @strongify(self)
        self.isSeeking = NO;
        [self updatePlaybackTime];
        
        if (finished) {
            finished(success);
        }
        [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_Seeking_End]];
        if ([self.delegate respondsToSelector:@selector(playerDidStopSeeking:)]) {
            [self.delegate playerDidStopSeeking:self];
        }
    }];
}

#pragma mark playbackTime
- (void)innerRemoveTimeObserver {
    if (!self.innerTimeBlock && !self.customTimeBlock) {
        [self.videoEngine removeTimeObserver];
    }
}

- (void)removeTimeObserver {
    self.customTimeBlock = nil;
    if (!self.innerTimeBlock && !self.customTimeBlock) {
        [self.videoEngine removeTimeObserver];
    }
}

- (void)didAddPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block {
    @weakify(self);
    [self.videoEngine addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:^{
        @strongify(self);
        if (self.playbackState == TTVPlaybackState_Playing) {
            [self updatePlaybackTime];
        }
        if (self.customTimeBlock) {
            self.customTimeBlock();
        }
    }];
}

- (void)innerAddPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block {
    [self innerRemoveTimeObserver];
    self.innerTimeBlock = block;
    [self didAddPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
}

- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block {
    // remove
    [self.videoEngine removeTimeObserver];
    self.playbackTimeInterval = interval;
    
    // 设置新的block
    self.customTimeBlock = block;
    [self didAddPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
}
//// playbacktime
- (void)updatePlaybackTime {
    
    if (self.isSeeking) {
        return;
    }
    
    if (![self ttv_isvalidNumber:self.videoEngine.currentPlaybackTime]) {
        return;
    }
    
//    self.playbackTime.currentPlaybackTime;
//    self.playbackTime.duration;
//    self.playbackTime.durationWatched;
//    self.playbackTime.playableDuration;
    
    // 发 action，需要做判断是否有变化
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_PlayBackTimeChanged]];
    if ([self.delegate respondsToSelector:@selector(player:playbackTimeChanged:)]) {
        [self.delegate player:self playbackTimeChanged:self.playbackTime];
    }
}

/// playtimer
- (void)_endObservePlayTime {
    [self innerRemoveTimeObserver];
}

- (void)_beginObservePlayTime {
    [self _endObservePlayTime];
    [self innerAddPeriodicTimeObserverForInterval:self.playbackTimeInterval queue:dispatch_get_main_queue() usingBlock:^{
        
    }];
}

- (BOOL)ttv_isvalidNumber:(NSTimeInterval)number {
    return !isnan(number) && number != NAN;
}

/// **************** TTVideoEngine delegate *************
- (void)videoEngine:(TTVideoEngine *)videoEngine fetchedVideoModel:(TTVideoEngineModel *)videoModel {
    if ([self.delegate respondsToSelector:@selector(player:didFetchedVideoModel:)]) {
        [self.delegate player:self didFetchedVideoModel:videoModel];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState {
    
    TTVReduxAction *action = [[TTVReduxAction alloc] initWithType:TTVPlayerActionType_PlaybackStateDidChanged];
    [self.playerStore dispatch:action];
    
    [[TTVIdleTimeService sharedService] lockScreen:YES later:YES];
    
    // 处理 播放时间相关的数据
    switch (playbackState) {
        case TTVideoEnginePlaybackStatePlaying:
        {
            [self _beginObservePlayTime];
            self.finishStatus = nil;
            [[TTVIdleTimeService sharedService] lockScreen:NO];
        }
            break;
        case TTVideoEnginePlaybackStatePaused:
            self.finishStatus = nil;
            break;
        case TTVideoEnginePlaybackStateStopped:
            [self _endObservePlayTime];
            break;
        default:
            [self _endObservePlayTime];
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(player:playbackStateDidChanged:)]) {
        [self.delegate player:self playbackStateDidChanged:(TTVPlaybackState)playbackState];
    }
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine {
    self.readyForDisplay = YES;
    self.playerView.alpha = 1.0;
    if ([self.delegate respondsToSelector:@selector(playerReadyToDisplay:)]) {
        [self.delegate playerReadyToDisplay:self];
    }
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_ReadyForDisplayChanged]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState {
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_LoadStateChanged]];
    if ([self.delegate respondsToSelector:@selector(player:loadStateDidChanged:)]) {
        [self.delegate player:self loadStateDidChanged:(TTVPlayerDataLoadState)loadState];
    }
}
- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if ([self.delegate respondsToSelector:@selector(playerPrepared:)]) {
        [self.delegate playerPrepared:self];
    }
}
// fetch 出错
- (void)videoEngine:(TTVideoEngine *)videoEngine retryForError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(player:retryForError:)]) {
        [self.delegate player:self retryForError:error];
    }
}
- (void)videoEngineStalledExcludeSeek:(TTVideoEngine *)videoEngine {
    if ([self.delegate respondsToSelector:@selector(playerStalledExcludeSeek:)]) {
        [self.delegate playerStalledExcludeSeek:self];
    }
}
// ************** finish ***************
- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    [self videoFinishedWithType:TTVPlayFinishStatusType_UserFinish error:nil sourceErrorStatus:0];
    
    //当在视频播放中切换上下一个时，可能由于视频frame变化造成的拉伸变形，故隐藏
    if (self.videoEngine.currentPlaybackTime != self.videoEngine.duration) {
        self.playerView.alpha = 0.0;
    }
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(NSError *)error {
    //当在视频播放中切换上下一个时，可能由于视频frame变化造成的拉伸变形，故隐藏 /// TODO, 如果这个需要保留下一帧怎么整
    if (self.videoEngine.currentPlaybackTime != self.videoEngine.duration) {
        self.playerView.alpha = 0.0;
    }
    
    BOOL tokenExpired = NO;
    if (error && error.code ==  -9990) {//TTVideoEngineErrorInvalidRequest ,兼容旧版本
        long errorCode = [error.userInfo tt_longValueForKey:@"kTTVideoEngineAPIRetCodeKey"];//kTTVideoEngineAPIRetCodeKey 兼容旧版本
        // 10408表示auth_token过期，50401表示play_token过期
        if (errorCode == 10408 || errorCode == 50401) {
            tokenExpired = YES;
        }
    }
    
    if (tokenExpired) {
        [self refreshTokenWithEngine:videoEngine];
    } else {
        [self videoFinishedWithType:TTVPlayFinishStatusType_SystemFinish error:error sourceErrorStatus:0];
    }
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    [self videoFinishedWithType:TTVPlayFinishStatusType_SystemFinish error:nil sourceErrorStatus:status];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    [self videoFinishedWithType:TTVPlayFinishStatusType_UserFinish error:nil sourceErrorStatus:0];
    if ([self.delegate respondsToSelector:@selector(playerCloseAysncFinish:)]) {
        [self.delegate playerCloseAysncFinish:self];
    }
}

- (void)refreshTokenWithEngine:(TTVideoEngine *)videoEngine
{
    @weakify(self);
    if ([self.delegate respondsToSelector:@selector(playerViewController:requestPlayTokenCompletion:)]) {
        [self.delegate player:self requestPlayTokenCompletion:^(NSError *error, NSString *authToken, NSString *bizToken) {
            @strongify(self);
            if (error) {
                [self videoFinishedWithType:TTVPlayFinishStatusType_SystemFinish error:error sourceErrorStatus:0];
            } else {
                [self setPlayAuthToken:nil authToken:authToken businessToken:bizToken];
                [self.videoEngine play];
            }
        }];
    }
}

- (void)videoFinishedWithType:(TTVPlayFinishStatusType)type error:(NSError *)error sourceErrorStatus:(NSInteger)status {
    self.readyForDisplay = NO;
    self.firstCallPlay = YES;
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_ReadyForDisplayChanged]];

    [self updatePlaybackTime];
    
    TTVPlayFinishStatus * finishStatus = [[TTVPlayFinishStatus alloc] init];
    finishStatus.type = type;
    
    if (type == TTVPlayFinishStatusType_SystemFinish) {
        finishStatus.playError = error;
        finishStatus.sourceErrorStatus = status;
    }
    else {
        finishStatus.playError = nil;
        finishStatus.sourceErrorStatus = 0;
    }
    
    //
    self.finishStatus = finishStatus;
    if ([self.delegate respondsToSelector:@selector(player:didFinishedWithStatus:)]) {
        [self.delegate player:self didFinishedWithStatus:self.finishStatus];
    }
}

- (NSInteger)playAPIVersion2
{
    return 2/*TTVideoEnginePlayAPIVersion2 兼容旧版本*/;
}

- (NSString *)apiForFetcher:(TTVideoEnginePlayAPIVersion)apiVersion {
    if ([self playAPIVersion2] == apiVersion) {
        NSString *playerV2URL = nil;
        if ([self.delegate respondsToSelector:@selector(playerV2URL:)]) {
            playerV2URL = [self.delegate playerV2URL:self path:@"/vod/get_play_info"];
        }
        return [TTVURLService urlForV2WithPlayerAuthToken:self.playAuthToken businessToken:self.businessToken playerV2URL:playerV2URL];
    } else if (TTVideoEnginePlayAPIVersion1 == apiVersion) {
        return [TTVURLService urlForV1WithVideoId:self.videoID businessToken:self.businessToken];
    } else {
        return [TTVURLService urlWithVideoId:self.videoID];
    }
}


#pragma mark - TTVideoEngineResolutionDelegate

- (void)suggestReduceResolution:(TTVideoEngine *)videoEngine {
    if (self.videoEngine.supportedResolutionTypes.count > 1
        && self.videoEngine.currentResolution != TTVideoEngineResolutionTypeSD) {
        // 在 自动 分辨率模式，当网络卡顿 3 次以后，并且视频当前播放清晰度不是标清时，提示用户是否降低播放器的分辨率到 标清
        //        TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeSuggestReduceResolution info:nil];
        //        [self.store dispatch:action];
    }
}

#pragma mark - tool
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

#pragma mark - getters & setters
- (TTVPlaybackState) playbackState {
    return (TTVPlaybackState)self.videoEngine.playbackState;
}

- (BOOL)isPlaybackEnded {
    return (self.finishStatus != nil);
}

+ (void)setIgnoreAudioInterruption:(BOOL)ignore {
    [TTVideoEngine setIgnoreAudioInterruption:ignore];
}
/// TODO
- (void)setHardwareDecode:(BOOL)hardwareDecode {
    if (!platformString) {
        platformString = [[self class] ttv_platformString];
    }
    if ([platformString isEqualToString:@"Simulator"]) {
        self.videoEngine.hardwareDecode = NO;
    }
    else {
        self.videoEngine.hardwareDecode = hardwareDecode;
    }
}

- (void)setLocalURL:(NSString *)localURL {
    [self.videoEngine setLocalURL:localURL];
    self.isLocalVideo = YES;
}

- (void)setPlayAuthToken:(NSString *)playAuthToken authToken:(NSString *)authToken businessToken:(NSString *)businessToken {
    self.playAuthToken = playAuthToken;
    self.businessToken = businessToken;
    self.authToken = authToken;
    if (!isEmptyString(playAuthToken) && !isEmptyString(businessToken) && !isEmptyString(authToken)) {
        [self.videoEngine setPlayAPIVersion:[self playAPIVersion2] auth:authToken];
    } else {
        if (!isEmptyString(authToken)) {
            [self.videoEngine setPlayAPIVersion:TTVideoEnginePlayAPIVersion1 auth:authToken];
        } else {
            [self.videoEngine setPlayAPIVersion:TTVideoEnginePlayAPIVersion0 auth:nil];
        }
    }
}

- (void)setVideoID:(NSString *)videoID host:(NSString *)host commonParameters:(NSDictionary *)commonParameters {
    self.videoID = videoID;
    [self.videoEngine setVideoID:videoID];
    self.host = host;
    self.commonParameters = commonParameters;
    // 给 URL 服务设置，要不后面拼接不了 video 的 url
    [TTVURLService setCommonParameters:commonParameters];
    [TTVURLService setHost:host];
    
    [TTVPlayerEnvironmentContext sharedInstance].host = host;
    [TTVPlayerEnvironmentContext sharedInstance].commonParameters = commonParameters;
}
- (void)setPlayAPIVersion:(TTVPlayerAPIVersion)apiVersion auth:(NSString *)auth {
    [self.videoEngine setPlayAPIVersion:(TTVideoEnginePlayAPIVersion)apiVersion auth:auth];
}
- (NSInteger)videoSizeForType:(TTVPlayerResolutionTypes)type {
    return [self.videoEngine videoSizeForType:(TTVideoEngineResolutionType)type];
}
- (NSInteger)videoSizeOfCurrentResolution {
    return [self videoSizeForType:self.currentResolution];
}
#pragma mark assosiated object
- (TTVideoEngine *)videoEngine {
    return objc_getAssociatedObject(self, @selector(videoEngine));
}
- (void)setVideoEngine:(TTVideoEngine *)videoEngine {
    objc_setAssociatedObject(self, @selector(videoEngine), videoEngine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)videoID {
    return objc_getAssociatedObject(self, @selector(videoID));
}
- (void)setVideoID:(NSString *)videoID {
    objc_setAssociatedObject(self, @selector(videoID), videoID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)host {
    return objc_getAssociatedObject(self, @selector(host));
}
- (void)setHost:(NSString *)host {
    objc_setAssociatedObject(self, @selector(host), host, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)isLocalVideo {
    return [objc_getAssociatedObject(self, @selector(isLocalVideo)) boolValue];
}
- (void)setIsLocalVideo:(BOOL)isLocalVideo {
    objc_setAssociatedObject(self, @selector(isLocalVideo), @(isLocalVideo), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSDictionary *)commonParameters {
    return objc_getAssociatedObject(self, @selector(commonParameters));
}
- (void)setCommonParameters:(NSDictionary *)commonParameters {
    objc_setAssociatedObject(self, @selector(commonParameters), commonParameters, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)businessToken {
    return objc_getAssociatedObject(self, @selector(businessToken));
}
- (void)setBusinessToken:(NSString *)businessToken {
    objc_setAssociatedObject(self, @selector(businessToken), businessToken, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (TTVPlayFinishStatus *)finishStatus {
    return objc_getAssociatedObject(self, @selector(finishStatus));
}
- (void)setFinishStatus:(TTVPlayFinishStatus *)finishStatus {
    if (self.finishStatus != finishStatus) {
        objc_setAssociatedObject(self, @selector(finishStatus), finishStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        TTVReduxAction *action = [TTVReduxAction actionWithType:TTVPlayerActionType_FinishStatusChanged info:self.finishStatus? @{TTVPlayerActionInfo_FinishStatus:self.finishStatus}:nil];
        [self.playerStore dispatch:action];
        return;
    }
    else {
        if (self.finishStatus.sourceErrorStatus != finishStatus.sourceErrorStatus ||
            self.finishStatus.playError != finishStatus.playError ||
            self.finishStatus.type != finishStatus.type) {
            objc_setAssociatedObject(self, @selector(finishStatus), finishStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            TTVReduxAction *action = [TTVReduxAction actionWithType:TTVPlayerActionType_FinishStatusChanged info:self.finishStatus? @{TTVPlayerActionInfo_FinishStatus:self.finishStatus}:nil];
            [self.playerStore dispatch:action];
            return;
        }
    }
    objc_setAssociatedObject(self, @selector(finishStatus), finishStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_block_t)customTimeBlock {
    return objc_getAssociatedObject(self, @selector(customTimeBlock));
}
- (void)setCustomTimeBlock:(dispatch_block_t)customTimeBlock {
    objc_setAssociatedObject(self, @selector(customTimeBlock), customTimeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (dispatch_block_t)innerTimeBlock {
    return objc_getAssociatedObject(self, @selector(innerTimeBlock));
}
- (void)setInnerTimeBlock:(dispatch_block_t)innerTimeBlock {
    objc_setAssociatedObject(self, @selector(innerTimeBlock), innerTimeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSTimeInterval)playbackTimeInterval {
    return [objc_getAssociatedObject(self, @selector(playbackTimeInterval)) doubleValue];
}
- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    objc_setAssociatedObject(self, @selector(playbackTimeInterval), @(playbackTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (TTVPlaybackTime *)playbackTime {
    return objc_getAssociatedObject(self, @selector(playbackTime));
}
- (void)setPlaybackTime:(TTVPlaybackTime *)playbackTime {
    objc_setAssociatedObject(self, @selector(playbackTime), playbackTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isFirstCallPlay {
    return [objc_getAssociatedObject(self, @selector(isFirstCallPlay)) boolValue];
}
- (void)setFirstCallPlay:(BOOL)firstCallPlay {
    objc_setAssociatedObject(self, @selector(isFirstCallPlay), @(firstCallPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isSeeking {
    return [objc_getAssociatedObject(self, @selector(isSeeking)) boolValue];
}
- (void)setIsSeeking:(BOOL)isSeeking {
    objc_setAssociatedObject(self, @selector(isSeeking), @(isSeeking), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)readyForDisplay {
    return [objc_getAssociatedObject(self, @selector(readyForDisplay)) boolValue];
}
- (void)setReadyForDisplay:(BOOL)readyForDisplay {
    objc_setAssociatedObject(self, @selector(readyForDisplay), @(readyForDisplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSInteger)playStateVirtualStack {
    return [objc_getAssociatedObject(self, @selector(playStateVirtualStack)) integerValue];
}
- (void)setPlayStateVirtualStack:(NSInteger)playStateVirtualStack {
    objc_setAssociatedObject(self, @selector(playStateVirtualStack), @(playStateVirtualStack), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)enableAudioSession {
    return [objc_getAssociatedObject(self, @selector(enableAudioSession)) boolValue];
}
- (void)setEnableAudioSession:(BOOL)enableAudioSession {
    objc_setAssociatedObject(self, @selector(enableAudioSession), @(enableAudioSession), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)startPlayFromLastestCache {
    return [objc_getAssociatedObject(self, @selector(startPlayFromLastestCache)) boolValue];
}
- (void)setStartPlayFromLastestCache:(BOOL)startPlayFromLastestCache {
    objc_setAssociatedObject(self, @selector(startPlayFromLastestCache), @(startPlayFromLastestCache), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)authToken {
    return objc_getAssociatedObject(self, @selector(authToken));
}
- (void)setAuthToken:(NSString *)authToken {
    objc_setAssociatedObject(self, @selector(authToken), authToken, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)playAuthToken {
    return objc_getAssociatedObject(self, @selector(playAuthToken));
}
- (void)setPlayAuthToken:(NSString *)playAuthToken {
    objc_setAssociatedObject(self, @selector(playAuthToken), playAuthToken, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)supportSeekAfterPlayerFinish {
    return [objc_getAssociatedObject(self, @selector(supportSeekAfterPlayerFinish)) boolValue];
}
- (void)setSupportSeekAfterPlayerFinish:(BOOL)supportSeekAfterPlayerFinish {
    objc_setAssociatedObject(self, @selector(supportSeekAfterPlayerFinish), @(supportSeekAfterPlayerFinish), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
