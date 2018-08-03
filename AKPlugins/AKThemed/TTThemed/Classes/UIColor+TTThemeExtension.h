//
//  UIColor+ZDThemeExtension.h
//  Zhidao
//
//  Created by Nick Yu on 15/1/26.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (SSUIColorAdditions)
/**
 * @brief 由一个以＃开头的16进至的色彩字串产生一个UIColor类实例，静态方法
 * @param hexString ＃开头的色彩字符串
 * @return 返回UIColor类，autorelease的
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

#ifndef SS_TODAY_EXTENSTION

@interface UIColor (TTThemeExtensionx)
/**
 *  根据key值返回当前主题的颜色
 *
 *  @param key key
 *
 *  @return 实例
 */
+ (instancetype)tt_themedColorForKey:(NSString *)key;

/**
 *  根据key值返回默认主题的颜色
 *
 *  @param key key
 *
 *  @return 实例
 */
+ (instancetype)tt_defaultColorForKey:(NSString *)key;

@end

@interface UIColor (SSTheme)

/**
 *  根据日夜间模式，返回相应的颜色
 *
 *  @param dayColorName dayColorName
 *  @param nightColorName nightColorName
 *
 *  @return 返回UIColor类，autorelease的
 */
+ (UIColor *)colorWithDayColorName:(NSString *)dayColorName nightColorName:(NSString *)nightColorName;

@end

#endif
