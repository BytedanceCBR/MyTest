//
//  ExploreMoviePlayerController.m
//  Article
//
//  Created by Chen Hong on 15/5/12.
//
//

#import "ExploreMoviePlayerController.h"
#import "ExploreMoviePlayerControlView.h"
#import "TTAudioSessionManager.h"
#import "TTMovieResolutionSelectView.h"
#import "TTAlphaThemedButton.h"
#import "TTMovieViewCacheManager.h"
#import "TTAPPIdleTime.h"

static const NSTimeInterval kAnimDuration = 0.1;
extern NSString *ttv_getFormattedTimeStrOfPlay(NSTimeInterval playTimeInterval);

@interface ExploreMoviePlayerController ()<ExploreMoviePlayerControlViewDelegate, TTMovieResolutionSelectViewDelegate>
{
    /**
     *  判断是否播放过
     */
    BOOL _ssIsPlayed;
    
    BOOL _playingBeforeInterruption;
    
    BOOL _isRefreshingSlider;
}

@property(nonatomic, assign)BOOL currentFullScreen;
@property(nonatomic, strong)TTMovieResolutionSelectView *resolutionSelectView;
@property(nonatomic, assign) BOOL isOwnPlayer;
@property(nonatomic, copy) NSURL *playUrl;
@end

@implementation ExploreMoviePlayerController

@synthesize isFullScreenButtonAction = _isFullScreenButtonAction;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareInit
{
    [super prepareInit];
    self.currentFullScreen = NO;

    self.controlView = [[ExploreMoviePlayerControlView alloc] initWithFrame:self.view.bounds videoType:self.videoPlayType];
    _controlView.delegate = self;
    _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_controlView];
    [_controlView showLoadingWithTitleBar];
    [_controlView disbleSlider];
    _controlView.enableResolution = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification  object:nil];
}

- (void)reuse
{
    [_controlView reuse];
}

- (id)initWithOwnPlayer:(BOOL)isOwn {
    self = [super initWithOwnPlayer:isOwn];
    if (self) {
        self.isOwnPlayer = isOwn;
    }
    
    return self;
}

- (BOOL)isMovieFullScreen
{
    return _currentFullScreen;
}

- (BOOL)hasTipType
{
    return [_controlView hasTipType];
}

- (BOOL)hasShowTipView
{
    return [_controlView hasShowTipView];
}

- (void)showRetryTipView
{
    [self showRetryTipViewWithTipString:nil];
}

- (void)showRetryTipViewWithTipString:(NSString *)tipString
{
    [_controlView showTipView:ExploreMoviePlayerControlViewTipTypeRetry andTipString:tipString];
}

- (void)showLiveOverTipView
{
    [_controlView showTipView:ExploreMoviePlayerControlViewTipTypeLiveOver];
}
- (void)showLiveWaitingTipView
{
    [_controlView showTipView:ExploreMoviePlayerControlViewTipTypeLiveWaiting];
}

- (void)showLoadingTipView {
    [_controlView showTipView:ExploreMoviePlayerControlViewTipTypeLoading];
}

- (void)hideLoadingTipView {
    [_controlView hideTipView];
}

- (ExploreMoviePlayerControlViewTipType)tipViewType
{
    return [_controlView tipViewType];
}

- (void)moviePlayContentForURL:(NSURL *)url
{
    self.playUrl = url;
    [super moviePlayContentForURL:url];
    _ssIsPlayed = NO;
}

- (void)refreshPlayButton {
    [self refreshPlayButton:NO];
}


- (void)showMovieFinishView {
    //remove掉切换清晰度
    [self.resolutionSelectView removeFromSuperview];
    self.resolutionSelectView = nil;
    [_controlView finishPlaying];
    [[TTAPPIdleTime sharedInstance_tt] lockScreen:YES later:YES];
}

- (void)refreshPlayButton:(BOOL)force
{
    if ([self isPlaying]) {
        if (!_ssIsPlayed) {
            _ssIsPlayed = YES;
            [_controlView setToolBarHidden:YES];
        }
        [_controlView hideLogoView];
        [_controlView hideTipView];
        [_controlView setIsPlaying:YES force:force];
        [[TTAPPIdleTime sharedInstance_tt] lockScreen:NO];
    }
    else {
        [_controlView setIsPlaying:NO force:force];
    }
}

- (void)refreshFullScreenButton
{
    [_controlView setIsFullScreen:_currentFullScreen];
}

