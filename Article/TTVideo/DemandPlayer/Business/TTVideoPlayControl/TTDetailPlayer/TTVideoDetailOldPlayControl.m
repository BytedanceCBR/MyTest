//
//  TTVideoDetailOldPlayControl.m
//  Article
//
//  Created by panxiang on 2017/6/6.
//
//

#import "TTVideoDetailOldPlayControl.h"
#import "ExploreMovieView.h"
#import "SSAppStore.h"
#import "TTMovieViewCacheManager.h"
#import "KVOController.h"
#import "TTVideoMovieBanner.h"
#import "TTDetailContainerViewController.h"
#import "TTAdManager.h"
#import "TTVideoDetailViewController.h"
#import "TTDetailContainerViewController.h"
#import "TTTrackerProxy.h"
#import "TTAdAppointAlertView.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "ExploreOrderedData.h"
#import "ExploreOrderedData+TTAd.h"

extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);

@interface TTVideoDetailOldPlayControl ()<ExploreMovieViewDelegate>
@property (nonatomic, assign) BOOL movieViewInitiated;
@property (nonatomic, assign) BOOL isInactive;
@property (nonatomic, assign) BOOL isPlayingWhenOpenRedPacket;
@end

@implementation TTVideoDetailOldPlayControl
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewPlayFinished:) name:kExploreMovieViewPlaybackFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
        [self addObserver];
    }
    return self;
}
- (void)releatedVideoCliced
{
    [self invalideMovieView];
    [ExploreMovieView removeAllExploreMovieView];
    self.movieView = nil;
}

- (void)setForbidLayout:(BOOL)forbidLayout
{
    [super setForbidLayout:forbidLayout];
    self.movieView.forbidLayout = forbidLayout;
    self.movieShotView.forbidLayout = forbidLayout;
    
}

- (void)setIsChangingMovieSize:(BOOL)isChangingMovieSize
{
    [super setIsChangingMovieSize:isChangingMovieSize];
    self.movieView.isChangingMovieSize = isChangingMovieSize;
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
        [self addMovieShotView];
    }
    [self settingMovieShotView:self.shareMovie.posterView];
    TTVideoTabBaseCellPlayControl *control = shareMovie.playerControl;
    ExploreMovieView *movieView = (ExploreMovieView *)control.movieView;
    if (!movieView) {
        movieView = (ExploreMovieView *)shareMovie.movieView;
    }
    [self movieViewAddDelegate:movieView];
    if ([movieView isKindOfClass:[ExploreMovieView class]]) {
        movieView.shouldShowNewFinishUI = YES;
    }
    
}

- (void)updateFrame
{
    [self.movieView updateFrame];
    [self.movieShotView updateFrame];
}

- (void)setForbidFullScreenWhenPresentAd:(BOOL)forbidFullScreenWhenPresentAd
{
    [super setForbidFullScreenWhenPresentAd:forbidFullScreenWhenPresentAd];
    self.movieView.forbidFullScreenWhenPresentAd = forbidFullScreenWhenPresentAd;
}

