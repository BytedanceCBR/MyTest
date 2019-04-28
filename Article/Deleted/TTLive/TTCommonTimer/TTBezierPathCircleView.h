//
//  TTBezierPathCircleView.h
//  Article
//
//  Created by xuzichao on 16/1/21.
//
//

#import <UIKit/UIKit.h>

@interface TTBezierPathCircleView : UIView

//颜色，默认白色
- (void)setCircleViewColor:(UIColor *)color;

//宽度，默认3
- (void)setCircleLineWidth:(CGFloat )width;

//最大角度,默认一圈
- (void)setCircleMaxRangeValue:(CGFloat )value; //default 2*M_PI

//绘制达到的角度
- (void)drawCircleWithRadiusValue:(CGFloat)radiusValue;

@end
