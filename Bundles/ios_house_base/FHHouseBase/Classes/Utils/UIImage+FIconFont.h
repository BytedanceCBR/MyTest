//
//  UIImage+FIconFont.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// text使用Unicode格式，需求在前面加  \U0000
#define ICON_FONT_IMG(fontSize,t,c)  [UIImage imageWithIconFontSize:fontSize text:t color:c]

#define FHBackBlackImage ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1])
#define FHBackWhiteImage ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor])

@interface UIImage (FIconFont)

+ (UIImage *)imageWithIconFontSize:(CGFloat)fontSize text:(NSString *)text color:(UIColor * _Nullable)color;

/**
 
 通过IconFont的形式创建图片
 
 * 例如 [UIImage imageWithIconFontName:@"iconfont" fontSize:100 text:@"\U0000e603" color:[UIColor greenColor]]
 
 @param iconFontName iconFont的name
 
 @param fontSize 字体的大小
 
 @param text 文本信息<unicode>
 
 @param color 颜色
 
 @return 创建的图片
 
 */

+ (UIImage *)imageWithIconFontName:(NSString *)iconFontName fontSize:(CGFloat)fontSize text:(NSString *)text color:(UIColor * _Nullable)color;


/// 通过代码画一个圆角进行覆盖
/// @param cornerRadius 圆角大小
/// @param color 颜色，注意是外部圆角的颜色，中间为透明
/// @param size 尺寸大小
+ (UIImage *)fh_interRoundRectMaskImageWithCornerRadius:(CGFloat)cornerRadius color:(UIColor *)color size:(CGSize)size;

/// 通过代码画一个圆角进行覆盖，不知道用哪个的话通常用这个，常用圆角
/// @param cornerRadius 圆角大小
/// @param color 颜色，注意是外部圆角的颜色，中间为透明
/// @param size 尺寸大小
+ (UIImage *)fh_outerRoundRectMaskImageWithCornerRadius:(CGFloat)cornerRadius color:(UIColor *)color size:(CGSize)size;


/// 渐变图片
/// @param colors 颜色 CGColor 类型
/// @param startPoint 起始点
/// @param endPoint 终点
/// @param size 大小
/// @param className 用于缓存区分
+ (UIImage *)fh_gradientImageWithColors:(NSArray *)colors startPoint:(CGPoint )startPoint endPoint:(CGPoint )endPoint size:(CGSize)size usedInClass:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