- (float)watchPercent
{
    return self.movieView.duration > 0 ? self.movieView.currentPlayingTime/self.movieView.duration : 0;
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

- (void)p_refreshFinishActionPrePlayBtnWithBannerHeight:(CGFloat)height {
    [self.movieView.moviePlayerController.controlView updateFinishActionItemsFrameWithBannerHeight:height];
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
    return [self.movieView.moviePlayerController isMovieFullScreen];
}

/**
 网络请求回来调用
 */
- (void)playMovieIfNeededAndRebindToMovieShotView:(BOOL)rebindToMovieShotView
{
    BOOL checkSuperViewFlag = rebindToMovieShotView ? [self.movieView superview] != self.movieShotView : [self.movieView superview] == nil;
    if (self.movieView && checkSuperViewFlag) {
        [self.movieShotView addSubview:self.movieView];
    }
    if (!self.movieView) {
        //自动播放, 服务端可控
        [self autoClickedPlayButton];
    } else {
        //继续播放
        if (![self.movieView isMovieFullScreen]) {
            [self attachMovieView];
        }
        if (![self.movieView isPlayingFinished]) {
            [self resumeMovie];
        }
    }
}

- (void)pauseMovieIfNeeded
{
    [self.movieView pauseMovie];
}


- (void)resumeMovie
{
    if (self.movieView) {
        [self.movieView resumeMovie];
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
    [self.movieView.moviePlayerController.controlView setToolBarHidden:hidden];
}

- (void)viewWillAppear
{
    NSInteger index = [self.viewController.navigationController.viewControllers count] - 1;//点击上一个,重新创建播放器后,置为NO
    BOOL should = self.shareMovie.hasClickRelated && [self detalViewControllerAtIndex:index].shouldPlayWhenBack;
    if (should) {
        [[TTMovieViewCacheManager sharedInstance] removeCacheMovieView:self.movieView forVideoID:[self article].videoID];
        [self playButtonClicked];
        if ([self.delegate respondsToSelector:@selector(ttv_playerControlerPreVideoDidPlay)]) {
            [self.delegate ttv_playerControlerPreVideoDidPlay];
        }
    }else{
        [self playMovieIfNeeded];
    }
    [self detalViewControllerAtIndex:index].shouldPlayWhenBack = NO;
    [self.movieView willAppear];
}

- (void)viewWillDisappear
{
    [self.movieView willDisappear];
}

- (void)viewDidDisappear
{
    [self.movieView didDisappear];
}

- (void)viewDidAppear
{
    [self.movieView didAppear];
}

- (void)showDetailButtonIfNeeded
{
    [self.movieView showDetailButtonIfNeeded];
}

- (void)addMovieViewObserver
{
    if (self.movieView) {
        __weak typeof(self) wself = self;
        [self.KVOController observe:self.movieView keyPath:NSStringFromSelector(@selector(isPlaying)) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            __strong typeof(wself) self = wself;
            if (self.movieView.isPlaying) {
                self.movieBanner.hidden = YES;
            } else if (self.movieView.isPlayingFinished) {
                self.movieBanner.hidden = NO;
                [self.movieBanner sendShowEvent];
                
                // 播放上一个按钮
                [self p_refreshFinishActionPrePlayBtnWithBannerHeight:(self.movieBanner.hidden)? 0: self.movieBanner.height];
                [self.movieView.moviePlayerController.controlView updateFinishShareActionItemsFrameWithBannerHeight:self.movieBanner.height];
            }
        }];
    }
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
    Article *article = [self article];
    ExploreOrderedData *orderedData = [self orderedData];
    if (orderedData == nil) {
        LOGD(@"error");
    }
    
    ExploreMovieViewModel *movieViewModel = [ExploreMovieViewModel viewModelWithOrderData:orderedData];
    if (!movieViewModel && article.videoAdExtra) {
        movieViewModel = [ExploreMovieViewModel viewModelWithArticleVideoAdExtra:article];
    }
    if (!movieViewModel) {
        movieViewModel = [[ExploreMovieViewModel alloc] init];
    }
    movieViewModel.type                   = ExploreMovieViewTypeDetail;
    movieViewModel.gdLabel                = self.detailModel.clickLabel;
    movieViewModel.videoPlayType          = TTVideoPlayTypeNormal ;
    movieViewModel.auithorId              = [self.detailModel.article.userInfo ttgc_contentID];
    //直播cell类型
    NSInteger videoType = 0;
    if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
        videoType = ((NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
    }
    if (videoType == 1) {
        movieViewModel.videoPlayType  = TTVideoPlayTypeLive;
    }
    
    movieViewModel.cID            = orderedData.categoryID;
    if (self.fromType == VideoDetailViewFromTypeCategory) {
        NSString *aID = orderedData.ad_id;
        movieViewModel.aID            = aID;
        movieViewModel.cID            = orderedData.categoryID;
        
    } else {
        NSNumber *ad_id = [self article].relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
        NSString *aID = [ad_id longLongValue] > 0 ? [NSString stringWithFormat:@"%@", ad_id] : @"";
        movieViewModel.aID = aID;
        movieViewModel.cID = self.detailModel.categoryID;
        
        if (!movieViewModel.logExtra) {
            movieViewModel.logExtra = [[self article] relatedLogExtra];
        }
    }
    
    NSString *videoID = article.videoID;
    if (isEmptyString(videoID)) {
        videoID = [article.videoDetailInfo objectForKey:VideoInfoIDKey];
    }
    movieViewModel.useSystemPlayer = !isEmptyString(article.videoLocalURL);
    ExploreMovieView *movie = [[TTMovieViewCacheManager sharedInstance] movieViewWithVideoID:videoID frame:[self frameForMovieView] type:ExploreMovieViewTypeDetail trackerDic:nil movieViewModel:movieViewModel];
    [self settingMovieView:movie];
    self.movieView.shouldShowNewFinishUI = YES;
    self.movieView.enableMultiResolution = YES;
    [self.movieView enableRotate:![self.article detailShowPortrait]];
    [self.movieView setVideoTitle:article.title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    NSDictionary *videoLargeImageDict = article.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [article.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [self.movieView setLogoImageDict:videoLargeImageDict];
    [self.movieView setVideoDuration:[article.videoDuration doubleValue]];
    [self.movieShotView addSubview:self.movieView];
    
    if (ttvs_isVideoShowOptimizeShare() > 0){
        if (isEmptyString(movieViewModel.aID)) {
            self.movieView.moviePlayerController.shouldShowShareMore = ttvs_isVideoShowOptimizeShare();
        }
    }
    self.movieView.moviePlayerController.isVideoBusiness = YES;
    ExploreVideoSP sp = ([article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? ExploreVideoSPLeTV : ExploreVideoSPToutiao;
    
    
    if ([[self article] hasVideoSubjectID]) {
        [self.movieView.tracker addExtraValue:[[self article] videoSubjectID] forKey:@"video_subject_id"];
    }
    [self addmovieTrackerEvent3Data];
    if (ttvs_isVideoFeedURLEnabled() && [article hasVideoPlayInfoUrl] && [article isVideoUrlValid]) {
        [self.movieView playVideoWithVideoInfo:article.videoPlayInfo exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    }
    else
    {
        [self.movieView playVideoForVideoID:videoID exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    }
    [self.movieShotView refreshUI];
}


- (void)addMovieShotView
{
    [self settingMovieShotView:[[ArticleVideoPosterView alloc] init]];
    self.shareMovie.posterView.isAD = NO;
    self.shareMovie.posterView.showSourceLabel = NO;
    self.shareMovie.posterView.showPlayButton = YES;
}

- (void)attachMovieView
{
    if (!([self.movieView.superview isKindOfClass:[UIWindow class]] || [self.movieView isMovieFullScreen])) {
        [self.movieView enableRotate:![self.article detailShowPortrait]];
        [self.movieShotView addSubview:self.movieView];
        [self.movieShotView bringSubviewToFront:self.movieView];
    }
    [self.movieView setVideoTitle:[self article].title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    self.movieView.hidden = NO;
    self.movieShotView.hidden = NO;
}

- (void)invalideMovieView
{
    if (self.movieView) {
        if (self.movieView.superview == self.movieShotView)
        {
            [self.movieView removeFromSuperview];
        }
        [self.movieView stopMovie];
        [self.movieView exitFullScreenIfNeed:NO];
        [self settingMovieView:nil];
    }
}

- (void)ttv_openRedPackert:(NSNotification *)notification
{
    if (self.movieView.isPlaying) {
        self.isPlayingWhenOpenRedPacket = YES;
    }
    [self.movieView pauseMovie];
}

- (void)ttv_closeRedPackert:(NSNotification *)notification
{
    if (self.isPlayingWhenOpenRedPacket) {
        [self.movieView playMovie];
    }
    self.isPlayingWhenOpenRedPacket = NO;
}

- (void)TTSFPauseVideoNotification:(NSNotification *)notification
{
    if (self.movieView.isPlaying) {
        self.isPlayingWhenOpenRedPacket = YES;
    }
    [self.movieView pauseMovie];
}

- (void)TTSFContinueVideoNotification:(NSNotification *)notification
{
    if (self.isPlayingWhenOpenRedPacket) {
        [self.movieView playMovie];
    }
    self.isPlayingWhenOpenRedPacket = NO;
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    if (self.movieView) {
        self.movieShotView.showPlayButton = YES;
        [self.movieView stopMovie];
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView removeFromSuperview];
    }
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if (self.movieView) {
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView pauseMovie];
    }
}

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [self.movieShotView refreshUI];
        [self.movieView removeFromSuperview];
    }
}

- (BOOL)shouldLayoutSubviews
{
    return !self.movieShotView.forbidLayout && !self.movieView.isChangingMovieSize;
}

- (void)layoutSubViews
{
    if (![self.movieView isMovieFullScreen] && !self.movieView.isRotateAnimating) {
        self.movieView.frame = [self frameForMovieView];
    }
}

- (void)movieViewAddDelegate:(ExploreMovieView *)movieView
{
    if ([movieView isKindOfClass:[ExploreMovieView class]]) {
        [self removeMovieViewObserver];
        self.shareMovie.movieView = movieView;
        [movieView markAsDetail];
        switch (self.detailModel.fromSource) {
            case NewsGoDetailFromSourceVideoFloat:
                movieView.tracker.subType = ExploreMovieViewTypeFloatMain;
                break;
            case NewsGoDetailFromSourceVideoFloatRelated:
                movieView.tracker.subType = ExploreMovieViewTypeFloatRelated;
                break;
            case NewsGoDetailFromSourceReadHistory:
                movieView.tracker.subType = ExploreMovieViewTypeReadHistory;
                break;
            case NewsGoDetailFromSourcePushHistory:
                movieView.tracker.subType = ExploreMovieViewTypePushHistory;
                break;
            default:
                movieView.tracker.subType = ExploreMovieViewTypeUnkown;
                break;
        }
        
        movieView.pauseMovieWhenEnterForground = NO;
        movieView.showDetailButtonWhenFinished = NO;
        movieView.movieViewDelegate = self;
        [self addMovieViewObserver];
    }
}

- (void)settingMovieView:(ExploreMovieView *)movieView
{
    if (self.shareMovie.movieView != movieView) {
        [self movieViewAddDelegate:movieView];
    }
}

- (void)settingMovieShotView:(ArticleVideoPosterView *)movieShotView
{
    if (self.shareMovie.posterView != movieShotView) {
        self.shareMovie.posterView = movieShotView;
    }
    if (self.shareMovie.posterView) {
        [self.shareMovie.posterView removeAllActions];
        [self.shareMovie.posterView.playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (ExploreMovieView *)movieView
{
    if ([self.shareMovie.movieView isKindOfClass:[ExploreMovieView class]]) {
        return (ExploreMovieView *)self.shareMovie.movieView;
    }
    return nil;
}

- (ArticleVideoPosterView *)movieShotView
{
    return self.shareMovie.posterView;
}

- (void)receiveAdClick:(NSNotification *)notification
{
    [self.movieView.tracker sendEndTrack];
}


- (void)removeMovieViewObserver
{
    if (self.movieView) {
        [self.KVOController unobserve:self.movieView];
    }
}

#pragma mark notification

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewShow:) name:TTAdAppointAlertViewShowKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewHide:) name:TTAdAppointAlertViewCloseKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAdClick:) name:@"kTTAdVideoManagerDidRelateAdClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_openRedPackert:) name:@"TTOpenRedPackertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_closeRedPackert:) name:@"TTCloseRedPackertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFPauseVideoNotification:) name:@"TTSFPauseVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFContinueVideoNotification:) name:@"TTSFContinueVideo" object:nil];
}

- (void)ttv_ApplicationWillResignActiveNotification:(NSNotification *)notification
{
    self.isInactive = YES;
}

- (void)ttv_ApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    self.isInactive = NO;
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
     [self pauseMovieIfNeeded];
}

