//
//  FHVideoView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/12.
//

#import "FHVideoView.h"
#import "AWEVideoPlayerController.h"

@interface FHVideoView ()

@property(nonatomic, strong) AWEVideoPlayerController *playerController;

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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerController.view.frame = self.bounds;
}

- (void)updateData {
    if(_playerController.isPlaying){
        return;
    }
    // 加载、播放
    [_playerController setContentURLString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v03033c20000bbvd7nlehji8cghrbb20&line=0&ratio=default&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    
    // 其他配置
    _playerController.muted = YES;
    _playerController.useCache = YES;
    _playerController.repeated = YES;  // 设置以后自动循环播放
    _playerController.scalingMode = AWEVideoScaleModeAspectFit;
    
    [_playerController prepareToPlay];
    [_playerController play];
}



@end
