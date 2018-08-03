//
//  TTVideoTabBaseCellNewPlayControl.m
//  Article
//
//  Created by panxiang on 2017/6/5.
//
//

#import "TTVideoTabBaseCellNewPlayControl.h"
#import "TTVPlayVideo.h"
#import "ExploreOrderedData.h"
#import "Article.h"
//#import "TTVideoTabLiveCellView.h"
#import "TTMovieViewCacheManager.h"
#import "TTVideoAutoPlayManager.h"
#import "ExploreArticleMovieViewDelegate.h"
#import "TTVideoCellActionBar.h"
#import "TTMovieExitFullscreenAnimatedTransitioning.h"
#import "TTVFullscreeenController.h"
#import "ExploreCellBase.h"
#import "KVOController.h"
#import "TTVPasterPlayer.h"
#import "TTVPlayerTipAdCreator.h"
#import "TTVPlayerTipAdFinished.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerUrlTracker.h"
#import "ExploreMovieView.h"
#import <TTImageView.h>
#import "TTUIResponderHelper.h"
#import "TTVPlayerTipShareCreater.h"
#import "TTVCommodityView.h"
#import "TTMessageCenter.h"
#import "TTVCommodityViewMessage.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "TTVCommodityFloatView.h"

#import "SSADEventTracker.h"
#import "ExploreOrderedData+TTAd.h"
#import "ExploreActionButton.h"

extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface TTVideoTabBaseCellNewPlayControl ()<TTVDemandPlayerDelegate ,TTVPlayVideoDelegate,TTVCommodityViewDelegate ,TTVCommodityViewMessage>
@property(nonatomic, strong)TTVPlayVideo *movieView;
@property(nonatomic, assign)BOOL isActive;
@property(nonatomic, assign)BOOL isPlayingWhenOpenRedPacket;
@property (nonatomic, strong) ExploreArticleMovieViewDelegate *movieViewDelegate;
@property (nonatomic, weak) UIViewController *presentedViewController;
@property (nonatomic, assign) BOOL playIsPlayingBefore;
@property (nonatomic, strong) TTVCommodityView *commodityView;
@end


@implementation TTVideoTabBaseCellNewPlayControl
@dynamic movieView;

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

