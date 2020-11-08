//
//  TTVDemandPlayer.m
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import "TTVDemandPlayer.h"
#import "TTVVideoPlayerStateStore.h"
#import "TTVPlayerStateAction.h"
#import "TTVFluxDispatcher.h"
#import "KVOController.h"
#import "TTMovieStore.h"
#import "TTVPalyerTrafficAlertView.h"
#import "TTVPlayerControlTipView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTSharePanelTransformMessage.h"
#import "TTVPlayerBackgroundManager.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVPlayerModel.h"
#import "TTVPlayerCacheProgressController.h"
#import "FHDemanderTrackerManager.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>

extern NSString * const TTVPlayerFinishActionTypeNone;
extern NSString * const TTVPlayerFinishActionTypeShare;
extern NSString * const TTVPlayerFinishActionTypeReplay;
extern NSString * const TTVPlayerFinishActionTypeMoreShare;
extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;

extern NSString * _Nonnull const kExploreMovieViewDidChangeFullScreenNotifictaion;
extern BOOL ttvs_isVideoNewRotateEnabled(void);
extern BOOL ttvs_isVideoPlayFullScreenShowDirectShare(void);
extern BOOL ttvs_isTitanVideoBusiness(void);
extern BOOL ttvs_isDoubleTapForDiggEnabled(void);

@interface TTVDemandPlayer ()<TTVPlayerControllerDataSource ,TTVPlayerControlViewDelegate ,TTVPlayerControllerDelegate ,TTSharePanelTransformMessage>

@property (nonatomic, strong) TTVPlayerController *playerController;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) TTVPlayerResolutionType currentResolution;
@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, strong) FHDemanderTrackerManager *commonTracker;// add by zjing 修改video相关埋点

@property (nonatomic, strong) TTVDemandPlayerContext *context;
@property (nonatomic, strong) NSHashTable *map;
@property (nonatomic, strong) TTVPlayerBackgroundManager *backgroundManager;
@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, assign) BOOL isPlaying;


@end

@implementation TTVDemandPlayer
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    UNREGISTER_MESSAGE(TTSharePanelTransformMessage, self);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        REGISTER_MESSAGE(TTSharePanelTransformMessage, self);
        self.playerStateStore = [[TTVVideoPlayerStateStore alloc] init];
        self.commonTracker = [[FHDemanderTrackerManager alloc] init];
        _parts = [NSMutableArray array];
        _delegates = [NSHashTable weakObjectsHashTable];
        _context = [[TTVDemandPlayerContext alloc] init];
        _playerView = [[TTVPlayerView alloc] init];
        _playerController = [[TTVPlayerController alloc] init];
        _playerController.playerView = self.playerView;
        _playerController.delegate = self;
        self.map = [NSHashTable weakObjectsHashTable];
    }
    return self;
}
    
- (void)setDelegate:(NSObject<TTVDemandPlayerDelegate> *)delegate
{
    if (delegate != _delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate) {
                [self.map removeObject:_delegate];
            }
            if (delegate) {
                [self.map addObject:delegate];
                _delegate = delegate;
            }
        });
    }
}

- (void)unregisterDelegate:(NSObject <TTVDemandPlayerDelegate> *)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.map containsObject:delegate]) {
            [self.map removeObject:delegate];
        }
    });
}

- (void)setPlayerModel:(TTVPlayerModel *)playerModel
{
    if (playerModel != _playerModel) {
        _playerModel = playerModel;
        self.playerStateStore.state.playerModel = self.playerModel;
        self.playerStateStore.state.isAutoPlaying = self.playerModel.isAutoPlaying;
    }
}

- (void)registerDelegate:(NSObject <TTVDemandPlayerDelegate> *)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.map containsObject:delegate]) {
            [self.map addObject:delegate];
        }
    });
}

- (void)setPlayerStateStore:(TTVVideoPlayerStateStore *)playerStateStore {
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)releaseAysnc
{
    [self.playerController releaseAysnc];
}

- (void)reset
{
    [self ttv_addPlayerStateStore];
}

- (void)readyToPlay
{
    if (!self.tipCreator) {
        self.tipCreator = [[TTVPlayerTipCreator alloc] init];
    }

    [self ttv_addPlayerController];
    [self ttv_addTipView];
    [self createTipViewSubViews];
    _controlView.playerStateStore = self.playerStateStore;

    if (self.playerModel.enableCommonTracker) {
        [self ttv_addPlayerTracker];
    }

    [_context setPlayerStateModel:self.playerStateStore.state];
    [self addBackgroundManager];
    [self configureParts];
}

