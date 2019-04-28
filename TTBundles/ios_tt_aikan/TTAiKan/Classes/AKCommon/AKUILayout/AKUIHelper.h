//
//  AKUIHelper.h
//  Article
//
//  Created by chenjiesheng on 2018/3/22.
//

#import <UIKit/UIKit.h>

@interface AKUIHelper : NSObject

+ (CAGradientLayer *)AiKanBackGrandientLayer;
+ (void)setupLayerToAIKanStyleWithlayer:(CAGradientLayer *)layer;
+ (NSString *)akColorHex;
+ (UIColor *)akColor;
+ (void)CALayerDisableAnimationActionBlock:(void(^)(void))block;
@end
