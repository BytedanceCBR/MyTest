//
//  TTVideoTabBaseCellOldPlayControl.m
//  Article
//
//  Created by panxiang on 2017/6/5.
//
//

#import "TTVideoTabBaseCellOldPlayControl.h"
#import "ExploreMovieView.h"
#import "ExploreOrderedData.h"
//#import "TTVideoTabLiveCellView.h"
#import "TTMovieViewCacheManager.h"
#import "TTVideoAutoPlayManager.h"
#import "ExploreArticleMovieViewDelegate.h"
#import "SSADEventTracker.h"
#import "TTVideoCellActionBar.h"
#import "ExploreActionButton.h"
#import "TTMovieExitFullscreenAnimatedTransitioning.h"
#import "TTVPlayVideo.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "TTUIResponderHelper.h"
#import "Article.h"
#import <TTImageView.h>

extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface TTVideoTabBaseCellOldPlayControl ()
@property(nonatomic, strong)ExploreMovieView *movieView;
@property(nonatomic, assign)BOOL isPlayingWhenOpenRedPacket;
@property (nonatomic, strong) ExploreArticleMovieViewDelegate *movieViewDelegate;
@end

@implementation TTVideoTabBaseCellOldPlayControl
@dynamic movieView;
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewPlayFinished:) name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlaybackNotification:) name:kExploreStopMovieViewPlaybackNotification object:self.movieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewDidExitFullScreen:) name:TTMovieDidExitFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_openRedPackert:) name:@"TTOpenRedPackertNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_closeRedPackert:) name:@"TTCloseRedPackertNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFPauseVideoNotification:) name:@"TTSFPauseVideo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TTSFContinueVideoNotification:) name:@"TTSFContinueVideo" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playButtonClicked
{
    [ExploreMovieView removeAllExploreMovieView];
    
    ExploreMovieViewModel *movieViewModel = [ExploreMovieViewModel viewModelWithOrderData:self.orderedData];
    movieViewModel.type                   = ExploreMovieViewTypeList;
    movieViewModel.gdLabel                = nil;
    movieViewModel.videoPlayType          = TTVideoPlayTypeNormal ;
    movieViewModel.auithorId              = [self.orderedData.article.userInfo ttgc_contentID];
//    //直播cell类型
//    if ([self isKindOfClass:[TTVideoTabLiveCellView class]]) {
//        movieViewModel.videoPlayType  = TTVideoPlayTypeLive;
//    }
    
    self.movieView = [[TTMovieViewCacheManager sharedInstance] movieViewWithVideoID:self.orderedData.article.videoID frame:self.logo.bounds type:ExploreMovieViewTypeList trackerDic:nil movieViewModel:movieViewModel];
    if (self.movieView) {
        [[TTMovieViewCacheManager sharedInstance].registMovieViewHash addObject:self.movieView];
    }
    
    self.movieView.shouldShowNewFinishUI = YES;
    self.movieView.enableMultiResolution = YES;
    [self.movieView enableRotate:![self.orderedData.article showPortrait]];
    
    [self.movieView setVideoTitle:self.orderedData.article.title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:YES];
    [self.movieView setLogoImageDict:self.orderedData.listLargeImageDict];
    [self.movieView setVideoDuration:[self.orderedData.article.videoDuration doubleValue]];
    
    if (ttvs_isVideoShowOptimizeShare() > 0){
        if (isEmptyString(movieViewModel.aID)) {
            self.movieView.moviePlayerController.shouldShowShareMore = ttvs_isVideoShowOptimizeShare();
        }
    }
    self.movieView.moviePlayerController.isVideoBusiness = YES;
    if ([self.orderedData couldAutoPlay]) {
        self.movieView.stopMovieWhenFinished = YES;
    }
    
    if ([[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:self.orderedData]) {
        self.movieView.tracker.isAutoPlaying = YES;
    }
    
    self.movieViewDelegate = [[ExploreArticleMovieViewDelegate alloc] init];
    self.movieViewDelegate.orderedData = self.orderedData;
    self.movieViewDelegate.viewBase = self.movieViewDelegateView;
    self.movieViewDelegate.logo = self.logo;
    self.movieView.movieViewDelegate = self.movieViewDelegate;
    WeakSelf;
    self.movieViewDelegate.shareButtonClickedBlock = ^{
        StrongSelf;
        [self moreButtonOnMovieFinishViewDidPress];
    };
    
    self.movieViewDelegate.playerShareButtonClickedBlock = ^{
        StrongSelf;
        [self ttv_shareButtonOnMovieTopViewDidPress];
    };
    
    self.movieViewDelegate.moreButtonClickedBlock = ^{
        StrongSelf;
        [self ttv_moreButtonOnMovieTopViewDidPress];
    };
    
    self.movieViewDelegate.shareActionClickedBlock = ^(NSString *activityType) {
        StrongSelf;
        [self shareActionClickedWithActivityType:activityType];
    };

    
    self.movieViewDelegate.movieViewWillAppear = ^(UIView *newView) {
        StrongSelf;
        [self movieViewViewWillAppear:newView];
    };
    self.movieViewDelegate.replayButtonClickedBlock = ^{
        StrongSelf;
        [self moviViewReplayButtonClicked];
    };
    [self.logo addSubview:self.movieView];
    if ([self.orderedData.article hasVideoSubjectID]) {
        [self.movieView.tracker addExtraValue:[self.orderedData.article videoSubjectID] forKey:@"video_subject_id"];
    }
    
    ExploreVideoSP sp = ([self.orderedData.article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? ExploreVideoSPLeTV : ExploreVideoSPToutiao;
    [self addMovieTrackerEvent3Data];
    if ([self.movieView isPaused]) {
        [self.movieView resumeMovie];
    } else {
        if (ttvs_isVideoFeedURLEnabled() && [self.orderedData.article hasVideoPlayInfoUrl] && [self.orderedData.article isVideoUrlValid]) {
            [self.movieView playVideoWithVideoInfo:self.orderedData.article.videoPlayInfo exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
        } else {
            [self.movieView playVideoForVideoID:self.orderedData.article.videoID exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
        }
        
        if (!isEmptyString(self.movieView.tracker.aID)) {
            if (self.movieView.tracker.type == ExploreMovieViewTypeList) {
                if (!self.movieView.tracker.isAutoPlaying || self.movieView.tracker.wasInDetail || self.movieView.tracker.isReplaying) {
                    
                    [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionBar.adActionButton.actionModel label:@"click" eventName:@"embeded_ad"];
                }
            }
        }
    }
}

- (void)ttv_shareButtonOnMovieTopViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieTopViewDidPress)]) {
        [self.delegate ttv_shareButtonOnMovieTopViewDidPress];
    }
}

- (void)ttv_moreButtonOnMovieTopViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_moreButtonOnMovieTopViewDidPress)]) {
        [self.delegate ttv_moreButtonOnMovieTopViewDidPress];
    }
}

