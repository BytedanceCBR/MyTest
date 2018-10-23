//
//  TTVPasterPlayer.m
//  Article
//
//  Created by panxiang on 2017/6/12.
//
//

#import "TTVPasterPlayer.h"
#import "TTVPasterADService.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTVPasterADViewController.h"
#import "NetworkUtilities.h"
#import "TTVPlayerIdleController.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TTVPasterPlayer ()<TTVPasterADDelegate>
@property (nonatomic, strong) TTVPasterADViewController *pasterADController;
@property (nonatomic, assign) BOOL playPasterADSuccess;
@property (nonatomic, assign) float requestPercent;

@property (nonatomic, strong) RACDisposable *playerLoadingStateDisposable;

@end

@implementation TTVPasterPlayer
- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

#pragma mark - Public Method

- (void)play {
    
    [_pasterADController resumeCurrentAD];
}

- (void)pause {
    
    [_pasterADController pauseCurrentAD];
}

- (void)stop {
    
    [_pasterADController stopCurrentADVideo];
}

- (BOOL)isPlaying {
    
    return ([_pasterADController isPlayingImage] || [_pasterADController isPlayingMovie]);
}

- (BOOL)hasPasterAd {
    
    return (_pasterADController);
}

- (BOOL)shouldPasterADPause {
    
    return [self.pasterADController shouldPauseCurrentAd];
}

#pragma mark - Setter & Getter

- (void)setPasterAdRequestInfo:(TTVPasterADURLRequestInfo *)pasterAdRequestInfo
{
    if (_pasterAdRequestInfo != pasterAdRequestInfo) {
        _pasterAdRequestInfo = pasterAdRequestInfo;
    }
}

- (void)setPlayerStateStore:(TTVVideoPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        [self playPasterWhenRemainderTime:self.playerStateStore.state.duration - self.playerStateStore.state.currentPlaybackTime];
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isInDetail) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        self.pasterADController.enterDetailFlag = self.playerStateStore.state.isInDetail;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        
        [self.pasterADController setIsFullScreen:self.playerStateStore.state.isFullScreen];
    }];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
                
            case TTVPlayerEventTypeFinished:
            case TTVPlayerEventTypeFinishedBecauseUserStopped:{
                
                BOOL afterPasterIsValid = ([self.pasterADController.playingADModel.videoPasterADInfoModel.duration integerValue] > 0 && !self.playerStateStore.state.pasterAdShowed && TTNetworkWifiConnected());

                if (afterPasterIsValid) {
                    __weak typeof(self) wself = self;
                    [self playPasterADs:nil completionBlock:^{
                        __strong typeof(wself) self = wself;
                        if ([self isMovieFullScreen]) {
                            
                            (!self.rotateScreenAction) ?: self.rotateScreenAction(NO, YES, nil);
                        }
                    }];
                } else {
                    
                    _pasterADController = nil;
                }
            }
                break;
            default:
                break;
        }
    }
    
}

- (float)requestPercent
{
    if (_requestPercent > 0) {
        return _requestPercent;
    }else{
        float requestPercent = [[[TTSettingsManager sharedManager] settingForKey:@"video_ad_request_percent" defaultValue:@0 freeze:YES] floatValue];
        _requestPercent = (requestPercent > 0 && requestPercent < 1) ? requestPercent: 0.8;
    }
    return _requestPercent;
}

- (void)playPasterWhenRemainderTime:(NSTimeInterval)remainderTime
{
    if (!self.playerStateStore.state.pasterAdShowed &&
        TTNetworkWifiConnected() &&
        remainderTime > 0 &&
        self.playerStateStore.state.duration > 0 &&
        remainderTime / self.playerStateStore.state.duration <= 1 - self.requestPercent &&
        !_pasterADController) {
        
        _pasterADController = [[TTVPasterADViewController alloc] init];
        _pasterADController.delegate = self;
        
        __weak typeof(self) wself = self;
        [self.pasterADController setupPasterADData:self.pasterAdRequestInfo completionBlock:^(BOOL success) {
            __strong typeof(wself) self = wself;
            self.playerStateStore.state.pasterADPreFetchValid = success;
        }];
    }
}

/**
 if (self.pasterADController.isPlayingImage || self.pasterADController.isPlayingMovie) {
 // 贴片广告时 原视频不进行流量弹窗提醒
 _trafficView.hidden = YES;
 return ;
 }
 */
