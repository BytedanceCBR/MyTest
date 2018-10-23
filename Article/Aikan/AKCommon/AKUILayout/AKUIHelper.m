//
//  AKUIHelper.m
//  Article
//
//  Created by chenjiesheng on 2018/3/22.
//

#import "AKUIHelper.h"
#import <UIColor+TTThemeExtension.h>
@implementation AKUIHelper

+ (void)CALayerDisableAnimationActionBlock:(void(^)(void))block
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (block) {
        block();
    }
    [CATransaction commit];
}

+ (CAGradientLayer *)AiKanBackGrandientLayer
{
    CAGradientLayer *layer = [CAGradientLayer layer];
    [self setupLayerToAIKanStyleWithlayer:layer];
    return layer;
}

+ (void)setupLayerToAIKanStyleWithlayer:(CAGradientLayer *)layer
{
    layer.colors = @[(id)[UIColor colorWithHexString:@"FF5900"].CGColor,
                     (id)[self akColor].CGColor];
    layer.locations = @[@0,@1];
    layer.startPoint = CGPointMake(0.13, 1);
    layer.endPoint = CGPointMake(0.87, 0);
}

+ (UIColor *)akColor
{
    return [UIColor colorWithHexString:[self akColorHex]];
}

+ (NSString *)akColorHex
{
    return @"FF0031";
}
@end
