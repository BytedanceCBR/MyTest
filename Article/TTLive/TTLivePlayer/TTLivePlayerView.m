//
//  TTLivePlayerView.m
//  Article
//
//  Created by matrixzk on 25/09/2017.
//

#import "TTLivePlayerView.h"
#import "TVLManager.h"
#import "TTLivePlayerControlView.h"
#import "TTVPlayerStateStore.h"
#import "TTVAudioActiveCenter.h"
#import "TTVPlayerIdleController.h"
#import "TTVPlayerAudioController.h"
#import <AVFoundation/AVAudioSession.h>
#import "TTLivePlayerTrafficViewController.h"

#import "TTTrackerWrapper.h"


@interface TTLivePlayerView () <TVLDelegate, TTLivePlayerControlViewDelegate>
@property (nonatomic, strong) TVLManager *liveManager;
@property (nonatomic, strong) TTLivePlayerControlView *controlView;
@property (nonatomic, strong) TTVAudioActiveCenter *audioActiveCenter;
@property (nonatomic) BOOL shouldAutoPlayWhenAppEnterForeground;
@property (nonatomic) BOOL shouldAutoPlayWhenTrafficViewDismiss;
@property (nonatomic, strong) TTLivePlayerTrafficViewController *trafficViewController;
@end


@implementation TTLivePlayerView

- (void)dealloc
{
    [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self uploadLiveLog];
    
//NSLog(@">>>>>> TTLivePlayerView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame liveInfo:nil];
}

- (instancetype)initWithFrame:(CGRect)frame liveInfo:(TVLApiRequestInfo *)liveInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        // LiveManager
        _liveManager = [[TVLManager alloc] initWithOwnPlayer:YES];
        [_liveManager setDelegate:self];
        [_liveManager setDataSource:liveInfo];
        [_liveManager setRetryTimeLimit:32];
        
        [self setupSubviews];
        
        // AudioAction
        _audioActiveCenter = [TTVAudioActiveCenter new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        // Play
        [_liveManager play];
    }
    return self;
}

- (void)setupSubviews
{
    // PlayerView
    _liveManager.playerView.frame = self.bounds;
    _liveManager.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_liveManager.playerView];
    
    // ControlView
    TTVPlayerStateStore *playerStateStore = [TTVPlayerStateStore new];
    playerStateStore.state.enableRotate = YES;
    _controlView = [[TTLivePlayerControlView alloc] initWithFrame:self.bounds playerStateStore:playerStateStore rotateTargetView:self];
    _controlView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _controlView.delegate = self;
    [self addSubview:_controlView];
    
    // TrafficView
    _trafficViewController = [TTLivePlayerTrafficViewController new];
    _trafficViewController.trafficView.frame = self.bounds;
    _trafficViewController.trafficView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    WeakSelf;
    _trafficViewController.willDisplayTrafficViewBlock = ^{
        StrongSelf;
        if (self.liveManager.isPlaying) {
            self.shouldAutoPlayWhenTrafficViewDismiss = YES;
            [self.liveManager pause];
        }
        [self.controlView exitFullScreenAnimated:YES completion:nil];
    };
    _trafficViewController.didEndDisplayingTrafficViewBlock = ^{
        StrongSelf;
        if (self.shouldAutoPlayWhenTrafficViewDismiss) {
            [self play];
            self.shouldAutoPlayWhenTrafficViewDismiss = NO;
        }
    };
    _trafficViewController.trafficView.hidden = YES;
    [self addSubview:_trafficViewController.trafficView];
}


#pragma mark - Public methods

- (void)setTitle:(NSString *)title
{
    [self.controlView setTitle:title];
}

- (void)setStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView
{
    [self.controlView setStatusView:statusView numOfParticipantsView:numOfParticipantsView];
}

- (void)play
{
    [self.liveManager play];
    
    !self.startPlayBlock ? : self.startPlayBlock();
    
    [self.controlView clickPlayButtonWhenLiveIsPlaying:NO];
}

- (void)pause
{
    [self.liveManager pause];
    
    [self.controlView clickPlayButtonWhenLiveIsPlaying:YES];
}


#pragma mark - TVLDelegate

