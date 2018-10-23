//
//  TTLocalAssetMovieController.m
//  Article
//
//  Created by xiangwu on 2016/12/8.
//
//

#import "TTLocalAssetMovieController.h"
#import "TTAVMoviePlayerController.h"
#import "TTLocalAssetMovieControlView.h"
#import "TTMovieFullscreenViewController.h"
#import "TTMovieEnterFullscreenAnimatedTransitioning.h"
#import "TTMovieExitFullscreenAnimatedTransitioning.h"
#import "UIViewController+TTMovieUtil.h"
#import "ExploreMovieManager.h"
#import "TTMovieFullscreenProtocol.h"
#import "TTVideoRotateScreenController.h"

extern BOOL ttvs_isVideoNewRotateEnabled(void);

@implementation TTLocalAssetMoviePlayModel

@end

@interface TTLocalAssetMovieView : UIView <TTMovieFullscreenProtocol, TTVideoRotateViewProtocol>

@property (nonatomic, strong) TTAVMoviePlayerController *moviePlayer;
@property (nonatomic, strong) TTLocalAssetMovieControlView *controlView;
@property (nonatomic, copy) dispatch_block_t stopMovieBlock;

@end

@implementation TTLocalAssetMovieView

@synthesize hasMovieFatherCell = _hasMovieFatherCell;
@synthesize movieFatherCellTableView = _movieFatherCellTableView;
@synthesize movieFatherCellIndexPath = _movieFatherCellIndexPath;
@synthesize movieFatherView = _movieFatherView;
@synthesize movieInFatherViewFrame = _movieInFatherViewFrame;

@synthesize baseTableView = _baseTableView;
@synthesize indexPath = _indexPath;
@synthesize rotateViewRect = _rotateViewRect;
@synthesize rotateSuperView = _rotateSuperView;

- (void)layoutSubviews {
    [super layoutSubviews];
    self.moviePlayer.view.frame = self.bounds;
    self.controlView.frame = self.bounds;
}

- (void)forceStoppingMovie {
    if (self.stopMovieBlock) {
        self.stopMovieBlock();
    }
}

- (void)forceStop {
    if (self.stopMovieBlock) {
        self.stopMovieBlock();
    }
}

@end

@interface TTLocalAssetMovieController () <TTAVMoviePlayerControllerDelegate, UIViewControllerTransitioningDelegate, TTLocalAssetMovieControlViewDelegate, ExploreMovieManagerDelegate, TTMovieFullscreenViewControllerDelegate>

@property (nonatomic, strong) TTAVMoviePlayerController *moviePlayer;
@property (nonatomic, strong) TTLocalAssetMovieControlView *controlView;
@property (nonatomic, strong) TTLocalAssetMovieView *innerMovieView;
@property (nonatomic, strong) TTMovieFullscreenViewController *fullscreenVC;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, assign) BOOL isRefreshingSlider;
@property (nonatomic, strong) ExploreMovieManager *movieManager;
@property (nonatomic, strong) TTVideoRotateScreenController *rotateController;

@property (nonatomic, assign) BOOL isNewRotate;


@end

