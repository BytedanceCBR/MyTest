//
//  TTRNVideoView.m
//  Article
//
//  Created by yin on 2016/12/29.
//
//

#import "TTRNVideoView.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTView.h"
#import "UIView+React.h"
#import "TTImageView.h"
#import "NetworkUtilities.h"
#import "TTAdConstant.h"
#import "TTAdCanvasManager.h"
#import "TTAdCommonUtil.h"
#import "TTVADPlayVideo.h"
#import "TTVBasePlayerModel.h"
#import "TTAdCanvasVideoBottomView.h"
#import <AVFoundation/AVFoundation.h>
#import "TTAVPlayerDefine.h"
#import "TTVPlayerControllerState.h"
#import "TTAdVideoTipCreator.h"

#define kTTRNVideoViewPlayNotification @"kTTRNVideoViewPlayNotification"

@interface TTRNVideoView ()<TTVBaseDemandPlayerDelegate>

@property (nonatomic, strong) TTVADPlayVideo* videoView;
@property (nonatomic, strong) TTImageView *logoView;
@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) BOOL pauseByEvent;  //是否因为后台、下一页被暂停

@end

@implementation TTRNVideoView

- (void)dealloc
{
    [self removeVideoNotification];
}

- (instancetype)init
{
    if ((self = [super init])) {
        super.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _muted = YES;
        _videoPosition = 0;
        self.pauseByEvent = NO;
        [self createSubviews];
        [self registerVideoNotification];
    }
    return self;
}

- (void)createSubviews
{
    [self addSubview:self.logoView];
    [self addSubview:self.playButton];
}

- (void)setMuted:(BOOL)muted
{
    if (_muted != muted) {
        _muted = muted;
        if (self.videoView) {
            self.videoView.player.muted = _muted;
            [self setMuteButton];
            [self trackMute];
        }
    }
}


- (void)setCover:(NSDictionary *)cover
{
    if (![_cover isEqualToDictionary:cover]) {
        _cover = [cover copy];
        NSString* coverUrl = [RCTConvert NSString:cover[@"uri"]];
        if (!isEmptyString(coverUrl)) {
            [self.logoView setImageWithURLString:coverUrl];
        }
    }
}

- (void)setPlay:(NSInteger)play
{
    if (play == TTAdCanvasVideoPlayType_Start) {
        if (!self.videoView && TTNetworkWifiConnected()) {
            [self startVideo];
        }
        else
        {
            if (self.videoView.player.context.playbackState == TTVVideoPlaybackStateFinished) {
                [self playVideo];
            }
        }
    }
    else if (play == TTAdCanvasVideoPlayType_Resume)
    {
        [self playVideo];
    }
    else if (play == TTAdCanvasVideoPlayType_Pause)
    {
        [self pauseVideo];
    }
}

