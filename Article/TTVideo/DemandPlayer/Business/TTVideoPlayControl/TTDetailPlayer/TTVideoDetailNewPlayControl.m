//
//  TTVideoDetailNewPlayControl.m
//  Article
//
//  Created by panxiang on 2017/6/6.
//
//

#import "TTVideoDetailNewPlayControl.h"
#import "SSAppStore.h"
#import "KVOController.h"
#import "TTVideoMovieBanner.h"
#import "TTDetailContainerViewController.h"
#import "TTVideoDetailViewController.h"
#import "TTTrackerProxy.h"
#import "TTVideoTabBaseCellPlayControl.h"
#import "TTVPlayVideo.h"
#import "TTVPlayerStateStore.h"
#import "ExploreMovieView.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVPasterPlayer.h"
#import "TTVPlayerTipAdCreator.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerUrlTracker.h"
#import <TTImageView.h>
#import "TTVPlayerTipShareCreater.h"
#import "TTVCommodityView.h"
#import "TTAdAppointAlertView.h"

#import "NSDictionary+TTGeneratedContent.h"
#import "ExploreOrderedData.h"
#import "ExploreOrderedData+TTAd.h"


extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);

@interface TTVideoDetailNewPlayControl ()<TTVDemandPlayerDelegate ,TTVCommodityViewDelegate>
@property (nonatomic, assign) BOOL movieViewInitiated;
@property (nonatomic, assign) BOOL isPlayingWhenDisappear;
@property (nonatomic, assign) BOOL isInactive;
@property (nonatomic, assign) BOOL isPlayingWhenOpenRedPacket;
@property(nonatomic, strong)TTVDemandPlayerContext *context;
@property (nonatomic, strong) TTVCommodityView *commodityView;
@end

@implementation TTVideoDetailNewPlayControl

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.movieView stop];
    [self.movieView removeFromSuperview];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addMovieViewObserver];
        self.isInactive = NO;
    }
    return self;
}

#pragma mark TTVDemandPlayerDelegate

- (void)playerLoadingState:(TTVPlayerLoadState)state
{

}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (state == TTVVideoPlaybackStatePlaying) {
        self.movieBanner.hidden = YES;
        [self ttv_showPrePlayBtnWithBannerHeight:0];
    } else if (state == TTVVideoPlaybackStateFinished) {
        self.movieBanner.hidden = NO;
        [self.movieBanner sendShowEvent];
        // 播放上一个按钮
        [self ttv_showPrePlayBtnWithBannerHeight:(self.movieBanner.hidden)? 0: self.movieBanner.height];
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeControlViewClickScreen:{
            [self ttv_showPrePlayBtnWithBannerHeight:0];
        }
            break;
        case TTVPlayerEventTypeFinishUIShare:{
            [self shareButtonClicked];
        }
            break;
        case TTVPlayerEventTypeTrafficFreeFlowPlay:
        case TTVPlayerEventTypeTrafficPlay:{
            self.movieBanner.hidden = YES;
        }
            break;
        case TTVPlayerEventTypePlayingShare:{
            [self shareButtonOnMovieTopViewDidPress];
        }
            break;
        case TTVPlayerEventTypePlayingMore:{
            [self moreButtonOnMovieTopViewDidPress];
        }
            break;
        case TTVPlayerEventTypeFinishMore:{
            [self moreButtonOnMovieTopViewDidPress]; 
        }
            break;
        case TTVPlayerEventTypeFinishDirectShare:{
            if ([action.payload isKindOfClass:[NSString class] ]) {
                NSString *activityType = action.payload;
                [self directShareActionWithActivityType:activityType];
            }
        }
            break;
        default:
            break;
    }
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerMovieViewFrameAfterExitFullscreen)]) {
        return [self.delegate ttv_playerControlerMovieViewFrameAfterExitFullscreen];
    }
    return CGRectZero;
}

- (void)releatedVideoCliced
{

}

