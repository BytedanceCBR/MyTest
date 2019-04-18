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

- (void)updateData:(FHVideoModel *)model {
    // 加载、播放
    [_playerController setContentURLString:model.contentUrl];
    // 其他配置
    _playerController.muted = model.muted;
    _playerController.useCache = model.useCache;
    _playerController.repeated = model.repeated;
    _playerController.scalingMode = model.scalingMode;
    
//    [_playerController prepareToPlay];
//    [_playerController play];
}

- (void)play {
    [_playerController prepareToPlay];
    [_playerController play];
}



@end
