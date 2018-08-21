//
//  TTVCellPlayMovie.m
//  Article
//
//  Created by panxiang on 2017/4/20.
//
//

#import "TTVCellPlayMovie.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "ExploreMovieViewModel+ConvertFromTTVFeedItem.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTMovieViewCacheManager.h"
#import "TTVDemanderPlayerTracker.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVFeedCellMoreActionManager.h"
#import "NewsDetailConstant.h"
#import "TTMovieStore.h"
#import "TTVPlayVideo.h"
#import "TTVPlayerUrlTracker.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerTipAdFinished.h"
#import "ExploreMovieView.h"
#import "TTVPlayerTipAdNewCreator.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "JSONAdditions.h"
//#import "TTShareToRepostManager.h"
#import "TTVPlayerAudioController.h"
#import "TTVCommodityViewMessage.h"

#import "TTVPlayerTipShareCreater.h"
#import "TTVPlayerTipRelatedCreator.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVAutoPlayManager.h"
#import "TTVCommodityView.h"
#import "TTVCommodityButtonView.h"
#import "TTVCommodityFloatView.h"
#import "TTVPasterPlayer.h"
#import "AKAwardCoinVideoMonitorManager.h"
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isPlayerShowRelated(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface TTVCellPlayMovie ()<TTVDemandPlayerDelegate,TTVPlayVideoDelegate ,TTVCommodityViewDelegate ,TTVCommodityViewMessage,TTVCommodityButtonViewDelegate>

@property (nonatomic, strong) TTVFeedCellMoreActionManager *moreActionMananger;
@property(nonatomic, copy)dispatch_block_t shareButtonClickedBlock;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) CGRect movieViewFrame;
@property (nonatomic, strong) TTVCommodityView *commodityView;
@end

@implementation TTVCellPlayMovie
@synthesize movieView = _movieView;
- (void)dealloc
{
    UNREGISTER_MESSAGE(TTVCommodityViewMessage, self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        REGISTER_MESSAGE(TTVCommodityViewMessage, self);
        self.isActive = YES;
        [self addNotification];
    }
    return self;
}

- (void)setDoubleTap666Delegate:(id<TTVPlayerDoubleTap666Delegate>)doubleTap666Delegate {
    _doubleTap666Delegate = doubleTap666Delegate;
    self.movieView.player.doubleTap666Delegate = doubleTap666Delegate;
}

- (TTVVideoArticle *)article
{
    return self.cellEntity.originData.article;
}

