//
//  TTRNLiveView.m
//  Article
//
//  Created by yin on 2017/2/15.
//
//

#import "ExploreMovieView.h"
#import "MJExtension.h"
#import "NetworkUtilities.h"
#import "RCTEventDispatcher.h"
#import "TTAdCanvasLiveModel.h"
#import "TTAdCanvasManager.h"
#import "TTAdCommonUtil.h"
#import "TTChatroomMovieView.h"
//#import "TTLiveDataSourceManager.h"
//#import "TTLiveTopBannerInfoModel.h"
#import "TTNetWorkManager.h"
#import "TTRNLiveView.h"
#import "TTRoute.h"
#import "TTImageView.h"

@interface TTRNLiveView ()<TTChatroomMovieViewDelegate>

@property (nonatomic, strong) TTChatroomMovieView* liveView;
@property (nonatomic, strong) SSThemedButton* statusView;
@property (nonatomic, strong) SSThemedButton* muteButton;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) TTAdCanvasLiveModel* liveModel;
@property (nonatomic, strong) TTImageView *logoView;
@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, strong) NSString* coverUrl;
@property (nonatomic, assign) BOOL pauseByEvent;  //是否因为后台、下一页被暂停

@end

@implementation TTRNLiveView

- (void)dealloc
{
    [self removeLiveNotification];
}

- (instancetype)init
{
    if ((self = [super init])) {
        super.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _muted = NO;
        _videoPosition = 0;
        self.pauseByEvent = NO;
        [self createSubviews];
        [self registerLiveNotification];
    }
    return self;
}

- (void)createSubviews
{
    [self addSubview:self.logoView];
    [self addSubview:self.playButton];
    self.playButton.hidden = YES;
}

#pragma mark --Setter

- (void)setCover:(NSDictionary *)cover
{
    if (![_cover isEqualToDictionary:cover]) {
        _cover = [cover copy];
        NSString* coverUrl = cover[@"uri"];
        self.coverUrl = coverUrl;
        if (!isEmptyString(coverUrl)) {
            [self.logoView setImageWithURLString:coverUrl];
        }
    }
}

- (void)setMuted:(BOOL)muted
{
    if (_muted != muted) {
        _muted = muted;
        if (self.liveView) {
            self.liveView.moviePlayerController.muted = _muted;
            [self setMutedButton];
            [self trackMute];
        }
    }
}

- (void)setLive_id:(NSString *)live_id
{
    if (![_live_id isEqualToString:live_id]) {
        _live_id = [live_id copy];
        NSString* url = [CommonURLSetting canvasAdLiveURLString];
        url = [url stringByAppendingString:_live_id];
        WeakSelf;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj){
            StrongSelf;
            self.liveModel = [[TTAdCanvasLiveModel alloc] initWithDictionary:jsonObj error:nil];
            
            //-----下面这堆全是为了无网下展示playButton,让用户触发播放-----
            TTLiveStatus live_status = self.liveModel.data.status.live_status.integerValue;
            NSInteger playback_status = self.liveModel.data.status.playback_status.integerValue;
            TTVideoPlayType play_type = TTVideoPlayTypeDefault;
            if (live_status == 3) {
                play_type = TTVideoPlayTypeLive;
                if (!TTNetworkWifiConnected()) {
                    self.playButton.hidden = NO;
                }
            }
            else if (playback_status == TTVideoPlayTypeLivePlayback)
            {
                play_type = TTVideoPlayTypeLivePlayback;
                if (!TTNetworkWifiConnected()) {
                    self.playButton.hidden = NO;
                }
            }
            //-----上面这堆全是为了无网下展示playButton,让用户触发播放-----
            
        }];
        
    }
}

- (void)setPlay:(NSInteger)play
{
    if (_play != play) {
        _play = play;
        if (play == TTAdCanvasVideoPlayType_Start) {
            if (!self.liveView && TTNetworkWifiConnected()) {
                [self startLive];
            }
            else if ([self.liveView isPlayingFinished])
            {
                [self.liveView userPlay];
            }
        }
        else if (play == TTAdCanvasVideoPlayType_Resume)
        {
            [self resumLive];
        }
        else if (play == TTAdCanvasVideoPlayType_Pause)
        {
            [self pauseLive];
        }
    }
}

- (void)setVideoPosition:(NSInteger)videoPosition
{
    if (_videoPosition != videoPosition) {
        _videoPosition = videoPosition;
    }
}


#pragma mark --PlayVideo

