//
//  FHVideoViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHVideoViewController.h"
#import "FHVideoView.h"
#import "Masonry.h"
#import "FHVideoViewModel.h"
#import "UIViewAdditions.h"
#import "FHVideoErrorView.h"
#import "FHVideoNetFlowTipView.h"
#import "FHUserTracker.h"
#import "TTVFullScreenPart.h"
#import <BDWebImage/BDWebImageManager.h>
#import "FHHMDTManager.h"

@interface FHVideoViewController ()<FHVideoViewDelegate,TTVPlayerDelegate,TTVPlayerCustomViewDelegate>

@property(nonatomic, strong) TTVPlayer *player;
@property(nonatomic, strong) FHVideoView *videoView;
@property(nonatomic, strong) FHVideoViewModel *viewModel;
@property(nonatomic, assign) TTVPlaybackState playState;
@property(nonatomic, assign) CGRect firstVideoFrame;
//是否正在显示流量提示view
@property (nonatomic, assign) BOOL isShowingNetFlow;
//上一次的状态
@property(nonatomic, assign) TTVPlaybackState lastPlaybackState;
//记录视频播放时长
@property (nonatomic, assign) NSTimeInterval stayTime;
@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, strong) FHVideoErrorView *errorView;

@property (nonatomic, assign) BOOL isFirstDisplay;

@end

@implementation FHVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //很关键，防止全屏时候view尺寸改变
//    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.isFirstDisplay = YES;
    
    [self initViews];
    [self initConstaints];
    [self initViewModel];
}

- (void)initViews {
//    self.player = [[TTVPlayer alloc] initWithOwnPlayer:YES configFileName:@"TTVPlayerStyle.plist"];
//    self.player.delegate = self;
//    self.player.customViewDelegate = self;
//    self.player.showPlaybackControlsOnViewFirstLoaded = NO;
//    self.player.enableNoPlaybackStatus = YES;
    
    self.videoView = [[FHVideoView alloc] initWithFrame:CGRectZero];
    _videoView.delegate = self;
    [self.view addSubview:_videoView];
}

- (void)initConstaints {
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (TTVPlayer *)player {
    if(!_player){
        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES configFileName:@"TTVPlayerStyle.plist"];
        _player.delegate = self;
        _player.showPlaybackControlsOnViewFirstLoaded = NO;
        _player.enableNoPlaybackStatus = YES;
    }
    if(!_player.customViewDelegate){
        _player.customViewDelegate = self;
    }
    return _player;
}

- (CGFloat)videoWidth {
    CGFloat wid = [self.player getVideoWidth];
    if (self.model.vWidth > 0) {
        wid = self.model.vWidth;
    }
    return wid;
}

- (CGFloat)videoHeight {
    CGFloat hei = [self.player getVideoHeight];
    if (self.model.vHeight) {
        hei = self.model.vHeight;
    }
    return hei;
}

- (void)initViewModel {
    self.viewModel = [[FHVideoViewModel alloc] initWithView:self.videoView controller:self];
}

- (void)updateData:(FHVideoModel *)model {
    if(model){
        // 是否是新的vid
        if (_model && ![model.videoID isEqualToString:_model.videoID]) {
            _playState = TTVPlaybackState_Stopped;
        }
        _model = model;
                
        NSString *placeHolderImageUrl = [_model.coverImageUrl stringByReplacingOccurrencesOfString:@"/origin/" withString:@"/large/"];
        NSString *key = [[BDWebImageManager sharedManager]  requestKeyWithURL:[NSURL URLWithString:placeHolderImageUrl]];
        UIImage *placeHolder = [[BDWebImageManager sharedManager].imageCache imageForKey:key];
        
//        self.videoView.coverView.imageUrl = _model.coverImageUrl;
        [self.videoView.coverView showWithImageUrl:_model.coverImageUrl placeHoder:placeHolder];
        
        if(!self.isFirstDisplay){
            [self updateVideo];
        }
    }
}