- (BOOL)enableRotate
{
    return !self.forbidLayout && !self.isChangingMovieSize && ![self.article detailShowPortrait];
}

- (void)setForbidLayout:(BOOL)forbidLayout
{
    [super setForbidLayout:forbidLayout];
    [self.movieView.player setEnableRotate:[self enableRotate]];
    self.movieShotView.forbidLayout = forbidLayout;
}

- (void)setIsChangingMovieSize:(BOOL)isChangingMovieSize
{
    [super setIsChangingMovieSize:isChangingMovieSize];
    [self.movieView.player setEnableRotate:[self enableRotate]];
    self.movieShotView.forbidLayout = !isChangingMovieSize;
}

- (void)setMovieFrame:(CGRect)movieFrame
{
    [super setMovieFrame:movieFrame];
    self.movieView.frame = self.movieFrame;
}

- (void)setShareMovie:(TTVideoShareMovie *)shareMovie
{
    [super setShareMovie:shareMovie];
    if (!self.movieShotView) {
        self.shareMovie.posterView = [self addMovieShotView];
    }
    if (self.shareMovie.posterView) {
        [self.shareMovie.posterView removeAllActions];
        [self.shareMovie.posterView.playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([shareMovie.playerControl isKindOfClass:[TTVideoTabBaseCellPlayControl class]]) {
        TTVideoTabBaseCellPlayControl *control = shareMovie.playerControl;
        TTVPlayVideo *movieView = (TTVPlayVideo *)control.movieView;
        if (!movieView) {
            movieView = (TTVPlayVideo *)shareMovie.movieView;
        }
        if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
            self.movieView = movieView;
        }
    }
}

- (void)setMovieView:(TTVPlayVideo *)movieView
{
    if (_movieView != movieView) {
        _movieView = movieView;
        _movieView.player.muted = NO;
        _movieView.player.delegate = self;
        _movieView.player.isInDetail = YES;
        _movieView.player.showTitleInNonFullscreen = NO;
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
    if ([[self article] directPlay]) {
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
//    self.context.tipType != TTVPlayerControlTipViewTypeRetry && 
    return (self.context.tipType != TTVPlayerControlTipViewTypeFinished && !self.context.isShowingTrafficAlert);
}

- (void)playMovieIfNeededAndRebindToMovieShotView:(BOOL)rebindToMovieShotView
{
    BOOL checkSuperViewFlag = rebindToMovieShotView ? [self.movieView superview] != self.movieShotView : [self.movieView superview] == nil;
    if (self.movieView && checkSuperViewFlag) {
        [self.movieShotView addSubview:self.movieView];
    }
    if (self.isPlayingWhenDisappear) {
        [self resumeMovie];
        self.isPlayingWhenDisappear = NO;
    }else{
        if (![self isFirstPlayMovie] && [self shouldAutoPlay]) {
            [self resumeMovie];
        }
    }
}

- (void)pauseMovieIfNeeded
{
    [self.movieView.player pause];
}


- (void)resumeMovie
{
    if (self.movieView) {
        if ([self.movieView.player.pasterPlayer hasPasterAd]) {
            [self.movieView.player.pasterPlayer play];
        }else{
            if (self.commodityView.superview != self.movieView && ![self.movieView.player.context isCommodityViewShow]) {
                [self.movieView.player play];
            }
        }
    }
    else
    {
        [self playButtonClicked];
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

- (void)viewWillAppear
{
    NSInteger index = [self.viewController.navigationController.viewControllers count] - 1;//点击上一个,重新创建播放器后,置为NO
    BOOL should = self.shareMovie.hasClickRelated && [self detalViewControllerAtIndex:index].shouldPlayWhenBack;
    if (should) {
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:[self article].videoID];
        [self playButtonClicked];
        if ([self.delegate respondsToSelector:@selector(ttv_playerControlerPreVideoDidPlay)]) {
            [self.delegate ttv_playerControlerPreVideoDidPlay];
        }
    }else{
        [self playMovieIfNeeded];
    }
    [self detalViewControllerAtIndex:index].shouldPlayWhenBack = NO;
}

- (void)viewWillDisappear
{
    self.isPlayingWhenDisappear = self.context.playbackState == TTVVideoPlaybackStatePlaying;
}

- (void)viewDidDisappear
{

}

- (void)viewDidAppear
{
    
}

- (void)showDetailButtonIfNeeded
{
}

- (void)addMovieViewObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewShow:) name:TTAdAppointAlertViewShowKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewHide:) name:TTAdAppointAlertViewCloseKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    //如果在正在播放时进入详情页，会没有注册监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_openRedPackert:) name:@"TTOpenRedPackertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_closeRedPackert:) name:@"TTCloseRedPackertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFPauseVideoNotification:) name:@"TTSFPauseVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFContinueVideoNotification:) name:@"TTSFContinueVideo" object:nil];

}

- (Article *)article
{
    return self.detailModel.article;
}

- (ExploreOrderedData *)orderedData
{
    return self.detailModel.orderedData;
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

    NSString *category = self.orderedData.categoryID;
    NSString *adID = nil;
    NSString *logExtra = self.orderedData.log_extra;
    NSString *videoID = self.article.videoID;
    if (isEmptyString(videoID)) {
        videoID = [self.article.videoDetailInfo objectForKey:VideoInfoIDKey];
    }
    if (self.fromType == VideoDetailViewFromTypeCategory) {
        adID = self.orderedData.ad_id;

    } else {
        NSNumber *ad_id = [self article].relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
        adID = [ad_id longLongValue] > 0 ? [NSString stringWithFormat:@"%@", ad_id] : @"";
        category = self.detailModel.categoryID;
        if (!logExtra) {
            logExtra = [[self article] relatedLogExtra];
        }
    }

    Article *article = [self article];
    TTGroupModel *group = self.orderedData.article.groupModel;

    TTVPlayerSP sp = ([self.orderedData.article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? TTVPlayerSPLeTV : TTVPlayerSPToutiao;

    //TTVPlayerModel
    TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
    model.categoryID = category;
    model.groupID = group.groupID;
    model.itemID = group.itemID;
    model.aggrType = group.aggrType;
    model.adID = adID;
    model.logExtra = logExtra;
    model.videoID = videoID;
    model.sp = sp;
    model.trackLabel = self.detailModel.clickLabel;
    model.isAutoPlaying = NO;
    model.enterFrom = [self enterFromString];
    model.categoryName = [self categoryName];
    model.authorId = [self.detailModel.article.userInfo ttgc_contentID];
    if (!SSIsEmptyDictionary(self.detailModel.logPb)) {
        model.logPb = self.detailModel.logPb;
    }else{
        model.logPb = self.detailModel.gdExtJsonDict[@"log_pb"];
    }
    if (article.isVideoSourceUGCVideo) {
        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    if ([self.orderedData.article.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
        model.localURL = self.orderedData.article.videoLocalURL;
    }else{
        model.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), self.orderedData.article.videoLocalURL];
    }
    if ([self.orderedData.article hasVideoSubjectID]) {
        model.videoSubjectID = [self.article videoSubjectID];
    }
    if (ttvs_isVideoFeedURLEnabled() && [self.orderedData.article hasVideoPlayInfoUrl] && [self.orderedData.article isVideoUrlValid]) {
        model.videoPlayInfo = self.orderedData.article.videoPlayInfo;
        model.expirationTime = [[NSDate date] timeIntervalSinceDate:self.orderedData.article.createdTime];
    }

    if (!isEmptyString(model.adID)) {//广告
        model.enablePasterAd = NO;
    }else{//非广告使用贴片功能
        model.enablePasterAd = YES;
        model.pasterAdFrom = @"textlink";
    }
    if ([self.orderedData.article.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
        model.localURL = self.orderedData.article.videoLocalURL;
    }else{
        model.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), self.orderedData.article.videoLocalURL];
    }
    if (ttvs_isVideoShowOptimizeShare() > 0){
        if (isEmptyString(model.adID)) {
            model.playerShowShareMore = ttvs_isVideoShowOptimizeShare();
        }
    }
    
    NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();

    //movieView
    self.movieView = [[TTVPlayVideo alloc] initWithFrame:[self frameForMovieView] playerModel:model];
    self.movieView.player.showTitleInNonFullscreen = NO;
    if (isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3){
        self.movieView.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
    }
    self.movieView.player.enableRotate = ![self.article detailShowPortrait];

    [self addUrlTracker];
    _movieView.player.delegate = self;
    NSDictionary *videoLargeImageDict = article.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [article.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [self.movieView setVideoLargeImageDict:videoLargeImageDict];
    //track
    if (self.movieView) {
        [self.movieShotView addSubview:self.movieView];
        [self.movieView.player readyToPlay];
        [self.movieView.player play];
    }
    [self.movieView.player setVideoTitle:self.orderedData.article.title];
    
    if (self.orderedData.isFakePlayCount) {
        [self.movieView.player setVideoWatchCount:self.orderedData.article.readCount playText:@"次阅读"];
    }else{
        [self.movieView.player setVideoWatchCount:[[self.orderedData.article.videoDetailInfo valueForKey:VideoWatchCountKey] doubleValue] playText:@"次播放"];
    }
    [self.movieShotView refreshUI];
}


- (void)addUrlTracker
{
    TTVPlayerUrlTracker *urlTracker = [self.orderedData videoPlayTracker];
    urlTracker.videoThirdMonitorUrl = self.orderedData.article.videoThirdMonitorUrl;
    [self.movieView.commonTracker registerTracker:urlTracker];
}


- (ArticleVideoPosterView *)addMovieShotView
{
    ArticleVideoPosterView *poster = [[ArticleVideoPosterView alloc] init];
    poster.isAD = NO;
    poster.showSourceLabel = NO;
    poster.showPlayButton = YES;
    return poster;
}

- (void)attachMovieView
{
    self.commodityView.position = [self getCommodityPosition];
    if (!([self.movieView.superview isKindOfClass:[UIWindow class]] || self.context.isFullScreen)) {
        self.movieView.player.enableRotate = ![self.article detailShowPortrait];
        [self.movieShotView addSubview:self.movieView];
        [self.movieShotView bringSubviewToFront:self.movieView];
    }
    [self.movieView.player setVideoTitle:[self article].title];
    [self.movieView.player setVideoWatchCount:[[self.orderedData.article.videoDetailInfo valueForKey:VideoWatchCountKey] doubleValue] playText:@"次播放"];
    self.movieView.hidden = NO;
    self.movieShotView.hidden = NO;
    [self.movieView.player setVideoWatchCount:[[self.orderedData.article.videoDetailInfo valueForKey:VideoWatchCountKey] doubleValue] playText:@"次播放"];
}

- (BOOL)isPlaying
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        return YES;
    }
    return NO;
}

- (NSString *)getCommodityPosition
{
    if (self.movieView && [self.movieView.player.context isFullScreen]) {
        return @"fullscreen";
    }
    return @"detail";
}

- (void)addCommodity
{
    [self.commodityView ttv_removeFromSuperview];
    TTVCommodityView *commodity = nil;
    if (self.movieView.superview) {
        commodity = [[TTVCommodityView alloc] initWithFrame:self.movieView.bounds];
        commodity.videoID = self.article.videoID;
        commodity.groupID = self.article.groupModel.groupID;
        commodity.position = [self getCommodityPosition];
        commodity.playVideo = self.movieView;
        [self.movieView.player setCommodityView:commodity];
    }
    commodity.delegate = self;
    [commodity setCommoditys:self.orderedData.article.commoditys];
    [commodity showCommodity];
    self.commodityView = commodity;
}

- (void)commodityViewClosed
{

}

#pragma mark notification

- (void)ttv_openRedPackert:(NSNotification *)notification
{
    if ([self isPlaying]) {
        self.isPlayingWhenOpenRedPacket = YES;
    }
    [self.movieView.player pause];
}

- (void)ttv_closeRedPackert:(NSNotification *)notification
{
    if (self.isPlayingWhenOpenRedPacket) {
        [self.movieView.player play];
    }
    self.isPlayingWhenOpenRedPacket = NO;
}

- (void)TTSFPauseVideoNotification:(NSNotification *)notification
{
    if ([self isPlaying]) {
        self.isPlayingWhenOpenRedPacket = YES;
    }
    [self.movieView.player pause];
}

- (void)TTSFContinueVideoNotification:(NSNotification *)notification
{
    if (self.isPlayingWhenOpenRedPacket) {
        [self.movieView.player play];
    }
    self.isPlayingWhenOpenRedPacket = NO;
}


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
    [self.movieView stop];
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    [self.movieView.player pause];
    [self.movieView exitFullScreen:YES completion:^(BOOL finished) {

    }];
}

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    [self.movieShotView refreshUI];
    [self.movieView removeFromSuperview];

}

