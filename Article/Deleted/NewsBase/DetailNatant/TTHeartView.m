//
//  ZDHeartView.m
//  Zhidao
//
//  Created by Nick Yu on 8/13/14.
//  Copyright (c) 2014 Baidu. All rights reserved.
//

#import "TTHeartView.h"
#import "SSThemed.h"
#import "UIImage+TTThemeExtension.h"

@interface TTHeartView ()

@property (nonatomic) UIView *waveView;
@end

@implementation TTHeartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _hasLiked = NO;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        self.waveView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 40, 40)];

        //红色波浪
        self.shapelayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 10)];
        [path addQuadCurveToPoint:CGPointMake(10, 10) controlPoint:(CGPoint){5, 7}];
        [path addQuadCurveToPoint:CGPointMake(20, 10) controlPoint:(CGPoint){15, 13}];
        [path addQuadCurveToPoint:CGPointMake(30, 10) controlPoint:(CGPoint){25, 7}];
        [path addQuadCurveToPoint:CGPointMake(40, 10) controlPoint:(CGPoint){35, 13}];
        [path addQuadCurveToPoint:CGPointMake(50, 10) controlPoint:(CGPoint){45, 7}];
        [path addQuadCurveToPoint:CGPointMake(60, 10) controlPoint:(CGPoint){55, 13}];
        [path addQuadCurveToPoint:CGPointMake(70, 10) controlPoint:(CGPoint){65, 7}];
        [path addQuadCurveToPoint:CGPointMake(80, 10) controlPoint:(CGPoint){75, 13}];
        [path addQuadCurveToPoint:CGPointMake(90, 10) controlPoint:(CGPoint){85, 7}];
        [path addQuadCurveToPoint:CGPointMake(100, 10) controlPoint:(CGPoint){95, 13}];

        [path addLineToPoint:CGPointMake(100, 40)];
        [path addLineToPoint:CGPointMake(0, 40)];
        [path closePath];

        self.shapelayer.path = path.CGPath;
        self.shapelayer.fillColor = SSGetThemedColorWithKey(kColorText4).CGColor;
        [self.waveView.layer addSublayer:self.shapelayer];

        // mask
        UIImage *image = [UIImage themedImageNamed:@"likeicon_actionbar_details_press.png"];
        self.imageViewBase = [[UIImageView alloc] initWithImage:image];
        self.imageViewBase.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.layer.mask = self.imageViewBase.layer;

        //顶上的图 灰色心型框
        UIImage *imageTop = [UIImage themedImageNamed:@"likeicon_actionbar_details.png"];
        self.imageViewTop = [[UIImageView alloc] initWithImage:imageTop];
        self.imageViewTop.frame = CGRectMake(0, 0, imageTop.size.width, imageTop.size.height);

        [self addSubview:self.imageViewTop];
        [self addSubview:self.waveView];
    }
    return self;
}

- (void)setHasLiked:(BOOL)hasLiked
{
    _hasLiked = hasLiked;
    [self adjustWaveView];
}

- (void)adjustWaveView
{
    self.waveView.hidden = _hasLiked;
    if (!_hasLiked) {
        self.waveView.center = CGPointMake(-50, 30);
    }
    else {
        self.waveView.center = CGPointMake(10, 0);
    }
}

-(void)doAnimationWithAppendAnimation:(TTHeartAnimationBlock)animation
                           completion:(TTHeartAnimationBlock)completion
{
    if (!_hasLiked) {
        self.waveView.hidden = NO;
        [UIView animateWithDuration:0.8
                         animations:^{
                             if (animation) {
                                 animation();
                             }
                             self.waveView.center = CGPointMake(20, 0);
                         }
                         completion:^(BOOL finished) {
                             _hasLiked = YES;
                             if (completion) {
                                 completion();
                             }
                         }];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    self.imageViewBase.image = [UIImage themedImageNamed:@"likeicon_actionbar_details_press.png"];
    self.imageViewTop.image = [UIImage themedImageNamed:@"likeicon_actionbar_details.png"];
    self.shapelayer.fillColor = SSGetThemedColorWithKey(kColorText4).CGColor;
}

@end
