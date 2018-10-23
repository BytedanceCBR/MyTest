//
//  TTVDetailPlayControl.m
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import "TTVDetailPlayControl.h"
#import "TTAccountLoginManager.h"
#import "SSAppStore.h"
#import "KVOController.h"
#import "TTDetailContainerViewController.h"
#import "TTTrackerProxy.h"
#import "TTVideoTabBaseCellPlayControl.h"
#import "TTVPlayVideo.h"
#import "TTVPlayerStateStore.h"
#import "ExploreMovieView.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVPasterPlayer.h"
#import "TTVPlayerTipAdNewCreator.h"
#import "TTVPlayerTipAdOldCreator.h"
#import "TTVPlayerTipAdOldFinish.h"
//#import "TTRedPacketManager.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerUrlTracker.h"
//#import "TTThemeImageView.h"
#import "ExploreOrderedADModel+TTVADSupport.h"
#import "ExploreOrderedADModel+TTVSupport.h"
#import "TTVideoDetailHeaderPosterView.h"
#import "TTVPlayVideo.h"
#import "VideoFeed.pbobjc.h"
#import "TTVMoviePlayerControlFinishAdEntity.h"
#import "TTVPlayerTipShareCreater.h"
#import "TTVPlayerTipRelatedCreator.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTAdAppointAlertView.h"
#import "ExploreOrderedData.h"
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"

#import "TTADVideoMZTracker.h"
#import "TTVCommodityView.h"
#import "TTVCommodityButtonView.h"
#import "TTVCommodityFloatView.h"
#import "TTVPasterPlayer.h"
#import "TTVMidInsertADPlayer.h"
#import "AKAwardCoinVideoMonitorManager.h"
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);
extern BOOL ttvs_isPlayerShowRelated(void);

@interface TTVDetailPlayControl ()<TTVDemandPlayerDelegate, TTVCommodityViewDelegate ,TTVCommodityButtonViewDelegate>
@property (nonatomic, assign) BOOL movieViewInitiated;
@property (nonatomic, assign) BOOL isInactive;
@property (nonatomic, strong) TTVPlayVideo *movieView;
@property(nonatomic, strong)TTVDemandPlayerContext *context;
@property(nonatomic, weak)TTVDetailContentEntity *entity;
@property (nonatomic, strong) TTVCommodityView *commodityView;
@end


@implementation TTVDetailPlayControl

- (void)dealloc
{
    //不能置空！！！这个delegate已经赋值给别人了
    //_movieView.player.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //在回到feed后继续播放的时候不能调用 stop
    if (self.movieView.superview == self.shareMovie.posterView) {
        [self.movieView stop];
        [self.movieView removeFromSuperview];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
        [self addMovieViewObserver];
        self.isInactive = NO;
    }
    return self;
}

- (void)setDoubleTap666Delegate:(id<TTVPlayerDoubleTap666Delegate>)doubleTap666Delegate {
    _doubleTap666Delegate = doubleTap666Delegate;
    self.movieView.player.doubleTap666Delegate = doubleTap666Delegate;
}

- (void)setDetailStateStore:(TTVDetailStateStore *)detailStateStore
{
    if (detailStateStore != _detailStateStore) {
        self.entity = detailStateStore.state.entity;
        [self.KVOController unobserve:self.detailStateStore.state];
        [_detailStateStore unregisterForActionClass:[TTVDetailStateAction class] observer:self];
        _detailStateStore = detailStateStore;
        [_detailStateStore registerForActionClass:[TTVDetailStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (BOOL)enableRotate
{
    return !self.detailStateStore.state.isChangingMovieSize && !self.detailStateStore.state.isChangingMovieSize && ![self.videoInfo detailShowPortrait];
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.detailStateStore.state keyPath:@keypath(self.detailStateStore.state,forbidLayout) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self.movieView.player setEnableRotate:[self enableRotate]];
        self.movieShotView.forbidLayout = self.detailStateStore.state.forbidLayout;
    }];
    
    [self.KVOController observe:self.detailStateStore.state keyPath:@keypath(self.detailStateStore.state,isChangingMovieSize) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self.movieView.player setEnableRotate:[self enableRotate]];
    }];
}

#pragma mark TTVDemandPlayerDelegate