- (void)setVideoPosition:(NSInteger)videoPosition
{
    if (_videoPosition != videoPosition) {
        _videoPosition = videoPosition;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.logoView.frame = self.bounds;
    self.playButton.frame = self.bounds;
}

#pragma mark -- PlayVideo

- (void)startVideo
{
    if (!self.videoView && !isEmptyString(self.video_id)) {
        TTVBasePlayerModel* videoModel = [[TTVBasePlayerModel alloc] init];
        videoModel.videoID = self.video_id;
        
        TTAdCanvasVideoBottomView* bottomView = [[TTAdCanvasVideoBottomView alloc] initWithFrame:CGRectZero];
        
        [bottomView setFullScreenButtonLogoName:_muted? @"video_mute_ad": @"video_voice_ad"];
        [bottomView.fullScreenButton addTarget:self action:@selector(muteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        TTAdVideoTipCreator* creator = [[TTAdVideoTipCreator alloc] init];

        self.videoView = [[TTVADPlayVideo alloc] initWithFrame:self.bounds playerModel:
                          videoModel];
        self.videoView.player.tipCreator = creator;
        self.videoView.player.bottomBarView = bottomView;
        [self.videoView.player setDelegate:self];
        self.videoView.player.enableRotate = NO;
        
        [self.videoView.player setMuted:_muted];
        NSString* coverUrl = [RCTConvert NSString:_cover[@"uri"]];
        [self.videoView setVideoLargeImageUrl:coverUrl];
    
        [self addSubview:self.videoView];
        [self.videoView.player readyToPlay];
        [self.videoView.player play];
        [self.videoView.player removeMiniSliderView];
        [self postPlayNotification];
        [self updateVideoSession:self.muted];
        
        [self trackStart];
        self.startDate = [NSDate date];
        
    }
}

- (void)playButtonClicked:(SSThemedButton*)button
{
    [self startVideo];
}

- (void)muteButtonClicked:(UIButton *)button
{
    [self.videoView.player setMuted:!self.videoView.player.context.muted];
    _muted = self.videoView.player.context.muted;
    [self setMuteButton];
    [self trackMute];
    [self updateVideoSession:self.muted];
}

- (void)setMuteButton
{
    UIButton* fullScreenButton = self.videoView.player.bottomBarView.fullScreenButton;
    [fullScreenButton setImage:[UIImage themedImageNamed:_muted? @"video_mute_ad": @"video_voice_ad"] forState:UIControlStateNormal];
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

- (void)playVideo
{
    if (self.videoView && self.videoView.player.context.playbackState == TTVVideoPlaybackStatePaused) {
        [self.videoView.player play];
        [self postPlayNotification];
        [self trackResume];
        [self updateVideoSession:self.muted];
    }
}

- (void)postPlayNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTRNVideoViewPlayNotification object:self.videoView];
}


- (void)pauseVideo
{
    if (self.videoView && self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        [self.videoView.player pause];
        [self trackPause];
    }
}

- (void)breakVideo
{
    if (self.videoView) {
        if (self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
            [self trackBreak];
        }
    }
}


#pragma mark - Notification

- (void)registerVideoNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseOtherVideoNoti:) name:kTTRNVideoViewPlayNotification object:self.videoView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideoNoti:) name:kTTAdCanvasVideoNotificationPause object:self.videoView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeVideoNoti:) name:kTTAdCanvasVideoNotificationResume object:self.videoView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(breakVideo) name:kTTAdCanvasNotificationExitCanvasPage object:self.videoView];
}

- (void)removeVideoNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]]) {
        if (self.videoView) {
            if (action.actionType == TTVPlayerEventTypeFinishUIReplay) {
                self.videoView.player.muted = self.muted;
                [self trackStart];
                [self postPlayNotification];
                self.startDate = [NSDate date];
            }
            else if (action.actionType == TTVPlayerEventTypePlayerResume){
                if ([[action.payload valueForKey:@"TTVPlayAction"] isEqualToString:@"TTVPlayActionUserAction"]) {
                    [self trackResume];
                    [self postPlayNotification];
                }
            }
            else if (action.actionType == TTVPlayerEventTypePlayerPause){
                if ([[action.payload valueForKey:@"TTVPauseAction"] isEqualToString:@"TTVPauseActionUserAction"]) {
                    [self trackPause];
                }
            }
        }
    }
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (self.videoView) {
        if (state == TTVVideoPlaybackStateFinished) {
            [self trackFinish];
        }
    }
}

- (void)resumeVideoNoti:(NSNotification*)noti
{
    if (self.videoView.player.context.playbackState == TTVVideoPlaybackStatePaused && self.pauseByEvent == YES) {
        [self playVideo];
        self.pauseByEvent = NO;
    }
}

- (void)pauseVideoNoti:(NSNotification*)noti
{
    if (self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        [self pauseVideo];
        self.pauseByEvent = YES;
    }
}


- (void)pauseOtherVideoNoti:(NSNotification*)noti
{
    if (self.videoView != noti.object) {
        [self.videoView.player pause];
    }
}

#pragma mark -- track

- (NSMutableDictionary *)ad_extra_data {
    NSMutableDictionary* pDict = [NSMutableDictionary dictionary];
    [pDict setValue:@(self.videoPosition) forKey:@"material_pos"];
    [pDict setValue:@(5) forKey:@"material_type"];
    return pDict;
}

- (void)trackStart
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"play_video" dict:dict];
}

- (void)trackFinish
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"finish_video" dict:dict];
}

- (void)trackResume
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"continue_video" dict:dict];
}

- (void)trackPause
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"pause_video" dict:dict];
}

- (void)trackBreak
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"break_video" dict:dict];
}

- (void)trackMute
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    if (_muted == YES) {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"mute_video" dict:dict];
    }
    else
    {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"sound_video" dict:dict];
    }
}

- (void)runOnMainThread:(void(^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
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
