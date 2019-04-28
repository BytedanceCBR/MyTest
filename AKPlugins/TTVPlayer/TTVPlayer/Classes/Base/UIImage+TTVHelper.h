//
//  UIImage+TTVHelper.h
//  Article
//
//  Created by 戚宽 on 2018/9/3.
//

#import <UIKit/UIKit.h>

@interface UIImage (TTVHelper)

/**
 *  生成一张纯色图片
 *  @param color 颜色
 *  @param size 生成的图片size
 */
+ (UIImage *)ttv_imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  生成一张新的尺寸图片
 *  @param size 生成的图片size
 */
- (UIImage *)ttv_resizedImageForSize:(CGSize)size;

/**
 *  以新的色值对图片进行着色
 *  @param tintColor 着色的色值
 */
- (UIImage *)ttv_imageWithTintColor:(UIColor *)tintColor;

// 用来在 pod 里使用的
+ (UIImage *)ttv_ImageNamed:(NSString *)name;


@end
