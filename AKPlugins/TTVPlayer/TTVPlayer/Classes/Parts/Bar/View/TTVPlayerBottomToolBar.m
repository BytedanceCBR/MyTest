//
//  TTVPlayerNavigationBar.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/7.
//

#import "TTVPlayerBottomToolBar.h"

@implementation TTVPlayerBottomToolBar

@synthesize backgroundImageView = _backgroundImageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroundImageView];
    }
    return self;
}

#pragma mark - layout
- (void)layoutSubviews {
    self.backgroundImageView.frame = self.bounds;
}

#pragma mark - getters & setters
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
    }
    return _backgroundImageView;
}


@end
