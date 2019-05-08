//
//  FHDetailStrickoutLabel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailStrickoutLabel.h"

@implementation FHDetailStrickoutLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.textColor setStroke];
    CGContextSetLineWidth(context, 1);
    CGFloat y = self.frame.size.height / 2;
    CGContextMoveToPoint(context, 0, y);
    CGSize size = [self sizeThatFits:CGSizeMake(100, 17)];
    CGContextAddLineToPoint(context, size.width, y);
    CGContextStrokePath(context);
}


@end
