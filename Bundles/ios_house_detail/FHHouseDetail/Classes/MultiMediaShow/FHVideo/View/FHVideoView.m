//
//  FHVideoView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/12.
//

#import "FHVideoView.h"
#import "AWEVideoPlayerController.h"
#import "FHVideoMiniSliderView.h"

@interface FHVideoView ()

@property(nonatomic, strong) AWEVideoPlayerController *playerController;
@property(nonatomic, strong) FHVideoMiniSliderView *miniSliderView;
@property(nonatomic, assign) BOOL isRefreshingSlider;

@end

@implementation FHVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    _playerController = [[AWEVideoPlayerController alloc] init];
    _playerController.view.backgroundColor = [UIColor blackColor];
    [self addSubview:_playerController.view];
    
    self.miniSliderView = [[FHVideoMiniSliderView alloc] initWithFrame:CGRectZero];
    self.miniSliderView.hidden = YES;
    [self addSubview:_miniSliderView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerController.view.frame = self.bounds;
    _miniSliderView.frame = CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width, 2);
}

- (void)updateData:(FHVideoModel *)model {
    // 加载、播放
    [_playerController setContentURLString:model.contentUrl];
    // 其他配置
    _playerController.muted = model.muted;
    _playerController.useCache = model.useCache;
    _playerController.repeated = model.repeated;
    _playerController.scalingMode = model.scalingMode;
    _miniSliderView.hidden = !model.isShowMiniSlider;
}

- (void)play {
    [_playerController prepareToPlay];
    [_playerController play];
}

- (void)pause {
    [_playerController pause];
}

- (void)refreshMiniSlider {
    if (_isRefreshingSlider) {
        return;
    }
    NSTimeInterval duration = self.playerController.duration;
    NSTimeInterval currentPlaybackTime = self.playerController.currentPlaybackTime;
    if (isnan(duration) || duration == NAN || duration <= 0 || isnan(currentPlaybackTime) || currentPlaybackTime == NAN || currentPlaybackTime < 0) {
        return;
    }
    CGFloat progress = ((currentPlaybackTime / duration) * 100.f);
    [self.miniSliderView setWatchedProgress:progress];
    
    NSTimeInterval playableDuration = self.playerController.playableDuration;
    if (playableDuration > 0 && !isnan(playableDuration) && playableDuration != NAN) {
        progress = (playableDuration / duration) * 100;
        [self.miniSliderView setCacheProgress:progress];
    }
    else {
        [self.miniSliderView setCacheProgress:0];
    }
}


@end
