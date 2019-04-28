//
//  TTRealnameAuthProgressLineView.m
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "TTRealnameAuthProgressLineView.h"

@implementation TTRealnameAuthProgressLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _processColor = [UIColor tt_themedColorForKey:kColorBackground7];
        _leftColor = [UIColor tt_themedColorForKey:kColorBackground1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat processWidth = self.width * self.percent;
    CGRect processRect = CGRectMake(0, 0, processWidth, self.height);
    CGRect leftRect = CGRectMake(processWidth, 0, self.width - processWidth, self.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.processColor.CGColor);
    CGContextFillRect(context, processRect);
    CGContextSetFillColorWithColor(context, self.leftColor.CGColor);
    CGContextFillRect(context, leftRect);
}

- (void)setPercent:(CGFloat)percent
{
    if (percent < 0.f || percent > 1.f || (_percent == percent)) {
        return;
    }
    _percent = percent;
    [self setNeedsDisplay];
}

- (void)setLeftColor:(UIColor *)leftColor
{
    if ([_leftColor isEqual:leftColor]) {
        return;
    }
    _leftColor = leftColor;
    [self setNeedsDisplay];
}

- (void)setProcessColor:(UIColor *)processColor
{
    if ([_processColor isEqual:processColor]) {
        return;
    }
    _processColor = processColor;
    [self setNeedsDisplay];
}

@end