- (void)clickShare
{
    self.moreActionMananger = [[TTVFeedCellMoreActionManager alloc] init];
    self.moreActionMananger.categoryId = self.cellEntity.categoryId;
    self.moreActionMananger.responder = self.fromView;
    self.moreActionMananger.cellEntity = self.cellEntity.originData;
    @weakify(self);
    self.moreActionMananger.didClickActivityItemAndQueryProcess = ^BOOL(NSString *type) {
        @strongify(self);
        if ([type isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
//            [self forwardToWeitoutiao];
            return YES;
        }
        return NO;
    };
//    self.moreActionMananger.shareToRepostBlock = ^(TTActivityType type) {
//        @strongify(self);
//        [self shareToRepostWithActivityType:type];
//    };
    [self.moreActionMananger shareButtonOnMovieClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {

    }];
}

//- (void)forwardToWeitoutiao {
//    //实际转发对象为文章，操作对象为文章
//    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                    originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.cellEntity.originData.ttv_convertedArticle]
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:nil
//                                                                operationItemType:TTRepostOperationItemTypeArticle
//                                                                  operationItemID:self.cellEntity.originData.itemID
//                                                                   repostSegments:nil];
//}

//- (void)shareToRepostWithActivityType:(TTActivityType)activityType {
//    [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                               repostType:TTThreadRepostTypeArticle
//                                                        operationItemType:TTRepostOperationItemTypeArticle
//                                                          operationItemID:self.cellEntity.originData.itemID
//                                                            originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.cellEntity.originData.ttv_convertedArticle]
//                                                             originThread:nil
//                                                           originShortVideoOriginalData:nil
//                                                        originWendaAnswer:nil
//                                                           repostSegments:nil];
//}

- (void)shareButtonClicked
{
    if (_shareButtonClickedBlock) {
        _shareButtonClickedBlock();
    }
}

- (NSString *)enterFrom
{
    if ([self.cellEntity.categoryId isEqualToString:kTTMainCategoryID]) {
        return @"click_headline";
    }else{
        return @"click_category";
    }
    return nil;
}

- (void)play
{
    [ExploreMovieView removeAllExploreMovieView];
    SAFECALL_MESSAGE(TTVCommodityViewMessage, @selector(ttv_message_removeall_comodityview), ttv_message_removeall_comodityview);

    TTVPlayerSP sp = (self.cellEntity.article.groupFlags & ArticleGroupFlagsDetailSP) > 0 ? TTVPlayerSPLeTV : TTVPlayerSPToutiao;
    TTVFeedItem *feedItem = self.cellEntity.originData;
    TTVVideoArticle *article = self.cellEntity.article;
    
    //TTVPlayerModel
    TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
    model.categoryID = self.cellEntity.categoryId;
    model.groupID = [NSString stringWithFormat:@"%lld",article.groupId];
    model.itemID = [NSString stringWithFormat:@"%lld",article.itemId];
    model.aggrType = article.aggrType;
    model.adID = article.adId;
    model.logExtra = article.logExtra;
    model.videoID = article.videoId;
    model.sp = sp;
    model.enterFrom = [self enterFrom];
    model.categoryName = self.cellEntity.categoryId;
    model.authorId = article.userId;
    if (feedItem.isVideoSourceUGCVideo) {
        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    NSDictionary *dic = [feedItem.logPb tt_JSONValue];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        model.logPb = dic;
    }
    if (!isEmptyString(article.videoDetailInfo.videoSubjectId)) {
        model.videoSubjectID = article.videoDetailInfo.videoSubjectId;
    }
    if (feedItem.isVideoSourceUGCVideo) {
        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    //只有有admodel才行,号外广告显示正常视频UI
    if ([self.cellEntity.originData.adModel isCreativeAd]) {//广告
        model.enablePasterAd = NO;
    }else{//非广告使用贴片功能
        model.enablePasterAd = YES;
        model.pasterAdFrom = @"feed";
    }
    BOOL isAutoPlaying = [feedItem couldAutoPlay];
    model.isAutoPlaying = isAutoPlaying;
    model.showMutedView = isAutoPlaying;
    if (isAutoPlaying) {
        //广告自动播放时每次从头播放
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:article.videoId];
        model.mutedWhenStart = YES;
        if ([[feedItem rawAdData] tta_boolForKey:@"auto_replay"]) {
            model.isLoopPlay = YES;
            model.disableFinishUIShow = YES;
        }
    }
    BOOL isVideoFeedURLEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_feed_url" defaultValue:@NO freeze:NO] boolValue];
    if (isVideoFeedURLEnabled && [self.cellEntity.originData hasVideoPlayInfoUrl] && [self.cellEntity.originData isVideoUrlValid]) {
        model.videoPlayInfo = self.cellEntity.originData.videoPlayInfo;
    }
    NSInteger isVideoShowOptimizeShare = ttvs_isVideoShowOptimizeShare();
    if (isVideoShowOptimizeShare > 0){
        if (isEmptyString(model.adID)) {
            model.playerShowShareMore = isVideoShowOptimizeShare;
        }
    }
    
    //movieView
    TTVPlayVideo *playVideo = [[TTVPlayVideo alloc] initWithFrame:self.logo.bounds playerModel:model];
    playVideo.player.delegate = self;
    playVideo.player.doubleTap666Delegate = self.doubleTap666Delegate;
    playVideo.delegate = self;
    if ([self.cellEntity.originData.adModel isCreativeAd]) {//广告
        playVideo.player.tipCreator = [[TTVPlayerTipAdNewCreator alloc] init];
    }else{
        if (ttvs_isPlayerShowRelated()) {
            playVideo.player.tipCreator = [[TTVPlayerTipRelatedCreator alloc] init];
        }else{
            NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
            if ((isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3) && isEmptyString(model.adID)){
                playVideo.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
            }
        }
    }
    playVideo.player.enableRotate = ![article showPortrait];
    
    NSDictionary *videoLargeImageDict = feedItem.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [feedItem.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [playVideo setVideoLargeImageDict:videoLargeImageDict];
    self.movieView = playVideo;
    [self.movieView.player readyToPlay];
    if (isAutoPlaying && self.cellEntity.article.adId.longLongValue > 0) {
        self.movieView.player.banLoading = YES;
        self.movieView.player.muted = [self.cellEntity.originData couldAutoPlay];
    }
    [self addUrlTrackerOnPlayer:playVideo];
    [self settingMovieView:self.movieView];
    [self.movieView.player play];
    [playVideo.player setVideoTitle:feedItem.title];
    [playVideo.player setVideoWatchCount:article.videoDetailInfo.videoWatchCount playText:@"次播放"];
    self.logo.userInteractionEnabled = ![feedItem couldAutoPlay];
    [self.logo addSubview:self.movieView];
    if (![TTDeviceHelper isPadDevice]) {
        playVideo.player.commodityFloatView.animationToView = self.cellEntity.moreButton;
        playVideo.player.commodityFloatView.animationSuperView = self.cellEntity.cell;
        [playVideo.player.commodityFloatView setCommoditys:self.cellEntity.originData.commoditys];
        playVideo.player.commodityButton.delegate = self;
    }

    [self ttv_configADFinishedView:playVideo.player.tipCreator.tipFinishedView];
    
    [[AKAwardCoinVideoMonitorManager shareInstance] monitorVideoWith:playVideo];
}

- (void)addCommodity{
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    if (self.movieView) {
        [TTVPlayVideo removeExcept:self.movieView];
    }else{
        [TTVPlayVideo removeAll];
    }
    [self.commodityView ttv_removeFromSuperview];
    SAFECALL_MESSAGE(TTVCommodityViewMessage, @selector(ttv_message_removeall_comodityview), ttv_message_removeall_comodityview);
    TTVCommodityView *commodity = nil;
    if (self.movieView.superview) {
        commodity = [[TTVCommodityView alloc] initWithFrame:self.movieView.bounds];
        commodity.playVideo = self.movieView;
        [self.movieView.player setCommodityView:commodity];
    }else{
        commodity = [[TTVCommodityView alloc] initWithFrame:self.logo.bounds];
        [self.logo addSubview:commodity];
    }
    if (self.movieView.superview && [self.movieView.player.context isFullScreen]) {
        commodity.position = @"fullscreen";
    }else{
        commodity.position = @"list";
    }
    commodity.videoID = self.cellEntity.article.videoId;
    commodity.groupID = @(self.cellEntity.article.groupId).stringValue;
    commodity.delegate = self;
    [commodity setCommoditys:self.cellEntity.originData.commoditys];
    [commodity showCommodity];
    self.commodityView = commodity;
    [self commodityViewshowed];
}

- (void)removeCommodityView {
    
    if (self.commodityView.superview) {
        
        [self.commodityView ttv_removeFromSuperview];
    }
}

- (void)commodityViewshowed
{
    if ([self.delegate respondsToSelector:@selector(ttv_commodityViewShowed)]) {
        [self.delegate ttv_commodityViewShowed];
    }
}

- (void)commodityViewClosed
{
    if ([self.delegate respondsToSelector:@selector(ttv_commodityViewClosed)]) {
        [self.delegate ttv_commodityViewClosed];
    }
}

- (void)ttv_clickCommodityButton
{
    [self addCommodity];
}

- (void)setVideoTitle:(NSString *)title
{
    [self.movieView.player setVideoTitle:title];
}

- (void)setVideoWatchCount:(NSInteger)watchCount
{
    [self.movieView.player setVideoWatchCount:watchCount playText:@"次播放"];
}
- (void)addUrlTrackerOnPlayer:(TTVPlayVideo *)playVideo
{
    TTVADInfo *adInfo = self.cellEntity.originData.adInfo;
    TTVVideoArticle *article = self.cellEntity.article;

    TTVPlayerUrlTracker *urlTracker = [[TTVPlayerUrlTracker alloc] init];
    urlTracker.effectivePlayTime = adInfo.videoTrackURL.effectivePlayTime;
    urlTracker.clickTrackURLs = adInfo.trackURL.clickTrackURLListArray;
    urlTracker.playTrackUrls = adInfo.videoTrackURL.playTrackURLListArray;
    urlTracker.activePlayTrackUrls = adInfo.videoTrackURL.activePlayTrackURLListArray;
    urlTracker.effectivePlayTrackUrls = adInfo.videoTrackURL.effectivePlayTrackURLListArray;
    urlTracker.videoThirdMonitorUrl = article.videoDetailInfo.videoThirdMonitorURL;
    urlTracker.playOverTrackUrls = adInfo.videoTrackURL.playoverTrackURLListArray;
    [playVideo.commonTracker registerTracker:urlTracker];
}

- (void)ttv_configADFinishedView:(TTVPlayerTipAdNewFinished *)finishedView
{
    if ([finishedView isKindOfClass:[TTVPlayerTipAdNewFinished class]]) {
        if ([self.cellEntity.originData isKindOfClass:[TTVFeedItem class]]) {
            [finishedView setData:[TTVMoviePlayerControlFinishAdEntity entityWithData:self.cellEntity.originData]];
        }
    }
}

#pragma mark TTVDemandPlayerDelegate

- (void)playerLoadingState:(TTVPlayerLoadState)state
{
    
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (state == TTVVideoPlaybackStateFinished ||
        state == TTVVideoPlaybackStateError) {
        self.logo.userInteractionEnabled = YES;
    }
    if (state == TTVVideoPlaybackStateFinished) {
        [self moviePlayFinishedAction];
    }
    
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeFinishUIShare:{
            [self shareButtonOnMovieFinishViewDidPress];
        }
            break;
        case TTVPlayerEventTypePlayingShare:{
            [self shareButtonOnMovieTopViewDidPress]; 
        }
            break;
        case TTVPlayerEventTypePlayingMore:{
            [self MoreButtonOnMoviewTopViewDidpress];
        }
            break;
        case TTVPlayerEventTypeFinishDirectShare:{
            if ([action.payload isKindOfClass:[NSString class] ]) {
                [self directShareActionWithActivityType:action.payload];
            }
        }
            break;
        case TTVPlayerEventTypePlayingDirectShare:{
            if ([action.payload isKindOfClass:[NSString class] ]) {
                [self playingDirectShareActionWithActivityType:action.payload];
            }
        }
            break;
        case TTVPlayerEventTypeFinishUIReplay:{
            [self movieReplayAction];
        }
            break;
        default:
            break;
    }
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    return self.logo.bounds;
}

- (void)moviePlayFinishedAction{
    if (self.movieView.playerModel.isLoopPlay) {
        [self.movieView.player setLogoImageViewHidden:YES];
        [self.movieView.player play];
        self.logo.userInteractionEnabled = NO;
    }
    if ([self.delegate respondsToSelector:@selector(ttv_moviePlayFinished)]) {
        [self.delegate ttv_moviePlayFinished];
    }
}

- (void)movieReplayAction{
    if ([self.delegate respondsToSelector:@selector(ttv_movieReplayAction)]) {
        [self.delegate ttv_movieReplayAction];
    }
}

- (void)movieViewWillMoveToSuperView:(UIView *)newView{
    if ([self.delegate respondsToSelector:@selector(ttv_movieViewWillMoveTosuperView:)]) {
        [self.delegate ttv_movieViewWillMoveTosuperView:newView];
    }
}

- (void)goVideoDetail
{
    [self.movieView.player sendAction:TTVPlayerEventTypeGoToDetail payload:nil];
}


- (void)shareButtonOnMovieFinishViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieFinishViewDidPress)]) {
        [self.delegate ttv_shareButtonOnMovieFinishViewDidPress];
    }
}

- (void)shareButtonOnMovieTopViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieTopViewDidPress)]) {
        [self.delegate ttv_shareButtonOnMovieTopViewDidPress];
    }
}

- (void)MoreButtonOnMoviewTopViewDidpress
{
    if ([self.delegate respondsToSelector:@selector(ttv_moreButtonOnMovieTopViewDidPress)]) {
        [self.delegate ttv_moreButtonOnMovieTopViewDidPress];
    }
}

- (void)directShareActionWithActivityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_directShareActionWithActivityType:)]) {
        [self.delegate ttv_directShareActionWithActivityType:activityType];
    }
}

- (void)playingDirectShareActionWithActivityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_directShareActionOnMovieWithActivityType:)]) {
        [self.delegate ttv_directShareActionOnMovieWithActivityType:activityType];
    }
}


- (void)settingMovieView:(TTVPlayVideo *)movieView
{
    movieView.player.isInDetail = NO;
    movieView.player.showTitleInNonFullscreen = YES;
}

- (void)setMovieView:(TTVPlayVideo *)movieView
{
    if (([movieView isKindOfClass:[TTVPlayVideo class]] || !movieView)) {
        _movieView = movieView;
        _movieView.player.delegate = self;
        _movieView.delegate = self;
        _movieView.player.doubleTap666Delegate = self.doubleTap666Delegate;
        [self settingMovieView:movieView];
    }
}

