//
//  FHVideoView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/12.
//

#import "FHVideoView.h"

@interface FHVideoView ()<FHVideoCoverViewDelegate>

@property(nonatomic ,strong) UIView *playerView;

@end

@implementation FHVideoView

- (instancetype)initWithFrame:(CGRect)frame playerView:(UIView *)playerView {
    self = [super initWithFrame:frame];
    if (self) {
        _playerView = playerView;
        [self initViews];
    }
    return self;
}

- (void)initViews {
    if(self.playerView){
        [self addSubview:self.playerView];
    }
    //未播放视频时的封面视图
    self.coverView = [[FHVideoCoverView alloc] initWithFrame:CGRectZero];
    _coverView.delegate = self;
    [self addSubview:_coverView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverView.frame = self.bounds;
    self.playerView.frame = self.bounds;
}

#pragma mark - FHVideoCoverViewDelegate

- (void)playVideo {
    if(self.delegate && [self.delegate respondsToSelector:@selector(startPlayVideo)]){
        [self.delegate startPlayVideo];
    }
}

@end