- (BOOL)shouldLayoutSubviews
{
    return !self.forbidLayout && !self.isChangingMovieSize;
}

- (ArticleVideoPosterView *)movieShotView
{
    return self.shareMovie.posterView;
}

- (void)receiveAdClick:(NSNotification *)notification
{
    [self.movieView.commonTracker sendEndTrack];
}

- (void)skStoreViewDidAppear:(NSNotification *)notification
{
    [self pauseMovieIfNeeded];
}

- (void)skStoreViewDidDisappear:(NSNotification *)notification
{
    [self playMovieIfNeeded];
}
     
- (void)appointAlertViewShow:(NSNotification *)notification
{
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)appointAlertViewHide:(NSNotification *)notification
{
    [self.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

#pragma mark movideView delegate

- (TTVideoDetailViewController *)detalViewControllerAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.viewController.navigationController.viewControllers.count) {
        TTDetailContainerViewController *controller = [self.viewController.navigationController.viewControllers objectAtIndex:index];
        TTVideoDetailViewController *detail = nil;
        if ([controller isKindOfClass:[TTDetailContainerViewController class]]) {
            detail = (TTVideoDetailViewController *)controller.detailViewController;
            if ([detail isKindOfClass:[TTVideoDetailViewController class]]) {
                return detail;
            }
        }
    }
    return nil;
}

