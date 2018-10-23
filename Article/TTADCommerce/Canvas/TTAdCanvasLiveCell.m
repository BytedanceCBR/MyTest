//
//  TTAdCanvasLiveView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "MJExtension.h"
#import "TTAdCanvasLiveCell.h"
#import "TTAdCanvasLiveModel.h"
#import "TTAdCanvasManager.h"
#import "TTAdCommonUtil.h"
#import "TTChatroomMovieView.h"
#import "TTLiveDataSourceManager.h"
#import "TTLiveTopBannerInfoModel.h"
#import "TTNetWorkManager.h"
#import <TTBaseLib/NetworkUtilities.h>
#import "TTImageView.h"

@interface TTAdCanvasLiveCell ()<TTChatroomMovieViewDelegate>

@property (nonatomic, strong) TTChatroomMovieView* liveView;
@property (nonatomic, strong) SSThemedButton* statusView;
@property (nonatomic, strong) SSThemedButton* muteButton;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) TTAdCanvasLiveModel* liveModel;
@property (nonatomic, strong) TTImageView *logoView;
@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, copy)   NSString* coverUrl;
@property (nonatomic, assign) BOOL pauseByEvent;  //是否因为后台、下一页被暂停
@property (nonatomic, strong) TTAdCanvasLayoutModel* model;

@end

@implementation TTAdCanvasLiveCell

- (void)dealloc
{
    [self removeLiveNotification];
}


- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.pauseByEvent = NO;
        [self registerLiveNotification];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    [self addSubview:self.logoView];
    [self addSubview:self.playButton];
    self.playButton.hidden = YES;
}

- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    self.model = model;
    [self.logoView setImageWithURLString:self.model.data.coverUrl];
    
    if (isEmptyString(self.model.data.liveId)) {
        return;
    }
    NSString* url = [CommonURLSetting canvasAdLiveURLString];
    url = [url stringByAppendingString:self.model.data.liveId];
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

#pragma mark --life cycle

- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
        {
            [self trackShow:itemIndex];
            if (!self.liveView) {
                if (TTNetworkWifiConnected()) {
                    [self startLive];
                    [self stopRemainMedias];
                    [self trackStart];
                }
            }
            else
            {
                if ([self.liveView isPaused])
                {
                    [self.liveView resumeMovie];
                    [self stopRemainMedias];
                    [self trackResume];
                }
            }
        }
            break;
        case TTAdCanvasItemShowStatus_DidEndDisplay:
        {
            if (self.liveView && [self.liveView isPlaying]) {
                [self.liveView pauseMovie];
                [self trackPause];
            }
        }
            break;
        default:
            break;
    }
}

- (void)cellPauseByEvent
{
    if ([self.liveView isPlaying]) {
        [self.liveView pauseLive];
        self.pauseByEvent = YES;
        [self stopRemainMedias];
        [self trackPause];
    }
}

- (void)cellResumeByEvent
{
    if ([self.liveView isPaused] && self.pauseByEvent == YES) {
        [self.liveView resumeMovie];
        self.pauseByEvent = NO;
        [self stopRemainMedias];
        [self trackResume];
    }
}

- (void)cellBreakByEvent
{
    if (self.liveView && [self.liveView isPlaying]) {
        [self.liveView pauseMovie];
        self.pauseByEvent = YES;
        [self trackBreak];
    }
}

#pragma mark --delegate
// when other media play
- (void)cellMediaPlay:(TTAdCanvasBaseCell *)canvasCell
{
    if (canvasCell != self) {
        if (self.liveView && [self.liveView isPlaying]) {
            [self.liveView pauseMovie];
            [self trackPause];
        }
    }
}

- (void)stopRemainMedias
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(canvasCellVideoPlay:)]) {
        [self.delegate canvasCellVideoPlay:self];
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
        self.liveView.moviePlayerController.muted = YES;
        [self.liveView enableRotate:NO];
        self.liveView.stopMovieWhenFinished = YES;
        self.liveView.movieViewDelegate = (id<TTChatroomMovieViewDelegate>)self;
        [self.liveView markAsDetail];
        
        [self addSubview:self.liveView];
        
    }
    
    [self.liveView playVideoForVideoID:video_id
                        exploreVideoSP:ExploreVideoSPToutiao
                         videoPlayType:play_type];
    
    [self.liveView setLogoImageUrl:self.coverUrl];
    
    BOOL muted = self.liveView.moviePlayerController.muted;
    [self.muteButton setImage:[UIImage themedImageNamed:muted? @"video_mute_ad": @"video_voice_ad"] forState:UIControlStateNormal];
    
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
    else
    {
        [self.liveView.moviePlayerController.controlView reLayoutToolBar4ReplayOfRNLiveWithMuteButton:self.muteButton];
    }
    self.playButton.hidden = YES;
    
    self.startDate = [NSDate date];
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
    [self setMutedButton];
    [self trackMute];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#pragma mark -- TTChatroomMovieViewDelegate
//stop to replay
- (void)replayButtonClicked
{
    if (self.liveView) {
        [self stopRemainMedias];
        [self trackStart];
        self.startDate = [NSDate date];
    }
}

- (void)retryButtonClickedStatus:(TTMoviePlaybackState)status
{
    if (status == TTMoviePlaybackStatePlaying) {
        [self stopRemainMedias];
        [self trackResume];
    }
    else if (status == TTMoviePlaybackStatePaused)
    {
        [self trackPause];
    }
}

- (void)setMutedButton
{
    BOOL muted = self.liveView.moviePlayerController.muted;
    [self.muteButton setImage:[UIImage themedImageNamed:muted? @"video_mute_ad": @"video_voice_ad"] forState:UIControlStateNormal];
}

#pragma mark -- Notification

- (void)registerLiveNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveFinishNotification:) name:kExploreMovieViewPlaybackFinishNotification object:self.liveView];
}

- (void)removeLiveNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)liveFinishNotification:(NSNotification*)notification
{
    if ([notification object] == self.liveView) {
        [self trackFinish];
    }
}


+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)constraintWidth
{
    CGFloat width = 0;
    if (model.styles.width.floatValue > 0) {
        width = (constraintWidth * 9)/16;
        return width>0? width:211;
    }
    return 211;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.logoView.frame = self.bounds;
    self.playButton.frame = self.bounds;
}

#pragma mark -- track

- (NSDictionary *)ad_extra_data {
    NSMutableDictionary* extra_data = [NSMutableDictionary dictionary];
    [extra_data setValue:@(6) forKey:@"material_type"];
    [extra_data setValue:@(self.model.indexPath) forKey:@"material_pos"];
    return extra_data;
}

- (void)trackShow:(NSInteger)indexPath
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_live" dict:dict];
}

- (void)trackStart {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"play_live" dict:dict];
}

- (void)trackFinish {
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
    BOOL muted = self.liveView.moviePlayerController.muted;
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:muted? @"mute_live":@"sound_live" dict:dict];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