- (UIView *)movieView
{
    if (_movieView) {
        return _movieView;
    }
    TTVPlayVideo *view = [self movieViewFromeLogo];
    return view;
}

- (TTVPlayVideo *)movieViewFromeLogo
{
    NSArray *subviews = self.logo.subviews;
    for (TTVPlayVideo *subView in subviews) {
        if ([subView isKindOfClass:[TTVPlayVideo class]]) {
            return subView;
        }
        if ([subView isKindOfClass:[ExploreMovieView class]]) {
            [((ExploreMovieView *)subView) stopMovieAfterDelay];
            [subView removeFromSuperview];
        }
    }
    return nil;
}

#pragma mark - notification

- (void)ttv_ApplicationWillResignActiveNotification:(NSNotification *)notification
{
    self.isActive = NO;
}

- (void)ttv_ApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isActive = YES;
    });
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_refreshViewBeginRefresh:) name:@"kTTRefreshViewBeginRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:nil];
}

- (void)ttv_refreshViewBeginRefresh:(NSNotification *)notification
{
    if ([[[notification userInfo] valueForKey:@"category_id"] isEqualToString:self.cellEntity.categoryId]) {
        if (!self.movieView) {
            self.movieView = [self movieViewFromeLogo];
        }
        if (self.movieView) {
            [self.movieView exitFullScreen:NO completion:nil];
            [self.movieView stop];
            [self.movieView removeFromSuperview];
        }else {
            [self removeFromLogView];
        }
        if ([self.delegate respondsToSelector:@selector(ttv_invalideMovieView)]) {
            [self.delegate ttv_invalideMovieView];
        }
        self.movieView = nil;
    }
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [self invalideMovieView];
    }
    
}

