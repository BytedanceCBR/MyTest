//
//  TTVideoPasterADViewController.m
//  Article
//
//  Created by Dai Dongpeng on 5/25/16.
//
//

#import "TTVideoPasterADViewController.h"
#import "ExploreMovieView.h"
#import "TTVideoPasterADModel.h"
#import "ExploreVideoModel.h"
#import "TTVideoPasterADNatantView.h"
#import "TTRoute.h"
#import "TTURLUTils.h"
#import "SSURLTracker.h"    
#import "TTVideoPasterADTracker.h"
#import "TTVideoPasterADService.h"

#import <Masonry.h>
#import "SSAppStore.h"


static NSString *const kEmbededADKey = @"embeded_ad";

@interface TTVideoPasterADViewController () <ExploreMovieViewPasterADDelegate, TTVideoPasterADNatantViewDelegate, ExploreMovieViewDelegate> {
    BOOL _allowClickToPause;
    UIDeviceOrientation _lastOrientation;
}

@property (nonatomic, strong) ExploreMovieView *movieView;
@property (nonatomic, strong) TTShowImageView  *imageView;
@property (nonatomic, strong) NSMutableArray <TTVideoPasterADModel *> *playingList;

@property (nonatomic, copy) TTVideoPasterADPlayCompletionBlock pasterADCompletionBlock;
@property (nonatomic, strong) TTVideoPasterADNatantView *natantView;
@property (nonatomic, assign) BOOL shouldPause;
@property (nonatomic, strong) TTVideoPasterADTracker *adTracker;

@property (nonatomic, strong) TTVideoPasterADService *pasterADService;

@property (nonatomic, strong) TTVideoRotateScreenController *rotateController;

@property (nonatomic, assign) BOOL clickedSkipBtn; // 上报用

@property (nonatomic, assign) BOOL clickedDownloadBtn; // 记录下载按钮点击状态 用于过滤notification

@end

@implementation TTVideoPasterADViewController

#pragma mark - Life Cycle

- (void)dealloc
{
//    NSLog(@">>>> %s",__func__);
    
    [self.adTracker sendShowOverWithExtra:nil duration:self.natantView.durationTime viewType:[self currentViewType]];
    
    [self endMonitorDeviceOrientationChange];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePauseButtonIfNeeded) object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _allowClickToPause = NO;
        self.adTracker = [[TTVideoPasterADTracker alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];


    }
    return self;
}

- (void)setupPasterADData:(TTVideoPasterADURLRequestInfo *)requestInfo {
    
    requestInfo.adFrom = ([self currentViewType] == ExploreMovieViewTypeList) ? @"feed" : @"textlink";
    
    __weak typeof (self) wself = self;

    [self.adTracker sendRequestDataWithExtra:nil duration:0 viewType:[self currentViewType]];
    
    [self.pasterADService fetchPasterADInfoWithRequestInfo:requestInfo completion:^(id response, NSError *error) {
       
        __strong  TTVideoPasterADViewController *sself = wself;
        
        sself.playingADModel = ([response isKindOfClass:[TTVideoPasterADModel class]]) ? response: nil;
        
        if (sself.playingADModel) {
            
            [sself setPlayingListWithArray:[@[sself.playingADModel] mutableCopy]];
            
            [sself setupSubViews];
        } else {
            
            [sself.adTracker sendResponsErrorWithExtra:nil duration:0 viewType:[sself currentViewType]];
        }
        
    }];
}

- (void)setupSubViews
{
    if (self.playingADModel.style == TTVideoPasterADStyleImage) {
        
        self.imageView = [[TTShowImageView alloc] initWithFrame:self.view.bounds];
        self.imageView.imageInfosModel = [[TTImageInfosModel alloc] initWithDictionary:self.playingADModel.videoPasterADInfoModel.imageList.firstObject];
        [self.imageView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [self.imageView removeGestureRecognizer:obj];
        }];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.imageView];
        
    } else if (self.playingADModel.style == TTVideoPasterADStyleVideo) {
        
        ExploreMovieViewModel *viewModel = [ExploreMovieViewModel new];
        viewModel.videoPlayType = TTVideoPlayTypePasterAD;
        viewModel.shouldNotRemoveAllMovieView = YES;
        
        self.movieView = [[ExploreMovieView alloc] initWithFrame:self.view.bounds movieViewModel:viewModel];
        [self.movieView.moviePlayerController.controlView removeFromSuperview];
        self.movieView.enableMultiResolution = YES;
        self.movieView.pasterADDelegate = self;
        self.movieView.movieViewDelegate = self;
        [self.view addSubview:self.movieView];
        self.movieView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.movieView.moviePlayerController.controlView.toolBar.hidden = YES;
        
        self.movieView.moviePlayerController.trackManager = nil;
        self.movieView.tracker = nil;
        self.movieView.isPasterADSource = YES;
        self.adTracker.movieView = self.movieView;
    }
}