- (void)liveStatusResponse:(TVLLiveStatus)status
{
//#warning - TO Delete: test
//    static NSInteger i = 0;
//    status = i;
//    i = (++i) % 6;
    ///
//NSLog(@">>>>>> live status : %@", @(status));
    
    
    TTLivePlayStatus livePlayStatus = TTLivePlayStatusUnknown;
    
    switch (status) {
        case TVLLiveStatusWaiting: // 等待直播
        case TVLLiveStatusPulling: // 正在拉流
        {
            livePlayStatus = TTLivePlayStatusNotStarted;
        } break;
            
        case TVLLiveStatusEnd: // 直播结束
        {
            livePlayStatus = TTLivePlayStatusEnd;
        } break;
        case TVLLiveStatusFail: // 直播失败
        {
            livePlayStatus = TTLivePlayStatusFaild;
        } break;
            
        default:
            break;
    }

    self.controlView.livePlayStatus = livePlayStatus;
}

// 开始播放第一帧，点重试时也会回调
- (void)startRender
{
    self.controlView.livePlayStatus = TTLivePlayStatusPlaying;
    
    !self.startPlayBlock ? : self.startPlayBlock();
    [self activeAudioSession];
    [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
    [[TTVPlayerAudioController sharedInstance] setCategory:AVAudioSessionCategoryPlayback];
    
    [self.trafficViewController showTrafficViewIfNeeded];

//NSLog(@">>>>>> startRender");
}

- (void)stallStart
{
    self.controlView.livePlayStatus = TTLivePlayStatusLoading;
    
    [self deactiveAudioSession];
    
//NSLog(@">>>>>> stallStart");
}

- (void)stallEnd
{
    self.controlView.livePlayStatus = TTLivePlayStatusPlaying;
    
    [self activeAudioSession];
    
    !self.startPlayBlock ? : self.startPlayBlock();
    
//NSLog(@">>>>>> stallEnd");
}

- (void)recieveError:(NSError *)error
{
    if (error.code == TVLErrorRetryTimeout) {
        self.controlView.livePlayStatus = TTLivePlayStatusBreak;
    } else {
        self.controlView.livePlayStatus = TTLivePlayStatusFaild;
    }
    
    [self deactiveAudioSession];
    [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
    
    [self uploadLiveLog];
    
//NSLog(@">>>>>> recieveError : %@", error);
}


#pragma mark - TTLivePlayerControlViewDelegate

- (void)ttlivePlayerControlViewPlayButtonDidPressed:(TTLivePlayerControlView *)controlView isPlaying:(BOOL)isPlaying
{
    if (isPlaying) {
        [self.liveManager pause];
        
        [self deactiveAudioSession];
        [[TTVPlayerIdleController sharedInstance] lockScreen:YES later:YES];
    } else {
        [self.liveManager play];
        
        !self.startPlayBlock ? : self.startPlayBlock();
        [self activeAudioSession];
        [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
    }
}

- (void)ttlivePlayerControlViewRetryButtonDidPressed:(TTLivePlayerControlView *)controlView
{
    [self.liveManager play];
    
    self.controlView.livePlayStatus = TTLivePlayStatusLoading;
    !self.startPlayBlock ? : self.startPlayBlock();
    [self activeAudioSession];
    [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
}

- (BOOL)ttlivePlayerViewShouldRotate
{
    BOOL shouldRotate = YES;
    if (self.shouldRotatePlayerViewBlock) {
        shouldRotate = self.shouldRotatePlayerViewBlock();
    }
    return shouldRotate && !self.trafficViewController.isShowingTrafficView;
}


#pragma mark - Notification

- (void)handleAppWillResignActiveNotification:(NSNotification *)notification
{
    if (self.liveManager.isPlaying) {
        self.shouldAutoPlayWhenAppEnterForeground = YES;
        [self.liveManager pause];
    }
}

- (void)handleAppDidBecomeActiveNotification:(NSNotification *)notification
{
    if (self.shouldAutoPlayWhenAppEnterForeground) {
        [self.liveManager play];
        self.shouldAutoPlayWhenAppEnterForeground = NO;
    }
}


#pragma mark - Audio Action

- (void)activeAudioSession
{
    [self.audioActiveCenter beactive];
}

- (void)deactiveAudioSession
{
    [self.audioActiveCenter deactive];
}


#pragma mark - event track

- (void)uploadLiveLog
{
    NSDictionary *logDict = self.liveManager.logEvent;
//NSLog(@">>>>>> log: %@", logDict);
    if (!logDict || logDict.count == 0) return;
    
    [TTTrackerWrapper eventV3:@"live_sdk_log" params:[logDict copy]];
}

@end