- (void)configureParts
{
    for (id <TTVPlayerContext> object in _parts) {
        if ([object conformsToProtocol:@protocol(TTVPlayerContext)]) {
            object.playerStateStore = self.playerStateStore;
        }
    }
}

- (void)addBackgroundManager
{
    if (!_backgroundManager) {
        @weakify(self);
        _backgroundManager = [[TTVPlayerBackgroundManager alloc] init];
        [_backgroundManager addDidBecomeActiveBlock:^{
            @strongify(self);
            if (self.context.showVideoFirstFrame) {
                NSDictionary *dic = [NSDictionary dictionaryWithObject:TTVPlayActionEnterForground forKey:TTVPlayAction];
                [self sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:dic];
            }
        } willResignActive:^{
            @strongify(self);
            NSDictionary *dic = [NSDictionary dictionaryWithObject:TTVPauseActionAppEnterBackgroud forKey:TTVPauseAction];
            [self sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:dic];
        }];
    }
}


- (void)runOnMainThread:(void(^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)setTipCreator:(id<TTVPlayerTipCreator>)tipCreator
{
    if (_tipCreator != tipCreator) {
        _tipCreator = tipCreator;
        [self createTipViewSubViews];
    }
}

- (void)createTipViewSubViews
{
    [_tipView createViewsWithCreator:self.tipCreator];
    _tipView.playerStateStore = self.playerStateStore;
    __weak typeof(self) wself = self;
    _tipView.retryView.retryAction = ^{
        __strong typeof(wself) self = wself;
        [self.playerController playVideoFromPayload:@{TTVPlayAction : TTVPlayActionRetry}];
        [self.playerStateStore sendAction:TTVPlayerEventTypeRetry payload:nil];
    };
    _tipView.finishedView.finishAction = ^(NSString *action) {
        __strong typeof(wself) self = wself;
        if ([action isEqualToString:TTVPlayerFinishActionTypeNone]){
            return;
        }else if ([action isEqualToString:TTVPlayerFinishActionTypeShare]){
            [self.playerStateStore sendAction:TTVPlayerEventTypeFinishUIShare payload:nil];
            return;
        }else if ([action isEqualToString:TTVPlayerFinishActionTypeReplay]){
            [self.playerStateStore sendAction:TTVPlayerEventTypeFinishUIReplay payload:nil];
            [self.playerController playVideoFromPayload:@{TTVPlayAction : TTVPlayActionFromUIFinished}];
            return;
        }else if ([action isEqualToString:TTVPlayerFinishActionTypeMoreShare]){
            [self.playerStateStore sendAction:TTVPlayerEventTypeFinishMore payload:nil];
            return;
        }else if ([action isEqualToString:TTActivityContentItemTypeWechatTimeLine] ||
                  [action isEqualToString:TTActivityContentItemTypeWechat]         ||
                  [action isEqualToString:TTActivityContentItemTypeQQZone]         ||
                  [action isEqualToString:TTActivityContentItemTypeQQFriend]){
            [self.playerStateStore sendAction:TTVPlayerEventTypeFinishDirectShare payload:action];
            return;
        }
    };
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (_tipView.tipType == TTVPlayerControlTipViewTypeUnknow) {
//            if (!_playerStateStore.state.showVideoFirstFrame && _playerStateStore.state.banLoading){
//
//            }else{
//                _tipView.tipType = TTVPlayerControlTipViewTypeLoading;
//            }
//        }
//    });
}

- (void)ttv_addPlayerController
{
    _playerController.playerStateStore = self.playerStateStore;
    _playerController.playerModel = self.playerModel;
    _playerController.playerDataSource = self;
    _playerController.playerView.frame = self.bounds;
    _playerController.rotateView = self.rotateView;
    [_playerController readyToPlay];
    if (_playerController.playerView.superview != self) {
        [self addSubview:_playerController.playerView];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController unobserveAll];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTVPlaybackState" object:self];
        if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished) {
            self.tipView.tipType = TTVPlayerControlTipViewTypeFinished;
        }
        else if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateError) {
            self.tipView.tipType = TTVPlayerControlTipViewTypeRetry;
        }
        [self runOnMainThread:^{
            for (id <TTVDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerPlaybackState:)]) {
                    [delegate playerPlaybackState:self.playerStateStore.state.playbackState];
                }
            }
        }];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isRotating) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self runOnMainThread:^{
            if (!self.playerStateStore.state.isRotating) {
                for (id <TTVDemandPlayerDelegate> delegate in self.map) {
                    if ([delegate respondsToSelector:@selector(playerOrientationState:)]) {
                        [delegate playerOrientationState:self.playerStateStore.state.isFullScreen];
                    }
                }
            }
        }];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,loadingState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self runOnMainThread:^{
            for (id <TTVDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerLoadingState:)]) {
                    [delegate playerLoadingState:self.playerStateStore.state.loadingState];
                }
            }
        }];
    }];
        
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self runOnMainThread:^{
            @strongify(self);
            for (id <TTVDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerOrientationState:)]) {
                    [delegate playerOrientationState:self.playerStateStore.state.isFullScreen];
                }
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewDidChangeFullScreenNotifictaion object:nil userInfo:@{@"isFullScreen":@(self.playerStateStore.state.isFullScreen)}];
        
        SAFECALL_MESSAGE(TTSharePanelTransformMessage, @selector(message_sharePanelIfNeedTransform:), message_sharePanelIfNeedTransform:self.playerStateStore.state.isFullScreen);
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self runOnMainThread:^{
            for (id <TTVDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerCurrentPlayBackTimeChange:duration:)]) {
                    [delegate playerCurrentPlayBackTimeChange:self.playerStateStore.state.currentPlaybackTime duration:self.playerStateStore.state.duration];
                }
            }
        }];
    }];
}

