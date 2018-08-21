//
//  TTVMidInsertADPlayer.m
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "TTVMidInsertADPlayer.h"
#import "TTVPasterADService.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTVMidInsertADViewController.h"
#import "NetworkUtilities.h"
#import "TTVPlayerIdleController.h"
#import "TTVMidInsertIconADView.h"
#import "TTImageInfosModel+Extention.h"
#import "NSTimer+NoRetain.h"
#import "SSAppStore.h"
#import "TTURLUTils.h"
#import "TTRoute.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVMidInsertADTracker.h"
#import "TTVMidInsertADService.h"
#import "TTVMidInsertADGuideCountdownView.h"
#import <ReactiveObjC/ReactiveObjC.h>

extern BOOL ttvs_videoMidInsertADEnable(void);
extern NSInteger ttvs_getVideoMidInsertADReqStartTime(void);
extern NSInteger ttvs_getVideoMidInsertADReqEndTime(void);

static const CGFloat kADGuideTolerance = 3.0f;

typedef NS_ENUM(NSInteger, TTVMidInsertADPlayerRequestStatus) {
    TTVMidInsertADPlayerRequestStatusUnknown = -1,
    TTVMidInsertADPlayerRequestStatusSuccess = 0,
    TTVMidInsertADPlayerRequestStatusFailed = 1,
    TTVMidInsertADPlayerRequestStatusIng = 2,
};

@interface TTVMidInsertADPlayer ()<TTVMidInsertADDelegate>
@property (nonatomic, strong) TTVMidInsertADViewController *pasterADController;
@property (nonatomic, assign) float requestPercent;
@property (nonatomic, assign) BOOL playingMidInsertAD;
@property (nonatomic, assign) BOOL playingADGuide;
@property (nonatomic, assign) NSTimeInterval oldPlaybackTime;
@property (nonatomic, strong) TTVMidInsertIconADView *iconADView;
@property (nonatomic, strong) NSArray <TTVMidInsertADModel *> *adModels;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) TTVMidInsertADService *midInsertADService;
@property (nonatomic, assign) TTVMidInsertADPlayerRequestStatus reqStatus;
@property (nonatomic, assign) BOOL showedMidInserAD; // player 生命周期内 只播放一次中插广告视频

@property (nonatomic, weak) TTVMidInsertADGuideCountdownView *guideCountdownView;
@property (nonatomic, strong) RACDisposable *playerLoadingStateDisposable;

@end