- (void)playerLoadingState:(TTVPlayerLoadState)state
{
    
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    ExploreOrderedData *orderData = [[ExploreOrderedData alloc] initWithArticle:(Article *)self.videoInfo];
    if (state == TTVVideoPlaybackStatePlaying) {
        self.movieBanner.hidden = YES;
        [self ttv_showPrePlayBtnWithBannerHeight:0];
        if ([self.movieView isAdMovie] && self.enableTrackSDK == 1) {
            if (self.detailStateStore.state.videoProgress > 0) {
                //这里判断是否要根据跳转的参数seek到一个进度
                [self.movieView.player seekVideoToProgress:self.detailStateStore.state.videoProgress complete:^(BOOL success) {
                }];
                self.detailStateStore.state.videoProgress = 0;
            }
            [[TTADVideoMZTracker sharedManager] mzTrackVideoUrls:orderData.adPlayTrackUrls adView:self.movieView];
        }
    } else if (state == TTVVideoPlaybackStateFinished) {
        self.movieBanner.hidden = NO;
        [self.movieBanner sendShowEvent];
        if ([self.movieView isAdMovie]) {
            if (self.enableTrackSDK == 1 && [TTADVideoMZTracker sharedManager].trackSDKView) {
                [[TTADVideoMZTracker sharedManager] mzStopTrack];
            }
            if (self.movieView.playerModel.isLoopPlay) {
                //广告视频自动播放
                [self.movieView.player setLogoImageViewHidden:YES];
                [self.movieView.player play];
            }
        }
        // 播放上一个按钮
        [self ttv_showPrePlayBtnWithBannerHeight:(self.movieBanner.hidden)? 0: self.movieBanner.height];
    }
}

- (void)playerOrientationState:(BOOL)isFullScreen
{
    self.detailStateStore.state.isFullScreen = isFullScreen;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]]) {
        switch (action.actionType) {
            case TTVPlayerEventTypeControlViewClickScreen:{
                [self ttv_showPrePlayBtnWithBannerHeight:0];
            }
                break;
            case TTVPlayerEventTypeFinishUIShare:{
                [self videoOverShareButtonClicked];
            }
                break;
            case TTVPlayerEventTypeFinishMore:{
                [self videoOverMoreButtonClicked];
            }
                break;
            case TTVPlayerEventTypePlayingMore:{
                [self playingMoreButtonClicked];
            }
                break;
            case TTVPlayerEventTypePlayingShare:{
                [self playingShareButtonClicked];
            }
                break;
            case TTVPlayerEventTypeFinishDirectShare:{
                if ([action.payload isKindOfClass:[NSString class]]) {
                    [self directShareActionWithActivityType:action.payload]; 
                }
            }
                break;
            case TTVPlayerEventTypePlayingDirectShare:{
                if ([action.payload isKindOfClass:[NSString class]]) {
                    [self playingDirectShareActionWithActivityType:action.payload];
                }
            }
                break;
            case TTVPlayerEventTypeTrafficPlay:{
                self.movieBanner.hidden = YES;
            }
                break;
            case TTVPlayerEventTypeControlViewClickFullScreenButton:
                [self fullScreenButtonClicked:action];
                break;
                
            default:
                break;
        }
    }else if ([action isKindOfClass:[TTVDetailStateAction class]]){
        
    }

}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerMovieViewFrameAfterExitFullscreen)]) {
        return [self.delegate ttv_playerControlerMovieViewFrameAfterExitFullscreen];
    }
    return CGRectZero;
}

#pragma mark - Setters

- (void)setMovieFrame:(CGRect)movieFrame
{
    if (!CGRectEqualToRect(_movieFrame, movieFrame)) {
        _movieFrame = movieFrame;
        self.movieView.frame = self.movieFrame;
    }
}

