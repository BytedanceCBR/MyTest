//
//  TTVBaseDemandPlayer.m
//  Article
//
//  Created by panxiang on 2017/9/15.
//
//

#import "TTVBaseDemandPlayer.h"
#import "TTVPlayerStateAction.h"
#import "TTVPlayerStateStore.h"
#import "TTVFluxDispatcher.h"
#import "KVOController.h"
#import "TTMovieStore.h"
#import "TTVPalyerTrafficAlertView.h"
#import "TTVPlayerControlTipView.h"
#import "TTVDemanderTrackerManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVPlayerView.h"
#import "TTVPlayerBackgroundManager.h"

extern NSString * const TTVPlayerFinishActionTypeNone;
extern NSString * const TTVPlayerFinishActionTypeShare;
extern NSString * const TTVPlayerFinishActionTypeReplay;

extern NSString * _Nonnull const kExploreMovieViewDidChangeFullScreenNotifictaion;

@interface TTVBaseDemandPlayer ()<TTVPlayerControllerDataSource ,TTVPlayerControlViewDelegate ,TTVPlayerControllerDelegate>
@property (nonatomic, strong) TTVPlayerController *playerController;
@property(nonatomic, strong)TTVPlayerControlTipView *tipView;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) TTVPlayerResolutionType currentResolution;
@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, strong) TTVDemanderTrackerManager *commonTracker;//通用的tracker
@property (nonatomic, strong) TTVDemandPlayerContext *context;
@property (nonatomic, strong) NSHashTable *map;
@property (nonatomic, strong) TTVPlayerView *playerView;
@property (nonatomic, strong) TTVPlayerBackgroundManager *backgroundManager;
@property (nonatomic, strong) NSMutableArray *parts;
@end

@implementation TTVBaseDemandPlayer
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playerStateStore = [[TTVPlayerStateStore alloc] init];
        self.commonTracker = [[TTVDemanderTrackerManager alloc] init];
        _delegates = [NSHashTable weakObjectsHashTable];
        _context = [[TTVDemandPlayerContext alloc] init];
        _playerView = [[TTVPlayerView alloc] init];
        _parts = [NSMutableArray array];
        _playerController = [[TTVPlayerController alloc] init];
        _playerController.playerView = self.playerView;
        _playerController.delegate = self;

        self.map = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)releaseAysnc
{
    [self.playerController releaseAysnc];
}

- (void)setDelegate:(NSObject<TTVBaseDemandPlayerDelegate> *)delegate
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

- (void)unregisterDelegate:(NSObject <TTVBaseDemandPlayerDelegate> *)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.map containsObject:delegate]) {
            [self.map removeObject:delegate];
        }
    });
}

- (void)registerDelegate:(NSObject <TTVBaseDemandPlayerDelegate> *)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.map containsObject:delegate]) {
            [self.map addObject:delegate];
        }
    });
}

- (void)setPlayerModel:(TTVBasePlayerModel *)playerModel
{
    if (playerModel != _playerModel) {
        _playerModel = playerModel;
        self.playerStateStore.state.playerModel = self.playerModel;
        self.playerStateStore.state.isAutoPlaying = self.playerModel.isAutoPlaying;
    }
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
    _commonTracker.playerStateStore = self.playerStateStore;
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
        _backgroundManager = [[TTVPlayerBackgroundManager alloc] init];
        @weakify(self);
        [_backgroundManager addDidBecomeActiveBlock:^{
            @strongify(self);
            if (self.context.showVideoFirstFrame) {
                [self sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:@{TTVPlayAction : TTVPlayActionEnterForground}];
            }
        } willResignActive:^{
            @strongify(self);
            [self sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:@{TTVPauseAction : TTVPauseActionAppEnterBackgroud}];
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

- (void)createTipViewSubViews
{
    _tipView.playerStateStore = self.playerStateStore;
    [_tipView createViewsWithCreator:self.tipCreator];
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
        }
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_tipView.tipType == TTVPlayerControlTipViewTypeUnknow) {
            _tipView.tipType = TTVPlayerControlTipViewTypeLoading;
        }
    });
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

- (void)registerPart:(NSObject <TTVPlayerContext> *)part
{
    if (part) {
        [_parts addObject:part];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController unobserveAll];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished) {
            self.tipView.tipType = TTVPlayerControlTipViewTypeFinished;
        }
        else if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStateError) {
            self.tipView.tipType = TTVPlayerControlTipViewTypeRetry;
        }
        switch (self.playerStateStore.state.playbackState) {
            case TTVVideoPlaybackStateFinished:
                if (self.playerModel.removeWhenFinished) {
                    [self.superview removeFromSuperview];
                }
                break;
            default:
                break;
        }
        [self runOnMainThread:^{
            for (id <TTVBaseDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerPlaybackState:)]) {
                    [delegate playerPlaybackState:self.playerStateStore.state.playbackState];
                }
            }
        }];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,loadingState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self runOnMainThread:^{
            for (id <TTVBaseDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerLoadingState:)]) {
                    [delegate playerLoadingState:self.playerStateStore.state.loadingState];
                }
            }
        }];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self runOnMainThread:^{
            for (id <TTVBaseDemandPlayerDelegate> delegate in self.map) {
                if ([delegate respondsToSelector:@selector(playerOrientationState:)]) {
                    [delegate playerOrientationState:self.playerStateStore.state.isFullScreen];
                }
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMovieViewDidChangeFullScreenNotifictaion object:nil userInfo:@{@"isFullScreen":@(self.playerStateStore.state.isFullScreen)}];
    }];
}

- (void)ttv_addTipView
{
    if (_tipView) {
        return;
    }
    //提示重新加载按钮
    _tipView = [[TTVPlayerControlTipView alloc] initWithFrame:self.bounds];
    _tipView.center = CGPointMake(self.controlView.width / 2, self.controlView.height / 2);
}


