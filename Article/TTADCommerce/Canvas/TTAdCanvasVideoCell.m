//
//  TTAdCanvasVideoView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasVideoCell.h"
#import "TTImageView.h"
#import "TTAdConstant.h"
#import "TTAdCanvasManager.h"
#import <TTBaseLib/NetworkUtilities.h>
#import "TTAdCommonUtil.h"
#import "TTVADPlayVideo.h"
#import "TTVBasePlayerModel.h"
#import "TTAdCanvasVideoBottomView.h"
#import <AVFoundation/AVFoundation.h>
#import "TTAVPlayerDefine.h"
#import "TTVPlayerControllerState.h"
#import "TTAdVideoTipCreator.h"

@interface TTAdCanvasVideoCell ()<TTVBaseDemandPlayerDelegate>

@property (nonatomic, strong) TTVADPlayVideo* videoView;
@property (nonatomic, strong) TTImageView *logoView;
@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) BOOL pauseByEvent;  //是否因为后台、下一页被暂停

@property (nonatomic, strong) TTAdCanvasLayoutModel* model;

@end

@implementation TTAdCanvasVideoCell

- (void)dealloc
{
    [self removeVideoNotification];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.pauseByEvent = NO;
        [self setSubViews];
    }
    return self;
}


- (void)setSubViews
{
    [self addSubview:self.logoView];
    [self addSubview:self.playButton];
}

- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    self.model = model;
    if (!isEmptyString(self.model.data.coverUrl)) {
        [self.logoView setImageWithURLString:self.model.data.coverUrl];
    }
}

#pragma mark --life cycle

- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
        {
            [self trackShow:itemIndex];
            if (!self.videoView) {
                if (TTNetworkWifiConnected()) {
                    [self startVideo];
                    [self stopRemainMedias];
                    [self trackStart];
                }
            }
            else if (self.videoView)
            {
                if (self.videoView.player.context.playbackState == TTVVideoPlaybackStatePaused)
                {
                    [self.videoView.player play];
                    [self stopRemainMedias];
                    [self trackResume];
                }
            }
        }
            break;
        case TTAdCanvasItemShowStatus_DidEndDisplay:
        {
            if (self.videoView && self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
                [self.videoView.player pause];
                [self trackPause];
            }
        }
            break;
        default:
            break;
    }
}

- (void)playButtonClicked:(UIButton *)button
{
    [self startVideo];
}

- (void)cellResumeByEvent
{
    if (self.videoView.player.context.playbackState == TTVVideoPlaybackStatePaused)
    {
        if (self.pauseByEvent == YES) {
            [self.videoView.player play];
            self.pauseByEvent = NO;
            [self stopRemainMedias];
            [self trackResume];
        }
        
    }
}

- (void)cellPauseByEvent
{
    if (self.videoView && self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        [self.videoView.player pause];
        self.pauseByEvent = YES;
        [self trackPause];
    }
}

- (void)cellBreakByEvent
{
    if (self.videoView && self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        [self.videoView.player pause];
        [self trackBreak];
    }
}

#pragma mark --delegate
// when other media play
- (void)cellMediaPlay:(TTAdCanvasBaseCell *)canvasCell
{
    if (canvasCell != self) {
        if (self.videoView && self.videoView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
            [self.videoView.player pause];
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


#pragma mark -- PlayVideo

- (void)startVideo
{
    if (!self.videoView && !isEmptyString(self.model.data.videoId)) {
        
        TTVBasePlayerModel* videoModel = [[TTVBasePlayerModel alloc] init];
        videoModel.videoID = self.model.data.videoId;
        
        TTAdCanvasVideoBottomView* bottomView = [[TTAdCanvasVideoBottomView alloc] initWithFrame:CGRectZero];
        
        [bottomView setFullScreenButtonLogoName:@"video_mute_ad"];
        [bottomView.fullScreenButton addTarget:self action:@selector(muteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        TTAdVideoTipCreator* creator = [[TTAdVideoTipCreator alloc] init];
        
        self.videoView = [[TTVADPlayVideo alloc] initWithFrame:self.bounds playerModel: videoModel];
        self.videoView.player.bottomBarView = bottomView;
        self.videoView.player.tipCreator = creator;
        [self.videoView.player setDelegate:self];
        self.videoView.player.enableRotate = NO;
        
        [self.videoView.player setMuted:YES];
        [self.videoView.player removeMiniSliderView];
        NSString* coverUrl = self.model.data.coverUrl;
        [self.videoView setVideoLargeImageUrl:coverUrl];
        
        [self addSubview:self.videoView];
        [self.videoView.player readyToPlay];
        [self.videoView.player play];
        [self updateVideoSession:YES];
        
        [self trackStart];
        self.startDate = [NSDate date];
        
    }
    
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

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]]) {
        if (self.videoView) {
            if (action.actionType == TTVPlayerEventTypeFinishUIReplay) {
                [self trackStart];
                [self stopRemainMedias];
                self.startDate = [NSDate date];
            }
            else if (action.actionType == TTVPlayerEventTypePlayerResume){
                [self trackResume];
            }
            else if (action.actionType == TTVPlayerEventTypePlayerPause){
                [self trackPause];
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


- (void)muteButtonClicked:(UIButton *)button
{
    BOOL muted = self.videoView.player.context.muted;
    [self.videoView.player setMuted:!muted];
    [self setMuteButton];
    [self trackMute];
    [self updateVideoSession:muted];
}


- (void)setMuteButton
{
    BOOL muted = self.videoView.player.context.muted;
    UIButton* fullScreenButton = self.videoView.player.bottomBarView.fullScreenButton;
    [fullScreenButton setImage:[UIImage themedImageNamed:muted? @"video_mute_ad": @"video_voice_ad"] forState:UIControlStateNormal];
}

#pragma mark - Notification

- (void)removeVideoNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)constraintWidth
{
    if ([model.data isFullScreen]) {
        return [UIScreen mainScreen].bounds.size.height;
    }
    return [super heightForModel:model inWidth:constraintWidth];
}


#pragma mark -- track

- (NSMutableDictionary *)ad_extra_data {
    NSMutableDictionary* extra_data = [NSMutableDictionary dictionary];
    [extra_data setValue:@(5) forKey:@"material_type"];
    [extra_data setValue:@(self.model.indexPath) forKey:@"material_pos"];
    return extra_data;
}

- (void)trackShow:(NSInteger)indexPath
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_video" dict:dict];
}


- (void)trackStart
{
    self.startDate = [NSDate date];
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
    [dict setValue:[self ad_extra_data] forKey:@"ad_extra_data"];
    NSTimeInterval duration =  (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    [dict setValue:@(duration).stringValue forKey:@"duration"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"break_video" dict:dict];
}

- (void)trackMute
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[self ad_extra_data].format2JSONString forKey:@"ad_extra_data"];
    BOOL muted = self.videoView.player.context.muted;
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:muted? @"mute_video":@"sound_video" dict:dict];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.logoView.frame = self.bounds;
    self.playButton.frame = self.bounds;
}

#pragma mark --Getter

- (TTImageView *)logoView
{
    if (!_logoView) {
        _logoView = [[TTImageView alloc] init];
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
