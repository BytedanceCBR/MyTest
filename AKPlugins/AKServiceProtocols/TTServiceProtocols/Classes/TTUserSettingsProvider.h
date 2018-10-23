//
//  TTUserSettingsProvider.h
//  Pods
//
//  Created by fengyadong on 2017/4/26.
//
//

#import <Foundation/Foundation.h>

/**
 *  字体大小
 */
typedef NS_ENUM(NSUInteger, TTUserSettingsFontSize){
    /**
     *  初始状态
     */
    TTFontSizeSettingTypeDefault = -1,
    /**
     *  普通
     */
    TTFontSizeSettingTypeNormal = 0,
    /**
     *  小
     */
    TTFontSizeSettingTypeMin = 1,
    /**
     *  大
     */
    TTFontSizeSettingTypeBig = 2,
    /**
     *  特大
     */
    TTFontSizeSettingTypeLarge = 3,
};

@protocol TTUserSettingsProvider <NSObject>

@required
/**
 返回当前用户设置的字号

 @return 用户设置的字号
 */
- (TTUserSettingsFontSize)settingFontSize;


/**
 用户修改字号

 @param settingFontSize 用户修改的字号大小
 */
- (void)setSettingFontSize:(TTUserSettingsFontSize)settingFontSize;

@end
