//
//  UIImage+IconFont.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/8.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// text使用Unicode格式，需求在前面加  \U0000
#define ICON_FONT_IMG(fontSize,t,c)  [UIImage imageWithIconFontSize:fontSize text:t color:c]

@interface UIImage (IconFont)


+ (UIImage *)imageWithIconFontSize:(CGFloat)fontSize text:(NSString *)text color:(UIColor *)color;

/**
 
 通过IconFont的形式创建图片
 
 * 例如 [UIImage imageWithIconFontName:@"iconfont" fontSize:100 text:@"\U0000e603" color:[UIColor greenColor]]
 
 @param iconFontName iconFont的name
 
 @param fontSize 字体的大小
 
 @param text 文本信息<unicode>
 
 @param color 颜色
 
 @return 创建的图片
 
 */

+ (UIImage *)imageWithIconFontName:(NSString *)iconFontName fontSize:(CGFloat)fontSize text:(NSString *)text color:(UIColor *)color;


@end

NS_ASSUME_NONNULL_END