- (void)ttv_addTipView
{
    if (!_tipView) {
        //提示重新加载按钮
        _tipView = [[TTVPlayerControlTipView alloc] initWithFrame:self.bounds];
        _tipView.center = CGPointMake(self.controlView.width / 2, self.controlView.height / 2);
    }
}

- (void)ttv_addPlayerTracker
{
    FHDemanderTrackerManager *tracker = self.commonTracker;
    tracker.trackLabel = self.playerModel.trackLabel;
    tracker.itemID = self.playerModel.itemID;
    tracker.groupID = self.playerModel.groupID;
    tracker.categoryID = self.playerModel.categoryID;
    tracker.logPb = self.playerModel.logPb;
    tracker.enterFrom = self.playerModel.enterFrom;
    tracker.categoryName = self.playerModel.categoryName;
    tracker.extraDic = self.playerModel.extraDic;
    tracker.playerStateStore = self.playerStateStore;
    [tracker configureData];
}


- (void)ttv_addPlayerStateStore
{
    TTVVideoPlayerStateStore *store = [[TTVVideoPlayerStateStore alloc] init];
    store.state.isFullScreen = self.playerStateStore.state.isFullScreen;
    store.state.playStateVirtualStack = 0;
    store.state.playerModel = self.playerModel;
    self.playerStateStore = store;
}

- (BOOL)shouldReactToPlay
{
    return (self.playerStateStore.state.isShowingTrafficAlert ||
            self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeRetry ||
            self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeFinished);
}

- (void)actionChangeCallbackWithAction:(TTVFluxAction *)action state:(id)state
{
    TTVPlayerStateAction *newAction = (TTVPlayerStateAction *)action;
    if (![newAction isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    switch (newAction.actionType) {
        case TTVPlayerEventTypeVirtualStackValuePlay:{
            if ([self shouldReactToPlay]) {
                return;
            }
            self.playerStateStore.state.playStateVirtualStack --;
            if (self.playerStateStore.state.playStateVirtualStack < 0) {
                self.playerStateStore.state.playStateVirtualStack = 0;
            }
            if (self.playerStateStore.state.playStateVirtualStack == 0) {
                if (!(self.playerStateStore.state.playbackState == TTVVideoPlaybackStateBreak ||
                     self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished ||
                     self.playerStateStore.state.playbackState == TTVVideoPlaybackStateError)) {
                    [self play];
                }
            }
        }
            break;
        case TTVPlayerEventTypeVirtualStackValuePause: {
            if ([self shouldReactToPlay]) {
                return;
            }
            // 状态校正 1 : pause时 播放状态 手动清空栈 初始化
            if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStatePlaying) {
                self.playerStateStore.state.playStateVirtualStack = 0;
            }
            // 状态校正 2 : pause时 栈空 & 不是播放状态 手动入栈一次
            if (self.playerStateStore.state.playbackState != TTVVideoPlaybackStatePlaying &&
                self.playerStateStore.state.playStateVirtualStack == 0) {
                self.playerStateStore.state.playStateVirtualStack = 1;
            }
            
            self.playerStateStore.state.playStateVirtualStack ++;
            
            [self pause];
        }
            break;
        case TTVPlayerEventTypeControlViewDoubleClickScreen: {

        }
            break;
            case TTVPlayerEventTypeAdDetailAction:{
                if ([self.playerStateStore.state isFullScreen]) {
                    [self.playerController exitFullScreen:NO completion:^(BOOL finished) {
                        
                    }];
                }
            }
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <TTVDemandPlayerDelegate> delegate in self.map) {
            if ([delegate respondsToSelector:@selector(actionChangeCallbackWithAction:)]) {
                [delegate actionChangeCallbackWithAction:(TTVPlayerStateAction *)action];
            }
        }
    });
    

}

