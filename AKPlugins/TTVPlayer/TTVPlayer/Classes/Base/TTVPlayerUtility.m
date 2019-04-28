//
//  TTVPlayerUtility.m
//  Article
//
//  Created by panxiang on 2018/12/11.
//

#import "TTVPlayerUtility.h"
#import "TTVPlayerMacro.h"

static TTVDeviceMode tt_deviceMode;


@implementation TTVPlayerUtility

+ (BOOL)judgePadDevice {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)judge896Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 896.0;
}

+ (BOOL)judge812Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 812;
}

+ (BOOL)judge736Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 736;
}

+ (BOOL)judge667Screen {
    //added 5.4:iPhone图集支持横屏，修改判断方式
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 667;
}

+ (BOOL)judge568Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 568;
}

+ (BOOL)judge480Screen {
    CGFloat longSide = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return longSide == 480;
}

+ (TTVDeviceMode)getDeviceType {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([self judgePadDevice]) {
            tt_deviceMode = TTVDeviceModePad;
        }
        else if ([self judge896Screen]) {
            tt_deviceMode = TTVDeviceMode896;
        }
        else if ([self judge812Screen]) {
            tt_deviceMode = TTVDeviceMode812;
        }
        else if ([self judge736Screen]) {
            tt_deviceMode = TTVDeviceMode736;
        }
        else if ([self judge667Screen]) {
            tt_deviceMode = TTVDeviceMode667;
        }
        else if ([self judge568Screen]) {
            tt_deviceMode = TTVDeviceMode568;
        }
        else if ([self judge480Screen]){
            tt_deviceMode = TTVDeviceMode480;
        }
        else{
            tt_deviceMode = TTVDeviceMode667;
        }
    });
    return tt_deviceMode;
}

+ (CGFloat)tt_fontSize:(CGFloat)normalSize {
    CGFloat size = normalSize;
    switch ([self getDeviceType]) {
        case TTVDeviceModePad: return ceil(size * 1.3);
        case TTVDeviceMode736:
        case TTVDeviceMode896: return ceil(size);
        case TTVDeviceMode667:
        case TTVDeviceMode812: return ceil(size);
        case TTVDeviceMode568: return ceil(size * 0.9);
        case TTVDeviceMode480: return ceil(size * 0.9);
    }
    return normalSize;
}

+ (UIFont *)tt_semiboldFontOfSize:(CGFloat)size
{
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        if ([UIFont fontWithName:@"PingFangSC-Semibold" size:size]) {
            return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
        }
    }
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        return [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];
    }
    return [UIFont systemFontOfSize:size];
}

+ (CGFloat)tt_padding:(CGFloat)normalPadding{
    CGFloat size = normalPadding;
    switch ([self getDeviceType]) {
        case TTVDeviceModePad: return ceil(size * 1.3);
        case TTVDeviceMode736:
        case TTVDeviceMode896: return ceil(size);
        case TTVDeviceMode667:
        case TTVDeviceMode812: return ceil(size);
        case TTVDeviceMode568: return ceil(size * 0.9);
        case TTVDeviceMode480: return ceil(size * 0.9);
    }
}



+ (UIFont *)fullScreenPlayerTitleFont:(NSInteger)fontSetting
{
    return [UIFont boldSystemFontOfSize:[self settedTitleFontSize:fontSetting]];
}

static NSDictionary *fontSizes = nil;

+ (float)settedTitleFontSize:(NSInteger)fontSetting {
    if (!fontSizes) {
        fontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                      @"iPhone667": @[@15, @17, @20, @23],
                      @"iPhone736" : @[@16, @18, @20, @23],
                      @"iPhone" : @[@14, @16, @18, @21]};
    }
    
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    NSInteger selectedIndex = fontSetting;
    switch (selectedIndex) {
        case 1:
            index = 0;
            break;
        case 0:
            index = 1;
            break;
        case 2:
            index = 2;
            break;
        case 3:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

+ (NSAttributedString *)attributedVideoTitleFromString:(NSString *)text {
    if (isEmptyString(text)) return nil;
    
    UIFont *textFont = [self ttv_distinctTitleFont];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2.0f;
    shadow.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.54f];
    shadow.shadowOffset = CGSizeZero;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping; // 解决折行问题
    paragraph.lineHeightMultiple = 1.4 * textFont.pointSize / textFont.lineHeight; // 行间距为字体的1.4倍
    
    NSDictionary *attributes = @{NSFontAttributeName           : textFont,
                                 NSShadowAttributeName         : shadow,
                                 NSParagraphStyleAttributeName : paragraph,
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (UIFont *)ttv_distinctTitleFont {
    CGFloat fontSize = 17.0f;
    if ([TTDeviceHelper is667Screen]) {
        fontSize = 18.0f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice] || [TTDeviceHelper isIPhoneXSeries]) {
        fontSize = 20.0f;
    }
    return TTVPlayerFont(@"PingFangSC-Semibold", fontSize);
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
    } else if([[str lowercaseString] hasPrefix:@"0x"])  {
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

+ (NSString *)transformProgressToTimeString:(CGFloat)progress duration:(NSTimeInterval)duration {
    NSTimeInterval currentTimeDuration = duration * progress;
    
    int hour = (int)currentTimeDuration / (60 * 60);
    if (hour > 0) {
        int minute = ((int)currentTimeDuration % 3600) / 60;
        int second = (int)currentTimeDuration % 60;
        
        return [NSString stringWithFormat:@"%i:%02i:%02i", hour, minute, second];
    } else {
        int minute = (int)currentTimeDuration / 60;
        int second = (int)currentTimeDuration % 60;
        
        return [NSString stringWithFormat:@"%02i:%02i", minute, second];
    }
    return nil;
}

+ (void)quitCurrentViewController {
    UIViewController * topVC = [TTUIResponderHelper visibleTopViewController];//[TTUIResponderHelper topViewControllerFor:self];
    if ([topVC presentingViewController]) {
        [topVC dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)topVC) popViewControllerAnimated:YES];
    } else {
        if (topVC.navigationController) {
            [topVC.navigationController popViewControllerAnimated:YES];
        } else {
            [topVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