#pragma mark - Public Method

- (void)startPlayVideoList:(NSArray *)videoList WithCompletionBlock:(TTVideoPasterADPlayCompletionBlock)completion
{
    self.pasterADCompletionBlock = completion;
//    [self setPlayingList:[videoList mutableCopy]];
    
    [self playNextADModel];
}

- (BOOL)isPlayingMovie
{
    return self.movieView.isPlaying;
}

- (BOOL)hasPasterView
{
    return self.natantView.superview != nil;
}

- (BOOL)isPlayingImage
{
    return (self.natantView && self.imageView && self.playingADModel);
}

- (BOOL)isPaused
{
    return [self.movieView isPaused];
}

- (void)setIsFullScreen:(BOOL)fullScreen
{
    [self.natantView setIsFullScreen:fullScreen];
}

- (ExploreMovieViewType)currentViewType
{
    if ([self.delegate respondsToSelector:@selector(currentViewType)]) {
        return [self.delegate currentViewType];
    }
    
    if (self.enterDetailFlag) {
        
        return ExploreMovieViewTypeDetail;
    }
    
    return ExploreMovieViewTypeList;
}

- (BOOL)shouldPauseCurrentAd
{
    return self.shouldPause;
}

- (void)pauseCurrentAD
{
    [self.movieView pauseMovie];
    [self.natantView pauseTimer];
}

- (void)resumeCurrentAD
{
    [self.movieView resumeMovie];
    [self.natantView resumeTimer];
}

- (void)stopCurrentADVideo
{
    [self setPlayingListWithArray:nil];
    [self.movieView stopMovie];
}

- (ExploreMoviePlayerController *)getMoviePlayerController
{
    return [self.movieView getMoviePlayerController];
}
#pragma mark - ExploreMovieViewPasterADDelegate

- (void)pasterADWillFinishWithPlayEnd:(BOOL)playEnd
{
    NSInteger percent = [self p_getPlayPercent:playEnd];
    
    if (!self.natantView || percent < 0) {
        
        return ;
    }
    
    NSDictionary *extra = @{@"percent" : @(percent)};
    if (self.natantView.durationTime > 0 && !playEnd) {
        
        [self.adTracker sendPlayBreakEventWithExtra:extra duration:[self p_getDuration] viewType:[self currentViewType] effectivePlay:[self p_isEffectivePlay]];

    } else {
        // 播放完成 以倒计时为准
        NSDictionary *extra = @{@"percent" : @([self p_getPlayPercent:YES])};
        [self.adTracker sendPlayOverEventWithExtra:extra duration:[self p_getDuration] viewType:[self currentViewType]];
    }
    
    if (self.clickedSkipBtn) {
        
        [self.adTracker sendSkipEventWithExtra:nil duration:[self p_getDuration] viewType:[self currentViewType] effectivePlay:[self p_isEffectivePlay]];
    }
    
    [self playNextADModel];
}