- (void)stopAllMovieViewPlay:(NSNotification *)notification
{
    [self.commodityView closeCommodity];
    [self invalideMovieView];
    [[TTVAutoPlayManager sharedManager] resetForce];
    self.movieView = nil;
    if ([[TTVAutoPlayManager sharedManager].model.uniqueID isEqualToString:[NSString stringWithFormat:@"%lld",self.cellEntity.originData.uniqueID]]) {
        [[TTVAutoPlayManager sharedManager] resetForce];
    }
}

- (void)removeFromLogView
{
    self.movieView = [self movieViewFromeLogo];
    [self.movieView exitFullScreen:NO completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.movieView = nil;
        });
    }];
    [self.movieView.player releaseAysnc];
    [self.movieView removeFromSuperview];
}

- (void)invalideMovieView
{
    if (self.movieView) {
        [self.movieView exitFullScreen:NO completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.movieView = nil;
            });
            [self.movieView.player releaseAysnc];
            [self.movieView removeFromSuperview];
        }];
    }else {
        [self removeFromLogView];
    }
    if ([self.delegate respondsToSelector:@selector(ttv_invalideMovieView)]) {
        [self.delegate ttv_invalideMovieView];
    }
}

- (void)beforeEndDisplaying
{
    
}

- (UIView *)detachMovieView {
    UIView *movieView = self.movieView;
    self.movieView.player.delegate = nil;
    self.movieView.delegate = nil;
    self.movieView.player.doubleTap666Delegate = nil;
    
    BOOL iOS9OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0;
    if (iOS9OrLater) {
        //ios8不移除，避免movieView被释放的问题
        [self.movieView removeFromSuperview];
    }
    self.movieView = nil;
    return movieView;
}

