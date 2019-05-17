//
//  FHVideoView.m
//  TTVPlayer_Example
//
//  Created by 谢思铭 on 2019/5/5.
//  Copyright © 2019 pxx914. All rights reserved.
//

#import "FHVideoView.h"

@interface FHVideoView ()

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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerView.frame = self.bounds;
}

@end