@implementation TTLocalAssetMovieController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_innerMovieView removeFromSuperview];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _moviePlayer = [[TTAVMoviePlayerController alloc] initWithOwnPlayer:NO];
        _moviePlayer.delegate = self;
        _controlView = [[TTLocalAssetMovieControlView alloc] init];
        _controlView.delegate = self;
        _innerMovieView = [[TTLocalAssetMovieView alloc] init];
        _innerMovieView.backgroundColor = [UIColor blackColor];
        _innerMovieView.moviePlayer = self.moviePlayer;
        _innerMovieView.controlView = self.controlView;
        _innerMovieView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_innerMovieView addSubview:_moviePlayer.view];
        [_innerMovieView addSubview:_controlView];
        WeakSelf;
        _innerMovieView.stopMovieBlock = ^ {
            StrongSelf;
            [self stop];
        };
        _rotateController = [[TTVideoRotateScreenController alloc] initWithRotateView:_innerMovieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

#pragma mark - public method

- (void)play {
    [self p_enterFullscreenWithCompletion:^{
        if (self.playModel.playURL) {
            self.moviePlayer.contentURL = [NSURL URLWithString:self.playModel.playURL];
            [self.moviePlayer prepareToPlay];
            [self.moviePlayer play];
        } else {
            if (!self.movieManager) {
                self.movieManager = [[ExploreMovieManager alloc] init];
                self.movieManager.delegate = self;
            }
            TTVideoURLRequestInfo *info = [[TTVideoURLRequestInfo alloc] init];
            info.videoID = self.playModel.videoID;
            info.sp = ExploreVideoDefinitionTypeSD;
            info.playType = TTVideoPlayTypeNormal;
            [self.movieManager fetchURLInfoWithRequestInfo:info];
        }
        [self p_resetPlayerTimer];
    }];
}

- (void)stop {
    [self.moviePlayer stop];
    [self.playbackTimer invalidate];
}

- (void)pause {
    [self.moviePlayer pause];
}

#pragma mark - update time

- (void)p_resetPlayerTimer {
    [self.playbackTimer invalidate];
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(p_updatePlaybackTime:) userInfo:nil repeats:YES];
}

- (void)p_updatePlaybackTime:(NSTimer *)timer {
    if (self.isRefreshingSlider) {
        return;
    }
    [self p_refreshWithPlaybackTime:self.moviePlayer.currentPlaybackTime duration:self.moviePlayer.duration];
}

#pragma mark - fullscreen

- (void)p_enterFullscreenWithCompletion:(dispatch_block_t)completion {
    if (ttvs_isVideoNewRotateEnabled()) {
        _isNewRotate = YES;
        [self p_newNeterFullscreenWithCompletion:completion];
        return;
    }
    _isNewRotate = NO;
    self.innerMovieView.hasMovieFatherCell = NO;
    self.innerMovieView.movieInFatherViewFrame = self.innerMovieView.frame;
    self.innerMovieView.movieFatherView = self.innerMovieView.superview;
    UIViewController *topMost = [UIViewController ttmu_currentViewController];
    UIInterfaceOrientation orientationBeforePresented = topMost.interfaceOrientation;
    UIInterfaceOrientation orientationAfterPresented = topMost.interfaceOrientation;
    UIInterfaceOrientationMask supportedOriendtation = UIInterfaceOrientationMaskPortrait;
    TTMovieFullscreenViewController *fullscreenVC = [[TTMovieFullscreenViewController alloc] initWithOrientationBeforePresented:orientationBeforePresented orientationAfterPresented:orientationAfterPresented supportedOrientations:supportedOriendtation];
    fullscreenVC.transitioningDelegate = self;
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        fullscreenVC.modalPresentationStyle = UIModalPresentationCustom;
    }
    else {
        fullscreenVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    fullscreenVC.animatedDuringTransition = YES;
    [topMost presentViewController:fullscreenVC animated:YES completion:^{
        if (completion) {
            completion();
        }
    }];
    self.fullscreenVC = fullscreenVC;
}

