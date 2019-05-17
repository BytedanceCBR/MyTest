//
//  TTRealnameAuthButton.m
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import "TTRealnameAuthButton.h"

@implementation TTRealnameAuthStartButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.backgroundColorThemeKey = kColorBackground7;
        self.titleColorThemeKey = kColorText7;
        self.highlightedTitleColorThemeKey = kColorText7Highlighted;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

@end

@implementation TTRealnameAuthCaptureButton

- (void)drawRect:(CGRect)rect
{
    CGFloat startRadius = 30.5;
    CGFloat endRadius = 25;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 6;
    if (self.enabled) { // 无夜间模式
        [[UIColor tt_defaultColorForKey:kColorBackground7] setStroke];
    } else {
        [[UIColor colorWithHexString:@"943535"] setStroke];
    }
    
    [path moveToPoint:CGPointMake(center.x + startRadius, center.y)];
    [path addArcWithCenter:center
                    radius:startRadius
                startAngle:0.0
                  endAngle:M_PI * 2
                 clockwise:YES];
    [path stroke];
    [path removeAllPoints];
    
    path.lineWidth = 0;
    if (self.enabled) {
        [[UIColor tt_defaultColorForKey:kColorBackground7] setFill];
    } else {
        [[UIColor colorWithHexString:@"943535"] setFill];
    }
    [path moveToPoint:CGPointMake(center.x + endRadius, center.y)];
    [path addArcWithCenter:center
                    radius:endRadius
                startAngle:0.0
                  endAngle:M_PI * 2
                 clockwise:YES];
    [path fill];
}

@end
