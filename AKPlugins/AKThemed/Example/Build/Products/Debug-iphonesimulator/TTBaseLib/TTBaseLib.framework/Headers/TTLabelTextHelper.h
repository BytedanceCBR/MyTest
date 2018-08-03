//
//  TTLabelTextHelper.h
//  TTLive
//
//  Created by 冯靖君 on 16/1/13.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTLabelTextHelper : NSObject

#pragma mark - 计算高度
/**
 *  计算attributedText的高度
 *
 *  @param text          文字
 *  @param fontSize      字体大小
 *  @param width         限宽
 *  @param lineHeight    行高
 *  @param numberOfLines 限制行数，0为不限行数
 *  @param indent        首行缩进
 *
 *  @return 计算出来的高度
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width;

/**
 *  @param numberOfLines 最大行数 行高为font.lineHeight
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width constraintToMaxNumberOfLines:(NSInteger)numberOfLines;

/**
 *  @param lineHeight 行高
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight;

/**
 *  @param numberOfLines 最大行数
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines;

/**
 *  @param indent 首行缩进值
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent;

/**
 *  @param alignment 对齐方式
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment;

/**
 *  获取size
 */
+ (CGSize)sizeOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment;

#pragma mark - 生成attributedString
/**
 *  根据传入参数, 通过设置NSParagraphStyle生成对应的attributedString
 *
 *  @param string     文字
 *  @param fontSize   字体大小
 *
 *  @default 行高默认是font.lineHeight
 *           断行方式默认为NSLineBreakByWordWrapping
 *           字体不加粗
 *           首行无缩进
 *  @return 返回attributedString
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize;

/**
 *  @param lineHeight 行高
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight;

/**
 *  @param lineBreakMode 断行方式
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  @param isBoldFontStyle 是否加粗
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold;

/**
 *  @param indent 首行缩进值
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold firstLineIndent:(CGFloat)indent;

/**
 *  @param alignment 对齐方式
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment;


@end
