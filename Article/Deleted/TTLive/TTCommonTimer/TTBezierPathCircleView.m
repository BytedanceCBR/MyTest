//
//  TTBezierPathCircleView.m
//  Article
//
//  Created by xuzichao on 16/1/21.
//
//

#import "TTBezierPathCircleView.h"

@interface TTBezierPathCircleView ()

@property (nonatomic,strong) UIColor *circleColor;
@property (nonatomic,assign) CGFloat maxRangeValue;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,strong) CAShapeLayer *backGroundLayer;
@property (nonatomic,strong) UIBezierPath *backGroundBezierPath;

@end

@implementation TTBezierPathCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.circleColor = [UIColor whiteColor];
        self.maxRangeValue = M_PI * 2;
        self.lineWidth = 3;
        //视图
        self.backgroundColor = [UIColor clearColor];
        self.backGroundLayer = [CAShapeLayer layer];
        self.backGroundLayer.fillColor = [[UIColor clearColor] CGColor];
        self.backGroundLayer.frame = self.frame;
        [self.layer addSublayer:self.backGroundLayer];
    }
    return self;
}

- (void)setCircleViewColor:(UIColor *)color
{
    self.circleColor = color;
}
- (void)setCircleLineWidth:(CGFloat )width
{
    self.lineWidth = width;
}
- (void)setCircleMaxRangeValue:(CGFloat )value
{
    self.maxRangeValue = value;
}

- (void)drawCircleWithRadiusValue:(CGFloat)radiusValue
{
    if (radiusValue > self.maxRangeValue) {
        radiusValue = self.maxRangeValue;
    }
    
    self.backGroundLayer.strokeColor = self.circleColor.CGColor;
    self.backGroundLayer.lineWidth = self.lineWidth;
    self.backGroundBezierPath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                               radius:(CGRectGetWidth(self.bounds)-self.lineWidth)/2.0
                                                           startAngle: - M_PI / 2
                                                             endAngle:radiusValue - M_PI / 2
                                                            clockwise:YES];
    self.backGroundLayer.path = self.backGroundBezierPath.CGPath;
}



@end