- (void)ttv_addPlayerTracker
{
    TTVDemanderTrackerManager *tracker = self.commonTracker;
    tracker.trackLabel = self.playerModel.trackLabel;
    tracker.itemID = self.playerModel.itemID;
    tracker.groupID = self.playerModel.groupID;
    tracker.aggrType = self.playerModel.aggrType;
    tracker.adID = self.playerModel.adID;
    tracker.logExtra = self.playerModel.logExtra;
    tracker.categoryID = self.playerModel.categoryID;
    tracker.videoSubjectID = self.playerModel.videoSubjectID;
    tracker.playerStateStore = self.playerStateStore;
    tracker.logPb = self.playerModel.logPb;
    tracker.enterFrom = self.playerModel.enterFrom;
    tracker.categoryName = self.playerModel.categoryName;
    tracker.authorId = self.playerModel.authorId;
    [tracker configureData];
}

- (void)reset
{
    [self ttv_addPlayerStateStore];
}

- (void)ttv_addPlayerStateStore
{
    TTVPlayerStateStore *store = [[TTVPlayerStateStore alloc] init];
    store.state.isFullScreen = self.playerStateStore.state.isFullScreen;
    store.state.playStateVirtualStack = 0;
    store.state.playerModel = self.playerStateStore.state.playerModel;
    self.playerStateStore = store;
}

- (BOOL)shouldReactToPlay
{
    return (self.playerStateStore.state.isShowingTrafficAlert || self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeRetry ||
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
                
                BOOL hasFrom = NO;
                if ([action.payload isKindOfClass:[NSDictionary class]]) {
                    [self.playerController playVideoFromPayload:action.payload];
                    hasFrom = YES;
                }
                if (!hasFrom) {
                    if (self.playerStateStore.state.playStateVirtualStack == 0) {
                        if (!(self.playerStateStore.state.playbackState == TTVVideoPlaybackStateBreak ||
                              self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished ||
                              self.playerStateStore.state.playbackState == TTVVideoPlaybackStateError)) {
                            [self play];
                        }
                    }
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
            BOOL hasFrom = NO;
            if ([action.payload isKindOfClass:[NSDictionary class]]) {
                [self.playerController pauseVideoFromPayload:action.payload];
                hasFrom = YES;
            }
            if (!hasFrom) {
                [self pause];
            }
        }
            break;
            
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id <TTVBaseDemandPlayerDelegate> delegate in self.map) {
            if ([delegate respondsToSelector:@selector(actionChangeCallbackWithAction:)]) {
                [delegate actionChangeCallbackWithAction:(TTVPlayerStateAction *)action];
            }
        }
    });
    
    
}

- (void)setVideoTitle:(NSString *)title
{
    [self.controlView setVideoTitle:title];
}

- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText
{
    [self.controlView setVideoWatchCount:watchCount playText:playText];
}

- (void)layoutSubviews
{
    self.playerView.frame = self.bounds;
    _controlView.frame = self.playerView.bounds;
    _tipView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)registerTracker:(NSObject <TTVPlayerContext> *)tracker
{
    if ([tracker conformsToProtocol:@protocol(TTVPlayerContext)]) {
        tracker.playerStateStore = self.playerStateStore;
    }
}

- (void)stop
{
    _backgroundManager = nil;
    @weakify(self);
    [[[[RACObserve(self.playerStateStore.state, isRotating) ignore:@YES] take:1] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self.playerController exitFullScreen:NO completion:^(BOOL finished) {
            @strongify(self);
            [self.playerController stopVideo];
        }];
    }];
}

- (void)play
{
    if (self.playerModel.enableBackgroundManager) {
        if (!_backgroundManager) {
            [self addBackgroundManager];
        }
        
    }
    [self.playerController playVideoFromPayload:@{TTVPlayAction : TTVPlayActionDefault}];
}

- (void)pause
{
    [self.playerController pauseVideo];
}

- (void)playWithPayload:(NSDictionary *)payload
{
    if (!payload) {
        [self play];
    }else{
        
        [self.playerController playVideoFromPayload:payload];
    }
}

- (void)pauseWithPayload:(NSDictionary *)payload
{
    if (!payload) {
        [self pause];
    }else{
        [self.playerController pauseVideoFromPayload:payload];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    self.playerController.playerView.backgroundView = backgroundView;
}

- (void)setLogoImageView:(UIView *)logoImageView
{
    self.playerController.playerView.logoImageView = logoImageView;
}

- (void)removeMiniSliderView {
    
    [self.controlView.miniSlider removeFromSuperview];
}

#pragma mark public TTVPlayerControllerDataSource
- (UIView<TTVPlayerViewControlView ,TTVPlayerContext> *)videoPlayerControlView
{
    if (self.playerModel.disableControlView) {
        return nil;
    }
    if (!_controlView || !([_controlView conformsToProtocol:@protocol(TTVPlayerViewControlView)] && [_controlView conformsToProtocol:@protocol(TTVPlayerContext)])) {
        _controlView = [[TTVPlayerControlView alloc] initWithFrame:self.bounds];
    }
    _controlView.delegate = self;
    _controlView.bottomBarView = self.bottomBarView;
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

- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised
{
    [self.playerController seekVideoToProgress:progress complete:finised];
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

@end


@implementation TTVBaseDemandPlayer(SetterPropterty)

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

- (void)setBannerHeight:(float)bannerHeight
{
    self.playerStateStore.state.bannerHeight = bannerHeight;
}

- (void)setEnableRotate:(BOOL)enableRotate
{
    self.playerStateStore.state.enableRotate = enableRotate;
}

@end