- (void)attachMovieView:(TTVPlayVideo *)movieView {
    if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
        self.movieView = movieView;
        self.movieView.player.isInDetail = NO;
        self.movieView.player.bannerHeight = 0;
        self.movieView.player.delegate = self;
        self.movieView.delegate = self;
        self.movieView.player.doubleTap666Delegate = self.doubleTap666Delegate;
        [self.logo addSubview:movieView];
        [self.logo bringSubviewToFront:movieView];
        movieView.frame = self.logo.bounds;
        if ([self isPlayingFinished]) {
            self.logo.userInteractionEnabled = YES;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //静音会卡住界面
            if ([self.cellEntity.originData couldAutoPlay]) {
                [[TTVPlayerAudioController sharedInstance] setActive:NO];
            }
            self.movieView.player.muted = [self.cellEntity.originData couldAutoPlay];
        });
    }
}


- (BOOL)hasMovieView
{
    if (!self.movieView) {
        self.movieView = [self movieViewFromeLogo];
    }
    if ([self.movieView.playerModel.videoID isEqualToString:self.cellEntity.originData.videoID]) {
        return YES;
    }
    return NO;
}

- (void)didEndDisplaying
{
    [self.commodityView closeCommodity];
    if (!self.movieView) {
        self.movieView = [self movieViewFromeLogo];
    }
    if (!self.movieView.player.context.isRotating &&
        !self.movieView.player.context.isFullScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self invalideMovieView];
        });
        self.movieView.hidden = YES;
        [self.movieView.player pause];
    }
}

- (void)viewWillDisappear
{
    [self.movieView.player saveCacheProgress];
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)viewWillAppear
{
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)cellInListWillDisappear:(TTCellDisappearType)context
{
    if (self.moreActionMananger) {
        [self.moreActionMananger dismissWithAnimation:YES];
        self.moreActionMananger = nil;
    }
    
    if (context == TTCellDisappearTypeChangeCategory) {
        [self.commodityView closeCommodity];
        if (self.movieView && self.movieView.superview) {
            if (![self.movieView.player.pasterPlayer shouldPasterADPause] &&
                isEmptyString(self.cellEntity.originData.adID) &&
                !self.movieView.player.context.isCommodityViewShow) {
                [self invalideMovieView];
                if (!self.isActive) {
                    [self.movieView removeFromSuperview];
                }
            }
        }
    }else if(context == TTCellDisappearTypeGoDetail){
    }else if(context == TTCellDisappearTypePresentedViewController){
        [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
    }
}

- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL))completion
{
    [self.movieView exitFullScreen:YES completion:completion];
    return YES;
}

- (UIView *)currentMovieView
{
    return self.movieView;
}

- (BOOL)isFullScreen
{
    return self.movieView.player.context.isFullScreen;
}

- (BOOL)isPlaying
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        return YES;
    }
    return NO;
}

- (BOOL)isRotating
{
    return self.movieView.player.context.isRotating;
}

- (void)invalideMovieViewAfterDelay:(BOOL)afterDelay
{
    [self invalideMovieView];
}

- (BOOL)isPaused
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStatePaused) {
        return YES;
    }
    return NO;
}

- (BOOL)isPlayingFinished
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStateFinished) {
        return YES;
    }
    return NO;
}

- (BOOL)isPlayingError
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStateError) {
        return YES;
    }
    return NO;
}

#pragma mark TTVCommodityViewMessage
- (void)ttv_message_removeall_comodityview
{
    [self.commodityView closeCommodity];
}

@end
