//
//  TTAdFullScreenVideoBottomActionView.m
//  Article
//
//  Created by carl on 2017/9/27.
//

#import "TTAdFullScreenVideoBottomActionView.h"

@interface TTAdFullScreenVideoBottomActionView ()
@property (nonatomic, strong) CALayer *backgroundLayer;
@end

@implementation TTAdFullScreenVideoBottomActionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)buildView {
    // GradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor];
    [self.layer addSublayer:gradientLayer];
    self.backgroundLayer = gradientLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundLayer.frame = self.bounds;
}

@end
