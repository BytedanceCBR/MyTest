//
//  WDUIHelper.m
//  Article
//
//  Created by 延晋 张 on 16/7/19.
//
//

#import "WDUIHelper.h"
#import "WDDefines.h"
#import "TTUserSettingsManager+FontSettings.h"

static CGFloat const kTTiOSiPadUIRatio = 1.3f;
static CGFloat const kTTiOSiPhone5SBelowUIRatio = 0.9f;

@implementation WDUIHelper

+ (CGFloat)wd_fontSize:(CGFloat)normalSize {
    CGFloat size = normalSize;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceilf(size * kTTiOSiPadUIRatio);
        case TTDeviceMode812: return ceilf(size);
        case TTDeviceMode736: return ceilf(size);
        case TTDeviceMode667: return ceilf(size);
        case TTDeviceMode568: return ceilf(size * kTTiOSiPhone5SBelowUIRatio);
        case TTDeviceMode480: return ceilf(size * kTTiOSiPhone5SBelowUIRatio);
    }
    return size;
}

+ (CGFloat)wd_fontSizeWithConstraint:(CGFloat)baseSize {
    CGFloat size = baseSize;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceilf(size * kTTiOSiPadUIRatio);
        case TTDeviceMode812: return ceilf(size);
        case TTDeviceMode736: return ceilf(size);
        case TTDeviceMode667: return ceilf(size);
        case TTDeviceMode568: return ceilf(size);
        case TTDeviceMode480: return ceilf(size);
    }
    return size;
}

+ (CGFloat)wd_padding:(CGFloat)normalPadding {
    CGFloat padding = normalPadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(padding * kTTiOSiPadUIRatio);
        case TTDeviceMode812: return ceil(padding);
        case TTDeviceMode736: return ceil(padding);
        case TTDeviceMode667: return ceil(padding);
        case TTDeviceMode568: return ceil(padding * kTTiOSiPhone5SBelowUIRatio);
        case TTDeviceMode480: return ceil(padding * kTTiOSiPhone5SBelowUIRatio);
    }
    return padding;
}

+ (CGFloat)wd_paddingWithConstraint:(CGFloat)basePadding {
    CGFloat padding = basePadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(padding * kTTiOSiPadUIRatio);
        case TTDeviceMode812: return ceil(padding);
        case TTDeviceMode736: return ceil(padding);
        case TTDeviceMode667: return ceil(padding);
        case TTDeviceMode568: return ceil(padding);
        case TTDeviceMode480: return ceil(padding);
    }
    return padding;
}

+ (CGFloat)wd_labelPadding:(CGFloat)normalPadding withFontSize:(CGFloat)fontSize {
    CGFloat padding = [WDUIHelper wd_padding:normalPadding];
    CGFloat size = [WDUIHelper wd_fontSize:fontSize];
    if (size > 20.0f) {
        return padding - [WDUIHelper wd_padding:2.0f];
    } else {
        return padding - [WDUIHelper wd_padding:1.0f];
    }
}

+ (CGSize)wd_size:(CGSize)normalSize {
    return CGSizeMake([self wd_padding:normalSize.width], [self wd_padding:normalSize.height]);
}

#pragma mark ------

+ (CGFloat)wdUserSettingFontSizeWithFontSize:(CGFloat)fontSize
{
    return [self userSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)wdUserSettingTransferWithLineHeight:(CGFloat)height
{
    return [self userSettingTransferWithLineHeight:height];
}

// 只放大，不缩小
+ (CGFloat)wdUserSettingFontSizeWithConstraintFontSize:(CGFloat)fontSize {
    return [self userSettingFontSizeWithConstraintFontSize:fontSize];
}

+ (CGFloat)wdUserSettingTransferWithConstraintLineHeight:(CGFloat)height {
    return [self userSettingTransferWithConstraintLineHeight:height];
}

+ (CGFloat)userSettingFontSizeWithFontSize:(CGFloat)fontSize
{
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
            case TTFontSizeSettingTypeMin:
            return fontSize - 2;
            case TTFontSizeSettingTypeNormal:
            return fontSize;
            case TTFontSizeSettingTypeBig:
            return fontSize + 2;
            case TTFontSizeSettingTypeLarge:
            return fontSize + 5;
        default:
            return fontSize;
    }
}

+ (CGFloat)userSettingTransferWithLineHeight:(CGFloat)lineHeight
{
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
            case TTFontSizeSettingTypeMin:
            return lineHeight - 3;
            case TTFontSizeSettingTypeNormal:
            return lineHeight;
            case TTFontSizeSettingTypeBig:
            return lineHeight + 3;
            case TTFontSizeSettingTypeLarge:
            return lineHeight + 8;
        default:
            return lineHeight;
    }
}

+ (CGFloat)userSettingFontSizeWithConstraintFontSize:(CGFloat)fontSize
{
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
            case TTFontSizeSettingTypeMin:
        {
            if (fontSize < 14) {
                return fontSize;
            }
            return fontSize - 2;
        }
            case TTFontSizeSettingTypeNormal:
            return fontSize;
            case TTFontSizeSettingTypeBig:
            return fontSize + 2;
            case TTFontSizeSettingTypeLarge:
            return fontSize + 5;
        default:
            return fontSize;
    }
}

+ (CGFloat)userSettingTransferWithConstraintLineHeight:(CGFloat)lineHeight
{
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
            case TTFontSizeSettingTypeMin:
            return lineHeight;
            case TTFontSizeSettingTypeNormal:
            return lineHeight;
            case TTFontSizeSettingTypeBig:
            return lineHeight + 3;
            case TTFontSizeSettingTypeLarge:
            return lineHeight + 8;
        default:
            return lineHeight;
    }
}


@end
