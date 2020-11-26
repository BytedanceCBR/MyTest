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
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "JSONAdditions.h"
#import "TTVPlayerAudioController.h"
#import "TTVPlayerTipShareCreater.h"
#import "TTVPlayerTipRelatedCreator.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVAutoPlayManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface TTVCellPlayMovie ()<TTVDemandPlayerDelegate,TTVPlayVideoDelegate>

@property (nonatomic, strong) TTVFeedCellMoreActionManager *moreActionMananger;
@property (nonatomic, copy) dispatch_block_t shareButtonClickedBlock;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) CGRect movieViewFrame;
@property (nonatomic, strong) TTVPlayerModel *model;

@end

@implementation TTVCellPlayMovie
@synthesize movieView = _movieView;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isActive = YES;
        [self addNotification];
    }
    return self;
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
            return YES;
        }
        return NO;
    };
    
    [self.moreActionMananger shareButtonOnMovieClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {

    }];
}

- (void)shareButtonClicked
{
    if (_shareButtonClickedBlock) {
        _shareButtonClickedBlock();
    }
}

- (void)setCellEntity:(TTVFeedListItem *)cellEntity {
    _cellEntity = cellEntity;
    [self configurePlayerModel];
}

- (void)configurePlayerModel {
    TTVPlayerSP sp = (self.cellEntity.article.groupFlags & ArticleGroupFlagsDetailSP) > 0 ? TTVPlayerSPLeTV : TTVPlayerSPToutiao;
    TTVFeedItem *feedItem = self.cellEntity.originData;
    TTVVideoArticle *article = self.cellEntity.article;
    
    //TTVPlayerModel
    TTVPlayerModel *model = [[TTVPlayerModel alloc] init];
    model.categoryID = self.cellEntity.categoryId;
    model.groupID = [NSString stringWithFormat:@"%lld",article.groupId];
    model.itemID = [NSString stringWithFormat:@"%lld",article.itemId];
    model.aggrType = article.aggrType;
    model.adID = article.adId;
    model.logExtra = article.logExtra;
    model.videoID = article.videoId;
    model.sp = sp;
    model.categoryName = self.cellEntity.categoryId;
    model.authorId = article.userId;
    model.extraDic = self.cellEntity.extraDic;
    model.enableCommonTracker = YES;
    
//    if (feedItem.isVideoSourceUGCVideo) {
//        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
//    }
    NSDictionary *dic = [feedItem.logPb tt_JSONValue];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        model.logPb = dic;
    }
    if (!isEmptyString(article.videoDetailInfo.videoSubjectId)) {
        model.videoSubjectID = article.videoDetailInfo.videoSubjectId;
    }
//    BOOL isVideoFeedURLEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_feed_url" defaultValue:@NO freeze:NO] boolValue];
//    if (isVideoFeedURLEnabled && [self.cellEntity.originData hasVideoPlayInfoUrl] && [self.cellEntity.originData isVideoUrlValid]) {
//        model.videoPlayInfo = self.cellEntity.originData.videoPlayInfo;
//    }

    _model = model;
}

- (void)readyToPlay {
    TTVFeedItem *feedItem = self.cellEntity.originData;
    TTVVideoArticle *article = self.cellEntity.article;
    //movieView
    TTVPlayVideo *playVideo = [[TTVPlayVideo alloc] initWithFrame:self.logo.bounds playerModel:self.model];
    playVideo.player.delegate = self;
    playVideo.delegate = self;

    NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
    if ((isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3) && isEmptyString(self.model.adID)){
        playVideo.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
    }
    
    playVideo.player.enableRotate = !self.cellEntity.forbidRotate;
    
    NSDictionary *videoLargeImageDict = feedItem.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [feedItem.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [playVideo setVideoLargeImageDict:videoLargeImageDict];
    self.movieView = playVideo;
    [self.movieView.player readyToPlay];
    self.movieView.player.muted = self.cellEntity.muted;
    [self addUrlTrackerOnPlayer:playVideo];
    [self settingMovieView:self.movieView];
    
    if(!self.cellEntity.hideTitleAndWatchCount){
        [playVideo.player setVideoTitle:feedItem.title];
        [playVideo.player setVideoWatchCount:article.videoDetailInfo.videoWatchCount playText:@"次播放"];
    }
    self.logo.userInteractionEnabled = ![feedItem couldAutoPlay];
}

- (void)play
{
    if(!self.movieView || self.movieView.hidden){
        [self readyToPlay];
    }

    if(self.movieView.superview){
        self.movieView.hidden = NO;
        if (!self.movieView.player.context.isFullScreen &&
            !self.movieView.player.context.isRotating) {
            if (self.movieView.player.context.playbackState != TTVVideoPlaybackStatePlaying) {
                [self.movieView.player play];
            }
        }
    }else{
        [ExploreMovieView removeAllExceptExploreMovieView:self.movieView];
        [self.logo addSubview:self.movieView];
        [self.movieView.player play];
    }
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

#pragma mark TTVDemandPlayerDelegate

- (void)playerLoadingState:(TTVPlayerLoadState)state
{
    
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if ([self.delegate respondsToSelector:@selector(playerPlaybackState:)]) {
        [self.delegate playerPlaybackState:state];
    }
    if (state == TTVVideoPlaybackStateFinished ||
        state == TTVVideoPlaybackStateError) {
        self.logo.userInteractionEnabled = YES;
    }
    if (state == TTVVideoPlaybackStateFinished) {
        [self moviePlayFinishedAction];
    }
}

- (void)playerCurrentPlayBackTimeChange:(NSTimeInterval)currentPlayBackTime duration:(NSTimeInterval)duration {
    if ([self.delegate respondsToSelector:@selector(playerCurrentPlayBackTimeChange:duration:)]) {
        [self.delegate playerCurrentPlayBackTimeChange:currentPlayBackTime duration:duration];
    }
}

- (void)playerOrientationState:(BOOL)isFullScreen {
    if(self.cellEntity.hideTitleAndWatchCount){
        if(isFullScreen){
            [self.movieView.player setVideoTitle:self.cellEntity.originData.title];
        }else{
            [self.movieView.player setVideoTitle:nil];
        }
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
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo[@"video"] && userInfo[@"video"] == self.movieView){
        return;
    }
    
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

    [self.movieView removeFromSuperview];
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
        if (self.movieView && self.movieView.superview) {
            [self invalideMovieView];
            if (!self.isActive) {
                [self.movieView removeFromSuperview];
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

@end
