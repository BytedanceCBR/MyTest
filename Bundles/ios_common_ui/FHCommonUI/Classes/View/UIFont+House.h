//
//  UIFont+House.h
//  Article
//
//  Created by 谷春晖 on 2018/11/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (House)

+(UIFont *)themeFontLight:(CGFloat)fontSize;

+(UIFont *)themeFontRegular:(CGFloat)fontSize;

+(UIFont *)themeFontMedium:(CGFloat)fontSize;

+(UIFont *)themeFontSemibold:(CGFloat)fontSize;

+(UIFont *)themeFontDINAlternateBold:(CGFloat)fontSize;

+(UIFont *)iconFontWithSize:(CGFloat)fontSize; //icon font

+(UIFont *)iconFontBWithSize:(CGFloat)fontSize; // B端 icon font

@end

NS_ASSUME_NONNULL_END