- (void)appointAlertViewHide:(NSNotification *)notification
{
    [self playMovieIfNeeded];
}

- (void)addmovieTrackerEvent3Data{
    [self.movieView.tracker addExtraValueFromDic:self.detailModel.gdExtJsonDict];
    [self.movieView.tracker addExtraValue:self.detailModel.article.itemID forKey:@"item_id"];
    [self.movieView.tracker addExtraValue:[self.detailModel uniqueID] forKey:@"group_id"];
    [self.movieView.tracker addExtraValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    [self.movieView.tracker addExtraValue:self.detailModel.logPb forKey:@"log_pb"];
    [self.movieView.tracker addExtraValue:self.detailModel.article.videoID forKey: @"video_id"];
    NSString *enterFrom = self.detailModel.clickLabel;
    NSString *categoryName = self.detailModel.categoryID;
    if (![enterFrom isEqualToString:@"click_headline"]) {
        if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceCategory)
        {
            enterFrom = @"click_category";
        }
        else if (self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
            enterFrom = @"click_widget";
        }
        if ([categoryName hasPrefix:@"_"]) {
            categoryName = [categoryName substringFromIndex:1];
        }
    }
    if (!categoryName || [categoryName isEqualToString:@"xx"]) {
        categoryName = [enterFrom stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }
    [self.movieView.tracker addExtraValue:enterFrom forKey:@"enter_from"];
    [self.movieView.tracker addExtraValue:categoryName forKey:@"category_name"];

    
    /** TODO video_play
     *parent_enterfrom
     *question_id
     *group_source
     */
    
    /** TODO video_over
     *parent_enterfrom
     *question_id
     *group_source
     */
    
}


#pragma mark movideView delegate
- (void)showDetailButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerShowDetailButtonClicked)]) {
        [self.delegate ttv_playerControlerShowDetailButtonClicked];
    }
}