- (void)playButtonClicked
{
    [ExploreMovieView removeAllExploreMovieView];
    SAFECALL_MESSAGE(TTVCommodityViewMessage, @selector(ttv_message_removeall_comodityview), ttv_message_removeall_comodityview);

    TTGroupModel *group = self.orderedData.article.groupModel;

    TTVPlayerSP sp = ([self.orderedData.article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? TTVPlayerSPLeTV : TTVPlayerSPToutiao;

    //TTVPlayerModel
    TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
    model.categoryID = self.orderedData.categoryID;
    model.groupID = group.groupID;
    model.itemID = group.itemID;
    model.aggrType = group.aggrType;
    model.adID = self.orderedData.ad_id;
    model.logExtra = self.orderedData.log_extra;
    model.videoID = self.orderedData.article.videoID;
    model.sp = sp;
    model.categoryName = [self categoryName];
    model.enterFrom = [self enterFromString];
    model.logPb = self.orderedData.logPb;
    model.authorId = [self.orderedData.article.userInfo ttgc_contentID];
    if ([self.orderedData.article hasVideoSubjectID]) {
        model.videoSubjectID = [self.article videoSubjectID];
    }
    if (self.orderedData.article.isVideoSourceUGCVideo) {
        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    if (!isEmptyString(model.adID)) {//广告
        model.enablePasterAd = NO;
    }else{//非广告使用贴片功能
        model.enablePasterAd = YES;
        model.pasterAdFrom = @"feed";
    }
    model.isAutoPlaying = [self.orderedData couldAutoPlay];
    if ([self.orderedData.article.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
        model.localURL = self.orderedData.article.videoLocalURL;
    }else{
        model.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), self.orderedData.article.videoLocalURL];
    }
    if (ttvs_isVideoFeedURLEnabled() && [self.orderedData.article hasVideoPlayInfoUrl] && [self.orderedData.article isVideoUrlValid]) {
        model.videoPlayInfo = self.orderedData.article.videoPlayInfo;
    }
    //分享一期
    if (ttvs_isVideoShowOptimizeShare() > 0){
        if (isEmptyString(model.adID)) {
            model.playerShowShareMore = ttvs_isVideoShowOptimizeShare();
        }
    }
    //movieView
    self.movieView = [[TTVPlayVideo alloc] initWithFrame:self.logo.bounds playerModel:model];
    if (!isEmptyString(model.adID)) {//广告
        self.movieView.player.tipCreator = [[TTVPlayerTipAdCreator alloc] init];
    }else{
        NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
        if (isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3){
            self.movieView.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
        }
    }

    self.movieView.player.commodityFloatView.animationToView = self.actionBar.moreButton;
    self.movieView.player.commodityFloatView.animationSuperView = self.actionBar.superview;
    self.movieView.player.delegate = self;
    self.movieView.delegate = self;
    self.movieView.player.enableRotate = ![self.orderedData.article showPortrait];

    [self addUrlTracker];
    [super setMovieView:self.movieView];
    [self.logo addSubview:self.movieView];
    NSDictionary *videoLargeImageDict = self.article.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [self.article.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [self.movieView setVideoLargeImageDict:videoLargeImageDict];
    self.logo.userInteractionEnabled = ![self.orderedData couldAutoPlay];
    [self.movieView.player readyToPlay];
    [self settingMovieView:self.movieView];
    [self.movieView.player play];
    [self.movieView.player setVideoTitle:self.orderedData.article.title];
    
    if (self.orderedData.isFakePlayCount) {
        [self.movieView.player setVideoWatchCount:self.orderedData.article.readCount playText:@"次阅读"];
    }else{
        [self.movieView.player setVideoWatchCount:[[self.orderedData.article.videoDetailInfo valueForKey:VideoWatchCountKey] doubleValue] playText:@"次播放"];
    }

    [self ttv_configADFinishedView:self.movieView.player.tipCreator.tipFinishedView];

}

- (void)addCommodity{
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
    commodity.videoID = self.article.videoID;
    commodity.groupID = self.article.groupModel.groupID;
    commodity.delegate = self;
    [commodity setCommoditys:self.orderedData.article.commoditys];
    [commodity showCommodity];
    self.commodityView = commodity;    
}

- (void)commodityViewClosed
{
    if ([self.delegate respondsToSelector:@selector(ttv_commodityViewClosed)]) {
        [self.delegate ttv_commodityViewClosed];
    }
}

- (void)addUrlTracker
{
    TTVPlayerUrlTracker *urlTracker = [self.orderedData videoPlayTracker];
    urlTracker.videoThirdMonitorUrl = self.orderedData.article.videoThirdMonitorUrl;
    [self.movieView.commonTracker registerTracker:urlTracker];
}

- (void)ttv_configADFinishedView:(TTVPlayerTipAdFinished *)finishedView
{
    if ([finishedView isKindOfClass:[TTVPlayerTipAdFinished class]]) {
        if ([self.orderedData isKindOfClass:[ExploreOrderedData class]]) {
            [finishedView setData:self.orderedData];
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
            [self moreButtonOnMovieTopViewDidPress];
        }
            break;
        case TTVPlayerEventTypeFinishDirectShare:{
            if ([action.payload isKindOfClass:[NSString class] ]) {
                NSString *activityType = action.payload;
                [self directShareActionWithActvityType:activityType];
            }
        }
            break;

        default:
            break;
    }
}

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    return self.logo.bounds;
}

- (void)movieViewWillMoveToSuperView:(UIView *)newView{
    if ([self.delegate respondsToSelector:@selector(ttv_movieViewWillAppear:)]) {
        [self.delegate ttv_movieViewWillAppear:newView];
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

- (void)moreButtonOnMovieTopViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_moreButtonOnMovieTopViewDidPress)]) {
        [self.delegate ttv_moreButtonOnMovieTopViewDidPress];
    }
}

- (void)directShareActionWithActvityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareActionClickedWithActivityType:)]){
        [self.delegate ttv_shareActionClickedWithActivityType:activityType];
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
        movieView.player.delegate = self;
        movieView.delegate = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            movieView.player.muted = [self.orderedData couldAutoPlay];
        });
        [super setMovieView:movieView];
        [self settingMovieView:movieView];
    }
}

