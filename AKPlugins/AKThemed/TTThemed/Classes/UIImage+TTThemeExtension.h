//
//  UIImage+ZDThemeExtension.h
//  Zhidao
//
//  Created by Nick Yu on 15/1/26.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#define noSSThemeModeNameKey @"noSSThemeModeNameKey"
 
@interface UIImage (TTThemeExtension)

/**
 *  根据key值返回当前主题的UIImage
 *
 *  @param key key
 *
 *  @return 实例
 */
+ (instancetype)tt_themedImageForKey:(NSString *)key; // example: [UIImage zd_themedImageForKey:@"mainNavBarBg"];

/**
 *  根据imageName返回相应主题的UIImage
 *
 *  @param imageName imageName
 *
 *  @return 实例
 */
+ (UIImage *)themedImageNamed:(NSString *)imageName;


@end
