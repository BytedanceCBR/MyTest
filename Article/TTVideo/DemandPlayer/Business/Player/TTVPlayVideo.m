//
//  TTVPlayVideo.m
//  Article
//
//  Created by panxiang on 2017/5/11.
//
//

#import "TTVPlayVideo.h"
#import "TTVPlayerController.h"
#import "TTMovieStore.h"
#import "TTVDemandPlayer.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerUrlTracker.h"
#import <TTImageView.h>
#import "TTNetworkUtilities.h"
#import <TTSettingsManager/TTSettingsManager.h>
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "NSObject+FBKVOController.h"
#import "SSAppStore.h"
#import "TTVVideoPlayerModel.h"
#import "TTVPasterPlayer.h"
#import "TTVMidInsertADPlayer.h"
#import "TTVResolutionStore.h"

extern NSString * const TTStrongPushNotificationWillShowNotification;
extern NSString * const TTStrongPushNotificationWillHideNotification;
extern NSString* const TTAdAppointAlertViewShowKey;
extern NSString* const TTAdAppointAlertViewCloseKey;

static __weak TTVPlayVideo *currentTTVPlayVideo_ = nil;

@interface TTVPlayVideo ()
@property (nonatomic, strong) TTImageView *logoImageView;
@property (nonatomic, strong) TTVVideoPlayerModel *playerModel;

@end

@implementation TTVPlayVideo
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //去掉,优化视频广告滑出屏幕的卡顿
    [_player stopWithFinishedBlock:nil];
}

- (instancetype)initWithFrame:(CGRect)frame playerModel:(TTVVideoPlayerModel *)playerModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _player = [[TTVDemandPlayer alloc] initWithFrame:self.bounds];
        [self addSubview:_player];
        [TTVPlayVideo setCurrentPlayingPlayVideo:self];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[TTMovieStore shareTTMovieStore] addMovie:self];
        self.playerModel = playerModel;
        [self ttv_kvo];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(strongPushNotificationWillShowNotification:) name:TTStrongPushNotificationWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(strongPushNotificationWillHideNotification:) name:TTStrongPushNotificationWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewShow:) name:TTAdAppointAlertViewShowKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewHide:) name:TTAdAppointAlertViewCloseKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_openRedPackert:) name:@"TTOpenRedPackertNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_closeRedPackert:) name:@"TTCloseRedPackertNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFPauseVideoNotification:) name:@"TTSFPauseVideo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFContinueVideoNotification:) name:@"TTSFContinueVideo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFExitFullScreenNotification:) name:@"TTSFVideoExitFullScreen" object:nil];
    }
    return self;
}

- (void)ttv_openRedPackert:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)ttv_closeRedPackert:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)appointAlertViewShow:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)appointAlertViewHide:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)skStoreViewDidAppear:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)skStoreViewDidDisappear:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)strongPushNotificationWillShowNotification:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)strongPushNotificationWillHideNotification:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)TTSFPauseVideoNotification:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)TTSFContinueVideoNotification:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)TTSFExitFullScreenNotification:(NSNotification *)notification
{
    [self exitFullScreen:YES completion:nil];
}

- (void)ttv_kvo
{
    @weakify(self);
//    [self.KVOController unobserve:[SSADManager shareInstance]];
//    [self.KVOController observe:[SSADManager shareInstance] keyPath:@keypath([SSADManager shareInstance],isSplashADShowed) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        @strongify(self);
//        if ([SSADManager shareInstance].isSplashADShowed) {
//            [self.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
//        }else{
//            [self.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
//        }
//    }];
    [self.KVOController unobserve:[TTAdSplashMediator shareInstance]];
    [self.KVOController observe:[TTAdSplashMediator shareInstance] keyPath:@keypath([TTAdSplashMediator shareInstance],isAdShowing) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if ([TTAdSplashMediator shareInstance].isAdShowing) {
            [self.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
        }else{
            [self.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
        }
    }];
}

- (void)setPlayerModel:(TTVVideoPlayerModel *)playerModel
{
    if (_playerModel != playerModel) {
//        playerModel.urlBaseParameter = [TTNetworkUtilities commonURLParameters];SSCommonLogic
//        BOOL isMultiResolutionEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_multi_resolution_enabled" defaultValue:@NO freeze:NO] boolValue];
        //获取f项目配置，根据配置是否显示标清和高清
        BOOL isMultiResolutionEnabled = [[SSCommonLogic fhSettings] tta_boolForKey:@"video_multi_resolution_enabled"];
        [TTVResolutionStore sharedInstance].userSelected = isMultiResolutionEnabled; //设置标清和普清是否自动
        playerModel.enableResolution = isMultiResolutionEnabled && playerModel.enableResolution; //配置是否显示标清和高清
        
        _playerModel = playerModel;
        [self ttv_addPlayer];
    }
}

- (void)resetPlayerModel:(TTVVideoPlayerModel *)playerModel
{
    self.playerModel = playerModel;
    [self.player reset];
    [self.player readyToPlay];
}

- (void)ttv_addPlayer
{
    _player.playerModel = self.playerModel;
    _player.rotateView = self;
}

- (void)setVideoLargeImageDict:(NSDictionary *)videoLargeImageDict
{
    if (!_logoImageView) {
        _logoImageView = [[TTImageView alloc] initWithFrame:self.frame];
        _logoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _logoImageView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        _logoImageView.userInteractionEnabled = YES;
        _logoImageView.imageView.userInteractionEnabled = YES;
        [self.player setLogoImageView:_logoImageView];
    }
    [_logoImageView setImageWithModel:[self logoImageModel:videoLargeImageDict]];;
}

- (TTImageInfosModel *)logoImageModel:(NSDictionary *)imageDict
{
    if (imageDict) {
        if (imageDict.count <= 0) {
            return nil;
        }
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:imageDict];
        return model;
    }
    return nil;
}

- (void)layoutSubviews
{
    _player.frame = self.bounds;
    [super layoutSubviews];
}

- (FHDemanderTrackerManager *)commonTracker
{
    return _player.commonTracker;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ([self.delegate respondsToSelector:@selector(movieViewWillMoveToSuperView:)]) {
        [self.delegate movieViewWillMoveToSuperView:newSuperview];
    }

}
/**
 TTMovieStoreAction 为了满足协议
 */

- (void)stopWithFinishedBlock:(TTVStopFinished)finishedBlock
{
    // 原视频 stop 贴片播放器同时 stop
    [self.player.pasterPlayer stop];
    [self.player.midInsertADPlayer stop];
    [self.player stopWithFinishedBlock:finishedBlock];
}

- (void)stop
{
    [self stopWithFinishedBlock:nil];
}

- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    [self.player exitFullScreen:animated completion:completion];
}

+ (void)removeExcept:(UIView <TTMovieStoreAction> *)video
{
    [[TTMovieStore shareTTMovieStore] removeExcept:video];
}

+ (void)removeAll
{
    [[TTMovieStore shareTTMovieStore] removeAll];
}

+ (void)setCurrentPlayingPlayVideo:(TTVPlayVideo *)playVideo
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    currentTTVPlayVideo_ = playVideo;
}

+ (TTVPlayVideo *)currentPlayingPlayVideo
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    return currentTTVPlayVideo_;
}

- (BOOL)isAdMovie
{
    return self.playerModel.adID.length > 0;
}

@end