- (void)setShareMovie:(TTVideoShareMovie *)shareMovie
{
    if (_shareMovie != shareMovie) {
        _shareMovie = shareMovie;
        if (!self.shareMovie.posterView) {
            self.shareMovie.posterView = [self addMovieShotView];
            [self.shareMovie.posterView removeAllActions];
            [self.shareMovie.posterView.playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([self.shareMovie.movieView isKindOfClass:[TTVPlayVideo class]]) {
            self.movieView = (TTVPlayVideo *)self.shareMovie.movieView;
        }
    }
}

- (void)configMovieView
{
    self.movieView.player.muted = NO;
    self.movieView.player.isInDetail = YES;
    self.movieView.player.showTitleInNonFullscreen = NO;
}

- (void)setMovieView:(TTVPlayVideo *)movieView
{
    if (_movieView != movieView) {
        _movieView = movieView;
        [self configMovieView];
        _movieView.player.delegate = self;
        self.context = movieView.player.context;
        self.shareMovie.movieView = _movieView;
    }
}

- (void)updateFrame
{
    [self.movieView layoutIfNeeded];
    [self.movieShotView updateFrame];
}

- (float)watchPercent
{
    return self.context.duration > 0 ? self.context.currentPlaybackTime/self.context.duration : 0;
}

- (UINavigationController *)navigationController
{
    return self.viewController.navigationController;
}

- (BOOL)p_isValidPlayPreVideo {
    
    BOOL isValid = NO;
    
    if (self.navigationController.viewControllers.count > 2) {
        // 仅从视频详情再次进入视频详情才会显示按钮
        NSUInteger curIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        if (curIndex - 1 > 0 && curIndex - 1 < self.navigationController.viewControllers.count) {
            
            if ([self.navigationController.viewControllers[curIndex - 1] isKindOfClass:[TTDetailContainerViewController class]]) {
                
                isValid = YES;
            }
        }
    }
    
    return isValid;
}

- (void)ttv_showPrePlayBtnWithBannerHeight:(CGFloat)height {
    self.movieView.player.bannerHeight = height;
}

- (void)autoClickedPlayButton
{    //app处于后台状态时，不允许自动播放
    if ([self.videoInfo directPlay]) {
        if (!self.movieView && !self.isInactive) {
            [self playButtonClicked];
        }
    }
}

- (BOOL)isMovieFullScreen
{
    return self.context.isFullScreen;
}

- (BOOL)isFirstPlayMovie
{
    if (!self.movieViewInitiated) {
        if (!self.movieView) {
            //自动播放, 服务端可控
            [self autoClickedPlayButton];
        } else {
            //继续播放
            if (![self isMovieFullScreen]) {
                [self attachMovieView];
            }
            if ([self shouldAutoPlay]) {
                [self resumeMovie];
            }
            self.movieViewInitiated = YES;
        }
        return YES;
    }
    return NO;
}

/**
 播放结束界面下不自动播放
 */
- (BOOL)shouldAutoPlay
{
    return (self.context.tipType != TTVPlayerControlTipViewTypeFinished && !self.context.isShowingTrafficAlert && !self.movieView.player.context.midADIsPlaying);
}

- (void)rebindToMovieShotView:(BOOL)rebindToMovieShotView
{
    BOOL checkSuperViewFlag = rebindToMovieShotView ? [self.movieView superview] != self.movieShotView : [self.movieView superview] == nil;
    if (self.movieView && checkSuperViewFlag) {
        [self.movieShotView addSubview:self.movieView];
    }
}

- (void)playMovieIfNeeded
{
    [self playMovieIfNeededAndRebindToMovieShotView:YES];
}

- (void)playMovieIfNeededAndRebindToMovieShotView:(BOOL)rebindToMovieShotView
{
    [self rebindToMovieShotView:rebindToMovieShotView];
    if (![self isFirstPlayMovie] && [self shouldAutoPlay]) {
        [self resumeMovie];
    }
}

- (void)pauseMovieIfNeeded
{
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}


- (void)resumeMovie
{
    if (self.movieView) {
        if ([self.movieView.player.pasterPlayer hasPasterAd]) {
            [self.movieView.player.pasterPlayer play];
        }else{
            if (self.commodityView.superview != self.movieView) {
                if (![TTDeviceHelper isPadDevice]) {
                    [self.movieView.player.commodityFloatView setCommoditys:self.videoInfo.commoditys];
                    self.movieView.player.commodityButton.delegate = self;
                }
            }
        }
    }
    else
    {
        if (self.commodityView.superview != self.movieView/* && ![TTRedPacketManager sharedManager].isShowingRedpacketView*/) {
            [self playButtonClicked];
        }
    }
    
}


- (void)viewDidLoad
{
    
}


- (void)setToolBarHidden:(BOOL)hidden
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(hidden),@"hidden",@(YES),@"autoHidden",nil];
    [self.movieView.player sendAction:TTVPlayerEventTypeControlViewHiddenToolBar payload:dic];
}