- (void)pasterADWillStart
{
    TTVideoPasterADNatantView *natantView = [[TTVideoPasterADNatantView alloc] initWithFrame:self.view.bounds pasterADModel:self.playingADModel];
    natantView.delegate = self;
    [self.movieView addSubview:natantView];
    [self.imageView addSubview:natantView];
    natantView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    [natantView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//        make.size.equalTo(self.view);
//    }];
    if (self.natantView) {
        [self.natantView removeFromSuperview];
    }
    self.natantView = natantView;
    
    BOOL isFullScreen = NO;
    if ([self.delegate respondsToSelector:@selector(isMovieFullScreen)]) {
        isFullScreen = [self.delegate isMovieFullScreen];
    }
    [self setIsFullScreen:isFullScreen];
    [self.movieView.moviePlayerController.controlView setHiddenMiniSliderView:YES];
    [self.adTracker sendPlayStartEventWithExtra:nil duration:0 viewType:[self currentViewType]];
}

- (void)pasterADWillPause
{
    [self.natantView pauseTimer];
//    if (_allowClickToPause) {
//        [self.natantView showPlayButtonAutoHidden:NO];
//    }
    
    [self.adTracker sendPauseWithExtra:nil duration:0 viewType:[self currentViewType]];
}

- (void)pasterADWillResume
{
    [self.natantView resumeTimer];
    if ([self.natantView isPlayButtonShowed]) {
        [self.natantView hidePlayButtonAnimated:YES];
    }
//    if (_allowClickToPause) {
//        [self.natantView showPauseButtonAutoHidden:YES];
//    }
}

- (void)pasterADWillStop
{
    //广告被中止
}

- (void)pasterADWillStalle
{
    [self.natantView pauseTimer];
}

- (void)pasterADWillPlayable
{
    [self.natantView resumeTimer];
}

- (void)pasterADNeedsRetry
{
    [self playNextADModel];

}

- (void)pasterADNeedsToFullScreen:(BOOL)isFullScreen
{
    [self setIsFullScreen:isFullScreen];
    [self fullScreenbuttonClicked:nil toggledTo:isFullScreen];
    if (isFullScreen && ![self.movieView isMovieFullScreen]) {
        [self.movieView.moviePlayerController enterFullscreen];
    } else if (!isFullScreen && [self.movieView isMovieFullScreen]){
        [self.movieView.moviePlayerController exitFullscreen];
    }
//    [self viewWillLayoutSubviews];
}

#pragma mark - TTVideoPasterADNatantViewDelegate

- (void)fullScreenbuttonClicked:(UIButton *)button toggledTo:(BOOL)fullScreen
{
    if ([self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        [self.delegate videoPasterADViewControllerToggledToFullScreen:fullScreen animationed:YES completionBlock:nil];
    }
    if (fullScreen) {
        [self.adTracker sendFullscreenWithExtra:nil duration:0 viewType:[self currentViewType]];
    }
}

- (void)skipButtonClicked:(UIButton *)button
{
    self.clickedSkipBtn = YES;
    
    if (self.playingADModel.style == TTVideoPasterADStyleImage) {
        [self.adTracker sendSkipEventWithExtra:nil duration:[self p_getDuration] viewType:[self currentViewType] effectivePlay:[self p_isEffectivePlay]];
    }

    [self endPlayingPasterAD];
}

static UINavigationController *nav;

- (void)showDetailButtonClicked:(UIButton *)button
{
    if (self.playingADModel.type == TTVideoPasterADPageTypeAPP) {
        
        [self jumpToDownloadAppFromButton:YES];
    }
    
    if (self.playingADModel.type == TTVideoPasterADPageTypeWeb) {
        [self jumpToADDetailPageFromButton:YES];
    }
}

- (void)pasterADClicked
{
    if (!_allowClickToPause) {
        if (self.playingADModel.type == TTVideoPasterADPageTypeAPP) {
            [self jumpToDownloadAppFromButton:NO];
        }
        if (self.playingADModel.type == TTVideoPasterADPageTypeWeb) {
            [self jumpToADDetailPageFromButton:NO];
        }
        return;
    }
    
    __unused __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePauseButtonIfNeeded) object:nil];
    
    if ([self.movieView isPlaying])
    {
        if ([self.natantView isPauseButtonShowed]) {
            [self.natantView hidePauseButtonAnimated:YES];
        } else {
            [self.natantView showPauseButtonAnimated:YES];
            [self performSelector:@selector(hidePauseButtonIfNeeded) withObject:nil afterDelay:1.5];
        }
    }
    else
    {
        if ([self.natantView isPlayButtonShowed]) {
            [self.natantView hidePlayButtonAnimated:YES];
        } else {
            [self.natantView showPlayButtonAnimated:YES];
        }
        
    }
}

- (void)backButtonClicked:(UIButton *)button
{
    [self setIsFullScreen:NO];
    if ([self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:YES completionBlock:nil];
    }
}

