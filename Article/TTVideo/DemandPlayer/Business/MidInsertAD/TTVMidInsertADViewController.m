//
//  TTVMidInsertADViewController.m
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "TTVMidInsertADViewController.h"
#import "TTRoute.h"
#import "TTURLUTils.h"
#import "SSURLTracker.h"
//#import "TTVPasterADTracker.h"
#import "TTVPasterADService.h"
#import "TTVMidInsertADModel.h"
#import "TTVMidInsertADNatantView.h"
#import "TTVMidInsertADService.h"
#import <Masonry.h>
#import "SSAppStore.h"
#import "TTVPlayVideo.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVMidInsertADTracker.h"
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVPlayerCacheProgressController.h"
#import "TTVVideoPlayerModel.h"
#import "TTVVideoPlayerStateStore.h"

static NSString *const kEmbededADKey = @"embeded_ad";
static const CGFloat kTTVPasterFadeInTimeInterval = 0.2f;

@interface TTVMidInsertADViewController () <TTVMidInsertADNatantViewDelegate, TTVDemandPlayerDelegate>

@property (nonatomic, strong) TTVPlayVideo *playerView;
//@property (nonatomic, strong) TTShowImageView  *imageView;
@property (nonatomic, strong) NSMutableArray <TTVMidInsertADModel *> *playingList;

@property (nonatomic, copy) TTVMidInsertADPlayCompletionBlock midInsertADCompletionBlock;
@property (nonatomic, strong) TTVMidInsertADNatantView *natantView;
@property (nonatomic, assign) BOOL shouldPause;
//@property (nonatomic, strong) TTVPasterADTracker *adTracker;

@property (nonatomic, assign) BOOL clickedSkipBtn; // 上报用

@property (nonatomic, assign) BOOL clickedDownloadBtn; // 记录下载按钮点击状态 用于过滤notification
@property (nonatomic, assign) BOOL isShowingCPTGuideAD;  //是否显示的是创意中贴
@property (nonatomic, strong) RACDisposable *pasterADWillStartDisposable;

@end

@implementation TTVMidInsertADViewController

#pragma mark - Life Cycle

- (void)dealloc
{
//    [self.adTracker sendShowOverWithExtra:nil duration:self.natantView.durationTime isInDetail:[self isInDetail]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
    }
    return self;
}


- (void)setupMidInsertADDataWithADModel:(TTVMidInsertADModel *)adModel {
    
    if (![adModel isKindOfClass:[TTVMidInsertADModel class]]) {
        
        return;
    }
    
    self.playingADModel = adModel;
    [self setPlayingListWithArray:[@[self.playingADModel] mutableCopy]];
    [self setupSubViews];
}

- (void)setupSubViews
{
    if (self.playingADModel.style == TTVMidInsertADStyleImage) {
        
//        self.imageView = [[TTShowImageView alloc] initWithFrame:self.view.bounds];
//        self.imageView.imageInfosModel = [[TTImageInfosModel alloc] initWithDictionary:self.playingADModel.videoPasterADInfoModel.imageList.firstObject];
//        [self.imageView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            
//            [self.imageView removeGestureRecognizer:obj];
//        }];
//        
//        [self.view addSubview:self.imageView];
        
    } else if (self.playingADModel.style == TTVMidInsertADStyleVideo) {
        
        TTVVideoPlayerModel *playerModel = [self playerModelWithPasterADModel:self.playingADModel];
        self.playerView = [[TTVPlayVideo alloc] initWithFrame:self.view.bounds playerModel:playerModel];
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:playerModel.videoID];
        self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.playerView.player.delegate = self;
        self.playerView.player.enableRotate = NO;//贴片广告播放器禁用转屏 使用原视频播放器整体监控转屏
        [self.playerView.player readyToPlay];
        [self.view addSubview:self.playerView];
    }
}

