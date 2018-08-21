//
//  UIView+TTImagePickerBlur.h
//  Article
//
//  Created by SongChai on 2017/4/24.
//
//

#import <UIKit/UIKit.h>

enum
{
    TTBlurEffectExtraLight , // 淡白色的毛玻璃效果
    TTBlurEffectWhite , //白色的毛玻璃效果
    TTBlurEffectBlack   //黑色的毛玻璃效果
};
#define  TTBlurEffect UInt32

@interface UIView (TTImagePickerBlur)

-(void) addBlurEffect : (TTBlurEffect) eBlurEffect ;
-(void) addBlurEffect : (TTBlurEffect) eBlurEffect withTintColor:(UIColor*)tintColor;
-(void) removeBlurEffect;
@end