- (UIView *)movieView
{
    if ([super movieView]) {
        return [super movieView];
    }
    TTVPlayVideo *view = [self movieViewFromeLogo];
    [self settingMovieView:view];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_ApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewPlayFinished:) name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:self.movieView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:self.movieView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:self.movieView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewDidExitFullScreen:) name:TTMovieDidExitFullscreenNotification object:self.movieView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_openRedPackert:) name:@"TTOpenRedPackertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_closeRedPackert:) name:@"TTCloseRedPackertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFPauseVideoNotification:) name:@"TTSFPauseVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFContinueVideoNotification:) name:@"TTSFContinueVideo" object:nil];
}

- (void)ttv_openRedPackert:(NSNotification *)notification
{
    if (self.isPlaying) {
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
    if (self.isPlaying) {
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

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [self invalideMovieView];
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
    self.movieView = nil;
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [self.movieView exitFullScreen:YES completion:^(BOOL finished) {

        }];
        [self.movieView.player pause];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(NO),@"hidden",@(NO),@"autoHidden",nil];
        [self.movieView.player sendAction:TTVPlayerEventTypeControlViewHiddenToolBar payload:dic];

        [self.movieView.player sendAction:TTVPlayerEventTypeShowVideoFirstFrame payload:nil];
    }
}


- (void)movieViewDidExitFullScreen:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(ttv_movieViewDidExitFullScreen)]) {
        [self.delegate ttv_movieViewDidExitFullScreen];
    }
}

- (void)removeFromLogView
{
    self.movieView = [self movieViewFromeLogo];
    [self.movieView stopWithFinishedBlock:^{
        [self.movieView removeFromSuperview];
    }];
}

- (void)invalideMovieView
{
    if (self.movieView) {
        [self.movieView exitFullScreen:NO completion:^(BOOL finished) {

        }];
        [self.movieView stop];
        [self.movieView removeFromSuperview];
    }else {
        [self removeFromLogView];
    }
    if ([self.delegate respondsToSelector:@selector(ttv_invalideMovieView)]) {
        [self.delegate ttv_invalideMovieView];
    }
}

- (UIView *)detachMovieView {
    UIView *movieView = self.movieView;
    [self.movieView removeFromSuperview];
    self.movieView = nil;
    return movieView;
}

- (void)attachMovieView:(TTVPlayVideo *)movieView {
    if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
        self.movieView = movieView;
        [self.logo addSubview:movieView];
        [self.logo bringSubviewToFront:movieView];
        movieView.frame = self.logo.bounds;
    }
}


- (BOOL)hasMovieView
{
    if (!self.movieView) {
        self.movieView = [self movieViewFromeLogo];
    }
    if ([self.movieView.playerModel.videoID isEqualToString:self.orderedData.article.videoID]) {
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
        [self invalideMovieView];
        self.movieView.hidden = YES;
        [self.movieView.player pause];
    }
}

- (void)willAppear
{
    if (self.playIsPlayingBefore && self.presentedViewController) {
        [self.movieView.player play];
        self.presentedViewController = nil;
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (context == CellInListDisappearContextTypeChangeCategory) {
        [self.commodityView closeCommodity];
    }
    if (self.movieView && self.movieView.superview) {
        if (![self.movieView.player.pasterPlayer shouldPasterADPause] && ![self.orderedData isAd]) {
            UIViewController *controller = [TTUIResponderHelper correctTopViewControllerFor:self.movieView];
            if (controller) {
                self.presentedViewController = controller;
                self.playIsPlayingBefore = self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying;
                [self.movieView.player pause];
            }else{
                [self.movieView stop];
                if (!self.isActive) {
                    [self.movieView removeFromSuperview];
                }
            }
        }
    }
}

#pragma mark TTVCommodityViewMessage
- (void)ttv_message_removeall_comodityview
{
    [self.commodityView closeCommodity];
}

- (BOOL)isPause
{
    return self.movieView.player.context.playbackState == TTVVideoPlaybackStatePaused;
}

- (BOOL)isStopped
{
    return self.movieView.player.context.playbackState == TTVVideoPlaybackStateFinished;
}

- (BOOL)isPlaying
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        return YES;
    }
    return NO;
}

- (BOOL)isMovieFullScreen
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.isFullScreen) {
        return YES;
    }
    return NO;
}

- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL))completion
{
    [self.movieView exitFullScreen:YES completion:completion];
    return YES;
}
- (NSString *)enterFromString{
    NSString *enterFrom = @"click_category";
    return enterFrom;
}

- (NSString *)categoryName{
    NSString *categoryName = self.orderedData.categoryID;
    return categoryName;
}

@end
