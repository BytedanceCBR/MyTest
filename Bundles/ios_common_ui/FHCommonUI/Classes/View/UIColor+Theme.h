//
//  UIColor+Theme.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <UIKit/UIKit.h>

#define RGB(r,g,b)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXRGBA(str)   [UIColor colorWithHexString:str]
#define HEXINTRGB(hex) [UIColor colorWithRGB:hex]
NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Theme)

// #ffffff
+(UIColor *)themeWhite;
// #333333
+(UIColor *)themeGray1;

// #666666
+(UIColor *)themeGray2;

// #999999
+(UIColor *)themeGray3;

// #bbbbbb
+(UIColor *)themeGray4;

// #dddddd(浅色背景色)
+(UIColor *)themeGray5;

// #e8e8e8(分割线)
+(UIColor *)themeGray6;

// #f5f5f5(背景色)
+(UIColor *)themeGray7;
// #f7f7f7
+(UIColor *)themeGray8;
// #ff5b4c
+(UIColor *)themeRed;
// #ff5869
+(UIColor *)themeRed1;
// #fff2ed
+(UIColor *)themeRed2;
// #ff8151
+(UIColor *)themeRed3;
// #0cce6b
+(UIColor *)themeGreen1;
// #299cff
+(UIColor *)themeBlue1;

// #ff5869
+(UIColor *)themeIMBubbleRed;

// #ff8151
+(UIColor *)themeIMOrange;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexStr:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+ (UIColor *)colorWithRGB:(uint)rgb;

+ (UIColor *)colorWithRGB:(uint)rgb alpha:(uint)alpha;

@end


NS_ASSUME_NONNULL_END