- (void)shareActionClickedWithActivityType:(NSString *)activityType
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareActionClickedWithActivityType:)]) {
        [self.delegate ttv_shareActionClickedWithActivityType:activityType];
    }
}

- (void)moreButtonOnMovieFinishViewDidPress
{
    if ([self.delegate respondsToSelector:@selector(ttv_shareButtonOnMovieFinishViewDidPress)]) {
        [self.delegate ttv_shareButtonOnMovieFinishViewDidPress];
    }
}

- (void)movieViewViewWillAppear:(UIView *)newView{
    if ([self.delegate respondsToSelector:@selector(ttv_movieViewWillAppear:)]) {
        [self.delegate ttv_movieViewWillAppear:newView];
    }
}

- (void)settingMovieView:(ExploreMovieView *)movieView
{
    movieView.movieViewDelegate = self.movieViewDelegate;
    movieView.tracker.type = ExploreMovieViewTypeList;
}

- (void)setMovieView:(ExploreMovieView *)movieView
{
    if ([movieView isKindOfClass:[ExploreMovieView class]] || !movieView) {
        [super setMovieView:movieView];
    }
}

- (void)moviViewReplayButtonClicked{
    if ([self.delegate respondsToSelector:@selector(ttv_movieViewReplayButtonDidPress)]) {
        [self.delegate ttv_movieViewReplayButtonDidPress];
    }
}

- (UIView *)movieView
{
    if ([super movieView]) {
        return [super movieView];
    }
    ExploreMovieView *view = [self movieViewFromeLogo];
    [self settingMovieView:view];
    return view;
}

#pragma mark notification

- (void)goVideoDetail
{
    [self.movieView.tracker sendPlayTrack];
}

- (void)ttv_openRedPackert:(NSNotification *)notification
{
    if (self.isPlaying) {
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
    if (self.isPlaying) {
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

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [self invalideMovieView];
    }
}

- (void)stopMovieViewPlaybackNotification:(NSNotification *)notification
{
    if (self.movieView == notification.object) {
        [self invalideMovieView];
    }
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    if (self.movieView == notification.object) {
        [self invalideMovieView];
    }
}

- (void)stopAllMovieViewPlay:(NSNotification *)notification
{
    [self invalideMovieView];
    self.movieView = nil;
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if (self.movieView) {
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView pauseMovieAndShowToolbar];
    }
}


- (void)movieViewDidExitFullScreen:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(ttv_movieViewDidExitFullScreen)]) {
        [self.delegate ttv_movieViewDidExitFullScreen];
    }
}