- (void)hidePauseButtonIfNeeded
{
    if ([self.movieView isPlaying]) {
        [self.natantView hidePauseButtonAnimated:YES];
    }
}

- (void)playButtonClicked:(UIButton *)button
{
    [self.movieView resumeMovie];
    [self.natantView showPauseButtonAnimated:NO];
    __unused __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePauseButtonIfNeeded) object:nil];
    [self performSelector:@selector(hidePauseButtonIfNeeded) withObject:nil afterDelay:1.5];
    [self.adTracker sendContinueWithExtra:nil duration:0 viewType:[self currentViewType]];
}

- (void)pauseButtonClicked:(UIButton *)button
{
    [self.movieView pauseMovie];
    [self.natantView showPlayButtonAnimated:NO];
    [self.adTracker sendPauseWithExtra:nil duration:0 viewType:[self currentViewType]];
}

- (void)timerOver {
    
    if (self.playingADModel.style == TTVideoPasterADStyleImage) {
        
        [self playNextADModel];
    } else {
        
        [self endPlayingPasterAD];
    }
}

- (void)replayButtonClicked:(UIButton *)button {
    
    [self.adTracker sendClickReplayButtonEventWithExtra:nil duration:0 viewType:[self currentViewType]];
    
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

- (void)setPlayingADModel:(TTVideoPasterADModel *)playingADModel
{
    if (_playingADModel != playingADModel) {
        _playingADModel = playingADModel;
    }
    self.adTracker.adModel = playingADModel;
}

- (TTVideoPasterADModel *)popADModel
{
    if (self.playingList.count > 0) {
        TTVideoPasterADModel *model = self.playingList.firstObject;
        [self.playingList removeObject:model];
        self.playingADModel = model;
        return model;
    }
    
    self.playingADModel = nil;
    return nil;
}

- (void)startPlayADmodel:(TTVideoPasterADModel *)adModel
{
    if (!adModel) {
        if (self.pasterADCompletionBlock) {
            self.pasterADCompletionBlock();
        }
        return;
    }
    
    if (adModel.style == TTVideoPasterADStyleImage) {
        
        [self beginMonitorDeviceOrientationChange];
        
        [self pasterADWillStart];
        
    } else if (adModel.style == TTVideoPasterADStyleVideo) {
        
        ExploreMovieViewModel *videoModel = [ExploreMovieViewModel new];
        videoModel.videoPlayType = TTVideoPlayTypePasterAD;
        videoModel.shouldNotRemoveAllMovieView = YES;
        
        TTVideoPasterADVideoInfoModel *videoInfoModel = adModel.videoPasterADInfoModel.videoInfo;

        videoModel.gModel = [[TTGroupModel alloc] initWithGroupID:videoInfoModel.videoGroupID];
        self.movieView.videoModel = videoModel;
        [self.movieView playVideoForVideoID:adModel.videoPasterADInfoModel.videoInfo.videoID exploreVideoSP:ExploreVideoSPToutiao videoPlayType:TTVideoPlayTypePasterAD];
    }
}

- (void)playNextADModel
{
    TTVideoPasterADModel *model = [self popADModel];
    [self startPlayADmodel:model];
}

- (void)jumpToDownloadAppFromButton:(BOOL)isFromButton {

    if (self.playingADModel.type != TTVideoPasterADPageTypeAPP) {
        
        return ;
    }
    
    if (isFromButton) {
        [self.adTracker sendDownloadClickButtonEventWithExtra:nil duration:0 viewType:[self currentViewType]];
    }else{
        [self.adTracker sendClickADEventWithExtra:nil duration:0 viewType:[self currentViewType]];
    }
    
    self.shouldPause = YES;
    [self.movieView pauseMovie];
    [self.natantView pauseTimer];
    
    self.clickedDownloadBtn = YES;

    if ([self.natantView isFullScreen] && [self.delegate respondsToSelector:@selector(videoPasterADViewControllerToggledToFullScreen:animationed:completionBlock:)]) {
        WeakSelf;
        [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:NO completionBlock:^(BOOL finished) {
            StrongSelf;
            [[SSAppStore shareInstance] openAppStoreByActionURL:self.playingADModel.videoPasterADInfoModel.downloadURL itunesID:self.playingADModel.videoPasterADInfoModel.appleID presentController:[TTUIResponderHelper topViewControllerFor: self.view.superview]];
        }];
        [self setIsFullScreen:NO];
        [self.movieView.moviePlayerController exitFullscreen];

        
    } else {
        [[SSAppStore shareInstance] openAppStoreByActionURL:self.playingADModel.videoPasterADInfoModel.downloadURL itunesID:self.playingADModel.videoPasterADInfoModel.appleID presentController:[TTUIResponderHelper topViewControllerFor: self.view.superview]];
    }
}

- (void)jumpToADDetailPageFromButton:(BOOL)isFromButton
{
    TTVideoPasterADInfoModel *model = self.playingADModel.videoPasterADInfoModel;
    
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
            [self.delegate videoPasterADViewControllerToggledToFullScreen:NO animationed:NO completionBlock:nil];
            [self setIsFullScreen:NO];
            [self.movieView.moviePlayerController exitFullscreen];
        }
        
        TTAppPageCompletionBlock block = ^(id obj) {
            [self.movieView resumeMovie];
            self.shouldPause = NO;
            [self.natantView resumeTimer];
        };
        [self.movieView pauseMovie];
        [self.natantView pauseTimer];
        
        NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:2];
        condition[@"completion_block"] = [block copy];
        condition[@"log_extra"] = self.playingADModel.videoPasterADInfoModel.logExtra;
        if (isFromButton) {
            [self.adTracker sendDetailClickButtonEventWithExtra:nil duration:0 viewType:[self currentViewType]];
        }else{
            [self.adTracker sendClickADEventWithExtra:nil duration:0 viewType:[self currentViewType]];
        }
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(condition)];
    }
}

