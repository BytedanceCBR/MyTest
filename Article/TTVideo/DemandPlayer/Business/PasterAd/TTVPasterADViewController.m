//
//  TTVPasterADViewController.m
//  Article
//
//  Created by Dai Dongpeng on 5/25/16.
//
//

#import "TTVPasterADViewController.h"
#import "ExploreMovieView.h"
#import "TTVPasterADModel.h"
#import "ExploreVideoModel.h"
#import "TTVPasterADNatantView.h"
#import "TTRoute.h"
#import "TTURLUTils.h"
#import "SSURLTracker.h"    
#import "TTVPasterADTracker.h"
#import "TTVPasterADService.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVPlayerCacheProgressController.h"
#import <Masonry.h>
#import "SSAppStore.h"

#import "TTVPlayVideo.h"
#import "TTVAdActionButtonCommand.h"
#import "TTVVideoPlayerModel.h"
#import "TTVVideoPlayerStateStore.h"
static NSString *const kEmbededADKey = @"embeded_ad";
static const CGFloat kTTVPasterFadeInTimeInterval = 0.2f;
NSString *const kKPWebViewControllerWillDisAppear = @"kKPWebViewControllerWillDisAppear";

@interface TTVPasterADViewController () <TTVPasterADNatantViewDelegate, TTVDemandPlayerDelegate>

@property (nonatomic, strong) TTVPlayVideo *playerView;
@property (nonatomic, strong) TTShowImageView  *imageView;
@property (nonatomic, strong) NSMutableArray <TTVPasterADModel *> *playingList;

@property (nonatomic, copy) TTVPasterADPlayCompletionBlock pasterADCompletionBlock;
@property (nonatomic, strong) TTVPasterADNatantView *natantView;
@property (nonatomic, assign) BOOL shouldPause;
@property (nonatomic, strong) TTVPasterADTracker *adTracker;

@property (nonatomic, strong) TTVPasterADService *pasterADService;

@property (nonatomic, strong) TTVideoRotateScreenController *rotateController;

@property (nonatomic, assign) BOOL clickedSkipBtn; // 上报用

@property (nonatomic, assign) BOOL clickedDownloadBtn; // 记录下载按钮点击状态 用于过滤notification
@property (nonatomic, strong) RACDisposable *pasterADWillStartDisposable;

@end

@implementation TTVPasterADViewController

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.adTracker sendShowOverWithExtra:nil duration:self.natantView.durationTime isInDetail:[self isInDetail]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.adTracker = [[TTVPasterADTracker alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kplViewControllerWillDisAppear) name:kKPWebViewControllerWillDisAppear object:nil];
    }
    return self;
}

- (void)setupPasterADData:(TTVPasterADURLRequestInfo *)requestInfo completionBlock:(void (^)(BOOL))block {
    
    [self.adTracker sendRequestDataWithExtra:nil duration:0 isInDetail:[self isInDetail]];
    
    __weak typeof (self) wself = self;
    [self.pasterADService fetchPasterADInfoWithRequestInfo:requestInfo completion:^(id response, NSError *error) {
       
        __strong typeof(wself) self = wself;
        
        self.playingADModel = ([response isKindOfClass:[TTVPasterADModel class]]) ? response: nil;
        
        BOOL success = NO;
        
        if (self.playingADModel) {
            
            success = YES;
            
            [self setPlayingListWithArray:[@[self.playingADModel] mutableCopy]];
            
            [self setupSubViews];
            
        } else {
            
            [self.adTracker sendResponsErrorWithExtra:nil duration:0 isInDetail:[self isInDetail]];
        }
        
        (!block) ?: block(success);
    }];
}

- (void)setupSubViews
{
    if (self.playingADModel.style == TTVPasterADStyleImage) {
        
        self.imageView = [[TTShowImageView alloc] initWithFrame:self.view.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.imageView.imageInfosModel = [[TTImageInfosModel alloc] initWithDictionary:self.playingADModel.videoPasterADInfoModel.imageList.firstObject];
        [self.imageView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [self.imageView removeGestureRecognizer:obj];
        }];
        
        [self.view addSubview:self.imageView];
        
    } else if (self.playingADModel.style == TTVPasterADStyleVideo) {
    
        TTVVideoPlayerModel *playerModel = [self playerModelWithPasterADModel:self.playingADModel];
        self.playerView = [[TTVPlayVideo alloc] initWithFrame:self.view.bounds playerModel:playerModel];
        self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:playerModel.videoID];
        self.playerView.player.delegate = self;
        self.playerView.player.enableRotate = NO;//贴片广告播放器禁用转屏 使用原视频播放器整体监控转屏
        [self.playerView.player readyToPlay];
        [self.playerView.player removeControlView];
        [self.view addSubview:self.playerView];
        self.adTracker.playVideo = self.playerView;
    }
}

