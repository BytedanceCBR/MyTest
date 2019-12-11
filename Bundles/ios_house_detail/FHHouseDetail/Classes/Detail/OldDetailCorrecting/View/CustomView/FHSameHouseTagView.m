//
//  FHSameHouseTagView.m
//  FHHouseBase
//
//  Created by 张静 on 2018/12/11.
//

#import "FHSameHouseTagView.h"

@implementation FHSameHouseTagView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
}

@end