- (void)setVideoInfo:(id<TTVArticleProtocol>)videoInfo
{
    NSString *old_log_extra = _videoInfo.logExtra;
    _videoInfo = videoInfo;

    if ([self isDetailArticleEnable] && self.movieView && [_videoInfo.adModel isCreativeAd]
    && ![self isADTipCreator:self.movieView.player.tipCreator]) {//广告
        if (isEmptyString(videoInfo.logExtra)) {
            _videoInfo.logExtra = old_log_extra;
        }
        self.movieView.player.tipCreator = [[TTVPlayerTipAdOldCreator alloc] init];
        [self ttv_configADFinishedView:(TTVPlayerTipAdFinished *)self.movieView.player.tipCreator.tipFinishedView];
    }
}

//setVideoinfo逻辑开关
- (BOOL)isDetailArticleEnable
{
    NSDictionary *config = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_visible_enable" defaultValue:@{} freeze:YES];
    if ([config isKindOfClass:[NSDictionary class]]) {
        if (![[config allKeys] containsObject:@"tt_detail_article_enable"] ) {
            return YES;
        }
        return [config tta_boolForKey:@"tt_detail_article_enable"];
    }
    return NO;
}

- (BOOL)isADTipCreator:(id<TTVPlayerTipCreator>)tipCreator
{
    NSString *className = NSStringFromClass(object_getClass(tipCreator));
    if ([className isEqualToString:@"TTVPlayerTipAdNewCreator"] || [className isEqualToString:@"TTVPlayerTipAdOldCreator"]) {
        return YES;
    }
    return NO;
}

- (void)addCommodity
{
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    [self.commodityView ttv_removeFromSuperview];
    TTVCommodityView *commodity = nil;
    if (self.movieView.superview) {
        commodity = [[TTVCommodityView alloc] initWithFrame:self.movieView.bounds];
        commodity.videoID = self.videoInfo.videoID;
        commodity.groupID = self.videoInfo.groupModel.groupID;
        commodity.position = [self getCommodityPosition];
        commodity.playVideo = self.movieView;
        [self.movieView.player setCommodityView:commodity];
    }
    commodity.delegate = self;
    [commodity setCommoditys:self.videoInfo.commoditys];

    [commodity showCommodity];
    self.commodityView = commodity;
}

- (NSString *)getCommodityPosition
{
    if (self.movieView && [self.movieView.player.context isFullScreen]) {
        return @"fullscreen";
    }
    return @"detail";
}

#pragma mark - TTVCommodityViewDelegate

- (void)commodityViewClosed
{
    
}

- (void)viewWillAppear
{
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
    [self playMovieIfNeeded];
}

- (void)viewWillDisappear
{
}

- (void)viewDidDisappear
{
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
    [self.movieView.player.midInsertADPlayer pause];
    [self.movieView.player.pasterPlayer pause];
}

- (void)viewDidAppear
{
    [self.movieView.player.midInsertADPlayer play];
    [self.movieView.player.pasterPlayer play];
    
    BOOL iOS8 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0;
    if (iOS8) {
        /***
         *    为什么ios8这里这样操作？
         *    为了解ios8播放器没有传递进详情页的问题，没有将feed上的播放器removefromsuperview
         * 然而feed上离开时打点的逻辑中会触发TTVCellplayMovie中settingMovieView方法导致isInDetail
         * 又被设置回NO，在这里再修正一下
         **/
        self.movieView.player.isInDetail = YES;
    }
}

- (void)showDetailButtonIfNeeded
{
}

- (void)addMovieViewObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    //如果在正在播放时进入详情页，会没有注册监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
}

- (CGRect)frameForMovieView
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerMovieFrame)]) {
        return [self.delegate ttv_playerControlerMovieFrame];
    }
    return CGRectZero;
}

