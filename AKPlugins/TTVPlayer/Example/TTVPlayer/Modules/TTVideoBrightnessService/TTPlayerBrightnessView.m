//
//  TTPlayerBrightnessView.m
//  Article
//
//  Created by 赵晶鑫 on 27/08/2017.
//
//

#import "TTPlayerBrightnessView.h"
#import <TTThemed/SSThemed.h>

static const CGFloat kBrightViewWH = 155;
static const CGFloat kBrightViewH = 7;
static const CGFloat kBrightViewPadding = 13;
static const CGFloat kBrightViewGridW = 7;
static const CGFloat kBrightViewGridH = 5;
static const int kBrightViewGridNum = 16;

@interface TTPlayerBrightnessView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIView *brightView;
@property (nonatomic, strong) NSMutableArray *gridArray;
@property (nonatomic, strong) UIToolbar *backView;

// 下面为X系列
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) NSMutableArray<UIImage *> *brightnessImages;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TTPlayerBrightnessView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 99;
        if ([TTDeviceHelper isIPhoneXSeries]) {
            [self setupXSeriesSubViews];
        } else {
            [self setupSubViews];
        }
    }
    return self;
}

- (void)setupSubViews {
    self.frame = CGRectMake(0, 0, kBrightViewWH, kBrightViewWH);
    self.centerX = [UIScreen mainScreen].bounds.size.width / 2;
    self.centerY = [UIScreen mainScreen].bounds.size.height / 2;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.hidden = NO;
    self.userInteractionEnabled = NO;
    self.alpha = 0.0f;
    
    _backView = [[UIToolbar alloc] initWithFrame:self.bounds];
    [self addSubview:_backView];
    
    UIImage *img = [UIImage imageNamed:@"ios_light"];
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    _logoImageView.centerX = self.width / 2;
    _logoImageView.centerY = self.height / 2;
    _logoImageView.image = img;
    [self addSubview:_logoImageView];
    
    _brightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBrightViewWH - 2 * kBrightViewPadding, kBrightViewH)];
    _brightView.top = _logoImageView.bottom + 19;
    _brightView.centerX = self.width / 2;
    _brightView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self addSubview:_brightView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = NSLocalizedString(@"亮度", nil);
    _titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_titleLabel sizeToFit];
    _titleLabel.centerX = self.width / 2;
    _titleLabel.bottom = _logoImageView.top - 14;
    [self addSubview:_titleLabel];
    
    _gridArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < kBrightViewGridNum; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBrightViewGridW, kBrightViewGridH)];
        view.backgroundColor = [UIColor whiteColor];
        [_brightView addSubview:view];
        [_gridArray addObject:view];
    }
    CGFloat space = (_brightView.width - kBrightViewGridW * kBrightViewGridNum) / (kBrightViewGridNum + 1);
    [_gridArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.left = (idx + 1) * space + idx * kBrightViewGridW;
        view.centerY = _brightView.height / 2;
    }];
    
    [self p_updateBrightness:[UIScreen mainScreen].brightness];
}

- (void)setupXSeriesSubViews {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    self.backgroundColor = [UIColor clearColor];
    self.hidden = NO;
    self.userInteractionEnabled = NO;
    self.alpha = 0;
    
    [self addSubview:self.containerView];
    self.containerView.size = CGSizeMake(32, 3);
    self.containerView.origin = CGPointMake(45, (self.height - self.containerView.height) / 2.0);
    
    [self addSubview:self.imageView];
    self.imageView.size = CGSizeMake(26, 24);
    self.imageView.right = self.containerView.left - 10;
    self.imageView.centerY = self.containerView.centerY;
    
    self.brightnessImages = [NSMutableArray arrayWithCapacity:3];
    for (int i = 1; i < 4; i++) {
        NSString *imageName = [NSString stringWithFormat:@"brightness_white_%d", i];
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.brightnessImages addObject:image];
    }
    [self.containerView.layer addSublayer:self.progressLayer];
}

- (void)showWithCurrentBrightness:(CGFloat)currentBrightness newBrightness:(CGFloat)newBrightness {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        [self animateBrightness:newBrightness];
        [self animateProgressLayer:currentBrightness newVolumeValue:newBrightness];
    } else {
        [self p_updateBrightness:newBrightness];
    }
}

- (void)dismissWithDuration:(CGFloat)duration completion:(void (^)())completion {
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

#pragma mark - XSeries
- (void)animateBrightness:(CGFloat)newBrightnessValue {
    NSInteger lastIndex = self.brightnessImages.count - 1;
    if (lastIndex < 0) {
        return;
    }
    
    NSInteger value = floor(newBrightnessValue * (lastIndex + 1));
    NSInteger index = value > lastIndex ? lastIndex : value;
    self.imageView.image = self.brightnessImages[index];
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

#pragma mark - Not XSeries
- (void)p_updateBrightness:(CGFloat)value {
    CGFloat average = 1.0 / kBrightViewGridNum;
    NSInteger cur = value / average - 1;
    [_gridArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cur == -1) {
            view.hidden = YES;
        } else if (idx <= cur) {
            view.hidden = NO;
        } else {
            view.hidden = YES;
        }
    }];
}

#pragma mark - Getter
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
        [path moveToPoint:CGPointMake(-2, self.containerView.height/2)];
        [path addLineToPoint:CGPointMake(self.containerView.width, self.containerView.height/2)];
        
        CAShapeLayer *layer = [CAShapeLayer new];
        layer.path = path.CGPath;
        layer.fillColor = [UIColor colorWithWhite:1 alpha:1.f].CGColor;
        layer.strokeColor = [UIColor colorWithWhite:1 alpha:1.f].CGColor;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        layer.lineWidth = 3;
        layer.strokeEnd = 0;
        _progressLayer = layer;
    }
    return _progressLayer;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.tintColor = [UIColor colorWithWhite:1 alpha:1.f];
    }
    return _imageView;
}

@end