- (void)endPlayingPasterAD {
    
    [self setPlayingListWithArray:nil];
    
    if (TTVideoPasterADStyleVideo == self.playingADModel.style) {
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
        NSTimeInterval currentPlaybackTime = [self.movieView.moviePlayerController currentPlaybackTime];
        
        NSTimeInterval duration = [self.movieView.moviePlayerController duration];
        if (isnan(duration) || duration == NAN || duration <= 0 || isnan(currentPlaybackTime) || currentPlaybackTime == NAN || currentPlaybackTime < 0) {
            percent = -1;
        } else {
            percent = (currentPlaybackTime / duration ) * 100;
            percent = percent > 100 ? 100 : percent;
        }
    }
    
    return percent;
}

#pragma mark - rotate fullscreen

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([TTDeviceHelper isPadDevice]) {
        
        return UIInterfaceOrientationMaskAll;
        
    } else {
        
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (void)beginMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:device];
}

- (void)endMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notify
{
    if (![self.natantView isTopMostView]) {
        
        return ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        id obj = notify.object;
        if ([obj isKindOfClass:[UIDevice class]]) {
            UIDeviceOrientation ori = [(UIDevice *)obj orientation];
            
            if (_lastOrientation == ori ||
                ori == UIDeviceOrientationFaceUp ||
                ori == UIDeviceOrientationFaceDown ||
                ori == UIDeviceOrientationUnknown) {
                return;
            }
            
            _lastOrientation = ori;
            
            if ((ori == UIDeviceOrientationPortrait)
                && self.natantView.isFullScreen) {

                [self setIsFullScreen:NO];
                [self fullScreenbuttonClicked:nil toggledTo:NO];
            }
            
            if (ori == UIDeviceOrientationLandscapeLeft ||
                ori == UIDeviceOrientationLandscapeRight){
                
                if (!self.natantView.isFullScreen) {
                    [self setIsFullScreen:YES];
                    [self fullScreenbuttonClicked:nil toggledTo:YES];
                }
            }
        }
    });
}
// 关闭 App Store 恢复广告播放
- (void)skStoreViewDidDisappear:(NSNotification*)notify {
    if (self.clickedDownloadBtn && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self.movieView resumeMovie];
        self.shouldPause = NO;
        [self.natantView resumeTimer];
        
        self.clickedDownloadBtn = NO;
    }
}

#pragma mark - getter 
- (TTVideoPasterADService *)pasterADService {
    
    if (!_pasterADService) {
        
        _pasterADService = [TTVideoPasterADService new];
    }
    
    return _pasterADService;
}

@end
