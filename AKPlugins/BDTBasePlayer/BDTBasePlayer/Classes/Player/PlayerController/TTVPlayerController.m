//
//  TTVPlayerController.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//
#import "TTVPlayerController.h"
#import "TTVPlayerOrientationController.h"
#import "TTVPlayerEventController.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerStateModel.h"
#import "TTVPlayerIdleController.h"
#import "TTVPlayerAudioController.h"
#import "TTVFluxDispatcher.h"
#import "NetworkUtilities.h"
#import "TTVPlayerSettingUtility.h"
#import "TTVPlayerCacheProgressController.h"
#import <AVFoundation/AVFoundation.h>
#import "TTVPalyerTrafficAlert.h"
#import "TTVPlayerAudioWave.h"
#import "TTVFullscreeenController.h"
#import "TTVPalyerTrafficAlert.h"
#import "TTVResolutionStore.h"
#import "UIColor+TTThemeExtension.h"
#import "TTVAudioActiveCenter.h"
#import "NSObject+FBKVOController.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "TTVChangeResolutionView.h"
#import "TTVChangeResolutionAlertView.h"

static __weak TTVPlayerController *currentPlayerController = nil;

@interface TTVPlayerController () <TTVFluxStoreCallbackProtocol, TTVOrientationDelegate>
/**
 播放器操作,封装了TTVideoEngine sdk
 */
@property (nonatomic, strong) TTVPlayerEventController *eventController;
@property (nonatomic, strong) TTVPlayerOrientationController *orientationController;//新旋转
@property (nonatomic, strong) TTVFullscreeenController *fullscreeenController;//旧旋转
@property (nonatomic, strong) TTVPalyerTrafficAlert *trafficAlert;
@property (nonatomic, strong) TTVPlayerAudioWave *audioWave;
@property(nonatomic, strong)TTVChangeResolutionView *changeResolutionView;
@property(nonatomic, strong)TTVChangeResolutionAlertView *changeResolutionAlertView;
@end

@implementation TTVPlayerController

- (void)dealloc {
    _playerDataSource = nil;
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [TTVPlayerController setCurrentPlayerController:self];
    }
    return self;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore {
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)readyToPlay
{
    [self ttv_addEventController];
    [_eventController readyToPlay];
    [self ttv_addPlayerView];
    [self ttv_addControlView];
//    [self performSelector:@selector(ttv_addControlView) withObject:nil afterDelay:0];
    [self ttv_addTrafficView];
    if ([_playerDataSource respondsToSelector:@selector(videoPlayerTipView)]) {
        _playerView.tipView = [_playerDataSource videoPlayerTipView];
    }

    if ([TTVPlayerSettingUtility ttvs_isVideoNewRotateEnabled]) {
        [self ttv_addRotate];//新旋转
    }else{
        [self ttv_addFullScreen];//旧旋转
    }
    [self ttv_addChageResolution];
    //不要去掉,为了再次设置setCategory
    [TTVAudioActiveCenter setupAudioSessionIsMuted:self.playerModel.mutedWhenStart];
}

#pragma mark setup

- (void)ttv_addEventController
{
    if (!_eventController) {
        _eventController = [[TTVPlayerEventController alloc] init];
    }
    _eventController.playerStateStore = _playerStateStore;
    _eventController.playerModel = self.playerModel;
}

- (void)releaseAysnc
{
    [_eventController releaseAysnc];
}

- (void)ttv_addPlayerView
{
    if (!_playerView) {
        _playerView = [[TTVPlayerView alloc] init];
    }
    _playerView.playerLayer = _eventController.playerLayer;
    _playerView.playerStateStore = _playerStateStore;
}

- (void)setRotateView:(UIView *)rotateView
{
    _rotateView = rotateView;
    _fullscreeenController.rotateView = self.rotateView;
    _orientationController.rotateView = self.rotateView;
}

- (void)ttv_addTrafficView
{
    TTVPalyerTrafficAlert *alert = [[TTVPalyerTrafficAlert alloc] init];
    alert.playerStateStore = self.playerStateStore;
    if ([_playerDataSource respondsToSelector:@selector(videoPlayerTrafficView)]) {
        [alert setTrafficView:[_playerDataSource videoPlayerTrafficView]];
        _playerView.trafficView = alert;
        _playerView.trafficView.hidden = YES;
        self.trafficAlert = alert;
    }
}

- (void)ttv_addControlView
{
    if ([_playerDataSource respondsToSelector:@selector(videoPlayerControlView)]) {
        _playerView.controlView = [_playerDataSource videoPlayerControlView];
    }
}

- (void)ttv_addRotate
{
    if (_fullscreeenController) {
        [_fullscreeenController exitFullScreen:YES completion:^(BOOL finished) {
            
        }];
    }
    if (!_orientationController) {
        _orientationController = [[TTVPlayerOrientationController alloc] init];
        _orientationController.delegate = self;
    }
    _orientationController.playerStateStore = _playerStateStore;
    _orientationController.rotateView = self.rotateView;
    _fullscreeenController = nil;
}