- (void)updateVideo {
    [self.player setVideoID:_model.videoID host:@"is.snssdk.com" commonParameters:nil];
    self.player.muted = _model.muted;
    self.player.looping = _model.repeated;

    if(_model.isShowControl){
        self.player.enableNoPlaybackStatus = NO;
        [self.player addPartFromConfigForKey:TTVPlayerPartKey_Gesture];
    }else{
        self.player.enableNoPlaybackStatus = YES;
        [self.player removePartForKey:TTVPlayerPartKey_Gesture];
    }
    
    [self showStartBtnWhenPause];
    
    if(_model.isShowMiniSlider){
        self.player.controlView.immersiveContentView.alpha = 1;
    }else{
        self.player.controlView.immersiveContentView.alpha = 0;
    }
}

- (void)readyToPlay {
    if(self.isFirstDisplay){
        self.videoView.playerView = self.player.view;
        [self updateVideo];
    }
    [self.viewModel hideCoverView];
}

- (void)play {
    [FHHMDTManager sharedInstance].videoCreateTime = [[NSDate date] timeIntervalSince1970];
    
    [self readyToPlay];

    if(!self.isShowingNetFlow && self.playbackState != TTVPlaybackState_Playing){
        [self.player play];
    }
}

- (void)pause {
    if(self.playbackState == TTVPlaybackState_Playing){
        [self.player pause];
    }
}

- (void)stop {
    [self.player stop];
}

- (void)close {
    [self.player close];
    if(self.playbackState == TTVPlaybackState_Playing){
        [self trackWithName:@"video_over"];
    }
}

- (void)resetTime {
    if(self.playbackState == TTVPlaybackState_Playing){
        self.stayTime = 0;
        self.startTime = [[NSDate date] timeIntervalSince1970];
    }else{
        self.stayTime = ([[NSDate date] timeIntervalSince1970] - self.startTime) * 1000;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.firstVideoFrame.size.height <= 0) {
        self.firstVideoFrame = self.view.frame;
    }
    if (self.playState == TTVPlaybackState_Stopped) {
        [self changeVideoFrame];
    }
}

// 只是改变 所播放视频的frame：videoFrame 值，布局并不改变
- (void)changeVideoFrame {
    if(self.isFullScreen){
        return;
    }
    
    CGRect vFrame = self.view.bounds;
    CGFloat vWidth = [self videoWidth];
    CGFloat vHeight = [self videoHeight];
    // 目前只处理origin.y 为0 的数据
    if (self.playState == TTVPlaybackState_Stopped) {
        self.videoFrame = self.firstVideoFrame;
        return;
    }
    if (vFrame.origin.y > 0) {
        vFrame = self.firstVideoFrame;
    }
    if (vWidth > 0 && vHeight > 0 && vFrame.size.width > 0 && vFrame.size.height > 0) {
        CGFloat radioW = vWidth / vFrame.size.width;
        CGFloat radioH = vHeight / vFrame.size.height;
        CGFloat radio = radioW > radioH ? radioW : radioH;
        CGFloat tempW = vWidth / radio;
        CGFloat tempH = vHeight / radio;
        CGFloat offsetX = (vFrame.size.width - tempW) / 2;
        CGFloat offsetY = (vFrame.size.height - tempH) / 2;
        vFrame.origin.x += offsetX;
        vFrame.origin.y += offsetY;
        vFrame.size.width = tempW;
        vFrame.size.height = tempH;
        self.videoFrame = vFrame;
    } else {
        self.videoFrame = vFrame;
    }
}

- (void)setPlayState:(TTVPlaybackState)playState {
    if (_playState == TTVPlaybackState_Stopped) {
        if (playState == TTVPlaybackState_Playing) {
            // 第一次开始播放，修改frame
            _playState = playState;
            [self changeVideoFrame];
        }
    } else if (_playState != TTVPlaybackState_Stopped) {
        // 可以 重新开始
        if (playState == TTVPlaybackState_Stopped) {
            _playState = TTVPlaybackState_Stopped;
            [self changeVideoFrame];
        }
    }
}

- (TTVPlaybackState)playbackState {
    return self.player.playbackState;
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime complete:(void (^)(BOOL))finised {
    [self.player setCurrentPlaybackTime:currentPlaybackTime complete:finised];
}

- (void)showStartBtnWhenPause {
    if(self.playbackState == TTVPlaybackState_Paused && self.model.isShowStartBtnWhenPause && !self.isShowingNetFlow){
        [self.viewModel showCoverViewStartBtn];
    }
    
    if(self.playbackState == TTVPlaybackState_Playing && self.model.isShowStartBtnWhenPause){
        [self.viewModel hideCoverViewStartBtn];
    }
}

- (void)exitFullScreen {
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
//    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        if(self.playbackState == TTVPlaybackState_Stopped && self.isFullScreen){
            [self.player.playerStore dispatch:[self.player.playerAction actionForKey:TTVPlayerActionType_RotateToInlineScreen]];
        }
//    });
}

