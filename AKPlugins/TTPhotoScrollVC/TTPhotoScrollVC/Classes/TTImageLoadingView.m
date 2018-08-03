//
//  TTImageLoadingView.m
//  Article
//
//  Created by Huaqing Luo on 15/4/15.
//
//

#import "TTImageLoadingView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIViewAdditions.h"

#define kOuterCircleRadius 20
#define kInnerCircleRadius 18

@interface TTArcView : UIView

@end

@implementation TTArcView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size = CGSizeMake(2 * kInnerCircleRadius, 2 * kInnerCircleRadius);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 3.f);
    [[UIColor tt_defaultColorForKey:kColorBackground4] setStroke];
    
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    CGContextAddArc(ctx, xCenter, yCenter, kInnerCircleRadius, - M_PI * 0.5, 0, 0);
    CGContextStrokePath(ctx);
}

@end

@interface TTImageLoadingView ()
{
    BOOL _isAnimating;
}

@property(nonatomic, assign) NSUInteger percent;
@property(nonatomic, strong, readwrite) UILabel * percentLabel;
@property(nonatomic, strong) UIImageView * animationView;


@end

@implementation TTImageLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size = CGSizeMake(32, 32);
    self = [super initWithFrame:frame];
    if (self) {
        [self.percentLabel setText:[NSString stringWithFormat:@"%d%%", 0]];
        [self.percentLabel sizeToFit];
        self.percentLabel.center = CGPointMake(self.width / 2.f, self.height / 2.f);
        
        _isAnimating = NO;
    }
    return self;
}

#pragma mark -- Setters/Getters

- (void)setLoadingProgress:(CGFloat)loadingProgress
{
    loadingProgress = MAX(loadingProgress, 0);
    loadingProgress = MIN(loadingProgress, 1.f);
    
    if (loadingProgress < 1.f && !_isAnimating) {
        [self startAnimating];
    }
    
    if (_loadingProgress != loadingProgress) {
        _loadingProgress = loadingProgress;
        NSUInteger percent = (NSUInteger)(_loadingProgress * 100);
        self.percent = percent;
        //[self setNeedsDisplay];
    }
}

- (void)setPercent:(NSUInteger)percent
{
    if (_percent != percent) {
        _percent = percent;
        [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (unsigned long)_percent]];
        [self.percentLabel sizeToFit];
        _percentLabel.center = CGPointMake(self.width / 2.f, self.height / 2.f);
        if (_percent == 100) {
            [self stopAnimating];
        }
    }
}

- (UILabel *)percentLabel
{
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_percentLabel setFont:[UIFont systemFontOfSize:10]];
        [_percentLabel setTextColor:[UIColor tt_defaultColorForKey:kColorText8]];
        [_percentLabel setTextAlignment:NSTextAlignmentCenter];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.center = CGPointMake(self.width / 2.f, self.height / 2.f);
        [self addSubview:_percentLabel];
    }
    
    return _percentLabel;
}

- (UIImageView *)animationView
{
    if (!_animationView) {
        _animationView = [[UIImageView alloc] initWithFrame:self.bounds];
        _animationView.image = [UIImage imageNamed:[self imageName]];
        _animationView.center = CGPointMake(self.width / 2.f, self.height / 2.f);
        [self addSubview:_animationView];
    }
    
    return _animationView;
}

- (NSString*)imageName
{
    return @"white_loading";
}

#pragma mark -- Animation

- (void)startAnimating
{
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.duration = 1.0f;
    rotateAnimation.repeatCount = HUGE_VAL;
    rotateAnimation.toValue = @(M_PI * 2);
    [self.animationView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    
    _isAnimating = YES;
}

- (void)stopAnimating
{
    [self.animationView.layer removeAllAnimations];
    [self.animationView removeFromSuperview];
    self.animationView = nil;
    
    _isAnimating = NO;
}

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 2.f);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    NSString * colorHexString = [NSString stringWithFormat:@"%@%@", kColorBackground4, @"4D"]; // alpha = 0.3
    [[UIColor colorWithHexString:colorHexString] setStroke];
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    CGFloat endAngle = - M_PI * 0.5 + self.loadingProgress * M_PI * 2 + 0.05; // 初始值0.05
    CGFloat radius = 21.f;
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, endAngle, 0);
    CGContextStrokePath(ctx);
    
    colorHexString = [NSString stringWithFormat:@"%@%@", kColorBackground4, @"14"]; // alpha = 0.08
    [[UIColor colorWithHexString:colorHexString] setStroke];
    CGContextAddArc(ctx, xCenter, yCenter, radius, endAngle, - M_PI * 0.5, 0);
    CGContextStrokePath(ctx);
}*/

@end