- (void)playPasterADs:(NSArray *)pasters completionBlock:(void(^)(void))block
{
    BOOL pasterFadeAnimationEnabled =  [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_end_patch_animation_enable" defaultValue:@NO freeze:NO] boolValue];
    if (pasterFadeAnimationEnabled && self.pasterADController.playerView == nil && self.fadePlayerLastFrameAction) {
        self.playerStateStore.state.pasterFadeAnimationExecuting = YES;
        self.fadePlayerLastFrameAction(^{
            CGFloat duration = [TTVPasterADViewController ttv_pasterFadeInTimeInterval] + 0.1f;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.playerStateStore.state.pasterFadeAnimationExecuting = NO;
            });

            [self playPasterADsInternal__:pasters completionBlock:block];
        });
    } else {
        [self playPasterADsInternal__:pasters completionBlock:block];
    }
}

- (void)playPasterADsInternal__:(NSArray *)pasters completionBlock:(void(^)(void))block
{
    if (self.pasterADController) {
        self.playerStateStore.state.pasterAdShowed = YES;
        [self addSubview:self.pasterADController.view];
        
        BOOL pasterFadeAnimationEnabled =  [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_end_patch_animation_enable" defaultValue:@NO freeze:NO] boolValue];
        if (pasterFadeAnimationEnabled && self.pasterADController.playerView != nil) {
            self.pasterADController.view.hidden = YES;
            self.pasterADController.playerView.player.playerStateStore.state.forbidLoadingAnimtaion = YES;
            self.playerStateStore.state.pasterFadeAnimationExecuting = YES;
            @weakify(self);
            [self.playerLoadingStateDisposable dispose];
            self.playerLoadingStateDisposable = [[[RACObserve(self.pasterADController.playerView.player.playerStateStore, state.loadingState) filter:^BOOL(NSNumber *value) {
                return [value unsignedIntegerValue] == TTVPlayerLoadStatePlayable;
            }] take:1] subscribeNext:^(id x) {
                @strongify(self);
                if (self.fadePlayerLastFrameAction) {
                    self.fadePlayerLastFrameAction(^{
                        CGFloat duration = [TTVPasterADViewController ttv_pasterFadeInTimeInterval] + 0.1f;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.playerStateStore.state.pasterFadeAnimationExecuting = NO;
                        });
                        
                        self.pasterADController.view.hidden = NO;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.pasterADController.playerView.player.playerStateStore.state.forbidLoadingAnimtaion = NO;
                        });
                    });
                }
            }];
        }
    } else {

        return ;
    }
    
    [self.pasterADController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    if ([self isMovieFullScreen]) {
        [self.pasterADController setIsFullScreen:[self isMovieFullScreen]];
        self.pasterADController.view.frame = self.bounds;
    }

    _playPasterADSuccess = YES;
    self.playerStateStore.state.pasterADIsPlaying = YES;
    self.playerStateStore.state.pastarADEnableRotate = YES;
    self.playerStateStore.state.pasterADPreFetchValid = NO;
    __weak typeof(self) wself = self;
    [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:YES];
    [self.pasterADController startPlayVideoList:pasters WithCompletionBlock:^{
        __strong typeof(wself) self = wself;
        [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
        [self.pasterADController.view removeFromSuperview];
        self.frame = CGRectZero;
        self.pasterADController = nil;
        self.playerStateStore.state.pasterADIsPlaying = NO;
        self.playerStateStore.state.pastarADEnableRotate = NO;
        if (block) {
            block();
        }
    }];
}

#pragma mark - TTVPasterADDelegate
- (BOOL)isMovieFullScreen {
    
    return self.playerStateStore.state.isFullScreen;
}

- (void)replayOriginalVideo {
    
    if (_replayAction) {
        
        _replayAction();
    }
}

- (void)videoPasterADViewControllerToggledToFullScreen:(BOOL)fullScreen
                                           animationed:(BOOL)animationed
                                       completionBlock:(void(^)(BOOL finished))completionBlock {
    
    if (_rotateScreenAction) {
        
        _rotateScreenAction(fullScreen, animationed, completionBlock);
    }
}

- (void)sendHostPlayerPauseAction {
    
    [self.playerStateStore sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (BOOL)isInDetail {
    
    return self.playerStateStore.state.isInDetail;
}

- (void)setPasterADRotateState:(BOOL)state {
    
    self.playerStateStore.state.pastarADEnableRotate = (state && self.playerStateStore.state.pasterADIsPlaying);
}

@end