- (void)resetNetFlowState {
    if(self.playbackState == TTVPlaybackState_Playing){
        self.isShowingNetFlow = NO;
    }
}

#pragma mark - FHVideoViewDelegate

- (void)startPlayVideo {
    [self play];
}

#pragma mark - TTVPlayerDelegate

// control layout的代理
- (void)viewDidLoad:(TTVPlayer *)player state:(TTVPlayerState *)state {
    ///传入旋转 view
    TTVFullScreenPart * part = (TTVFullScreenPart *)[self.player partForKey:TTVPlayerPartKey_Full];
    part.customAnimator.rotateView = self.view;
}

/// 播放器展示第一帧
- (void)playerReadyToDisplay:(TTVPlayer *)player {
    [[FHHMDTManager sharedInstance] videoFirstFrameReport:VIDEO_FHVideoViewController];
}

- (void)playerViewDidLayoutSubviews:(TTVPlayer *)player state:(TTVPlayerState *)state {
    BOOL fullScreen = ((TTVPlayerState *)player.playerStore.state).fullScreenState.fullScreen;
    CGRectEdge leftEdge = fullScreen ? 20 : 12;
    CGRectEdge topEdge = 12;

    UIView *topBar = [player partControlForKey:TTVPlayerPartControlKey_TopBar];
    topBar.width = topBar.superview.width;
    topBar.height = fullScreen ? 130 : 70;
    topBar.left = 0;
    topBar.top = 0;

    UIView * defaultBackButton = [player partControlForKey:TTVPlayerPartControlKey_BackButton];
    UIView * defaultTitleLable = [player partControlForKey:TTVPlayerPartControlKey_TitleLabel];
    UIView * defaultLoadingView = [player partControlForKey:TTVPlayerPartControlKey_LoadingView];
    [defaultLoadingView setNeedsLayout];
    [defaultTitleLable sizeToFit];

    UIView * playCenter = [player partControlForKey:TTVPlayerPartControlKey_PlayCenterToggledButton];
    [playCenter sizeToFit];
    playCenter.center = CGPointMake(player.view.width / 2.0, player.view.height / 2.0);

    if (fullScreen) {
        defaultBackButton.size = CGSizeMake(24, 24);
        defaultBackButton.top = 32;
        defaultBackButton.left = 12;
        defaultTitleLable.frame = CGRectMake(defaultBackButton.right, 0, player.view.width - 2 * leftEdge, defaultTitleLable.height);
        defaultTitleLable.centerY = defaultBackButton.centerY;
    }else{
        defaultTitleLable.frame = CGRectMake(leftEdge, topEdge, player.view.width - 2 * leftEdge, defaultTitleLable.height);
    }

    UIEdgeInsets safeInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        if (fullScreen) {
            safeInset = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets;
        }
    }

    UIView *toolbar = [player partControlForKey:TTVPlayerPartControlKey_BottomBar];
    toolbar.width = player.view.width;
    toolbar.height = fullScreen ? 130 : 70;
    toolbar.left = 0;
    toolbar.bottom = player.view.height;

    UIView *currentTimeLabel = [player partControlForKey:TTVPlayerPartControlKey_TimeCurrentLabel];
    UIView *slider = [player partControlForKey:TTVPlayerPartControlKey_Slider];
    UIView *totalTimeLabel = [player partControlForKey:TTVPlayerPartControlKey_TimeTotalLabel];
    UIView *fullScreenBtn = [player partControlForKey:TTVPlayerPartControlKey_FullToggledButton];
    //只有进度条 ，全屏功能的时候
    [currentTimeLabel sizeToFit];
    currentTimeLabel.left = leftEdge;
    currentTimeLabel.centerY = (toolbar.height - safeInset.bottom - (fullScreen ? 25.5 : 16));

    NSInteger right = 0;
    fullScreenBtn.hidden = fullScreen == YES;
    if (fullScreenBtn && !fullScreenBtn.hidden) {
        fullScreenBtn.width = 32;
        fullScreenBtn.height = 32;
        fullScreenBtn.right = toolbar.width - 10;
        fullScreenBtn.centerY = currentTimeLabel.centerY;
        right = fullScreenBtn.left;
    }else{
        right = player.view.width - leftEdge;
    }

    [totalTimeLabel sizeToFit];
    totalTimeLabel.right = right - 10;
    totalTimeLabel.centerY = currentTimeLabel.centerY;

    NSInteger sliderEdge = 8;
    slider.width = totalTimeLabel.left - sliderEdge * 2 - currentTimeLabel.right;
    slider.height = toolbar.height/2;
    slider.left = currentTimeLabel.right + sliderEdge;
    slider.centerY = currentTimeLabel.centerY;
    
    
}