- (void)ttv_addFullScreen
{
    if (_orientationController) {
        [_orientationController exitFullScreen:YES completion:^(BOOL finished) {
            
        }];
    }
    if (!_fullscreeenController) {
        _fullscreeenController = [[TTVFullscreeenController alloc] init];
        _fullscreeenController.delegate = self;
    }
    _fullscreeenController.playerStateStore = _playerStateStore;
    _fullscreeenController.rotateView = self.rotateView;
    _orientationController = nil;
}

- (void)ttv_addChageResolution
{
    _changeResolutionView = [[TTVChangeResolutionView alloc] init];
    _changeResolutionView.playerStateStore = self.playerStateStore;
    _changeResolutionView.hidden = YES;
    self.playerView.changeResolutionView = _changeResolutionView;
    
    if (self.playerStateStore.state.enableSmothlySwitch){
        _changeResolutionAlertView = [[TTVChangeResolutionAlertView alloc] init];
        _changeResolutionAlertView.playerStateStore = self.playerStateStore;
        _changeResolutionAlertView.hidden = YES;
        self.playerView.changeResolutionAlertView = _changeResolutionAlertView;
    }
}

#pragma mark - public method

- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    if (self.fullscreeenController) {
        [self.fullscreeenController exitFullScreen:animated completion:completion];
    }else{
        [self.orientationController exitFullScreen:animated completion:completion];
    }
}

- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    if (self.fullscreeenController) {
        [self.fullscreeenController enterFullScreen:animated completion:completion];
    }else{
        [self.orientationController enterFullScreen:animated completion:completion];
    }
}

- (void)changeResolution:(TTVPlayerResolutionType)type
{
    [self.eventController changeResolution:type];
}

- (void)playVideo
{
    [_eventController playVideoFromPayload:@{TTVPlayAction : TTVPlayActionDefault}];
}

- (void)playVideoFromPayload:(NSDictionary *)payload{
    [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
    [_eventController playVideoFromPayload:payload];
}

- (void)pauseVideo {
    [_eventController pauseVideo];
}

- (void)pauseVideoFromPayload:(NSDictionary *)payload
{
    [_eventController pauseVideoFromPayload:payload];
}

- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised {
    if (progress < 0) {
        progress = 0;
    }
    if (progress > 100) {
        progress = 100;
    }
    [_eventController seekVideoToProgress:progress complete:finised];
}

- (void)stopVideo {
    [self.eventController saveCacheProgress];
    [_eventController stopVideo];
}

- (void)saveCacheProgress
{
    [_eventController saveCacheProgress];
}
#pragma mark - store callback

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeShowVideoFirstFrame:{
            [self.trafficAlert setTrafficVideoDuration:self.playerStateStore.state.duration videoSize:self.playerStateStore.state.videoSize inDetail:self.playerStateStore.state.isInDetail];
        }
            break;
        case TTVPlayerEventTypeFinished:
        case TTVPlayerEventTypeFinishedBecauseUserStopped:{
            [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
        }
            break;
        case TTVPlayerEventTypeEncounterError:{
            [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
        }
            break;
        case TTVPlayerEventTypeSwitchResolution:{
            [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
            if (!self.playerStateStore.state.enableSmothlySwitch) {
                UIView *snapView = [self.eventController.playerLayer snapshotViewAfterScreenUpdates:YES];
                self.playerView.snapView = snapView;
            }
        }
            break;
        case TTVPlayerEventTypeTrafficShow:{
            [self pauseVideo];
            if (self.playerStateStore.state.isFullScreen) {
                __weak typeof(self) wself = self;
                [self exitFullScreen:YES completion:^(BOOL finished) {
                    __strong typeof(wself) self = wself;
                    self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeUnknow;
                }];
            }
        }
            break;
        case TTVPlayerEventTypeTrafficPlay:{
            TTVPlayerStateModel *stateModel = _playerStateStore.state;
            if (stateModel.currentResolution == TTVPlayerResolutionTypeSD) {
                [self playVideoFromPayload:@{TTVPlayAction : TTVPlayActionTrafficContinue}];
            } else { //切换到标清播放
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:@(TTVPlayerResolutionTypeSD) forKey:@"resolution_type"];
                [dic setValue:@(YES) forKey:@"is_auto_switch"];
                [self.playerStateStore sendAction:TTVPlayerEventTypeSwitchResolution payload:dic];
                [self changeResolution:TTVPlayerResolutionTypeSD];
            }
        }
            break;
            
        case TTVPlayerEventTypeTrafficStop:{
            [self stopVideo];
        }
            break;
        case TTVPlayerEventTypeTrafficWillOverFreeFlowShow: {
            [self pauseVideo];
            if (self.playerStateStore.state.isFullScreen) {
                __weak typeof(self) wself = self;
                [self exitFullScreen:YES completion:^(BOOL finished) {
                    __strong typeof(wself) self = wself;
                    self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeUnknow;
                    [self.trafficAlert showFreeFlowTipView:NO didOverFlow:NO userInfo:nil];
                }];
            } else {
                
                [self.trafficAlert showFreeFlowTipView:NO didOverFlow:NO userInfo:nil];
            }
        }
            break;
            
        case TTVPlayerEventTypeTrafficDidOverFreeFlowShow: {
            [self pauseVideo];
            if (self.playerStateStore.state.isFullScreen) {
                __weak typeof(self) wself = self;
                [self exitFullScreen:YES completion:^(BOOL finished) {
                    __strong typeof(wself) self = wself;
                    self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeUnknow;
                    [self.trafficAlert showFreeFlowTipView:NO didOverFlow:YES userInfo:nil];
                }];
            } else {
                
                [self.trafficAlert showFreeFlowTipView:NO didOverFlow:YES userInfo:nil];
            }
        }
            break;
            
        case TTVPlayerEventTypeTrafficFreeFlowSubscribeShow: {
            
            [self pauseVideo];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
            params[@"category_name"] = self.playerModel.categoryID;
            params[@"position"] = self.playerStateStore.state.isInDetail ? @"detail": @"list";
            params[@"group_id"] = self.playerModel.groupID;
            params[@"source"] = @"data_package_tip";
            
            if (self.playerStateStore.state.isFullScreen) {
                __weak typeof(self) wself = self;
                [self exitFullScreen:YES completion:^(BOOL finished) {
                    __strong typeof(wself) self = wself;
                    self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeUnknow;
                    [self.trafficAlert showFreeFlowTipView:YES didOverFlow:NO userInfo:nil];
                }];
            } else {
                [self.trafficAlert showFreeFlowTipView:YES didOverFlow:NO userInfo:params];
            }
        }
            break;
        case TTVPlayerEventTypeTrafficFreeFlowPlay: {
            NSDictionary *dic = action.payload;
            if ([dic isKindOfClass:[NSDictionary class]] && [dic valueForKey:@"resolution_type"]) {
                NSNumber *resolution = [dic valueForKey:@"resolution_type"];
                if ([[dic valueForKey:@"is_auto_switch"] boolValue]) {
                    [TTVResolutionStore sharedInstance].forceSelected = YES;
                    [TTVResolutionStore sharedInstance].autoResolution = [resolution integerValue];
                }
                if (resolution.integerValue == self.playerStateStore.state.currentResolution) {
                    [self playVideoFromPayload:@{TTVPlayAction : TTVPlayActionTrafficContinue}];
                }else{
                    [self playVideo];
                    [self changeResolution:[resolution integerValue]];
                }
            } else {
                [self playVideoFromPayload:@{TTVPlayAction : TTVPlayActionTrafficContinue}];
            }
        }
        default:
            break;
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isInDetail) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self.trafficAlert setTrafficVideoDuration:self.playerStateStore.state.duration videoSize:self.playerStateStore.state.videoSize inDetail:self.playerStateStore.state.isInDetail];
    }];
}