- (void)refreshSlider {
    if (_isRefreshingSlider) {
        return;
    }
    NSTimeInterval duration = self.duration;
    NSTimeInterval currentPlaybackTime = self.currentPlaybackTime;
    if (isnan(duration) || duration == NAN || duration <= 0 || isnan(currentPlaybackTime) || currentPlaybackTime == NAN || currentPlaybackTime < 0) {
        return;
    }
    
    [_controlView enableSlider];
    
    [self refreshTimeLabel:duration currentPlaybackTime:currentPlaybackTime];
    
    [_controlView setTotalTime:duration];
    
    CGFloat progress = ((currentPlaybackTime / duration) * 100.f);
    [_controlView setWatchedProgress:progress];
    
    if (self.playableDuration > 0 && !isnan(self.playableDuration) && self.playableDuration != NAN) {
        progress = (self.playableDuration / duration) * 100;
        [_controlView setCacheProgress:progress];
    }
    else {
        [_controlView setCacheProgress:0];
    }

    if ([self.moviePlayerDelegate respondsToSelector:@selector(movieControllerRemainderTime:)]) {
        [self.moviePlayerDelegate movieControllerRemainderTime:self.duration - currentPlaybackTime];
    }
}

- (void)refreshTimeLabel:(NSTimeInterval)duration currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    if (duration <= 0 || currentPlaybackTime < 0) {
        [_controlView updateTimeLabel:@"00:00" durationLabel:@"00:00"];
        return;
    }
    
    if (currentPlaybackTime > duration) {
        currentPlaybackTime = duration;
    }
    [_controlView updateTimeLabel:ttv_getFormattedTimeStrOfPlay(currentPlaybackTime) durationLabel:ttv_getFormattedTimeStrOfPlay(duration)];
}

- (void)p_hideResolutionView {
    UIView *v = _resolutionSelectView;
    _resolutionSelectView = nil;
    [UIView animateWithDuration:kAnimDuration animations:^{
        v.alpha = 0.f;
    } completion:^(BOOL finished) {
        [v removeFromSuperview];
    }];
}

#pragma mark -- override

- (NSString *)currentCDNHost
{
    if (_moviePlayerDelegate && [_moviePlayerDelegate respondsToSelector:@selector(currentCDNHost)]) {
        return [_moviePlayerDelegate currentCDNHost];
    }
    return nil;
}

#pragma mark -- ExploreMoviePlayerControlViewDelegate

- (void)controlViewTouched:(UIView *)controlView
{
    if ([self.moviePlayerDelegate respondsToSelector:@selector(controlViewTouched:)]) {
        [self.moviePlayerDelegate controlViewTouched:self.controlView];
    }
}

- (void)controlView:(UIView *)controlView didAppear:(BOOL)appear
{
}

- (void)controlView:(UIView *)controlView willAppear:(BOOL)appear
{
}

- (void)controlViewWillDisappear:(UIView *)controlView
{
    if (_resolutionSelectView) {
        [self p_hideResolutionView];
    }
}

- (void)controlViewRetryButtonClicked:(UIView *)controlView
{
    if (controlView != _controlView) {
        return;
    }
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControlViewRetryButtonClicked:)]) {
        [self.moviePlayerDelegate movieControlViewRetryButtonClicked:self];
    }
    [_controlView showTipView:ExploreMoviePlayerControlViewTipTypeLoading];
}

- (void)controlViewPlayButtonClicked:(UIView *)controlView replay:(BOOL)replay
{
    if (controlView != _controlView) {
        return;
    }
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerPlayButtonClicked:replay:)]) {
        [self.moviePlayerDelegate movieControllerPlayButtonClicked:self replay:replay];
    }
}

- (void)controlViewShareButtonClicked:(UIView *)controlView
{
    if (controlView != _controlView) {
        return;
    }
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerShareButtonClicked:)]) {
        [self.moviePlayerDelegate movieControllerShareButtonClicked:self];
    }
}

- (void)controlViewMoreButtonClicked:(UIView *)controlView{
    if (controlView != _controlView) {
        return;
    }
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerMoreButtonClicked:)]) {
        [self.moviePlayerDelegate movieControllerMoreButtonClicked:self];
    }
}

- (void)controlViewShareActionClicked:(UIView *)controlView withActivityType:(NSString *)activityType{
    if (controlView != _controlView) {
        return;
    }
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerShareActionClicked:withActivityType:)]) {
        [self.moviePlayerDelegate movieControllerShareActionClicked:self withActivityType:activityType];
    }

}