- (BOOL)shouldShowDetailButton
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerShouldShowDetailButton)]) {
        return [self.delegate ttv_playerControlerShouldShowDetailButton];
    }
    return NO;
}

- (CGRect)movieViewFrameAfterExitFullscreen
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerControlerMovieViewFrameAfterExitFullscreen)]) {
        return [self.delegate ttv_playerControlerMovieViewFrameAfterExitFullscreen];
    }
    return CGRectZero;
}

- (BOOL)shouldDisableUserInteraction
{
    return NO;
}

- (BOOL)shouldPlayWhenViewWillAppear
{
    if (!self.movieView) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldResumePlayWhenActive
{
    return (self.viewController.parentViewController == self.navigationController.topViewController && !self.viewController.presentedViewController && !self.navigationController.presentedViewController);
}

- (void)replayButtonClicked
{
    self.movieViewInitiated = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttv_playerReplayButtonClicked)]){
        [self.delegate ttv_playerReplayButtonClicked];
    }
}

- (void)replayButtonClickedInTrafficView
{
    self.movieBanner.hidden = YES;
    self.movieViewInitiated = YES;
}

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

- (BOOL)shouldStopMovieWhenInBackground
{
    return NO;
}

- (void)shareActionClickedWithActivityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_playerShareActionClickedWithActivityType:)]) {
        [self.delegate ttv_playerShareActionClickedWithActivityType:activityType];
    }
}


- (void)shareButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieFinishViewClicked)]) {
        [self.delegate ttv_shareButtonOnMovieFinishViewClicked];
    }
}

- (void)FullScreenshareButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieTopViewClicked)]) {
        [self.delegate ttv_shareButtonOnMovieTopViewClicked];
    }
}

- (void)moreButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(ttv_moreButtonOnMovieTopViewClicked)]) {
        [self.delegate ttv_moreButtonOnMovieTopViewClicked];
    }
}

- (void)controlViewTouched:(ExploreMoviePlayerControlView *)controlView {
    [controlView enablePrePlayBtn:NO isFromFinishAtion:NO];
}

@end