- (TTVPlayerModel *)playerModelWithPasterADModel:(TTVPasterADModel *)pasterADModel {
    
    TTVVideoPlayerModel *playerModel = [[TTVVideoPlayerModel alloc] init];
    playerModel.videoID = pasterADModel.videoPasterADInfoModel.videoInfo.videoID;
    playerModel.groupID = pasterADModel.videoPasterADInfoModel.videoInfo.videoGroupID;
    playerModel.aggrType = 0;
    return playerModel;
}

#pragma mark - Public Method

- (void)startPlayVideoList:(NSArray *)videoList WithCompletionBlock:(TTVPasterADPlayCompletionBlock)completion
{
    self.pasterADCompletionBlock = completion;
    
    [self playNextADModel];
}

- (BOOL)isPlayingMovie
{
    return (self.playerView.player.context.playbackState == TTVVideoPlaybackStatePlaying);
}

- (BOOL)isPlayingImage
{
    return (self.natantView && self.imageView && self.playingADModel);
}

- (BOOL)isPaused
{
    return (self.playerView.player.context.playbackState == TTVVideoPlaybackStatePaused);
}

- (void)setIsFullScreen:(BOOL)fullScreen
{
    [self.natantView setIsFullScreen:fullScreen];
}

- (BOOL)isInDetail
{
    if ([self.delegate respondsToSelector:@selector(isInDetail)]) {
        return [self.delegate isInDetail];
    }
    
    return NO;
}

- (BOOL)shouldPauseCurrentAd
{
    return self.shouldPause;
}

- (void)pauseCurrentAD
{
    [self.playerView.player pause];
    [self.natantView pauseTimer];
}

- (void)resumeCurrentAD
{
    if (![self.natantView isTopMostView]) {
        
        return ;
    }
    
    [self.playerView.player play];
    [self.natantView resumeTimer];
}

- (void)stopCurrentADVideo
{
    [self setPlayingListWithArray:nil];
    [self.playerView.player stopWithFinishedBlock:nil];
}

