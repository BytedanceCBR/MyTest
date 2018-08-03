//
//  UIView+CustomTimingFunction.h
//
//
//  Created by 王双华 on 17/1/17.
//
//

#import <UIKit/UIKit.h>

//wiki 文档 https://wiki.bytedance.net/pages/viewpage.action?pageId=76123308
typedef NS_ENUM(NSUInteger, CustomTimingFunction) {
    CustomTimingFunctionDefault = 0,
    CustomTimingFunctionLinear,
    CustomTimingFunctionEaseIn,
    CustomTimingFunctionEaseOut,
    CustomTimingFunctionEaseInOut,
    CustomTimingFunctionQuadIn,
    CustomTimingFunctionQuadOut,
    CustomTimingFunctionQuadInOut,
    CustomTimingFunctionCubicIn,
    CustomTimingFunctionCubicOut,
    CustomTimingFunctionCubicInOut,
    CustomTimingFunctionQuartIn,
    CustomTimingFunctionQuartOut,
    CustomTimingFunctionQuartInOut,
    CustomTimingFunctionQuintIn,
    CustomTimingFunctionQuintOut,
    CustomTimingFunctionQuintInOut,
    CustomTimingFunctionSineIn,
    CustomTimingFunctionSineOut,
    CustomTimingFunctionSineInOut,
    CustomTimingFunctionCircIn,
    CustomTimingFunctionCircOut,
    CustomTimingFunctionCircInOut,
    CustomTimingFunctionExpoIn,
    CustomTimingFunctionExpoOut,
    CustomTimingFunctionExpoInOut,
    CustomTimingFunctionBackIn,
    CustomTimingFunctionBackOut,
    CustomTimingFunctionBackInOut,
    CustomTimingFunctionQuadraticEasyOut,
};

@interface UIView (CustomTimingFunction)

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction animation:(void (^)(void))animation;

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction animation:(void (^)(void))animation completion:(void (^)(BOOL finished))completion;

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animation:(void (^)(void))animation completion:(void (^)(BOOL finished))completion;

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
@end