- (void)playButtonClicked
{
    [ExploreMovieView removeAllExploreMovieView];
    //号外广告,没有admodel,只有ad_id 和logExtra
    NSString *category = self.entity.categoryId;
    NSString *adID = self.videoInfo.adIDStr ? self.videoInfo.adIDStr : self.videoInfo.adModel.ad_id;
    NSString *logExtra = self.videoInfo.logExtra ? self.videoInfo.logExtra : self.videoInfo.adModel.log_extra;
    NSString *videoID = self.videoInfo.videoID;
    if (isEmptyString(videoID)) {
        videoID = [self.videoInfo.videoDetailInfo objectForKey:VideoInfoIDKey];
    }
        
    TTVPlayerSP sp = ([self.videoInfo.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? TTVPlayerSPLeTV : TTVPlayerSPToutiao;
    
    //TTVPlayerModel
    TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
    model.categoryID = category;
    model.groupID = [NSString stringWithFormat:@"%lld",self.videoInfo.uniqueID];
    model.itemID = self.videoInfo.itemID;
    model.aggrType = [self.videoInfo.aggrType integerValue];
    model.adID = adID;
    if ([self.videoInfo.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
        model.localURL = self.videoInfo.videoLocalURL;
    }else{
        model.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), self.videoInfo.videoLocalURL];
    }
    model.logExtra = logExtra;
    model.videoID = videoID;
    model.sp = sp;
    model.trackLabel = self.detailStateStore.state.entity.clickLabel;
    model.isAutoPlaying = NO;
    model.logPb = self.detailStateStore.state.logPb;
    model.enterFrom = self.detailStateStore.state.enterFrom;
    model.categoryName = self.detailStateStore.state.categoryName;
    model.authorId = self.detailStateStore.state.authorId;
    model.fromGid = [self.detailStateStore.state ttv_fromGid];
    if (self.videoInfo.isVideoSourceUGCVideo) {
        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    if ([self.videoInfo.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
        model.localURL = self.videoInfo.videoLocalURL;
    }else{
        model.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), self.videoInfo.videoLocalURL];
    }
    if ([self.videoInfo hasVideoSubjectID]) {
        model.videoSubjectID = [self.videoInfo videoSubjectID];
    }
    BOOL isVideoFeedURLEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_feed_url" defaultValue:@NO freeze:NO] boolValue];
    if (isVideoFeedURLEnabled && [self.videoInfo hasVideoPlayInfoUrl] && [self.videoInfo isVideoUrlValid]) {
        model.videoPlayInfo = self.videoInfo.videoPlayInfo;
//        model.expirationTime = [[NSDate date] timeIntervalSinceDate:self.videoInfo.createdTime];
    }
    
    NSInteger isVideoShowOptimizeShare = ttvs_isVideoShowOptimizeShare();
    if (isVideoShowOptimizeShare > 0){
        if (isEmptyString(model.adID)){
            model.playerShowShareMore = isVideoShowOptimizeShare;
        }
    }
    
    //只有有admodel才行,号外广告显示正常视频UI
    if ([self.videoInfo.adModel isCreativeAd]) {//广告
        model.enablePasterAd = NO;
    }else{//非广告使用贴片功能
        model.enablePasterAd = YES;
        model.pasterAdFrom = @"textlink";
    }
    
    //movieView
    TTVPlayVideo *movie = [[TTVPlayVideo alloc] initWithFrame:[self frameForMovieView] playerModel:model];
    self.movieView = movie;
    
    //只有有admodel才行,号外广告显示正常视频UI
    if ([self.videoInfo.adModel isCreativeAd]) {//广告
        if ([self ttv_shouldAllocTipAdNewCreator]) {
            self.movieView.player.tipCreator = [[TTVPlayerTipAdNewCreator alloc] init];
        }else if ([self.videoInfo isKindOfClass:[Article class]]){
            self.movieView.player.tipCreator = [[TTVPlayerTipAdOldCreator alloc] init];
        }
    } else {
        if (ttvs_isPlayerShowRelated()) {
            self.movieView.player.tipCreator = [[TTVPlayerTipRelatedCreator alloc] init];
        } else {
            NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
            if ((isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3)) {
                self.movieView.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
            }
        }
    }
    self.movieView.player.enableRotate = ![self.videoInfo detailShowPortrait];
    [self addUrlTracker];
    _movieView.player.delegate = self;
    self.movieView.player.doubleTap666Delegate = self.doubleTap666Delegate;
    NSDictionary *videoLargeImageDict = self.videoInfo.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [self.videoInfo.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [self.movieView setVideoLargeImageDict:videoLargeImageDict];
    if (self.movieView) {
        [self.movieShotView addSubview:self.movieView];
        [self.movieView.player readyToPlay];
        [self configMovieView];
        [self.movieView.player play];
    }
    if (![TTDeviceHelper isPadDevice]) {
        [self.movieView.player.commodityFloatView setCommoditys:self.videoInfo.commoditys];
        self.movieView.player.commodityButton.delegate = self;
    }
    [self.movieView.player setVideoTitle:self.videoInfo.title];
    [self.movieView.player setVideoWatchCount:[[self.videoInfo.videoDetailInfo valueForKey:@"video_watch_count"] doubleValue] playText:@"次播放"];
    [self.movieShotView refreshUI];
    [self ttv_configADFinishedView:(TTVPlayerTipAdFinished *)self.movieView.player.tipCreator.tipFinishedView];
    
    [[AKAwardCoinVideoMonitorManager shareInstance] monitorVideoWith:movie];
}


- (void)addUrlTracker
{
    TTVPlayerUrlTracker *urlTracker = [[TTVPlayerUrlTracker alloc] init];
    urlTracker.effectivePlayTime = self.videoInfo.adModel.effectivePlayTime;
    urlTracker.clickTrackURLs = self.videoInfo.adModel.click_track_url_list;
    urlTracker.playTrackUrls = self.videoInfo.adModel.playTrackUrls;
    urlTracker.activePlayTrackUrls = self.videoInfo.adModel.activePlayTrackUrls;
    urlTracker.effectivePlayTrackUrls = self.videoInfo.adModel.effectivePlayTrackUrls;
    urlTracker.videoThirdMonitorUrl = [self.videoInfo.videoDetailInfo stringValueForKey:@"video_third_monitor_url" defaultValue:nil];
    urlTracker.playOverTrackUrls = self.videoInfo.adModel.playOverTrackUrls;
    [self.movieView.commonTracker registerTracker:urlTracker];
}

- (BOOL)ttv_shouldAllocTipAdNewCreator {
    BOOL result = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttv_shouldAllocTipAdNewCreator)]) {
        result = [self.delegate ttv_shouldAllocTipAdNewCreator];
    }
    if (!result) {
        result = [self.videoInfo isKindOfClass:[TTVFeedItem class]];
    }
    return result;
}