- (void)player:(TTVPlayer *)player didFinishedWithStatus:(TTVPlayFinishStatus *)finishStatus {
    [self.viewModel didFinishedWithStatus:finishStatus];
}

/// 播放器播放状态变化通知
- (void)player:(TTVPlayer *)player playbackStateDidChanged:(TTVPlaybackState)playbackState {
    self.playState = playbackState;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(playbackStateDidChanged:)]){
        [self.delegate playbackStateDidChanged:playbackState];
    }
    
    if(playbackState == TTVPlaybackState_Playing && self.isFirstDisplay){
        self.isFirstDisplay = NO;
    }
    
    //埋点
    [self resetTime];
    [self trackPlayBackState];
    //退出全屏播放
    [self exitFullScreen];
    //重置4g网络弹窗的状态
    [self resetNetFlowState];
    //暂停时显示或者隐藏按钮
    [self showStartBtnWhenPause];
    
    self.lastPlaybackState = playbackState;
}

/// 网络发生变化,出流量提示，应该暂停
- (void)playerDidPauseByCellularNet:(TTVPlayer *)player {
    self.isShowingNetFlow = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerDidPauseByCellularNet)]){
        [self.delegate playerDidPauseByCellularNet];
    }
}

/// 进入全屏
- (void)playerDidEnterFullscreen:(TTVPlayer *)player {
    [self trackWithName:@"enter_fullscreen"];
    self.isFullScreen = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerDidEnterFullscreen)]){
        [self.delegate playerDidEnterFullscreen];
    }
}

/// 离开全屏
- (void)playerDidExitFullscreen:(TTVPlayer *)player {
    [self trackWithName:@"exit_fullscreen"];
    self.isFullScreen = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerDidExitFullscreen)]){
        [self.delegate playerDidExitFullscreen];
    }
}

#pragma mark - 埋点相关

- (void)trackPlayBackState {
    if(self.playbackState == TTVPlaybackState_Playing){
        if(self.lastPlaybackState == TTVPlaybackState_Stopped){
            [self trackWithName:@"video_play"];
        }else{
            [self trackWithName:@"video_continue"];
        }
    }else if(self.playbackState == TTVPlaybackState_Paused){
        [self trackWithName:@"video_pause"];
    }else{
        [self trackWithName:@"video_over"];
    }
}

//埋点
- (void)trackWithName:(NSString *)name {
    NSMutableDictionary *dict = [self.tracerDic mutableCopy];
    dict[@"item_id"] = self.model.videoID;
    
    if([name isEqualToString:@"video_pause"] || [name isEqualToString:@"video_over"]){
        dict[@"stay_time"] = @(self.stayTime);
    }
    
    TRACK_EVENT(name, dict);
}

#pragma mark - TTVPlayerCustomViewDelegate

- (UIView<TTVPlayerErrorViewProtocol> *)customPlayerErrorFinishView {
    FHVideoErrorView *view = [[FHVideoErrorView alloc] init];
    view.imageUrl = self.model.coverImageUrl;
    
    __weak typeof(self) wself = self;
    view.willClickRetry = ^{
        [wself trackWithName:@"click_load"];
    };
    
    self.errorView = view;
    
    return view;
}

- (UIView<TTVFlowTipViewProtocol> *)customCellularNetTipView {
    FHVideoNetFlowTipView *view = [[FHVideoNetFlowTipView alloc] initWithFrame:self.videoView.bounds tipText:nil isSubscribe:nil];
    
    __weak typeof(self) wself = self;
    view.continuePlayBlockAddtion = ^{
        __strong typeof(wself) self = wself;
        wself.isShowingNetFlow = NO;
    };
    
    return view;
}

@end
