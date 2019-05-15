//
//  TTVFullScreenVolumeView.m
//  Article
//
//  Created by mazhaoxiang on 2018/11/9.
//

#import "TTVFullScreenVolumeView.h"

@interface TTVFullScreenVolumeView ()

@property (nonatomic, strong) CAGradientLayer *shadowLayer;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *volumeImageViews;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TTVFullScreenVolumeView

- (instancetype)init {
    if (self = [super init]) {
        self.windowLevel = UIWindowLevelStatusBar + 99;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    self.backgroundColor = [UIColor clearColor];
    self.hidden = NO;
    self.userInteractionEnabled = NO;
    [self.layer addSublayer:self.shadowLayer];
    self.shadowLayer.frame = self.layer.bounds;
    
    [self addSubview:self.containerView];
    self.containerView.size = CGSizeMake(260, 2);
    self.containerView.center = CGPointMake(self.width / 2.0 + 15, 16);
    
    UIImage *image = [[UIImage imageNamed:@"volume_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.size = CGSizeMake(26, 24);
    self.imageView.right = self.containerView.left - 10;
    self.imageView.centerY = self.containerView.centerY;
    self.imageView.tintColor = [UIColor colorWithWhite:1 alpha:1.f];
    [self addSubview:self.imageView];
    
    self.volumeImageViews = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        NSString *imageName = [NSString stringWithFormat:@"volume_black_%d", i];
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:imageView];
        imageView.alpha = 0;
        imageView.tintColor = [UIColor colorWithWhite:1 alpha:1.f];
        [self.volumeImageViews addObject:imageView];
        imageView.frame = self.imageView.frame;
    }
    [self.containerView.layer addSublayer:self.progressLayer];
    
    // iOS8中，keyWindow方向没有旋转，因此在这里将视图旋转一下
    if ([TTDeviceHelper OSVersionNumber] < 9) {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            CGFloat tx = -[UIScreen mainScreen].bounds.size.width / 2 + 32;
            CGFloat ty = [UIScreen mainScreen].bounds.size.width / 2 - 32;
            CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, tx, ty);
            self.transform = CGAffineTransformRotate(transform, -M_PI_2);
        } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            CGFloat tx = 10;
            CGFloat ty = [UIScreen mainScreen].bounds.size.width / 2 - 32;
            CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, tx, ty);
            self.transform = CGAffineTransformRotate(transform, M_PI_2);
        }
    }
}

- (void)animateAudio:(CGFloat)newVolumeValue{
    NSInteger lastIndex = self.volumeImageViews.count - 1;
    if (lastIndex < 0) {
        return;
    }
    NSInteger index = 0;
    if (newVolumeValue == 0) {
        self.volumeImageViews[0].alpha = 1;
        for (int i = 1; i <= lastIndex ; i++) {
            self.volumeImageViews[i].alpha = 0;
        }
        return;
    }
    self.volumeImageViews[0].alpha = 0;
    NSInteger value = floor(newVolumeValue * lastIndex) + 1;
    index = value > lastIndex ? lastIndex : value;
    for (int i = 1; i <= index; i++) {
        [UIView animateWithDuration:0.15 animations:^{
            self.volumeImageViews[i].alpha = 1;
        }];
    }
    for (unsigned long j = lastIndex; j > index; j--) {
        [UIView animateWithDuration:0.15 animations:^{
            self.volumeImageViews[j].alpha = 0;
        }];
    }
}

- (void)animateProgressLayer:(CGFloat)currentVolumeValue newVolumeValue:(CGFloat)newVolumeValue{
    [self.progressLayer removeAllAnimations];
    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnima.duration = 0.15;
    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnima.fromValue = [NSNumber numberWithFloat:currentVolumeValue];
    pathAnima.toValue = [NSNumber numberWithFloat:newVolumeValue];
    pathAnima.fillMode = kCAFillModeForwards;
    pathAnima.removedOnCompletion = NO;
    [self.progressLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
}

#pragma mark - Public Methods
- (void)showWithCurrentVolume:(CGFloat)currentVolume newVolume:(CGFloat)newVolume {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
    
    [self animateAudio:newVolume];
    [self animateProgressLayer:currentVolume newVolumeValue:newVolume];
}

- (void)dismissWithDuration:(CGFloat)duration completion:(void (^)(void))completion {
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            !completion?:completion();
        }];
    } else {
        self.alpha = 0;
        !completion?:completion();
    }
}

#pragma mark - Getter
- (CAGradientLayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [[CAGradientLayer alloc] init];
        _shadowLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:.7f].CGColor,
                                (__bridge id)[UIColor clearColor].CGColor];
    }
    return _shadowLayer;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.layer.cornerRadius = 1;
        _containerView.clipsToBounds = YES;
        _containerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.3f];
    }
    return _containerView;
}

- (CAShapeLayer *)progressLayer{
    if (!_progressLayer) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(-2, self.containerView.height / 2)];
        [path addLineToPoint:CGPointMake(self.containerView.width, self.containerView.height / 2)];
        
        CAShapeLayer *layer = [CAShapeLayer new];
        layer.path = path.CGPath;
        layer.fillColor = [UIColor colorWithWhite:1 alpha:1.f].CGColor;
        layer.strokeColor = [UIColor colorWithWhite:1 alpha:1.f].CGColor;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        layer.lineWidth = 2;
        layer.strokeEnd = 0;
        _progressLayer = layer;
    }
    return _progressLayer;
}

@end