- (void)p_newNeterFullscreenWithCompletion:(dispatch_block_t)completion {
    self.innerMovieView.rotateSuperView = self.innerMovieView.superview;
    self.innerMovieView.rotateViewRect = self.innerMovieView.frame;
    [self.rotateController enterFullScreen:YES completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)p_exitFullscreen {
    if (_isNewRotate) {
        [self p_newExitFullscreen];
        return;
    }
    self.fullscreenVC.animatedDuringTransition = YES;
    [self.fullscreenVC dismissViewControllerAnimated:YES completion:^{
        [self.controlView refreshSliderFrame];
        self.innerMovieView.hasMovieFatherCell = NO;
        self.innerMovieView.movieInFatherViewFrame = CGRectZero;
        self.innerMovieView.movieFatherView = nil;
        if (self.movieFinishBlock) {
            self.movieFinishBlock();
        }
    }];
}

- (void)p_newExitFullscreen {
    [self.rotateController exitFullScreen:YES completion:^{
        if (self.movieFinishBlock) {
            self.movieFinishBlock();
        }
    }];
}

- (void)p_refreshPlayState {
    [self.controlView refreshPlayButton:[self.moviePlayer isPlaying]];
}

- (void)p_refreshWithPlaybackTime:(NSTimeInterval)playbackTime duration:(NSTimeInterval)duration {
    if (duration == NAN || duration <= 0 || playbackTime == NAN || playbackTime < 0) {
        [self.controlView updateTimeLabel:@"00:00" durationLabel:@"00:00"];
        return;
    }
    if (playbackTime > duration) {
        playbackTime = duration;
    }
    NSInteger minute = (NSInteger)duration / 60;
    NSInteger second = (NSInteger)duration % 60;
    NSString *durationStr = [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
    minute = (NSInteger)playbackTime / 60;
    second = (NSInteger)playbackTime % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
    [self.controlView updateTimeLabel:timeStr durationLabel:durationStr];
    
    CGFloat progress = playbackTime / duration * 100.f;
    [self.controlView setTotalTime:duration];
    [self.controlView setWatchedProgress:progress];
    [self.controlView setCachedProgress:progress];
}


#pragma mark - notification

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.moviePlayer pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self.moviePlayer play];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:[TTMovieFullscreenViewController class]]) {
        return [[TTMovieEnterFullscreenAnimatedTransitioning alloc] initWithSmallMovieView:self.innerMovieView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[TTMovieFullscreenViewController class]]) {
        return [[TTMovieExitFullscreenAnimatedTransitioning alloc] initWithFullscreenMovieView:self.innerMovieView];
    }
    return nil;
}

#pragma mark - TTAVMoviePlayerControllerDelegate

- (void)playerController:(TTAVMoviePlayerController *)playerController playbackDidFinish:(NSDictionary *)reason {
    [self p_exitFullscreen];
}

- (void)playerController:(TTAVMoviePlayerController *)player playbackStateDidChange:(TTMoviePlaybackState)playbackState {
    [self p_refreshPlayState];
}

- (void)playerController:(TTAVMoviePlayerController *)player loadStateDidChange:(TTMovieLoadState)loadState {
    
}

- (void)playerControllerIsPrepareToPlay:(TTAVMoviePlayerController *)player {
    
}

#pragma mark - TTLocalAssetMovieControlViewDelegate

- (void)controlViewWillExitFullScreen:(TTLocalAssetMovieControlView *)controlView {
    [self p_exitFullscreen];
}

- (void)controlViewDidPressPlayButton:(TTLocalAssetMovieControlView *)controlView {
    if (self.moviePlayer.playbackState == TTMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
    } else {
        [self.moviePlayer play];
    }
    [self p_refreshPlayState];
}

- (void)controlView:(TTLocalAssetMovieControlView *)controlView isSeekingToProgress:(CGFloat)progress totalTime:(NSTimeInterval)totalTime {
    self.isRefreshingSlider = YES;
    NSTimeInterval seekTime = totalTime * progress / 100;
    [self p_refreshWithPlaybackTime:seekTime duration:totalTime];
}
- (void)controlView:(TTLocalAssetMovieControlView *)controlView didSeekToProgress:(CGFloat)progress totalTime:(NSTimeInterval)totalTime {
    self.isRefreshingSlider = NO;
    self.moviePlayer.currentPlaybackTime = totalTime * progress / 100.f;
}

#pragma mark - ExploreMovieManagerDelegate

- (void)manager:(ExploreMovieManager *)manager errorDict:(NSDictionary *)errorDict videoModel:(ExploreVideoModel *)videoModel {
    self.moviePlayer.contentURL = [NSURL URLWithString:videoModel.videoInfo.videoURLInfoMap.video1.mainURLStr];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
}

#pragma mark - getter & setter

- (UIView *)movieView {
    return (UIView *)self.innerMovieView;
}

@end