- (void)shareButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieFinishViewClicked)]) {
        [self.delegate ttv_shareButtonOnMovieFinishViewClicked];
    }
}

- (void)shareButtonOnMovieTopViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieTopViewClicked)]){
        [self.delegate ttv_shareButtonOnMovieTopViewClicked];
    }
}

- (void)moreButtonOnMovieTopViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_moreButtonOnMovieTopViewClicked)]) {
        [self.delegate ttv_moreButtonOnMovieTopViewClicked];
    }

}

- (void)directShareActionWithActivityType:(NSString *)activityType{
    if ([self.delegate respondsToSelector:@selector(ttv_playerShareActionClickedWithActivityType:)]){
        [self.delegate ttv_playerShareActionClickedWithActivityType:activityType];
    }
}

- (NSString *)enterFromString{
    NSString *enterFrom = self.detailModel.clickLabel;
    if (![enterFrom isEqualToString:@"click_headline"]) {
        if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceCategory)
        {
            enterFrom = @"click_category";
        }
        else if (self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
            enterFrom = @"click_widget";
        }
    }
    return enterFrom;
}

- (NSString *)categoryName{
    NSString *categoryName = self.detailModel.categoryID;
    if (!categoryName || [categoryName isEqualToString:@"xx"]) {
        categoryName = [[self enterFromString] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }else{
        if (![[self enterFromString] isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }
    return categoryName;
}

@end