- (TTVVideoPlayerModel *)playerModelWithPasterADModel:(TTVMidInsertADModel *)pasterADModel {
    
    TTVVideoPlayerModel *playerModel = [[TTVVideoPlayerModel alloc] init];
    TTVPasterADVideoInfoModel *videoInfo = pasterADModel.midInsertADInfoModel.guideVideoInfo ?: pasterADModel.midInsertADInfoModel.videoInfo;
    playerModel.videoID = videoInfo.videoID;
    playerModel.groupID = videoInfo.videoGroupID;
    playerModel.aggrType = 0;
    playerModel.disableFinishUIShow = YES;
    
    return playerModel;
}

#pragma mark - Public Method

- (void)startPlayVideoList:(NSArray *)videoList WithCompletionBlock:(TTVMidInsertADPlayCompletionBlock)completion
{
    self.midInsertADCompletionBlock = completion;
    TTVMidInsertADModel *model = self.playingList.firstObject;
    self.isShowingCPTGuideAD = model.midInsertADInfoModel.guideVideoInfo != nil;
    
    [self playNextADModel];
}

- (BOOL)isPlayingMovie
{
    return (self.playerView.player.context.playbackState == TTVVideoPlaybackStatePlaying);
}

- (BOOL)isPlayingImage
{
//    return (self.natantView && self.imageView && self.playingADModel);
    return NO;
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
    [self.playerView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)resumeCurrentAD
{
    [self.playerView.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
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
            
        case TTVVideoPlaybackStatePlaying: {
            [self.natantView resumeTimer];
        }
            break;
            
        case TTVVideoPlaybackStatePaused: {
            [self.natantView pauseTimer];
        }
            break;
        default:
            break;
    }
}

- (void)pasterADVideoPlayFinish:(BOOL)playEnd {
    
    if (!self.playingADModel) {
        return;
    }
    
    NSString *guideVideoID = self.playingADModel.midInsertADInfoModel.guideVideoInfo.videoID;
    
    if (!isEmptyString(guideVideoID) &&
        [self.playerView.playerModel.videoID isEqualToString:guideVideoID]) {
        
        TTVPasterADVideoInfoModel *videoInfo = self.playingADModel.midInsertADInfoModel.videoInfo;
        TTVVideoPlayerModel *playerModel = [[TTVVideoPlayerModel alloc] init];
        playerModel.videoID = videoInfo.videoID;
        playerModel.groupID = videoInfo.videoGroupID;
        playerModel.disableFinishUIShow = self.playerView.playerModel.disableFinishUIShow;
        playerModel.aggrType = 0;
        [self.playerView resetPlayerModel:playerModel];
        
        [self pasterADWillStart];
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:playerModel.videoID];
        [self.playerView.player play];
        
        return ;
    }
    
    NSInteger percent = [self p_getPlayPercent:playEnd];
    
    if (!self.natantView || percent < 0) {
        
        return ;
    }
    
    if (self.natantView.durationTime > 0 && !playEnd) {
        [TTVMidInsertADTracker sendMidInsertADPlayBreakEventForADModel:self.playingADModel duration:[self p_getDuration] effective:[self p_isEffectivePlay] isInDetail:[self isInDetail]];
    } else {
        [TTVMidInsertADTracker sendMidInsertADPlayOverEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail]];
    }
    
    [TTVMidInsertADTracker sendMidInsertADShowOverEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail]];

    
    [self playNextADModel];
}

