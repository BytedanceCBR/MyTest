//
//  UIView+CustomTimingFunction.m
//
//
//  Created by 王双华 on 17/1/17.
//
//

#import "UIView+CustomTimingFunction.h"

@implementation UIView (CustomTimingFunction)

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction animation:(void (^)(void))animation
{
    [self animateWithDuration:duration customTimingFunction:customTimingFunction animation:animation completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction animation:(void (^)(void))animation completion:(void (^)(BOOL finished))completion
{
    [self animateWithDuration:duration customTimingFunction:customTimingFunction delay:0.f options:0 animation:animation completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animation:(void (^)(void))animation completion:(void (^)(BOOL finished))completion
{
    NSAssert(animation, @"animation block mast not be nil");
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[self functionWithType:customTimingFunction]];
    [UIView animateWithDuration:duration delay:delay options:options animations:^{
        if (animation) {
            animation();
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    [CATransaction commit];
}

+ (void)animateWithDuration:(NSTimeInterval)duration customTimingFunction:(CustomTimingFunction)customTimingFunction delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    NSAssert(animations, @"animations block mast not be nil");
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[self functionWithType:customTimingFunction]];
    [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:^{
        if (animations) {
            animations();
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    [CATransaction commit];
}

+(CAMediaTimingFunction *)functionWithType:(CustomTimingFunction)type
{
    switch (type) {
        case CustomTimingFunctionDefault:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            break;
        case CustomTimingFunctionLinear:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;
            
        case CustomTimingFunctionEaseIn:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case CustomTimingFunctionEaseOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        case CustomTimingFunctionEaseInOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;
        case CustomTimingFunctionQuadIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.26 :0 :0.6 :0.2];
            break;
        case CustomTimingFunctionQuadOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.4 :0.8 :0.74 :1];
            break;
        case CustomTimingFunctionQuadInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.48 :0.04 :0.52 :0.96];
            break;
        case CustomTimingFunctionCubicIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0.68 :0.06];
            break;
        case CustomTimingFunctionCubicOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
            break;
        case CustomTimingFunctionCubicInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.66 :0 :0.34 :1];
            break;
        case CustomTimingFunctionQuartIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.52 :0 :0.74 :0];
            break;
        case CustomTimingFunctionQuartOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.26 :1 :0.48 :1];
            break;
        case CustomTimingFunctionQuartInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.76 :0 :0.24 :1];
            break;
        case CustomTimingFunctionQuintIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.64 :0 :0.78 :0];
            break;
        case CustomTimingFunctionQuintOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.22 :1 :0.36 :1];
            break;
        case CustomTimingFunctionQuintInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.84 :0 :0.16 :1];
            break;
        case CustomTimingFunctionSineIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.47 :0 :0.745 :0.715];
            break;
        case CustomTimingFunctionSineOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.39 :0.575 :0.565 :1];
            break;
        case CustomTimingFunctionSineInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.445 :0.05 :0.55 :0.95];
            break;
        case CustomTimingFunctionCircIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.54 :0 :1 :0.44];
            break;
        case CustomTimingFunctionCircOut:
            return [CAMediaTimingFunction functionWithControlPoints:0 :0.56 :0.46 :1];
            break;
        case CustomTimingFunctionCircInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.88 :0.14 :0.12 :0.86];
            break;
        case CustomTimingFunctionExpoIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.66 :0 :0.86 :0];
            break;
        case CustomTimingFunctionExpoOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
            break;
        case CustomTimingFunctionExpoInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.9 :0 :0.1 :1];
            break;
        case CustomTimingFunctionBackIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.6 :-0.28 :0.73 :0.04];
            break;
        case CustomTimingFunctionBackOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.17 :0.89 :0.32 :1.27];
            break;
        case CustomTimingFunctionBackInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.27 :1.55];
            break;
        default:
            break;
    }
    return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}

@end