@implementation TTVMidInsertADPlayer
- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)init {
    
    if (self = [super init]) {
        _reqStatus = TTVMidInsertADPlayerRequestStatusUnknown;
        _oldPlaybackTime = 0;
    }
    
    return self;
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
        NSTimeInterval newPlaybackTime = self.playerStateStore.state.currentPlaybackTime;
        if (ABS(newPlaybackTime - self.oldPlaybackTime) > 1.f) {
            self.oldPlaybackTime = newPlaybackTime;
            [self playPasterWhenRemainderTime:newPlaybackTime];
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isInDetail) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        self.pasterADController.enterDetailFlag = self.playerStateStore.state.isInDetail;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        
        [self.pasterADController setIsFullScreen:self.playerStateStore.state.isFullScreen];
        [self.iconADView updatSizeForFullScreenStatusChanged:self.playerStateStore.state.isFullScreen];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,toolBarState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        
        [self ttv_updateIconADFrameWithShowToolBarAnimated:YES];
    }];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
                
            case TTVPlayerEventTypeFinishedBecauseUserStopped:{
                if (self.iconADView.TTVMidInsertIconADCloseAction) {
                    self.iconADView.TTVMidInsertIconADCloseAction();
                }
            }
                break;
            case TTVPlayerEventTypeControlViewDragSliderTouchBegin: {
                if (self.playingADGuide) {
                    [TTVMidInsertADTracker sendADEventWithlabel:@"drag_skip" adModel:self.adModels.firstObject duration:self.playerStateStore.state.currentPlaybackTime * 1000 extra:@{@"position" : @([action.payload[@"fromTime"] doubleValue] * 1000)}];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)playPasterWhenRemainderTime:(NSTimeInterval)remainderTime
{
    // 数据请求
    if (TTNetworkWifiConnected() &&
        ttvs_videoMidInsertADEnable() &&
        (self.reqStatus == TTVMidInsertADPlayerRequestStatusUnknown || self.reqStatus == TTVMidInsertADPlayerRequestStatusFailed) &&
        remainderTime >= ttvs_getVideoMidInsertADReqStartTime() / 1000 &&
        remainderTime  <= ttvs_getVideoMidInsertADReqEndTime() / 1000) {
        @weakify(self);
        NSMutableDictionary *requestInfoParams = [[NSMutableDictionary alloc] initWithDictionary:self.midInsertAdRequestInfo];
        [requestInfoParams setValue:@((int)(self.playerStateStore.state.duration * 1000)) forKey:@"video_duration"];
        [requestInfoParams setValue:@((int)(self.playerStateStore.state.currentPlaybackTime * 1000)) forKey:@"video_position"];
        self.reqStatus = TTVMidInsertADPlayerRequestStatusIng;
        [self.midInsertADService fetchMidInsertADInfoWithRequestInfo:[requestInfoParams copy] completion:^(id response, NSError *error) {
            @strongify(self);
            self.reqStatus = (error) ? TTVMidInsertADPlayerRequestStatusFailed: TTVMidInsertADPlayerRequestStatusSuccess;
            if ([response isKindOfClass:[NSArray class]]) {
                self.adModels = response;
            }
        }];
    }
    
    TTVMidInsertADModel *firstADModel = self.adModels.firstObject;
    BOOL midInsertADCanBeShow = TTNetworkWifiConnected() &&
    !self.playingMidInsertAD &&
    !self.showedMidInserAD &&
    self.playerStateStore.state.playbackState == TTVVideoPlaybackStatePlaying &&
    [firstADModel isKindOfClass:[TTVMidInsertADModel class]] &&
    firstADModel.midInsertADInfoModel.adStartTime;
    
    @weakify(self);
    void (^pasterADShowBlock)(void) = ^{
        @strongify(self);
        self.playingMidInsertAD = YES;
        TTVMidInsertADModel *adModel = self.adModels.firstObject;
        _pasterADController = [[TTVMidInsertADViewController alloc] init];
        _pasterADController.delegate = self;
        [_pasterADController setupMidInsertADDataWithADModel:adModel];
        
        [self.playerStateStore sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
        
        @weakify(self);
        [self ttv_playPasterADs:nil completionBlock:^{
            @strongify(self);
            self.playingMidInsertAD = NO;
            self.showedMidInserAD = YES;
            [self.playerStateStore sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
        }];
    };
    
    // 显示中插倒计时
    if (midInsertADCanBeShow && firstADModel.style == TTVMidInsertADStyleVideo &&
        firstADModel.midInsertADInfoModel.guideVideoInfo == nil &&
        firstADModel.midInsertADInfoModel.guideWords && firstADModel.midInsertADInfoModel.guideTime &&
        firstADModel.midInsertADInfoModel.adStartTime.integerValue / 1000.f > firstADModel.midInsertADInfoModel.guideTime.integerValue / 1000.f)
    {
        if (self.playingADGuide && ABS(firstADModel.midInsertADInfoModel.adStartTime.integerValue / 1000.f - remainderTime) >= firstADModel.midInsertADInfoModel.guideTime.integerValue / 1000.f + kADGuideTolerance) {
            self.playingADGuide = NO;
            [self.guideCountdownView terminateTimer];
            [self.guideCountdownView removeFromSuperview];
        } else if (!self.playingADGuide &&
                   ABS(firstADModel.midInsertADInfoModel.adStartTime.integerValue / 1000.f - remainderTime) <  firstADModel.midInsertADInfoModel.guideTime.integerValue / 1000.f + kADGuideTolerance) {
            self.playingADGuide = YES;
            
            TTVMidInsertADGuideCountdownView *guideCountdownView = [[TTVMidInsertADGuideCountdownView alloc] initWithFrame:CGRectMake(self.width - 12 - 119.5, 0, 119.5, 25) pasterADModel:firstADModel];
            self.guideCountdownView = guideCountdownView;
            guideCountdownView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            @weakify(guideCountdownView, self);
            guideCountdownView.guideCountdownCompleted = ^{
                @strongify(guideCountdownView, self);
                self.playingADGuide = NO;
                [guideCountdownView removeFromSuperview];
                pasterADShowBlock();
            };
            if (self.guideCountdownViewNeedShow) {
                self.guideCountdownViewNeedShow(guideCountdownView);
            }
            [TTVMidInsertADTracker sendADEventWithlabel:@"guide_show" adModel:firstADModel duration:self.playerStateStore.state.currentPlaybackTime * 1000 extra:nil];
        }
    }
    
    // 中插广告
    if (midInsertADCanBeShow &&
        !self.playingADGuide &&
        self.adModels.firstObject.style != TTVMidInsertADStyleNone &&
        ABS(self.adModels.firstObject.midInsertADInfoModel.adStartTime.integerValue / 1000.f - remainderTime) < .5f) {
        
        pasterADShowBlock();
    }
    
    if (TTNetworkWifiConnected() &&
        !self.playerStateStore.state.iconADIsPlaying) {
        // 角标广告
        [self ttv_showMidInsertIconADWithRemainderTime:remainderTime];
    }
}

- (void)ttv_showMidInsertIconADWithRemainderTime:(NSTimeInterval)remainderTime {
    
    for (TTVMidInsertADModel *adModel in self.adModels) {
        
        if (adModel.style != TTVMidInsertADStyleMarkImage ||
            !adModel.midInsertADInfoModel.adStartTime) {
            continue;
        }
        
        if (ABS(adModel.midInsertADInfoModel.adStartTime.integerValue / 1000.f - remainderTime) < .5f) {
            
            self.playerStateStore.state.iconADIsPlaying = YES;
            
            self.iconADView = [[TTVMidInsertIconADView alloc] initWithFrame:CGRectZero imageModel:[[TTImageInfosModel alloc] initWithDictionary:adModel.midInsertADInfoModel.imageList.firstObject] closeEnabled:adModel.midInsertADInfoModel.enableClose];
            [self.iconADView updatSizeForFullScreenStatusChanged:self.playerStateStore.state.isFullScreen];
            [self addSubview:self.iconADView];
            
            [TTVMidInsertADTracker sendIconADShowEventForADModel:adModel duration:self.playerStateStore.state.currentPlaybackTime * 1000 isInDetail:[self isInDetail]];

            [self ttv_updateIconADFrameWithShowToolBarAnimated:NO];
            
            @weakify(self);
            self.iconADView.TTVMidInsertIconADCloseAction = ^{
                @strongify(self);
                [self ttv_closeIconAD:self.iconADView adModel:adModel isTimerFire:NO];
            };
            self.iconADView.TTVMidInsertIconADGoDetailAction = ^{
                @strongify(self);
                [self ttv_jumpToDetailAD:adModel];
            };
            
            NSTimeInterval delaySeconds = adModel.midInsertADInfoModel.displayTime.integerValue / 1000;
            _timer = [NSTimer tt_timerWithTimeInterval:delaySeconds repeats:YES block:^(NSTimer *timer) {
                @strongify(self);
                [self ttv_closeIconAD:self.iconADView adModel:adModel isTimerFire:YES];
            }];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)ttv_closeIconAD:(TTVMidInsertIconADView *)iconADView adModel:(TTVMidInsertADModel *)adModl isTimerFire:(BOOL)isTimerFire {
    
    NSTimeInterval duration = (isTimerFire)? _timer.timeInterval: _timer.timeInterval - (_timer.fireDate.timeIntervalSince1970 - [NSDate date].timeIntervalSince1970);
    [TTVMidInsertADTracker sendIconADShowOverEventForADModel:adModl duration:duration * 1000 isInDetail:[self isInDetail]];
    [iconADView removeFromSuperview];
    self.iconADView = nil;
    self.playerStateStore.state.iconADIsPlaying = NO;
    [self.timer invalidate];
}

- (void)ttv_playPasterADs:(NSArray *)pasters completionBlock:(void(^)(void))block
{
    if (self.fadePlayerLastFrameAction) {
        self.playerStateStore.state.pasterFadeAnimationExecuting = YES;
        self.fadePlayerLastFrameAction(^{
            CGFloat duration = [TTVMidInsertADViewController ttv_pasterFadeInTimeInterval] + 0.1f;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.playerStateStore.state.pasterFadeAnimationExecuting = NO;
            });
            
            [self ttv_playPasterADsInternal__:pasters completionBlock:block];
        });
    } else {
        [self ttv_playPasterADsInternal__:pasters completionBlock:block];
    }
}

- (void)ttv_playPasterADsInternal__:(NSArray *)pasters completionBlock:(void(^)(void))block
{
    if (self.pasterADController) {
        [self addSubview:self.pasterADController.view];
        
        //非创意中贴显示进入动效
        if (self.pasterADController.playingADModel.midInsertADInfoModel.guideVideoInfo == nil) {
            self.pasterADController.view.hidden = YES;
            self.pasterADController.playerView.player.playerStateStore.state.forbidLoadingAnimtaion = YES;
            @weakify(self);
            [self.playerLoadingStateDisposable dispose];
            self.playerLoadingStateDisposable = [[[RACObserve(self.pasterADController.playerView.player.playerStateStore, state.loadingState) filter:^BOOL(NSNumber *value) {
                return [value unsignedIntegerValue] == TTVPlayerLoadStatePlayable;
            }] take:1] subscribeNext:^(id x) {
                @strongify(self);
                self.pasterADController.view.hidden = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.pasterADController.playerView.player.playerStateStore.state.forbidLoadingAnimtaion = NO;
                });
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
    
    self.playerStateStore.state.midADIsPlaying = YES;
    __weak typeof(self) wself = self;
    [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:YES];
    [self.pasterADController startPlayVideoList:pasters WithCompletionBlock:^{
        __strong typeof(wself) self = wself;
        [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
        [self.pasterADController.view removeFromSuperview];
        self.pasterADController = nil;
        self.playerStateStore.state.midADIsPlaying = NO;
        if (block) {
            block();
        }
    }];
}

- (void)ttv_jumpToDetailAD:(TTVMidInsertADModel *)adModel {
    
    if (adModel.type == TTVMidInsertADPageTypeAPP) {
        if (self.playerStateStore.state.isFullScreen) {
            (!_rotateScreenAction) ?: _rotateScreenAction(NO, NO, nil);
        }
        [TTVMidInsertADTracker sendRealTimeDownloadWithModel:adModel];
        [TTVMidInsertADTracker sendIconADClickEventForADModel:adModel duration:self.playerStateStore.state.currentPlaybackTime * 1000 isInDetail:[self isInDetail] extra:@{@"has_v3": @"1"}];
        [[SSAppStore shareInstance] openAppStoreByActionURL:adModel.midInsertADInfoModel.downloadURL itunesID:adModel.midInsertADInfoModel.appleID presentController:[TTUIResponderHelper correctTopViewControllerFor: self.superview]];
    }
    
    if (adModel.type == TTVMidInsertADPageTypeWeb) {
        TTVMidInsertADInfoModel *model = adModel.midInsertADInfoModel;
        if (isEmptyString(model.openURL) && isEmptyString(model.webURL)) {
            
            return;
        }
        
        NSURL *url;
        // openURL 优先级高于 webURL;
        if (!isEmptyString(model.openURL)) {
            
            url = [TTStringHelper URLWithURLString:model.openURL];
            
        } else if (!isEmptyString(model.webURL)) {
            
            url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{ @"url" : model.webURL}];
        }
        
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            if (self.playerStateStore.state.isFullScreen) {
                (!_rotateScreenAction) ?: _rotateScreenAction(NO, NO, nil);
            }
            
            @weakify(self);
            TTAppPageCompletionBlock block = ^(id obj) {
                @strongify(self);
                [self.playerStateStore sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
            };
            
            [self.playerStateStore sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
            NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:2];
            condition[@"completion_block"] = [block copy];
            condition[@"log_extra"] = model.logExtra;
            [TTVMidInsertADTracker sendIconADClickEventForADModel:adModel duration:self.playerStateStore.state.currentPlaybackTime * 1000 isInDetail:[self isInDetail] extra:nil];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(condition)];
        }
    }
}

- (void)ttv_updateIconADFrameWithShowToolBarAnimated:(BOOL)animated {
    
    if (!self.iconADView) {
        return ;
    }
    
    if (self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateDidShow) {
        [self.iconADView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(-40.f);
            make.left.mas_offset(15.f);
        }];
    }
    
    if (self.playerStateStore.state.toolBarState == TTVPlayerControlViewToolBarStateDidHidden) {
        [self.iconADView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(-15.f);
            make.left.mas_offset(15.f);
        }];
    }
    
    NSTimeInterval duration = (animated) ? .25f: .0f;
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - TTVPasterADDelegate
- (BOOL)isMovieFullScreen {
    
    return self.playerStateStore.state.isFullScreen;
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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.playerStateStore.state.iconADIsPlaying &&
        CGRectContainsPoint(self.iconADView.frame, point)) {
        return YES;
    }
    
    if (self.playerStateStore.state.midADIsPlaying) {
        
        return [super pointInside:point withEvent:event];
    }
    
    return NO;
}

#pragma mark - getter
- (TTVMidInsertADService *)midInsertADService {
    
    if (!_midInsertADService) {
        
        _midInsertADService = [[TTVMidInsertADService alloc] init];
    }
    
    return _midInsertADService;
}

@end