- (void)pasterADWillStart
{
    [self.playerView.player removeControlView];

    TTVMidInsertADNatantView *natantView = [[TTVMidInsertADNatantView alloc] initWithFrame:self.view.bounds pasterADModel:self.playingADModel];
    natantView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    natantView.delegate = self;
    if (self.playerView && self.playerView.player.playerStateStore.state.loadingState != TTVPlayerLoadStatePlayable) {
        [natantView pauseTimer];
    }
    
    if (self.natantView) {
        [self.natantView removeFromSuperview];
    }
    
//    [self.imageView addSubview:natantView];
    [self.playerView addSubview:natantView];
    
    if (!self.isShowingCPTGuideAD) {
        natantView.alpha = 0.0f;
        natantView.superview.alpha = 0.0f;
        [UIView animateWithDuration:kTTVPasterFadeInTimeInterval delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            natantView.alpha = 1.0f;
            natantView.superview.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
        natantView.superview.transform = CGAffineTransformMakeScale(1.2, 1.2);
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
    [TTVMidInsertADTracker sendMidInsertADPlayEventForADModel:self.playingADModel duration:self.playerView.player.context.currentPlaybackTime * 1000 isInDetail:[self isInDetail]];
    [TTVMidInsertADTracker sendMidInsertADShowEventForADModel:self.playingADModel duration:self.playerView.player.context.currentPlaybackTime * 1000 isInDetail:[self isInDetail]];
}

#pragma mark - TTVPasterADNatantViewDelegate

- (void)fullScreenbuttonClicked:(UIButton *)button toggledTo:(BOOL)fullScreen
{
    if ([self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        [self.delegate videoPasterADViewControllerToggledToFullScreen:fullScreen animationed:YES completionBlock:nil];
        if (fullScreen) {
            [TTVMidInsertADTracker sendMidInsertADFullScreenEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail]];
        }
    }
}

- (void)skipButtonClicked:(UIButton *)button
{
    self.clickedSkipBtn = YES;
    
    [TTVMidInsertADTracker sendMidInsertADClickCloseEventForADModel:self.playingADModel duration:[self p_getDuration] effective:[self p_isEffectivePlay] isInDetail:[self isInDetail]];
    
    [self endPlayingPasterAD];
}

static UINavigationController *nav;

- (void)showDetailButtonClicked:(UIButton *)button
{
    if (self.playingADModel.type == TTVPasterADPageTypeAPP) {
        
        [self jumpToDownloadAppFromDetailButtonClick:YES];
    }
    
    if (self.playingADModel.type == TTVPasterADPageTypeWeb) {
        [self jumpToADDetailPageFromDetailButtonClick:YES];
    }
}

- (void)pasterADClicked
{
    if (self.playingADModel.type == TTVMidInsertADPageTypeAPP) {
        [self jumpToDownloadAppFromDetailButtonClick:NO];
    }
    if (self.playingADModel.type == TTVMidInsertADPageTypeWeb) {
        [self jumpToADDetailPageFromDetailButtonClick:NO];
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

- (void)setPlayingADModel:(TTVMidInsertADModel *)playingADModel
{
    if (_playingADModel != playingADModel) {
        _playingADModel = playingADModel;
    }
}

- (TTVMidInsertADModel *)popADModel
{
    if (self.playingList.count > 0) {
        TTVMidInsertADModel *model = self.playingList.firstObject;
        [self.playingList removeObject:model];
        self.playingADModel = model;
        return model;
    }
    
    self.playingADModel = nil;
    return nil;
}

- (void)startPlayADmodel:(TTVMidInsertADModel *)adModel
{
    if (!adModel) {
        if (self.midInsertADCompletionBlock) {
            self.midInsertADCompletionBlock();
        }
        return;
    }
    
    NSString *adVideoID = self.playingADModel.midInsertADInfoModel.videoInfo.videoID;
    if (!isEmptyString(adVideoID) &&
        [self.playerView.playerModel.videoID isEqualToString:adVideoID]) {
        [self.pasterADWillStartDisposable dispose];
        @weakify(self);
        self.pasterADWillStartDisposable = [[[RACObserve(self.view, hidden) ignore:@YES] take:1] subscribeNext:^(id x) {
            @strongify(self);
            [self pasterADWillStart];
        }];
    } else {
        
        [self.playerView.player removeBottomBarView];
    }
    
    if (adModel.style == TTVPasterADStyleVideo) {
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:self.playerView.player.playerModel.videoID];
        [self.playerView.player play];
    }
}

- (void)playNextADModel
{
    TTVMidInsertADModel *model = [self popADModel];
    [self startPlayADmodel:model];
}

- (void)jumpToDownloadAppFromDetailButtonClick:(BOOL)isFrom {
    
    if (self.playingADModel.type != TTVPasterADPageTypeAPP) {
        
        return ;
    }
    //realtime app click
    [TTVMidInsertADTracker sendRealTimeDownloadWithModel:self.playingADModel];
    if (isFrom) {
        [TTVMidInsertADTracker sendMidInsertADClickDetailEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail] extra:@{@"has_v3": @"1"}];
    } else {
        [TTVMidInsertADTracker sendMidInsertADClickVideoEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail]];
    }
    
    self.shouldPause = YES;
    [self pauseCurrentAD];
    
    self.clickedDownloadBtn = YES;
    
    if ([self.natantView isFullScreen] && [self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        WeakSelf;
        [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:NO completionBlock:^(BOOL finished) {
            StrongSelf;
            [[SSAppStore shareInstance] openAppStoreByActionURL:self.playingADModel.midInsertADInfoModel.downloadURL itunesID:self.playingADModel.midInsertADInfoModel.appleID presentController:[TTUIResponderHelper correctTopViewControllerFor: self.view.superview]];
        }];
        [self setIsFullScreen:NO];
        
    } else {
        [[SSAppStore shareInstance] openAppStoreByActionURL:self.playingADModel.midInsertADInfoModel.downloadURL itunesID:self.playingADModel.midInsertADInfoModel.appleID presentController:[TTUIResponderHelper correctTopViewControllerFor: self.view.superview]];
    }
}

- (void)jumpToADDetailPageFromDetailButtonClick:(BOOL)isFrom
{
    TTVMidInsertADInfoModel *model = self.playingADModel.midInsertADInfoModel;
    
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
        
        self.shouldPause = YES;
        
        if ([self.natantView isFullScreen] && [self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
            
            @weakify(self);
            [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:NO completionBlock:^(BOOL finished) {
                @strongify(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self ttv_jumpToADDetailPageWithURL:url fromDetailButtonClick:isFrom];
                });
            }];
            [self setIsFullScreen:NO];
        } else {
            [self ttv_jumpToADDetailPageWithURL:url fromDetailButtonClick:isFrom];
        }
    }
}

