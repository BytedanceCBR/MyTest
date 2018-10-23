//
//  TSVWaterfallCollectionViewCellHelper.m
//  Article
//
//  Created by 邱鑫玥 on 2017/9/12.
//

#import "TSVWaterfallCollectionViewCellHelper.h"
#import "TTUserSettingsManager+FontSettings.h"

@implementation TSVWaterfallCollectionViewCellHelper

+ (float)titleFontSize {
    static NSDictionary *fontSizes = nil;
    if (!fontSizes) {
        fontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                      @"iPhone667": @[@16,@18,@20,@23],
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
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

+ (float)titleLineHeight
{
    return [self titleFontSize] * 25 / 19;
}

@end