- (void)saveCacheProgress
{
    if (self.playerStateStore.state.currentPlaybackTime + 2 < self.playerStateStore.state.duration) {
        [self.playerController saveCacheProgress];
    }
}

- (void)setVideoTitle:(NSString *)title
{
    if ([self.controlView respondsToSelector:@selector(setVideoTitle:)]) {
        [self.controlView setVideoTitle:title];
    }
}

- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText
{
    if ([self.controlView respondsToSelector:@selector(setVideoWatchCount:playText:)]) {
        [self.controlView setVideoWatchCount:watchCount playText:playText];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect targetFrame = CGRectMake(0, 0, self.width, self.height);
    if ([TTDeviceHelper isIPhoneXDevice] && self.playerStateStore.state.isFullScreen) {
        if (self.playerStateStore.state.enableRotate) {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(0, 44, 0, 44));
        } else {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(44, 0, 0, 0));
        }
    }
    self.playerView.frame = targetFrame;
}

#pragma mark public

- (void)registerPart:(NSObject <TTVPlayerContext> *)part
{
    if (part) {
        [_parts addObject:part];
        if ([part respondsToSelector:@selector(setPlayerStateStore:)]) {
            part.playerStateStore = self.playerStateStore;
        }
    }
}

- (void)registerTracker:(NSObject <TTVPlayerContext> *)tracker
{
    if ([tracker conformsToProtocol:@protocol(TTVPlayerContext)]) {
        tracker.playerStateStore = self.playerStateStore;
    }
}

- (void)stop
{
    [self stopWithFinishedBlock:^{
        
    }];
}

- (void)stopWithFinishedBlock:(TTVStopFinished)finishedBlock
{
    _backgroundManager = nil;
    @weakify(self);
    [[[[RACObserve(self.playerStateStore.state, isRotating) ignore:@YES] take:1] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self.playerController exitFullScreen:NO completion:^(BOOL finished) {
            @strongify(self);
            [self.playerController stopVideo];
            finishedBlock ? finishedBlock() : nil;
        }];
    }];
}

- (void)play
{
    if (!_backgroundManager) {
        [self addBackgroundManager];
    }
    [self.playerController playVideo];
}

- (void)pause
{
    [self.playerController pauseVideo];
}

- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised
{
    [self.playerController seekVideoToProgress:progress complete:finised];
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    self.playerController.playerView.backgroundView = backgroundView;
}

- (void)setLogoImageView:(UIView *)logoImageView
{
    self.playerController.playerView.logoImageView = logoImageView;
}

- (void)refreshTotalWatchTime
{
    [self.playerStateStore sendAction:TTVPlayerEventTypeRefreshTotalWatchTime payload:nil];
}

- (void)setLogoImageViewHidden:(BOOL)hidden
{
    [self.playerController.playerView.logoImageView setHidden:hidden];
}

#pragma mark public TTVPlayerControllerDataSource
- (UIView<TTVPlayerViewControlView ,TTVPlayerContext> *)videoPlayerControlView
{
    if (self.playerModel.disableControlView) {
        return nil;
    }
    if (!([_controlView conformsToProtocol:@protocol(TTVPlayerViewControlView)] && [_controlView conformsToProtocol:@protocol(TTVPlayerContext)])) {
        _controlView = [[TTVPlayerControlView alloc] initWithFrame:self.bounds];
        _controlView.bottomBarView = self.bottomBarView;
    }
    _controlView.delegate = self;
    if (_controlView.frame.size.width <= 0) {
        _controlView.frame = self.bounds;
    }
    return _controlView;
}

- (UIView<TTVPlayerViewTrafficView> *)videoPlayerTrafficView
{
    TTVPalyerTrafficAlertView *alert = [[TTVPalyerTrafficAlertView alloc] init];
    return alert;
}

- (UIView<TTVPlayerControlTipView ,TTVPlayerContext> *)videoPlayerTipView
{
    if (!_tipView) {
        [self ttv_addTipView];
    }
    return _tipView;
}

#pragma mark - TTVPlayerControllerDelegate

