//
//  HTSVideoPlayColor.m
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import "HTSVideoPlayColor.h"

static NSString *const ColorS1  = @"1e1e1e";
static NSString *const ColorS2  = @"cccccc";
static NSString *const ColorS3  = @"4e66f3";
static NSString *const ColorS4  = @"f85959";
static NSString *const ColorS5  = @"ffffff";
static NSString *const ColorS6  = @"a8ea09";
static NSString *const ColorS7  = @"999999";
static NSString *const ColorS8  = @"f85858";
static NSString *const ColorS9  = @"eaeaea";
static NSString *const ColorS10 = @"689EE1";
static NSString *const ColorS11 = @"666666";
static NSString *const ColorS17 = @"d5d5d5";
static NSString *const ColorS19 = @"ff00de";
static NSString *const ColorS20 = @"f6f6f6";
static NSString *const ColorS21 = @"812ed7";
static NSString *const ColorS22 = @"f0641f";
static NSString *const ColorS23 = @"f1302f";
static NSString *const ColorS24 = @"ff2d55";

@implementation HTSVideoPlayColor

+ (void)load
{
    [HTSVideoPlayColor sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!self.colors || self.colors.count == 0) {
            NSMutableDictionary *colorDictionary = [NSMutableDictionary dictionary];
            colorDictionary[@"S1"] = ColorS1;
            colorDictionary[@"S2"] = ColorS2;
            colorDictionary[@"S3"] = ColorS3;
            colorDictionary[@"S4"] = ColorS4;
            colorDictionary[@"S5"] = ColorS5;
            colorDictionary[@"S6"] = ColorS6;
            colorDictionary[@"S7"] = ColorS7;
            colorDictionary[@"S8"] = ColorS8;
            colorDictionary[@"S9"] = ColorS9;
            colorDictionary[@"S10"] = ColorS10;
            colorDictionary[@"S11"] = ColorS11;
            colorDictionary[@"S17"] = ColorS17;
            colorDictionary[@"S19"] = ColorS19;
            colorDictionary[@"S20"] = ColorS20;
            colorDictionary[@"S21"] = ColorS21;
            colorDictionary[@"S22"] = ColorS22;
            colorDictionary[@"S23"] = ColorS23;
            colorDictionary[@"S24"] = ColorS24;
            self.colors = [colorDictionary copy];
        }
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HTSVideoPlayColor *colorService = nil;
    
    dispatch_once(&onceToken, ^{
        colorService = [[HTSVideoPlayColor alloc] init];
    });
    
    return colorService;
}

+ (UIColor *)colorWithHexString:(NSString *)hexStr
{
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

static inline NSUInteger hexStrToInt(NSString *str)
{
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str, CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a)
{
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

@end