- (void)invalideMovieView
{
    if (self.movieView) {
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView stopMovie];
        [self.movieView removeFromSuperview];
    }else{
        [self removeFromLogView];
    }
    if ([self.delegate respondsToSelector:@selector(ttv_invalideMovieView)]) {
        [self.delegate ttv_invalideMovieView];
    }
    //解决视频tableView偶现同事播放两个视频的情况
    NSEnumerator *movieViewEnmerator = [[TTMovieViewCacheManager sharedInstance].registMovieViewHash objectEnumerator];
    id obj;
    while (obj = [movieViewEnmerator nextObject]) {
        if ([obj isKindOfClass: [ExploreMovieView class]]) {
            [obj exitFullScreenIfNeed:NO];
            [obj stopMovie];
            [obj removeFromSuperview];
        }
    }
    [[TTMovieViewCacheManager sharedInstance].registMovieViewHash removeAllObjects];
}

- (void)beforeCellReuse
{
    if (![self.movieView isPlaying]) {
        [self.movieView removeFromSuperview];
    }
}

- (ExploreMovieView *)movieViewFromeLogo
{
    for (ExploreMovieView *subView in self.logo.subviews) {
        if ([subView isKindOfClass:[ExploreMovieView class]]) {
            return subView;
        }
        if ([subView isKindOfClass:[TTVPlayVideo class]]) {
            [((TTVPlayVideo *)subView) stop];
            [subView removeFromSuperview];
        }
    }
    return nil;
}

- (void)removeFromLogView
{
    self.movieView = [self movieViewFromeLogo];
    [self.movieView removeFromSuperview];
    [self.movieView stopMovieAfterDelay];
}


- (UIView *)detachMovieView {
    UIView *movieView = self.movieView;
    [self.movieView removeFromSuperview];
    self.movieView = nil;
    return movieView;
}

- (void)attachMovieView:(ExploreMovieView *)movieView {
    if (movieView) {
        if ([movieView isKindOfClass:[ExploreMovieView class]]) {
            self.movieView = movieView;
            [self.logo addSubview:movieView];
            [self.logo bringSubviewToFront:movieView];
            movieView.frame = self.logo.bounds;
        }
    }
}


- (BOOL)hasMovieView
{
    if (!self.movieView) {
        self.movieView = [self movieViewFromeLogo];
    }
    if ([self.movieView.videoID isEqualToString:self.orderedData.article.videoID] && !isEmptyString(self.orderedData.article.videoID)) {
        return YES;
    }
    return NO;
}


- (void)didEndDisplaying
{
    if (!self.movieView) {
        self.movieView = [self movieViewFromeLogo];
    }
    if (!self.movieView.isMovieFullScreen && !self.movieView.isRotateAnimating) {
        [self.movieView pauseMovie];
        self.movieView.hidden = YES;
        [self.movieView stopMovieAfterDelay];
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (self.movieView && self.movieView.superview) {
        if (![self.movieView shouldPasterADPause] && ![self.movieView isAdMovie]) {
            if ([TTUIResponderHelper topViewControllerFor:self.movieView].presentedViewController) {
                [self.movieView pauseMovie];
            }else{
                [self.movieView stopMovie];
            }
        }
    }
}

- (BOOL)isPause
{
    if (self.movieView && self.movieView.superview && [self.movieView isPaused]) {
        return YES;
    }
    return NO;
}

- (BOOL)isStopped
{
    if (self.movieView && self.movieView.superview && [self.movieView isPlayingFinished]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPlaying
{
    if (self.movieView && self.movieView.superview && [self.movieView isPlaying]) {
        return YES;
    }
    return NO;
}

- (BOOL)isMovieFullScreen
{
    if (self.movieView && self.movieView.superview && [self.movieView isMovieFullScreen]) {
        return YES;
    }
    return NO;
}

- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL))completion
{
    return [self.movieView exitFullScreen:YES completion:completion];
}

#pragma mark - 埋点3.0

- (void)addMovieTrackerEvent3Data{
    [self.movieView.tracker addExtraValue:self.orderedData.article.itemID forKey:@"item_id"];
    [self.movieView.tracker addExtraValue:[self.orderedData uniqueID] forKey:@"group_id"];
    [self.movieView.tracker addExtraValue:self.orderedData.article.aggrType forKey:@"aggr_type"];
    //self.detailModel.gdExtJsonDict
    [self.movieView.tracker addExtraValue:self.orderedData.logPb forKey:@"log_pb"];
    [self.movieView.tracker addExtraValue:self.orderedData.article.videoID forKey: @"video_id"];
    
    /** TODO video_play
     *parent_enterfrom
     *question_id
     *group_source
     */
    
    /** TODO video_over
     *version_type
     *percent
     *parent_enterfrom
     *position
     *question_id
     *group_source
     */
    
}
@end