- (void)startLive
{
    NSString* video_id = self.liveModel.live_id;
    if (isEmptyString(video_id)) {
        return;
    }
    TTLiveStatus live_status = self.liveModel.data.status.live_status.integerValue;
    NSInteger playback_status = self.liveModel.data.status.playback_status.integerValue;
    TTVideoPlayType play_type = TTVideoPlayTypeDefault;
    if (live_status == 3) {
        play_type = TTVideoPlayTypeLive;
    }
    else if (playback_status == TTVideoPlayTypeLivePlayback)
    {
        play_type = TTVideoPlayTypeLivePlayback;
    }
    else
    {
        if (!isEmptyString(self.coverUrl)) {
            [self.logoView setImageWithURLString:self.coverUrl];
        }
        return;
    }
    
    // 生成该model完全为了事件统计
    TTChatroomMovieViewModel *movieViewModel = [TTChatroomMovieViewModel new];
    movieViewModel.type = ExploreMovieViewTypeDetail;
    movieViewModel.gModel = [[TTGroupModel alloc] initWithGroupID:video_id itemID:video_id impressionID:nil aggrType:1];
    movieViewModel.videoPlayType = play_type;
    
    
    if (!self.liveView) {
        self.liveView = [[TTChatroomMovieView alloc] initWithFrame:self.bounds type:ExploreMovieViewTypeDetail trackerDic:nil movieViewModel:movieViewModel];
        self.liveView.movieViewDelegate = self;
        self.liveView.moviePlayerController.muted = _muted;
        [self.liveView enableRotate:NO];
        self.liveView.stopMovieWhenFinished = YES;
        self.liveView.movieViewDelegate = (id<TTChatroomMovieViewDelegate>)self;
        [self.liveView markAsDetail];
        
        [self addSubview:self.liveView];
        [self updateVideoSession:self.muted];
    }
    
    [self.liveView playVideoForVideoID:video_id
                        exploreVideoSP:ExploreVideoSPToutiao
                         videoPlayType:play_type];
    
    [self.liveView setLogoImageUrl:self.coverUrl];
    
    [self.muteButton setImage:[UIImage themedImageNamed:_muted? @"video_mute_ad": @"video_voice_ad"] forState:UIControlStateNormal];
    
    if (play_type == TTVideoPlayTypeLive) {
        [self.statusView setTitle:@"直播中" forState:UIControlStateNormal];
        [self.statusView sizeToFit];
        [self.liveView.moviePlayerController.controlView resetToolBar4RNLiveWithStatusView:self.statusView muteButton:self.muteButton];
    }
    else if (play_type == TTVideoPlayTypeLivePlayback)
    {
         [self.statusView setTitle:@"回放" forState:UIControlStateNormal];
        [self.statusView sizeToFit];
        [self.liveView.moviePlayerController.controlView reLayoutToolBar4ReplayOfRNLiveWithMuteButton:self.muteButton];
    }
    self.playButton.hidden = YES;
    
    [self trackStart];
    self.startDate = [NSDate date];
}

- (void)resumLive
{
    if (self.liveView && [self.liveView isPaused]) {
        [self.liveView resumeMovie];
        [self trackResume];
        [self updateVideoSession:self.muted];
    }
}

- (void)pauseLive
{
    if (self.liveView && [self.liveView isPlaying]) {
        [self.liveView pauseMovie];
        [self trackPause];
    }
}

#pragma mark --Button Click

- (void)playButtonClicked:(SSThemedButton*)button
{
    [self startLive];
    
}

- (void)muteButtonTouched:(SSThemedButton*)muteButton
{
    BOOL muted = self.liveView.moviePlayerController.muted;
    self.liveView.moviePlayerController.muted = !muted;
    _muted = self.liveView.moviePlayerController.muted;
    [self setMutedButton];
    [self trackMute];
    [self updateVideoSession:self.muted];
}

- (void)updateVideoSession:(BOOL)mute {
    if (mute) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    } else {
        if(![[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback]) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
    }
}


- (void)setMutedButton
{
    [self.muteButton setImage:[UIImage themedImageNamed:_muted? @"video_mute_ad": @"video_voice_ad"] forState:UIControlStateNormal];
}

#pragma mark -- Notification

- (void)registerLiveNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoViewPlayFinished:) name:kExploreMovieViewPlaybackFinishNotification object:self.liveView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:self.liveView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:self.liveView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:self.liveView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseLiveView:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseLiveView:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumLiveView:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseLiveView:) name:kTTAdCanvasVideoNotificationPause object:self.liveView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumLiveView:) name:kTTAdCanvasVideoNotificationResume object:self.liveView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(breakLive:) name:kTTAdCanvasNotificationExitCanvasPage object:self.liveView];
}

