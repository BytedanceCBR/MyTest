//
//  TTCommentUIHelper.m
//  Article
//
//  Created by Jiyee Sheng on 19/01/2018.
//
//

#import "TTCommentUIHelper.h"
#import <TTUserSettings/TTUserSettingsManager.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>


@implementation TTCommentUIHelper

+ (UIFont *)tt_fontOfSize:(CGFloat)size {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        if ([UIFont fontWithName:@"PingFangSC-Regular" size:size]) {
            return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
        }
    }
    return [UIFont systemFontOfSize:size];
}

+ (CGFloat)tt_sizeWithFontSetting:(CGFloat)normalSize {
    switch ([TTUserSettingsManager settingFontSize]) {
        case TTFontSizeSettingTypeMin:
            return normalSize - 2.f;
            break;
        case TTFontSizeSettingTypeNormal:
            return normalSize;
            break;
        case TTFontSizeSettingTypeBig:
            return normalSize + 2.f;
            break;
        case TTFontSizeSettingTypeLarge:
            return normalSize + 5.f;
            break;
        default:
            return normalSize;
            break;
    }
}

@end
