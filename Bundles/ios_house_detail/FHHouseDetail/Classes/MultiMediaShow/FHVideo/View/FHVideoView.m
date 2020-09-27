//
//  FHVideoView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/12.
//

#import "FHVideoView.h"
#import <Masonry/Masonry.h>

@interface FHVideoView ()<FHVideoCoverViewDelegate>

@end

@implementation FHVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //未播放视频时的封面视图
        self.coverView = [[FHVideoCoverView alloc] initWithFrame:self.bounds];
        self.coverView.delegate = self;
        [self addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerView.frame = self.bounds;
}

- (void)setPlayerView:(UIView *)playerView {
    if(!_playerView){
        _playerView = playerView;
        _playerView.frame = self.bounds;
        [self insertSubview:_playerView belowSubview:_coverView];
    }
}

#pragma mark - FHVideoCoverViewDelegate

- (void)playVideo {
    if(self.delegate && [self.delegate respondsToSelector:@selector(startPlayVideo)]){
        [self.delegate startPlayVideo];
    }
}

@end