- (void)controlViewFullScreenButtonClicked:(UIView *)controlView
{
    if (controlView != _controlView) {
        return;
    }
    
    BOOL changeToFullscreen = !self.currentFullScreen;
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerFullScreenButtonClicked:isFullScreen:completion:)]) {
        if ([self.moviePlayerDelegate respondsToSelector:@selector(setIsFullScreenButtonAction:)]) {
            [self.moviePlayerDelegate setIsFullScreenButtonAction:self.isFullScreenButtonAction];
        }
        [self.moviePlayerDelegate movieControllerFullScreenButtonClicked:self isFullScreen:changeToFullscreen completion:nil];
    }
}

- (void)controlView:(UIView *)controlView seekProgress:(CGFloat)progress
{
    if (controlView != _controlView) {
        return;
    }
    [self seekToProgress:progress];
    _isRefreshingSlider = NO;
}

- (void)controlView:(UIView *)controlView changeCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime totalTime:(NSTimeInterval)totalTime
{
    if (controlView != _controlView) {
        return;
    }
    _isRefreshingSlider = YES;
    [self refreshTimeLabel:totalTime currentPlaybackTime:currentPlaybackTime];
}

- (BOOL)controlViewCanRotate {
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerCanRotate:)]) {
        return [self.moviePlayerDelegate movieControllerCanRotate:self];
    }
    
    return YES;
}

- (BOOL)controlViewShouldPauseWhenEnterForeground {
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerShouldPauseWhenEnterForeground:)]) {
        return [self.moviePlayerDelegate movieControllerShouldPauseWhenEnterForeground:self];
    }
    
    return YES;
}

- (void)controlViewFullScreenLandscapeLeftRightRotate {
    if (self.moviePlayerDelegate && [self.moviePlayerDelegate respondsToSelector:@selector(movieControllerLandscapeLeftRightRotate:)]) {
        [self.moviePlayerDelegate movieControllerLandscapeLeftRightRotate:self];
    }
}

- (void)controlViewResolutionButtonClicked:(UIView *)controlView
{
    TTMovieResolutionSelectView *view = self.resolutionSelectView;
    if (view.superview) {
        [self p_hideResolutionView];
    } else {
        NSArray *types;
        if ([self.movieDelegate respondsToSelector:@selector(supportedResolutionTypes)]) {
            types = [self.moviePlayerDelegate supportedResolutionTypes];
        }
        [view setSupportTypes:types currentType:self.definitionType];
        
        self.resolutionSelectView.frame = CGRectMake(0, 0, self.resolutionSelectView.viewSize.width, self.resolutionSelectView.viewSize.height);
        self.resolutionSelectView.bottom = self.controlView.height - 40;
        self.resolutionSelectView.centerX = self.controlView.bottomBarView.resolutionButton.centerX;
        [self.controlView addSubview:self.resolutionSelectView];
        self.resolutionSelectView.alpha = 0.f;
        [UIView animateWithDuration:kAnimDuration animations:^{
            self.resolutionSelectView.alpha = 1.f;
        }];
    }
    
    if (self.enableMultiResolution) {
        NSArray *types = [self.moviePlayerDelegate supportedResolutionTypes];
        NSDictionary *extra = @{@"num" : [@(types.count) stringValue]};
        wrapperTrackEventWithCustomKeys(@"video", @"clarity_click", self.gModel.groupID, nil, extra);
    }
}

- (void)controlView:(UIView *)controlView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.moviePlayerDelegate respondsToSelector:@selector(controlViewTouched:)]) {
        [self.moviePlayerDelegate controlViewTouched:self.controlView];
    }
    if (_resolutionSelectView) {
        [self p_hideResolutionView];
    }
}

- (void)controlViewPrePlayButtonClicked:(UIView *)controlView {
    
    if ([self.moviePlayerDelegate respondsToSelector:@selector(movieControllerPrePlayButtonClicked:)]) {
        
        [self.moviePlayerDelegate movieControllerPrePlayButtonClicked:self];
    }
}

- (BOOL)isADVideo {
    if (self.adId.length) {
        return YES;
    }
    return NO;
}

- (BOOL)movieHasFirstFrame
{
    if ([self.moviePlayerDelegate respondsToSelector:@selector(movieHasFirstFrame)]) {
        return [self.moviePlayerDelegate movieHasFirstFrame];
    }
    return NO;
}

