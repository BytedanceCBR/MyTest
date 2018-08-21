//
//  TTRedpackIntroRotationView.m
//  TTAnimationDemo
//
//  Created by xushuangqing on 04/12/2017.
//  Copyright © 2017 xushuangqing. All rights reserved.
//

#import "TTRedpackIntroRotationView.h"

@interface TTRedpackIntroRotationView()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) CALayer *rotationLayer;
@property (nonatomic, strong) CALayer *imageLayer;

@property (nonatomic, strong) CAKeyframeAnimation *imageAnimation;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

@end

@implementation TTRedpackIntroRotationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        [self addSubview:self.backgroundImageView];
        [self.layer addSublayer:self.rotationLayer];
        [self.rotationLayer addSublayer:self.imageLayer];
    }
    return self;
}

- (void)startAnimation {
    [self.rotationLayer addAnimation:self.rotationAnimation forKey:@"rotation"];
    [self.imageLayer addAnimation:self.imageAnimation forKey:@"image"];
}

- (void)stopAnimation {
    [self.rotationLayer removeAllAnimations];
    [self.imageLayer removeAllAnimations];
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.image = [UIImage imageNamed:@"short_video_red_pack_bg"];
    }
    return _backgroundImageView;
}

- (CALayer *)rotationLayer {
    if (!_rotationLayer) {
        _rotationLayer = [CALayer layer];
        _rotationLayer.frame = CGRectMake(CGRectGetMidX(self.bounds) - 10.0f, CGRectGetMidY(self.bounds) - 10.0f, 20.0f, 20.0f);
        _rotationLayer.zPosition = 100.0f;
    }
    return _rotationLayer;
}

- (CALayer *)imageLayer {
    if (!_imageLayer) {
        _imageLayer = [CALayer layer];
        _imageLayer.frame = CGRectMake(0, 0, 20.0f, 20.0f);
    }
    return _imageLayer;
}

- (CAKeyframeAnimation *)imageAnimation {
    if (!_imageAnimation) {
        _imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        _imageAnimation.values = [self animationImagesArray];
        _imageAnimation.duration = 2.0f;
        _imageAnimation.keyTimes = @[@0.0, @0.5, @1.0f];
        _imageAnimation.repeatCount = HUGE_VALF;
        _imageAnimation.calculationMode = kCAAnimationDiscrete;
    }
    return _imageAnimation;
}

- (CABasicAnimation *)rotationAnimation {
    if (!_rotationAnimation) {
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        _rotationAnimation.duration = 1.0f;
        _rotationAnimation.fromValue = @(-M_PI_2);
        _rotationAnimation.toValue = @(M_PI_2);
        _rotationAnimation.repeatCount = HUGE_VALF;
    }
    return _rotationAnimation;
}

- (NSArray *)animationImagesArray {
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithCapacity:2];
    UIImage *moneyImage = [UIImage imageNamed:@"short_video_red_pack_money"];
    [muArray addObject:(id)[moneyImage CGImage]];
    UIImage *cameraImage = [UIImage imageNamed:@"short_video_red_pack_camera"];
    [muArray addObject:(id)[cameraImage CGImage]];
    return [muArray copy];
}

@end
