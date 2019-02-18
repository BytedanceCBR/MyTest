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

// #081f33
+(UIColor *)themeBlack;

// #a1aab3
+(UIColor *)themeGray;
// #f2f4f5
+(UIColor *)themeGrayPale;

// #45494d
+(UIColor *)themeGray1;

// #737a80
+(UIColor *)themeGray2;

// #8a9299
+(UIColor *)themeGray3;

// #a1aab3
+(UIColor *)themeGray4;

// #e1e3e6
+(UIColor *)themeGray5;

// #e8eaeb
+(UIColor *)themeGray6;

// #f2f4f5
+(UIColor *)themeGray7;

// #299cff
+(UIColor *)themeBlue;

// #081f33
+(UIColor *)themeBlue1;

// #299cff
+(UIColor *)themeBlue2;

// #3d6e99
+(UIColor *)themeBlue3;

// #e6f3ff
+(UIColor *)themeBlue4;

// #ff5b4c
+(UIColor *)themeRed;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexStr:(NSString *)hexString;

+ (UIColor *)colorWithRGB:(uint)rgb;

+ (UIColor *)colorWithRGB:(uint)rgb alpha:(uint)alpha;

@end


NS_ASSUME_NONNULL_END
