//
//  TTVCustomVolumeView.m
//  Article
//
//  Created by zhengjiacheng on 2018/8/31.
//

#import "TTVCustomVolumeView.h"
#import "UIImage+TTVHelper.h"

#define kDefaultContainerLayerBgColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12]
#define kLightContainerLayerBgColor [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3]
#define kDefaultProgressLayerBgColor [UIColor blackColor].CGColor
#define kLightProgressLayerBgColor [UIColor whiteColor].CGColor

#define kStatusBarHeight ([TTDeviceHelper isIPhoneXSeries] ? 44 : 20)
#define kLayerWidth ([TTDeviceHelper isIPhoneXSeries] ? 3 : 2)
#define kLayerLeftMergin ([TTDeviceHelper isIPhoneXSeries] ? 45 : 8)
#define kPathAnimationduration ([TTDeviceHelper isIPhoneXSeries] ? 0.07 : 0.15)

@interface TTVCustomVolumeView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, assign) TTVCustomVolumeStyle style;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *audioImageArr;
@property (nonatomic, strong) UIImageView *audioImageView;
@end

@implementation TTVCustomVolumeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 99;
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kStatusBarHeight);
    [self addSubview:self.containerView];
    [self.containerView.layer addSublayer:self.progressLayer];
    [self setHidden:NO];
    self.userInteractionEnabled = NO;
    
    self.alpha = 0;
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        UIImageView *audioImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"volume_black"]];
        [self addSubview:audioImage];
        self.audioImageView = audioImage;
        audioImage.frame = CGRectMake(16, (self.height - 24)/2, 26, 24);
        self.audioImageArr = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"volume_black_%d", i];
            UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
            [self addSubview:imageView];
            imageView.alpha = 0;
            [self.audioImageArr addObject:imageView];
            imageView.frame = audioImage.frame;
        }
    }
    [self refreshStyle];
}

- (void)refreshStyle{
    switch (self.style) {
        case TTVCustomVolumeStyleLight:
            self.backgroundColor = [UIColor clearColor];
            self.progressLayer.fillColor = kLightProgressLayerBgColor;
            self.progressLayer.strokeColor = kLightProgressLayerBgColor;
            self.containerView.backgroundColor = kLightContainerLayerBgColor;
            break;
        case TTVCustomVolumeStyleDefault:
            self.backgroundColor = [UIColor whiteColor];
            self.progressLayer.fillColor = kDefaultProgressLayerBgColor;
            self.progressLayer.strokeColor = kDefaultProgressLayerBgColor;
            self.containerView.backgroundColor = kDefaultContainerLayerBgColor;
            break;
        default:
            break;
    } 
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        UIColor *color = self.style == TTVCustomVolumeStyleLight ? [UIColor whiteColor] : [UIColor blackColor];
        self.audioImageView.image = [self.audioImageView.image ttv_imageWithTintColor:color];
        for (UIImageView *imageView in self.audioImageArr) {
            imageView.image = [imageView.image ttv_imageWithTintColor:color];
        }
    }
}

- (void)showWithStyle:(TTVCustomVolumeStyle)style currentVolume:(CGFloat)currentVolume newVolume:(CGFloat)newVolume{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
    
    if (self.style != style) {
        self.style = style;
        [self refreshStyle];
    }
    [self animateProgressLayer:currentVolume newVolumeValue:newVolume];
    if ([TTDeviceHelper isIPhoneXSeries]) {
        [self animateAudio:newVolume];
    }
}

- (void)dismissWithDuration:(CGFloat)duration completion:(void(^)(void))completion{
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            !completion?:completion();
        }];
    }else{
        self.alpha = 0;
        !completion?:completion();
    }
}

- (void)animateProgressLayer:(CGFloat)currentVolumeValue newVolumeValue:(CGFloat)newVolumeValue{
    [self.progressLayer removeAllAnimations];
    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnima.duration = kPathAnimationduration;
    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnima.fromValue = [NSNumber numberWithFloat:currentVolumeValue];
    pathAnima.toValue = [NSNumber numberWithFloat:newVolumeValue];
    pathAnima.fillMode = kCAFillModeForwards;
    pathAnima.removedOnCompletion = NO;
    [self.progressLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
}

- (void)animateAudio:(CGFloat)newVolumeValue{
    NSInteger lastIndex = self.audioImageArr.count - 1;
    if (lastIndex < 0) {
        return;
    }
    NSInteger index = 0;
    if (newVolumeValue == 0) {
        self.audioImageArr[0].alpha = 1;
        for (int i = 1; i <= lastIndex; i++) {
            self.audioImageArr[i].alpha = 0;
        }
        return;
    }
    self.audioImageArr[0].alpha = 0;
    NSInteger value = floor(newVolumeValue * lastIndex) + 1;
    index = value > lastIndex ? lastIndex : value;
    for (int i = 1; i <= index; i++) {
        [UIView animateWithDuration:0.15 animations:^{
            self.audioImageArr[i].alpha = 1;
        }];
    }
    for (unsigned long j = lastIndex; j > index; j--) {
        [UIView animateWithDuration:0.15 animations:^{
            self.audioImageArr[j].alpha = 0;
        }];
    }
}

- (UIView *)containerView{
    if (!_containerView) {
        CGFloat width = [TTDeviceHelper isIPhoneXSeries] ? 32:self.width - 2*kLayerLeftMergin;
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(kLayerLeftMergin, self.height/2-kLayerWidth/2, width, kLayerWidth)];
        _containerView.layer.cornerRadius = _containerView.height/2;
        _containerView.clipsToBounds = YES;
        _containerView.backgroundColor = kDefaultContainerLayerBgColor;
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
        layer.fillColor = kDefaultProgressLayerBgColor;
        layer.strokeColor = kDefaultProgressLayerBgColor;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        layer.lineWidth = kLayerWidth;
        layer.strokeEnd = 0;
        _progressLayer = layer;
    }
    return _progressLayer;
}




@end
