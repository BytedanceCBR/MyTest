//
//  TTVAudioWaveView.m
//  Article
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVAudioWaveView.h"

#import "UIColor+TTThemeExtension.h"
#import "TTThemeManager.h"

static const NSInteger waveNumbers = 4;
static const CGFloat waveHeight = 16;
static const CGFloat waveWidth = 2;
static const CGFloat waveGap = 2;

@interface TTVAudioWaveView ()

@property (nonatomic, strong) NSArray *waveLayers;
@property (nonatomic, strong) NSArray *waveKeyValues;

@property (nonatomic, readwrite) BOOL isWaving;

@end

@implementation TTVAudioWaveView


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.width = waveNumbers * waveWidth + (waveNumbers - 1) * waveGap;
    frame.size.height = waveHeight;
    self = [super initWithFrame:frame];
    if (self) {
        for (CAShapeLayer *waveLayer in self.waveLayers) {
            [self.layer addSublayer:waveLayer];
        }
        [self _customThemeChanged:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_customThemeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)wave
{
    if (self.isWaving) {
        return;
    }
    self.isWaving = YES;
    for (NSInteger index = 0; index < waveNumbers; index++) {
        [self addAnimationToWaveAtIndex:index];
    }
}

- (void)finish
{
    for (CAShapeLayer *waveLayer in self.waveLayers) {
        [waveLayer removeAllAnimations];
    }
    self.isWaving = NO;
}

- (void)_customThemeChanged:(NSNotification *)noti
{
    for (CAShapeLayer *wave in self.waveLayers) {
        TTThemeManager *themeManager = [TTThemeManager sharedInstance_tt];
        wave.strokeColor = [UIColor colorWithHexString:[themeManager selectFromDayColorName:@"FFFFFF" nightColorName:@"CACACA"]].CGColor;
    }
}

- (void)addAnimationToWaveAtIndex:(NSInteger)index
{
    CAShapeLayer *wave = self.waveLayers[index];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    animation.values = self.waveKeyValues[index];
    animation.repeatCount = MAXFLOAT;
    animation.duration = 1.5;
    if (index == 0 || index == waveNumbers) {
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }

    NSString *keyName = [NSString stringWithFormat:@"waveAnimation%ld", (long)index];
    [wave addAnimation:animation forKey:keyName];
}

- (NSArray *)waveLayers
{
    if (!_waveLayers) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:waveNumbers];
        for (NSInteger index = 0; index < waveNumbers; index++) {
            [mutableArray addObject:[self waveLayerAtIndex:index]];
        }
        _waveLayers = [mutableArray copy];
    }
    return _waveLayers;
}

- (void)setIsWaving:(BOOL)isWaving
{
    _isWaving = isWaving;
    self.hidden = !_isWaving;
}

- (NSArray *)waveKeyValues
{
    if (!_waveKeyValues) {
        _waveKeyValues = @[@[@0.3, @0.6, @0.2, @0.7, @0.3],
                           @[@1.0, @0.4, @0.8, @0.2, @1.0],
                           @[@0.5, @0.8, @0.4, @1.0, @0.5],
                           @[@0.7, @0.1, @0.5, @0.3, @0.7]];
    }
    return _waveKeyValues;
}

- (CAShapeLayer *)waveLayerAtIndex:(NSInteger)index
{
    CAShapeLayer *waveLayer = [CAShapeLayer layer];
    waveLayer.frame = CGRectMake(index * (waveGap + waveWidth), 0, waveWidth, waveHeight);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(waveWidth / 2, waveHeight)];
    [path addLineToPoint:CGPointMake(waveWidth / 2, 0)];

    waveLayer.path = path.CGPath;
    waveLayer.lineWidth = waveWidth;
    waveLayer.strokeStart = 0;
    waveLayer.strokeEnd = [self.waveKeyValues[index][0] floatValue];
    return waveLayer;
}

@end