#pragma mark - setter & getter

- (void)setPlayerDataSource:(id<TTVPlayerControllerDataSource>)playerDataSource {
    if (_playerDataSource != playerDataSource) {
        _playerDataSource = playerDataSource;
    }
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (!self.audioWave && muted && self.playerModel.showMutedView) {
        self.audioWave = [[TTVPlayerAudioWave alloc] initWithFrame:self.playerView.frame];
        self.playerView.waveView = self.audioWave;
    }
    TTVVideoPlaybackState state = self.eventController.playerStateStore.state.playbackState;
    self.playerStateStore.state.muted = muted;
    self.eventController.muted = muted;
    self.audioWave.muted = muted;
    if (muted && state == TTVVideoPlaybackStatePlaying) {
        [self.eventController playVideo];
    }
}

- (void)setBanLoading:(BOOL)banLoading{
    _banLoading = banLoading;
    self.playerStateStore.state.banLoading = banLoading;
}

#pragma mark - TTVOrientationDelegate

- (void)forceVideoPlayerStop {
    [self stopVideo];
}

- (BOOL)videoPlayerCanRotate {
    BOOL shouldAutoRotate_out = YES;
    BOOL shouldAutoRotate_inner = YES;
    if ([self.playerStateStore.state.delegate respondsToSelector:@selector(shouldAutoRotate)]) {
        shouldAutoRotate_out = [self.playerStateStore.state.delegate shouldAutoRotate];
    }
    if ([self.delegate respondsToSelector:@selector(shouldAutoRotate)]) {
        shouldAutoRotate_inner = [self.delegate shouldAutoRotate];
    }
    return shouldAutoRotate_out && shouldAutoRotate_inner && self.playerStateStore.state.playbackState != TTVVideoPlaybackStateBreak && !self.playerStateStore.state.isRotating;
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttv_movieViewFrameAfterExitFullscreen)]) {
        return [self.delegate ttv_movieViewFrameAfterExitFullscreen];
    }
    return CGRectZero;
}

+ (void)setCurrentPlayerController:(TTVPlayerController *)playerController
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    currentPlayerController = playerController;
}

+ (TTVPlayerController *)currentPlayerController
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    return currentPlayerController;
}

@end