- (BOOL)shouldControlViewHaveAdButton {
    if (self.adId.length) {
        return YES;
    }
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

#pragma mark - TTMovieResolutionSelectViewDelegate

- (void)didSelectWithType:(ExploreVideoDefinitionType)type
{
    [UIView animateWithDuration:kAnimDuration animations:^{
        self.resolutionSelectView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_resolutionSelectView removeFromSuperview];
        _resolutionSelectView = nil;
        NSString *typeString = [TTMovieResolutionSelectView typeStringForType:type];
        [self.controlView setResolutionString:typeString];
        [TTMovieViewCacheManager sharedInstance].userSelected = YES;
        if ([self.moviePlayerDelegate respondsToSelector:@selector(movieController:ResolutionButtonClickedWithType:typeString:)]) {
            [self.moviePlayerDelegate movieController:self ResolutionButtonClickedWithType:type typeString:typeString];
        }
    }];
    if (self.enableMultiResolution) {
        NSArray *supportTypes = [self.moviePlayerDelegate supportedResolutionTypes];
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:2];
        [extra setValue:[@(supportTypes.count) stringValue] forKey:@"num"];
        NSString *str = @"360P";
        if (type == ExploreVideoDefinitionTypeHD) {
            str = @"480P";
        } else if (type == ExploreVideoDefinitionTypeFullHD) {
            str = @"720P";
        }
        [extra setValue:str forKey:@"definition"];
        wrapperTrackEventWithCustomKeys(@"video", @"clarity_select", self.gModel.groupID, nil, extra);
    }
}

- (TTMovieResolutionSelectView *)resolutionSelectView
{
    if (!_resolutionSelectView) {
        _resolutionSelectView = [[TTMovieResolutionSelectView alloc] init];
        _resolutionSelectView.delegate = self;
    }
    return _resolutionSelectView;
}

- (void)setEnableMultiResolution:(BOOL)enableMultiResolution
{
    _enableMultiResolution = enableMultiResolution;
    _controlView.enableResolution = enableMultiResolution;
}

- (void)setDefinitionType:(ExploreVideoDefinitionType)definitionType
{
    _definitionType = definitionType;
    NSString *typeString = [TTMovieResolutionSelectView typeStringForType:definitionType];
    self.controlView.resolutionString = typeString;
}

-(void)setShouldShowShareMore:(NSInteger)shouldShowShareMore{
    _shouldShowShareMore = shouldShowShareMore;
    self.controlView.shouldShowShareMore = shouldShowShareMore;
}

- (void)setIsVideoBusiness:(BOOL)isVideoBusiness{
    _isVideoBusiness = isVideoBusiness;
    self.controlView.isVideoBusiness = isVideoBusiness;
}

- (void)enterFullscreen
{
    self.currentFullScreen = YES;

    [self refreshResolutionButton];
    [self refreshFullScreenButton];
    
    if (self.enableMultiResolution) {
        NSArray *types = [self.moviePlayerDelegate supportedResolutionTypes];
        NSDictionary *extra = @{@"num" : [@(types.count) stringValue]};
        wrapperTrackEventWithCustomKeys(@"video", @"clarity_show", self.gModel.groupID, nil, extra);
    }
}

- (void)refreshResolutionButton
{
    if ([self.moviePlayerDelegate respondsToSelector:@selector(supportedResolutionTypes)]) {
        NSArray *types = [self.moviePlayerDelegate supportedResolutionTypes];
        self.controlView.enableResulutionButtonClicked = types.count > 1;
    }
}

- (void)exitFullscreen
{
    self.currentFullScreen = NO;
    [self refreshFullScreenButton];
}

- (void)interruptPlay
{
    [self pause];
    [[TTAudioSessionManager sharedInstance] setActive:NO];
    [self invalidatePlaybackTimer];

}

- (void)resumePlay
{
    if (_playingBeforeInterruption) {
        if ([self.moviePlayerDelegate respondsToSelector:@selector(shouldResumePlayWhenInterruptionEnd)]) {
            if ([self.moviePlayerDelegate shouldResumePlayWhenInterruptionEnd]) {
                [self moviePlay];
            }
        }
        else
        {
            [self moviePlay];
        }
    }

    [[TTAudioSessionManager sharedInstance] setActiveSynchronization:YES];

}

#pragma mark -- Notification

static BOOL ifInterruptPlayWhenResignActive = YES;
- (void)receiveBecomeActiveNotification:(NSNotification *)notification
{
    if (!_controlView.hasFinished) {
        [self refreshPlayButton:YES];
    }
    if (_playingBeforeInterruption) {
        [self resumePlay];
        ifInterruptPlayWhenResignActive = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ifInterruptPlayWhenResignActive = YES;
    });
}

- (void)willResignActiveNotification:(NSNotification *)notification
{
    _playingBeforeInterruption = self.playbackState == TTMoviePlaybackStatePlaying;

    /**
     防止在别的地方读到了错的playbackState
     */
    if (ifInterruptPlayWhenResignActive) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self interruptPlay];
        });
    }
}

@end