#pragma mark - TTVDemandPlayerDelegate

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action {
    
    if ([action isKindOfClass:[TTVPlayerStateAction class]]) {
        
        switch (action.actionType) {
            case TTVPlayerEventTypeTrafficFreeFlowPlay:
            case TTVPlayerEventTypeTrafficPlay: {
                
                [self.natantView resumeTimer];
                self.natantView.hidden = NO;
            }
                break;
            case TTVPlayerEventTypeTrafficFreeFlowSubscribeShow:
            case TTVPlayerEventTypeTrafficWillOverFreeFlowShow:
            case TTVPlayerEventTypeTrafficShow:{
                [self.natantView pauseTimer];
                self.natantView.hidden = YES;
            }
                break;
            case TTVPlayerEventTypeLoadStateChanged: {
                if (self.playerView) {
                    if (self.playerView.player.context.loadState == TTVPlayerLoadStatePlayable) {
                        [self.natantView resumeTimer];
                    } else {
                        [self.natantView pauseTimer];
                    }
                }
            }
                break;
            case TTVPlayerEventTypePlayerPause: {
                [self.natantView pauseTimer];
            }
                break;
            case TTVPlayerEventTypePlayerResume: {
                [self.natantView resumeTimer];
            }
                break;
            case TTVPlayerEventTypeTrafficFreeFlowSubscribe: {
                if ([self.delegate respondsToSelector:@selector(sendHostPlayerPauseAction)]) {
                    [self.delegate sendHostPlayerPauseAction];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    return self.view.bounds;
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {
    
    switch (state) {
        case TTVVideoPlaybackStateFinished:
        {
            [self pasterADVideoPlayFinish:YES];
        }
            break;
        case TTVVideoPlaybackStateBreak:
        {
            [self pasterADVideoPlayFinish:NO];
        }
            break;
            
        default:
            break;
    }
}

- (void)pasterADVideoPlayFinish:(BOOL)playEnd {
    
    NSInteger percent = [self p_getPlayPercent:playEnd];
    
    if (!self.natantView || percent < 0) {
        
        return ;
    }
    
    NSDictionary *extra = @{@"percent" : @(percent)};
    if (self.natantView.durationTime > 0 && !playEnd) {
        
        [self.adTracker sendPlayBreakEventWithExtra:extra duration:[self p_getDuration] isInDetail:[self isInDetail] effectivePlay:[self p_isEffectivePlay]];
        
    } else {
        // 播放完成 以倒计时为准
        NSDictionary *extra = @{@"percent" : @([self p_getPlayPercent:YES])};
        [self.adTracker sendPlayOverEventWithExtra:extra duration:[self p_getDuration] isInDetail:[self isInDetail]];
    }
    
    if (self.clickedSkipBtn) {
        
        [self.adTracker sendSkipEventWithExtra:nil duration:[self p_getDuration] isInDetail:[self isInDetail] effectivePlay:[self p_isEffectivePlay]];
    }
    
    [self playNextADModel];
}

- (void)pasterADWillStart
{
    TTVPasterADNatantView *natantView = [[TTVPasterADNatantView alloc] initWithFrame:self.view.bounds pasterADModel:self.playingADModel];
    natantView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    natantView.delegate = self;
    if (self.playerView != nil && self.playerView.player.playerStateStore.state.loadingState != TTVPlayerLoadStatePlayable) {
        [natantView pauseTimer];
    }

    if (self.natantView) {
        [self.natantView removeFromSuperview];
    }
    
    [self.imageView addSubview:natantView];
    [self.playerView addSubview:natantView];
    
    BOOL pasterFadeAnimationEnabled =  [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_end_patch_animation_enable" defaultValue:@NO freeze:NO] boolValue];
    if (pasterFadeAnimationEnabled) {
        natantView.alpha = 0.0f;
        natantView.superview.alpha = 0.0f;
        [UIView animateWithDuration:kTTVPasterFadeInTimeInterval delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            natantView.alpha = 1.0f;
            natantView.superview.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
        natantView.superview.transform = CGAffineTransformMakeScale(1.05, 1.05);
        [UIView animateWithDuration:0.8f customTimingFunction:CustomTimingFunctionExpoOut animation:^{
            natantView.superview.transform = CGAffineTransformIdentity;
        }];
    }
    
    self.natantView = natantView;
    
    BOOL isFullScreen = NO;
    if ([self.delegate respondsToSelector:@selector(isMovieFullScreen)]) {
        isFullScreen = [self.delegate isMovieFullScreen];
    }
    [self setIsFullScreen:isFullScreen];
    [self.adTracker sendPlayStartEventWithExtra:nil duration:0 isInDetail:[self isInDetail]];
}

#pragma mark - TTVPasterADNatantViewDelegate

- (void)fullScreenbuttonClicked:(UIButton *)button toggledTo:(BOOL)fullScreen
{
    if ([self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        [self.delegate videoPasterADViewControllerToggledToFullScreen:fullScreen animationed:YES completionBlock:nil];
    }
    if (fullScreen) {
        [self.adTracker sendFullscreenWithExtra:nil duration:0 isInDetail:[self isInDetail]];
    }
}

- (void)skipButtonClicked:(UIButton *)button
{
    self.clickedSkipBtn = YES;
    
    if (self.playingADModel.style == TTVPasterADStyleImage) {
        [self.adTracker sendSkipEventWithExtra:nil duration:[self p_getDuration] isInDetail:[self isInDetail] effectivePlay:[self p_isEffectivePlay]];
    }

    [self endPlayingPasterAD];
}

static UINavigationController *nav;

- (void)showDetailButtonClicked:(UIButton *)button
{
    if (self.playingADModel.type == TTVPasterADPageTypeAPP) {
        [self jumpToDownloadAppFromDetailButton:YES];
    }
    
    if (self.playingADModel.type == TTVPasterADPageTypeWeb) {
        [self jumpToADDetailPageFromDetailButton:YES];
    }
}

- (void)pasterADClicked
{
    if (self.playingADModel.type == TTVideoPasterADPageTypeAPP) {
        [self jumpToDownloadAppFromDetailButton:NO];
    }
    if (self.playingADModel.type == TTVideoPasterADPageTypeWeb) {
        [self jumpToADDetailPageFromDetailButton:NO];
    }
}

- (void)backButtonClicked:(UIButton *)button
{
    [self setIsFullScreen:NO];
    if ([self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:YES completionBlock:nil];
    }
}

- (void)timerOver {
    
    if (self.playingADModel.style == TTVPasterADStyleImage) {
        
        [self playNextADModel];
    } else {
        
        [self endPlayingPasterAD];
    }
}

- (void)pauseTimer {
    
    if ([_delegate respondsToSelector:@selector(setPasterADRotateState:)]) {
        
        [_delegate setPasterADRotateState:NO];
    }
}

- (void)resumeTimer {
    
    if ([_delegate respondsToSelector:@selector(setPasterADRotateState:)]) {
        
        [_delegate setPasterADRotateState:YES];
    }
}

- (void)replayButtonClicked:(UIButton *)button {
    
    [self.adTracker sendClickReplayButtonEventWithExtra:nil duration:0 isInDetail:[self isInDetail]];
    
    if ([self.delegate respondsToSelector:@selector(replayOriginalVideo)]) {
        
        [self.delegate replayOriginalVideo];
    }

    [self endPlayingPasterAD];
}

#pragma mark - Private Method

- (void)setPlayingListWithArray:(NSMutableArray *)array
{
    self.playingList = array;
}

- (void)setPlayingADModel:(TTVPasterADModel *)playingADModel
{
    if (_playingADModel != playingADModel) {
        _playingADModel = playingADModel;
    }
    self.adTracker.adModel = playingADModel;
}

- (TTVPasterADModel *)popADModel
{
    if (self.playingList.count > 0) {
        TTVPasterADModel *model = self.playingList.firstObject;
        [self.playingList removeObject:model];
        self.playingADModel = model;
        return model;
    }
    
    self.playingADModel = nil;
    return nil;
}

- (void)startPlayADmodel:(TTVPasterADModel *)adModel
{
    if (!adModel) {
        if (self.pasterADCompletionBlock) {
            self.pasterADCompletionBlock();
        }
        return;
    }
    
    [self.pasterADWillStartDisposable dispose];
    @weakify(self);
    self.pasterADWillStartDisposable = [[[RACObserve(self.view, hidden) ignore:@YES] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [self pasterADWillStart];
    }];
    
    if (adModel.style == TTVPasterADStyleVideo) {
        
        [self.playerView.player play];
    }
}

- (void)playNextADModel
{
    TTVPasterADModel *model = [self popADModel];
    [self startPlayADmodel:model];
}

- (void)jumpToDownloadAppFromDetailButton:(BOOL)isFrom {

    if (self.playingADModel.type != TTVPasterADPageTypeAPP) {
        
        return ;
    }
    
    self.shouldPause = YES;
    [self.playerView.player pause];
    [self.natantView pauseTimer];
    
    self.clickedDownloadBtn = YES;
    [self.adTracker sendWithRealTimeDownload];
    if (isFrom) {
        [self.adTracker sendDownloadClickButtonEventWithExtra:nil duration:0 isInDetail:[self isInDetail]];
    } else {
        [self.adTracker sendClickADEventWithExtra:nil duration:0 isInDetail:[self isInDetail]];
    }
    
    if ([self.natantView isFullScreen] && [self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        WeakSelf;
        [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:NO completionBlock:^(BOOL finished) {
            StrongSelf;
            [[SSAppStore shareInstance] openAppStoreByActionURL:self.playingADModel.videoPasterADInfoModel.downloadURL itunesID:self.playingADModel.videoPasterADInfoModel.appleID presentController:[TTUIResponderHelper correctTopViewControllerFor: self.view.superview]];
        }];
        [self setIsFullScreen:NO];
        
    } else {
        [[SSAppStore shareInstance] openAppStoreByActionURL:self.playingADModel.videoPasterADInfoModel.downloadURL itunesID:self.playingADModel.videoPasterADInfoModel.appleID presentController:[TTUIResponderHelper correctTopViewControllerFor: self.view.superview]];
    }
}
- (BOOL)openWebWithTag:(NSString *)tag
{
    TTVPasterADInfoModel *model = self.playingADModel.videoPasterADInfoModel;
    
    if (isEmptyString(model.openURL) && isEmptyString(model.webURL)) {
        return NO;
    }
    
    TTVADWebModel *adModel = [[TTVADWebModel alloc] init];
    adModel.open_url = model.openURL;
    adModel.web_url = model.webURL;
    adModel.web_title = model.webTitle;
    adModel.log_extra = model.logExtra;
    adModel.ad_id = [NSString stringWithFormat:@"%@", model.adID];
    
    TTAppPageCompletionBlock block = ^(id obj) {
        [self.playerView.player play];
        self.shouldPause = NO;
        [self.natantView resumeTimer];
    };

    if ([TTAdAction handleDetailActionModel:adModel sourceTag:kEmbededADKey completeBlock:block] ) {
        NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
        [applinkParams setValue:adModel.log_extra forKey:@"log_extra"];
        if (!isEmptyString(adModel.web_url) && isEmptyString(adModel.open_url)) {
            NSString *adIDStr = [NSString stringWithFormat:@"%@",model.adID];
            wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", adIDStr, nil, applinkParams);
        }
        return YES;
    }
    return NO;
}

- (void)jumpToADDetailPageFromDetailButton:(BOOL)isFrom
{
    if ([self openWebWithTag:@"embeded_ad"]) {
        self.shouldPause = YES;
        
        if ([self.natantView isFullScreen] && [self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
            [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:NO completionBlock:nil];
            [self setIsFullScreen:NO];
        }
        [self.playerView.player pause];//百万英雄后贴 进入直播后返回继续播放
        [self.natantView pauseTimer];
        
        if (isFrom) {
            [self.adTracker sendDetailClickButtonEventWithExtra:nil duration:0 isInDetail:[self isInDetail]];
        } else {
            [self.adTracker sendClickADEventWithExtra:nil duration:0 isInDetail:[self isInDetail]];
        }
    }
}

- (void)endPlayingPasterAD {
    
    [self setPlayingListWithArray:nil];
    
    if (TTVPasterADStyleVideo == self.playingADModel.style) {
        [self stopCurrentADVideo];
    }
    
    [self playNextADModel];
}

- (BOOL)p_isEffectivePlay {
    
    BOOL effective = YES;
    
    if ([self p_getDuration] < self.playingADModel.videoPasterADInfoModel.videoInfo.effectivePlayTime.integerValue) {
        
        effective = NO;
    }
    
    return effective;
}

- (NSInteger)p_getDuration {
    
    return ([self.playingADModel.videoPasterADInfoModel.duration integerValue] - self.natantView.durationTime);
}

- (NSInteger)p_getPlayPercent:(BOOL)playEnd {
    
    NSInteger percent;
    if (playEnd) {
        percent = 100;
    } else {
        NSTimeInterval currentPlaybackTime = self.playerView.player.context.currentPlaybackTime;
        
        NSTimeInterval duration = self.playerView.player.context.duration;
        if (isnan(duration) || duration == NAN || duration <= 0 || isnan(currentPlaybackTime) || currentPlaybackTime == NAN || currentPlaybackTime < 0) {
            percent = -1;
        } else {
            percent = (currentPlaybackTime / duration ) * 100;
            percent = percent > 100 ? 100 : percent;
        }
    }
    
    return percent;
}

// 关闭 App Store 恢复广告播放
- (void)skStoreViewDidDisappear:(NSNotification*)notify {
    if (self.clickedDownloadBtn && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self.playerView.player play];
        self.shouldPause = NO;
        [self.natantView resumeTimer];
        
        self.clickedDownloadBtn = NO;
    }
}

- (void)applicationBecomeActive{
    self.shouldPause = NO;
    [self.natantView resumeTimer];
}

-  (void)kplViewControllerWillDisAppear{
    [self.playerView.player play];
    self.shouldPause = NO;
    [self.natantView resumeTimer];
}

#pragma mark - getter 
- (TTVPasterADService *)pasterADService {
    
    if (!_pasterADService) {
        
        _pasterADService = [TTVPasterADService new];
    }
    
    return _pasterADService;
}

+ (CGFloat)ttv_pasterFadeInTimeInterval
{
    BOOL pasterFadeAnimationEnabled =  [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_end_patch_animation_enable" defaultValue:@NO freeze:NO] boolValue];
    return pasterFadeAnimationEnabled ? kTTVPasterFadeInTimeInterval : 0.0f;
}

@end