- (BOOL)shouldAutoRotate
{
    return (self.playerStateStore.state.playbackState != TTVVideoPlaybackStateFinished);
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttv_movieViewFrameAfterExitFullscreen)]) {
        return [self.delegate ttv_movieViewFrameAfterExitFullscreen];
    }
    return CGRectZero;
}

#pragma mark ControlViewDelegate
- (void)controlViewPlayButtonClicked:(UIView *)controlView isPlay:(BOOL)isPlay{
    if (isPlay) {
        [self.playerController pauseVideoFromPayload:@{TTVPauseAction : TTVPauseActionUserAction}];
    }else{
        if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStatePaused) {
            [self.playerStateStore sendAction:TTVPlayerEventTypePlayerContinuePlay payload:nil];
        }
        [self.playerController playVideoFromPayload:@{TTVPlayAction : TTVPlayActionUserAction}];
    }
}

- (void)controlViewFullScreenButtonClicked:(UIView *)controlView isFull:(BOOL)isFull{
    self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeFullButton;
    [self.playerStateStore sendAction:TTVPlayerEventTypeControlViewClickFullScreenButton payload:@{@"isFullScreen" : @(isFull)}];
    if (isFull) {
        [self.playerController exitFullScreen:YES completion:^(BOOL finished) {
            self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeUnknow;

        }];
    }else{
        [self.playerController enterFullScreen:YES completion:^(BOOL finished) {

        }];
    }
}

- (void)controlViewBackButtonClicked:(UIView *)controlView{
    self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeBackButton;
    if (self.playerStateStore.state.isFullScreen) {
        [self exitFullScreen:YES completion:^(BOOL finished) {
            self.playerStateStore.state.exitFullScreeenType = TTVPlayerExitFullScreeenTypeUnknow;
        }];
    }
}

- (void)controlView:(UIView *)controlView seekProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised
{
    [self.playerController seekVideoToProgress:progress complete:finised];
}

- (void)controlViewPlayerShareButtonClicked:(UIView *)controlView
{
    [self.playerStateStore sendAction:TTVPlayerEventTypePlayingShare payload:nil];
}

- (void)controlViewPlayerMoreButtonClicked:(UIView *)controlView
{
    [self.playerStateStore sendAction:TTVPlayerEventTypePlayingMore payload:nil];
}

#pragma mark TTMovieStoreAction
/**
 兼容老旧播放器 符合 TTMovieStoreAction 协议
 */
- (void)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL finished))completion
{
    [self.playerController exitFullScreen:animation completion:completion];
}

- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    [self.playerController enterFullScreen:animated completion:completion];
}

- (void)sendAction:(TTVPlayerEventType)event payload:(id)payload
{
    [self.playerStateStore sendAction:event payload:payload];
}

- (void)removeControlView
{
    [self.controlView removeFromSuperview];
}

#pragma mark -- TTSharePanelTransformMessage

- (void)message_sharePanelIfNeedTransformWithBlock:(TTSharePanelFullScreenTransformHandler )fullScreenTransformHandler
{
    if (fullScreenTransformHandler) {
        fullScreenTransformHandler(self.playerStateStore.state.isFullScreen, [UIApplication sharedApplication].statusBarOrientation);
    }
}

- (void)removeBottomBarView {
    
    [self.controlView.bottomBarView removeFromSuperview];
    [self.controlView.miniSlider removeFromSuperview];
}
@end


@implementation TTVDemandPlayer(SetterPropterty)

- (void)setShowTitleInNonFullscreen:(BOOL)showTitleInNonFullscreen
{
    self.playerStateStore.state.showTitleInNonFullscreen = showTitleInNonFullscreen;
}

- (void)setIsInDetail:(BOOL)isInDetail
{
    self.playerStateStore.state.isInDetail = isInDetail;
}

- (void)setMuted:(BOOL)muted
{
    self.playerController.muted = muted;
}

- (void)setBanLoading:(BOOL)banLoading
{
    self.playerController.banLoading = banLoading;
}

- (void)setBannerHeight:(float)bannerHeight
{
    self.playerStateStore.state.bannerHeight = bannerHeight;
}

- (void)setEnableRotate:(BOOL)enableRotate
{
    self.playerStateStore.state.enableRotate = enableRotate;
}

- (void)setScaleMode:(TTVPlayerScalingMode)scaleMode {
    self.playerController.scaleMode = scaleMode;
    if(scaleMode == TTVPlayerScalingModeAspectFill){
        self.playerController.playerView.logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    }else if(scaleMode == TTVPlayerScalingModeAspectFit){
        self.playerController.playerView.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end




