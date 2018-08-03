//
//  TTThemeManager.h
//  Zhidao
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"


//plist文件中存储的主题模式关键字
extern NSString *const TTThemeModeStorageKey;
//主题修改广播通知
extern NSString *const TTThemeManagerThemeModeChangedNotification;

typedef enum {
    TTThemeModeDay,//默认主题
    TTThemeModeNight//夜间主题
} TTThemeMode;

@interface TTThemeManager : NSObject  <Singleton>

@property (nonatomic, assign, readonly) TTThemeMode currentThemeMode;

/**
 *  使用新的bundle配置
 */
+ (void)applyBundleName:(NSString *)bundleName;

/**
 *  根据关键字，返回主题颜色
 *
 *  @param key 关键字
 *
 *  @return UIColor
 */
- (UIColor *)themedColorForKey:(NSString *)key;

/**
 *  根据关键字，返回主题的图片
 *
 *  @param key 关键字
 *
 *  @return UIImage
 */
- (UIImage *)themedImageForKey:(NSString *)key;

/**
 *  根据关键字，返回颜色的数值
 *
 *  @param key 关键字
 *
 *  @return 颜色数值
 */
- (NSString *)rgbaValueForKey:(NSString *)key;

/**
 *  查找默认主题中的颜色数值
 *
 *  @param key 关键字
 *
 *  @return 颜色数值
 */
- (NSString *)rgbaDefalutThemeValueForKey:(NSString *)key;

/**
 *  查找默认主题中的颜色
 *
 *  @param key 关键字
 *
 *  @return 颜色
 */
- (UIColor *)defaultThemeColorForKey:(NSString *)key;

/**
 *  返回当前状态栏样式
 *
 *  @return UIStatusBarStyle
 */
- (UIStatusBarStyle)statusBarStyle;

/**
 *  判断当前模式是否允许修改StatusBarStyle
 *
 *  @return BOOL
 */
- (BOOL)viewControllerBasedStatusBarStyle;

/**
 *  转换主题
 *
 *  @param themeMode 主题类型
 *
 *  @return 返回转换的结果,
 */
- (BOOL)switchThemeModeto:(TTThemeMode)themeMode;

/**
 *  当前主题名称，目前作为关键字用于UIImage+TTThemeExtension选取图片,后面应该将UIImage+TTThemeExtension的功能并入themeImageForkey,删除该函数
 *
 *  @return 白天返回“default”，夜间返回“night”
 */
- (NSString *)currentThemeName;

/**
 *  根据主题，返回不同的颜色值
 *
 *  @param dayName   白天主题颜色
 *  @param nightName 夜间主题颜色
 *
 *  @return NSString
 */
- (NSString *)selectFromDayColorName:(NSString *)dayName nightColorName:(NSString *)nightName;

@end