- (void)ttv_jumpToADDetailPageWithURL:(NSURL *)url fromDetailButtonClick:(BOOL)isFrom {
    
    TTAppPageCompletionBlock block = ^(id obj) {
        [self resumeCurrentAD];
        self.shouldPause = NO;
    };

    [self pauseCurrentAD];
    
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:2];
    condition[@"completion_block"] = [block copy];
    condition[@"log_extra"] = self.playingADModel.midInsertADInfoModel.logExtra;
    condition[@"ad_id"] = self.playingADModel.midInsertADInfoModel.adID.stringValue;
    
    if (isFrom) {
        [TTVMidInsertADTracker sendMidInsertADClickDetailEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail] extra:nil];
    } else {
        [TTVMidInsertADTracker sendMidInsertADClickVideoEventForADModel:self.playingADModel duration:[self p_getDuration] isInDetail:[self isInDetail]];
    }
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(condition)];
}

- (void)endPlayingPasterAD {
    
    [self setPlayingListWithArray:nil];
    
    if (TTVPasterADStyleVideo == self.playingADModel.style) {
        [self stopCurrentADVideo];
    }
}

- (BOOL)p_isEffectivePlay {
    
    BOOL effective = YES;
    
    if ([self p_getDuration] < self.playingADModel.midInsertADInfoModel.videoInfo.effectivePlayTime.integerValue) {
        
        effective = NO;
    }
    
    return effective;
}

- (NSInteger)p_getDuration {
    
    return (self.playingADModel.midInsertADInfoModel.displayTime.integerValue / 1000.0 - self.natantView.durationTime) * 1000.0;
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
//        [self.playerView.player play];
        [self resumeCurrentAD];
        self.shouldPause = NO;
//        [self.natantView resumeTimer];
        
        self.clickedDownloadBtn = NO;
    }
}

+ (CGFloat)ttv_pasterFadeInTimeInterval
{
    return kTTVPasterFadeInTimeInterval;
}

@end
