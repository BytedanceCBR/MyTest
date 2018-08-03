//
//  UIColor+TTThemeExtension.m
//  Zhidao
//
//  Created by Nick Yu on 15/1/26.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "TTBaseMacro.h"
#import "TTThemeManager.h"

@implementation UIColor (SSUIColorAdditions)

//+ (UIColor *)colorWithHexString:(NSString *)hexString {
//    
//    if(isEmptyString(hexString))
//    {
//        SSLog(@"color is empty!");
//        return [UIColor clearColor];
//    }
//    
//    /* convert the string into a int */
//    unsigned int colorValueR,colorValueG,colorValueB,colorValueA;
//    NSString *hexStringCleared = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    hexStringCleared = [hexStringCleared stringByReplacingOccurrencesOfString:@"0x" withString:@""];
//    if(hexStringCleared.length == 3) {
//        /* short color form */
//        /* im lazy, maybe you have a better idea to convert from #fff to #ffffff */
//        hexStringCleared = [NSString stringWithFormat:@"%@%@%@%@%@%@", [hexStringCleared substringWithRange:NSMakeRange(0, 1)],[hexStringCleared substringWithRange:NSMakeRange(0, 1)],
//                            [hexStringCleared substringWithRange:NSMakeRange(1, 1)],[hexStringCleared substringWithRange:NSMakeRange(1, 1)],
//                            [hexStringCleared substringWithRange:NSMakeRange(2, 1)],[hexStringCleared substringWithRange:NSMakeRange(2, 1)]];
//    }
//    if(hexStringCleared.length == 6) {
//        hexStringCleared = [hexStringCleared stringByAppendingString:@"ff"];
//    }
//    
//    /* im in hurry ;) */
//    NSString *red = [hexStringCleared substringWithRange:NSMakeRange(0, 2)];
//    NSString *green = [hexStringCleared substringWithRange:NSMakeRange(2, 2)];
//    NSString *blue = [hexStringCleared substringWithRange:NSMakeRange(4, 2)];
//    NSString *alpha = [hexStringCleared substringWithRange:NSMakeRange(6, 2)];
//    
//    NSAssert(red && green && blue && alpha, @"nil string argument");
//    [[NSScanner scannerWithString:red] scanHexInt:&colorValueR];
//    [[NSScanner scannerWithString:green] scanHexInt:&colorValueG];
//    [[NSScanner scannerWithString:blue] scanHexInt:&colorValueB];
//    [[NSScanner scannerWithString:alpha] scanHexInt:&colorValueA];
//    
//    
//    return [UIColor colorWithRed:((colorValueR)&0xFF)/255.0
//                           green:((colorValueG)&0xFF)/255.0
//                            blue:((colorValueB)&0xFF)/255.0
//                           alpha:((colorValueA)&0xFF)/255.0];
//}


+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if (isEmptyString(hexString)) {
        return [UIColor clearColor];
    }
    if ([hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    //    static NSPredicate *_predicate;
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    //        _predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(([0-9a-fA-F]{3})|([0-9a-fA-F]{6,8}))$"];
    //    });
    //    if (![_predicate evaluateWithObject:hexString]) {
    //        return nil;
    //    }
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
    return [self tt_colorWithRGB:rgb alpha:alpha];
}

+ (UIColor *)tt_colorWithRGB:(uint)rgb {
    return [self tt_colorWithRGB:rgb alpha:255.0];
}

+ (UIColor *)tt_colorWithRGB:(uint)rgb alpha:(uint)alpha {
    return [self colorWithRed:(CGFloat)((rgb & 0xFF0000) >> 16) / 255.0
                        green:(CGFloat)((rgb & 0x00FF00) >> 8) / 255.0f
                         blue:(CGFloat)(rgb & 0x0000FF) / 255.0
                        alpha:alpha / 255.0];
}

+ (UIColor *)tt_colorWithARGBHex:(uint) hex
{
    int red, green, blue, alpha;
    if (hex >0xFFFFFF) {
        // 包含Alpha部分
    }
    
    blue = hex & 0x000000FF;
    green = ((hex & 0x0000FF00) >> 8);
    red = ((hex & 0x00FF0000) >> 16);
    alpha = ((hex & 0xFF000000) >> 24);
    
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha/255.f];
}

@end

#ifndef SS_TODAY_EXTENSTION

@implementation UIColor (TTThemeExtension)

+ (instancetype)tt_themedColorForKey:(NSString *)key
{
    return [[TTThemeManager sharedInstance_tt] themedColorForKey:key];
}

+ (instancetype)tt_defaultColorForKey:(NSString *)key
{
    return [[TTThemeManager sharedInstance_tt] defaultThemeColorForKey:key];
}

@end

@implementation UIColor (SSTheme)

+ (UIColor *)colorWithDayColorName:(NSString *)dayColorName nightColorName:(NSString *)nightColorName
{
    return [self colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:dayColorName nightColorName:nightColorName]];
}

@end

#endif