- (void)ttv_configADFinishedView:(TTVPlayerTipAdFinished *)finishedView
{
    if ([self ttv_shouldAllocTipAdNewCreator] && [finishedView isKindOfClass:[TTVPlayerTipAdNewFinished class]]) {
        TTVFeedItem *item = (TTVFeedItem *)self.videoInfo;
        TTVMoviePlayerControlFinishAdEntity* entity = [TTVMoviePlayerControlFinishAdEntity entityWithData:item];
        entity.raw_ad_data = self.detailStateStore.state.rawAdData;
        [finishedView setData: entity];
    }else if ([self.videoInfo isKindOfClass:[Article class]] && [finishedView isKindOfClass:[TTVPlayerTipAdOldFinish class]]){
        ExploreOrderedData *orderData = [[ExploreOrderedData alloc] initWithArticle:(Article *)self.videoInfo];
        orderData.raw_ad_data = self.detailStateStore.state.rawAdData;
        [finishedView setData:orderData];
    }else if ([self.videoInfo isKindOfClass:[TTVVideoInformationResponse class]] && [finishedView isKindOfClass:[TTVPlayerTipAdOldFinish class]]){
        ExploreOrderedData *orderData = [[ExploreOrderedData alloc] initWithArticle:(Article *)self.videoInfo];
        orderData.raw_ad_data = self.detailStateStore.state.rawAdData;
        [finishedView setData:orderData];
    }
}

- (void)invalideMovieView {
    [self invalideMovieViewWithFinishedBlock:nil];
}

- (void)invalideMovieViewWithFinishedBlock:(void (^)(void))finishedBlock
{
    @weakify(self);
    [self.movieView stopWithFinishedBlock:^{
        @strongify(self);
        [self.movieView removeFromSuperview];
        self.movieView = nil;
        finishedBlock ? finishedBlock() : nil;
    }];
}

- (TTVideoDetailHeaderPosterView *)addMovieShotView
{
    TTVideoDetailHeaderPosterView *poster = [[TTVideoDetailHeaderPosterView alloc] init];
    poster.isAD = NO;
    poster.showSourceLabel = NO;
    poster.showPlayButton = YES;
    return poster;
}

