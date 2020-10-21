//
//  FHUGCShortVideoView.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/10/13.
//

#import "FHUGCShortVideoView.h"
#import "TTVPlayVideo.h"
#import "TTVPlayerController.h"
#import "TTMovieStore.h"
#import "TTVDemandPlayer.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerUrlTracker.h"
#import "TTImageView.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import <TTSettingsManager/TTSettingsManager.h>
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "NSObject+FBKVOController.h"
#import "SSAppStore.h"
#import "TTVVideoPlayerModel.h"
#import "TTVPasterPlayer.h"
#import "TTVMidInsertADPlayer.h"
#import "TTVResolutionStore.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTArticleBase/SSCommonLogic.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTAccountSDK/TTAccount.h>

extern NSString * const TTStrongPushNotificationWillShowNotification;
extern NSString * const TTStrongPushNotificationWillHideNotification;
extern NSString* const TTAdAppointAlertViewShowKey;
extern NSString* const TTAdAppointAlertViewCloseKey;

static __weak FHUGCShortVideoView *currentTTVPlayVideo_ = nil;

@interface FHUGCShortVideoView ()
@property (nonatomic, strong) TTImageView *logoImageView;
@end
@implementation FHUGCShortVideoView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //去掉,优化视频广告滑出屏幕的卡顿
    [_player stopWithFinishedBlock:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
        [self movieConfig];
    }
    return self;
}

- (void)createViews {
    self.backgroundColor = [UIColor blackColor];
    _player = [[TTVDemandPlayer alloc] initWithFrame:self.bounds];
    _player.enableRotate = NO;
    _player.controlView.miniSlider.hidden = YES;
    [self addSubview:_player];
}

- (void)movieConfig {
    [FHUGCShortVideoView setCurrentPlayingPlayVideo:self];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [[TTMovieStore shareTTMovieStore] addMovie:self];
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
    [self exitFullScreen:YES completion:^(BOOL finished) {
        
    }];
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

- (void)resetPlayerModel:(TTVPlayerModel *)playerModel
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
//    [self.player.pasterPlayer stop];
//    [self.player.midInsertADPlayer stop];
    [self.player stopWithFinishedBlock:finishedBlock];
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

+ (void)setCurrentPlayingPlayVideo:(FHUGCShortVideoView *)playVideo
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    currentTTVPlayVideo_ = playVideo;
}

+ (FHUGCShortVideoView *)currentPlayingPlayVideo
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    return currentTTVPlayVideo_;
}

- (BOOL)isAdMovie
{
    return self.playerModel.adID.length > 0;
}

- (void)readyToPlay {
        [self.player readyToPlay];
    //    if (isAutoPlaying && self.cellEntity.article.adId.longLongValue > 0) {
    //        self.movieView.player.banLoading = YES;
    //        self.movieView.player.muted = [self.cellEntity.originData couldAutoPlay];
    //    }
//        self.playerView.player.muted = YES;
    //    [self addUrlTrackerOnPlayer:playVideo];
        [self settingMovieView:self.player];
}

- (void)reset {
    [self.player reset];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player stopWithFinishedBlock:^{
    }];
}

- (void)play
{
    [self.player setBanLoading:YES];
    [self.player play];
    self.player.controlView.miniSlider.hidden = YES;
//    if(!self.cellEntity.hideTitleAndWatchCount){
//        [playVideo.player setVideoTitle:feedItem.title];
//        [playVideo.player setVideoWatchCount:article.videoDetailInfo.videoWatchCount playText:@"次播放"];
//    }
//    self.logo.userInteractionEnabled = ![feedItem couldAutoPlay];
//    if (![TTDeviceHelper isPadDevice]) {
//        playVideo.player.commodityFloatView.animationToView = self.cellEntity.moreButton;
//        playVideo.player.commodityFloatView.animationSuperView = self.cellEntity.cell;
//        [playVideo.player.commodityFloatView setCommoditys:self.cellEntity.originData.commoditys];
//        playVideo.player.commodityButton.delegate = self;
//    }

//    [self ttv_configADFinishedView:playVideo.player.tipCreator.tipFinishedView];
//
//    [[AKAwardCoinVideoMonitorManager shareInstance] monitorVideoWith:playVideo];
}

- (void)settingMovieView:(TTVDemandPlayer *)player
{
    player.isInDetail = NO;
    player.showTitleInNonFullscreen = YES;
}

@end
