//
//  FHCornerView.m
//  FHHouseBase
//
//  Created by 张静 on 2018/12/11.
//

#import "FHCornerView.h"

@implementation FHCornerView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
}

@end