- (void)removeLiveNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)videoViewPlayFinished:(NSNotification *)notification
{
    if ([notification object] == self.liveView) {
        if (self.liveView && [self.liveView isPlayingFinished]) {
            [self trackFinish];
        }
    }
}

- (void)stopVideoViewPlay:(NSNotification *)notification
{
    if (self.liveView) {
        if (![self.liveView isPlayingFinished]) {
            [self trackPause];
            [self.liveView pauseMovie];
        }
        
    }
}

- (void)stopVideoViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if (self.liveView&& [self.liveView isPlaying]) {
        [self.liveView pauseMovie];
    }
}


- (void)pauseLiveView:(NSNotification*)noti
{
    if (self.liveView&& [self.liveView isPlaying]) {
        [self.liveView pauseMovie];
        self.pauseByEvent = YES;
        [self trackPause];
    }
}

- (void)resumLiveView:(NSNotification*)noti
{
    if (self.liveView&& [self.liveView isPaused]) {
        if (self.pauseByEvent == YES) {
            [self.liveView resumeMovie];
            self.pauseByEvent = NO;
            [self trackResume];
            [self updateVideoSession:self.muted];
        }
    }
}

- (void)breakLive:(NSNotification*)noti
{
    if (self.liveView) {
        if ([self.liveView isPlaying]) {
            [self trackBreak];
        }
        [self.liveView stopMovie];
        
    }
}

#pragma mark -- TTChatroomMovieViewDelegate
//stop to replay
- (void)replayButtonClicked
{
    if (self.liveView) {
        self.liveView.moviePlayerController.muted = _muted;
        [self trackStart];
        self.startDate = [NSDate date];
    }
}

- (void)retryButtonClickedStatus:(TTMoviePlaybackState)status
{
    if (status == TTMoviePlaybackStatePlaying) {
        _play = TTMoviePlaybackStatePlaying;
        [self trackResume];
    }
    else if (status == TTMoviePlaybackStatePaused)
    {
        _play = TTMoviePlaybackStatePaused;
        [self trackPause];
    }
}


#pragma mark -- track

- (NSMutableDictionary *)ad_extra_data {
    NSMutableDictionary* ad_extra_data = [NSMutableDictionary dictionary];
    [ad_extra_data setValue:@(self.videoPosition) forKey:@"material_pos"];
    [ad_extra_data setValue:@(6) forKey:@"material_type"];
    return ad_extra_data;
}

- (void)trackStart
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString  forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"play_live" dict:dict];
}

- (void)trackFinish
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"finish_live" dict:dict];
}

- (void)trackResume
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"continue_live" dict:dict];
}

- (void)trackPause
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"pause_live" dict:dict];
}


- (void)trackBreak
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"break_live" dict:dict];
}

- (void)trackMute
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    if (_muted == YES) {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"mute_live" dict:dict];
    }
    else
    {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"sound_live" dict:dict];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.logoView.frame = self.bounds;
    self.playButton.frame = self.bounds;
}


#pragma mark --Getter

- (SSThemedButton*)statusView
{
    if (!_statusView) {
        _statusView = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _statusView.layer.cornerRadius = 5;
        _statusView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _statusView.titleLabel.font = [UIFont systemFontOfSize:12];
        _statusView.contentEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 8);
        _statusView.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
        _statusView.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -3);
        _statusView.userInteractionEnabled = NO;
        [_statusView setImage:[UIImage themedImageNamed:@"chatroom_icon_video1"] forState:UIControlStateNormal];
        _statusView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground7];
        _statusView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground7].CGColor;
        [_statusView setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
    }
    return _statusView;
}

- (SSThemedButton*)muteButton
{
    if (!_muteButton) {
        _muteButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_muteButton addTarget:self action:@selector(muteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        NSString *imageName = @"video_voice_ad";
        [_muteButton setImage:[UIImage themedImageNamed:imageName] forState:UIControlStateNormal];
    }
    return _muteButton;
}


#pragma mark --Getter

- (TTImageView *)logoView
{
    if (!_logoView) {
        _logoView = [[TTImageView alloc] initWithFrame:self.bounds];
        _logoView.backgroundColor = [UIColor clearColor];
        _logoView.contentMode = UIViewContentModeScaleAspectFill;
        _logoView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoView.layer.masksToBounds = YES;
        _logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _logoView;
}

- (SSThemedButton *)playButton
{
    if (!_playButton) {
        _playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _playButton.imageName = @"playicon_video";
        _playButton.selectedImageName = @"playicon_video_press";
        [_playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
