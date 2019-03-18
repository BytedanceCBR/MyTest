//
//  UIColor+Theme.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

+(UIColor *)themeWhite
{
    return [UIColor whiteColor];
}

+(UIColor *)themeGray1
{
    return RGB(0x33, 0x33, 0x33);
}

+(UIColor *)themeGray2
{
    return RGB(0x66, 0x66, 0x66);
}

+(UIColor *)themeGray3
{
    return RGB(0x99, 0x99, 0x99);
}

+(UIColor *)themeGray4
{
    return RGB(0xbb, 0xbb, 0xbb);
}

+(UIColor *)themeGray5
{
    return RGB(0xdd, 0xdd, 0xdd);
}

+(UIColor *)themeGray6
{
    return RGB(0xe8, 0xe8, 0xe8);
}

+(UIColor *)themeGray7
{
    return RGB(0xf5, 0xf5, 0xf5);
}

+(UIColor *)themeGray8
{
    return RGB(0xf7, 0xf7, 0xf7);
}

+(UIColor *)themeRed
{
    return RGB(0xff, 0x5b, 0x4c);
}

+(UIColor *)themeRed1
{
    return RGB(0xff, 0x58, 0x69);
}

+(UIColor *)themeRed2
{
    return RGB(0xff, 0xf2, 0xed);
}

+(UIColor *)themeRed3
{
    return RGB(0xff, 0x81, 0x51);
}

+(UIColor *)themeGreen1
{
    return RGB(0x0c, 0xce, 0x6b);
}

+(UIColor *)themeBlue1
{
    return RGB(0x29, 0x9c, 0xff);
}

+(UIColor *)themeIMBubbleRed
{
    return RGB(0xff, 0x58, 0x69);
}

+(UIColor *)themeIMOrange
{
    return RGB(0xff, 0x81, 0x51);
}

+ (UIColor *)colorWithHexStr:(NSString *)hexString {
    [UIColor colorWithHexString:hexString];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if (hexString == nil || hexString.length == 0) {
        return [UIColor clearColor];
    }
    if ([hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }

    if (hexString.length == 3) {
        // 处理F12 为 FF1122
        NSString *index0 = [hexString substringWithRange:NSMakeRange(0, 1)];
        NSString *index1 = [hexString substringWithRange:NSMakeRange(1, 1)];
        NSString *index2 = [hexString substringWithRange:NSMakeRange(2, 1)];
        hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@", index0, index0, index1, index1, index2, index2];
    }
    unsigned int alpha = 0xFF;

    if(hexString.length < 6) {
        return [UIColor blackColor];
    }

    NSString *rgbString = [hexString substringToIndex:6];
    NSString *alphaString = [hexString substringFromIndex:6];
    // 存在Alpha
    if (alphaString.length > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:alphaString];
        if (![scanner scanHexInt:&alpha]) {
            alpha = 0xFF;
        }
    }

    unsigned int rgb = 0;
    NSScanner *scanner = [NSScanner scannerWithString:rgbString];
    if (![scanner scanHexInt:&rgb]) {
        return nil;
    }
    return [self colorWithRGB:rgb alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    if (hexString == nil || hexString.length == 0) {
        return [UIColor clearColor];
    }
    if ([hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    if (hexString.length == 3) {
        // 处理F12 为 FF1122
        NSString *index0 = [hexString substringWithRange:NSMakeRange(0, 1)];
        NSString *index1 = [hexString substringWithRange:NSMakeRange(1, 1)];
        NSString *index2 = [hexString substringWithRange:NSMakeRange(2, 1)];
        hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@", index0, index0, index1, index1, index2, index2];
    }
    if(hexString.length < 6) {
        return [UIColor blackColor];
    }
    
    NSString *rgbString = [hexString substringToIndex:6];
    NSString *alphaString = [hexString substringFromIndex:6];
    // 存在Alpha
    if (alphaString.length > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:alphaString];
        if (![scanner scanHexInt:&alpha]) {
            alpha = 0xFF;
        }
    }
    
    unsigned int rgb = 0;
    NSScanner *scanner = [NSScanner scannerWithString:rgbString];
    if (![scanner scanHexInt:&rgb]) {
        return nil;
    }
    return [self colorWithRGB:rgb alpha:alpha * 255.0];
}

+ (UIColor *)colorWithRGB:(uint)rgb {
    return [self colorWithRGB:rgb alpha:255.0];
}

+ (UIColor *)colorWithRGB:(uint)rgb alpha:(uint)alpha {
    return [self colorWithRed:(CGFloat)((rgb & 0xFF0000) >> 16) / 255.0
                        green:(CGFloat)((rgb & 0x00FF00) >> 8) / 255.0f
                         blue:(CGFloat)(rgb & 0x0000FF) / 255.0
                        alpha:alpha / 255.0];
}


@end