- (void)attachMovieView
{
    if (!([self.movieView.superview isKindOfClass:[UIWindow class]] || self.context.isFullScreen)) {
        self.movieView.player.enableRotate = ![self.videoInfo detailShowPortrait];
        [self.movieShotView addSubview:self.movieView];
        [self.movieShotView bringSubviewToFront:self.movieView];
    }
    [self.movieView.player setVideoTitle:self.videoInfo.title];
    [self.movieView.player setVideoWatchCount:[[self.videoInfo.videoDetailInfo valueForKey:@"video_watch_count"] doubleValue] playText:@"次播放"];
    self.movieView.hidden = NO;
    self.movieShotView.hidden = NO;
}

- (void)ttv_clickCommodityButton
{
    [self addCommodity];
}

#pragma mark notification

- (void)ttv_ApplicationWillResignActiveNotification:(NSNotification *)notification
{
    self.isInactive = YES;
}

- (void)ttv_ApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    self.isInactive = NO;
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    [self invalideMovieView];
}

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    [self.movieShotView refreshUI];
    [self.movieView removeFromSuperview];
}

- (BOOL)shouldLayoutSubviews
{
    return !self.detailStateStore.state.forbidLayout && !self.detailStateStore.state.isChangingMovieSize;
}

- (TTVideoDetailHeaderPosterView *)movieShotView
{
    if ([self.shareMovie.posterView isKindOfClass:[TTVideoDetailHeaderPosterView class]]) {
        return (TTVideoDetailHeaderPosterView *)self.shareMovie.posterView;
    }
    return nil;
}

- (void)receiveAdClick:(NSNotification *)notification
{
    [self.movieView.commonTracker sendEndTrack];
}

- (void)skStoreViewDidAppear:(NSNotification *)notification
{
}

- (void)skStoreViewDidDisappear:(NSNotification *)notification
{
    [self rebindToMovieShotView:YES];
}


#pragma mark movideView delegate

- (id <TTVDetailContext>)detalViewControllerAtIndex:(NSInteger)index
{
    UINavigationController *nav = self.viewController.parentViewController.navigationController;
    if (index >= 0 && index < nav.viewControllers.count) {
        TTDetailContainerViewController *controller = [nav.viewControllers objectAtIndex:index];
        id <TTVDetailContext> detail = nil;
        if ([controller isKindOfClass:[TTDetailContainerViewController class]]) {
            detail = (id <TTVDetailContext> )controller.detailViewController;
            if ([detail conformsToProtocol:@protocol(TTVDetailContext)]) {
                return detail;
            }
        }
    }
    return nil;
}

- (void)playingShareButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerShareButtonClicked)]) {
        [self.delegate ttv_playerControlerShareButtonClicked];
    }
}

- (void)videoOverShareButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerFinishTipShareButtonClicked)]) {
        [self.delegate ttv_playerFinishTipShareButtonClicked];
    }
}

- (void)fullScreenButtonClicked:(TTVPlayerStateAction *)action
{
    BOOL isFull = NO;
    if ([action.payload isKindOfClass:[NSDictionary class]] && [((NSDictionary *)(action.payload))[@"isFullScreen"] isKindOfClass:[NSNumber class]]) {
        isFull = [((NSDictionary *)(action.payload))[@"isFullScreen"] boolValue];
    }
    if ([self.delegate respondsToSelector:@selector(ttv_playerControllerFullScreenButtonClicked:)]) {
        [self.delegate ttv_playerControllerFullScreenButtonClicked:isFull];
    }
}

- (void)playingMoreButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerMoreButtonClicked:)]) {
        [self.delegate ttv_playerControlerMoreButtonClicked:[self isMovieFullScreen]];
    }
}

- (void)videoOverMoreButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerFinishTipMoreButtonClicked)]) {
        [self.delegate ttv_playerFinishTipMoreButtonClicked];
    }
}

- (void)directShareActionWithActivityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerFinishTipDirectShareActionWithActivityType:)]) {
        [self.delegate ttv_playerFinishTipDirectShareActionWithActivityType:activityType];
    }
}

- (void)playingDirectShareActionWithActivityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_playingShareViewDirectShareActionWithActivityType:)]) {
        [self.delegate ttv_playingShareViewDirectShareActionWithActivityType:activityType];
    }
}

@end



