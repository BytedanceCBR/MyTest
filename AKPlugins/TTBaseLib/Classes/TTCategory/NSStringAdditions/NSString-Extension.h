//
//  NSString-Extension.h
//  Article
//
//  Created by 杨心雨 on 16/9/20.
//
//

#import <UIKit/UIKit.h>

#pragma mark - Theme 模式相关
/** 模式相关 */
@interface NSString (Theme)

/** 添加高亮后缀 */
- (nonnull NSString *)tt_suffixHighlighted;

/** 添加高亮后缀 */
- (nonnull NSString *)tt_suffixSelected;

/** 添加高亮后缀 */
- (nonnull NSString *)tt_suffixDisabled;

@end

#pragma mark - Attributed 属性文字
/** 属性文字 */
@interface NSString (Attributed)

/**
 获取属性文字

 @param font            字体
 @param lineHeight      行高
 @param lineBreakMode   折行方式
 @param firstLineIndent 首行缩进
 @param alignment       布局方式

 @return 属性文字
 */
- (nonnull NSAttributedString *)tt_attributedStringWithFont:(UIFont * _Nonnull)font
                                                 lineHeight:(CGFloat)lineHeight
                                              lineBreakMode:(NSLineBreakMode)lineBreakMode
                                            firstLineIndent:(CGFloat)firstLineIndent
                                                  alignment:(NSTextAlignment)alignment;

- (nonnull NSAttributedString *)tt_attributedStringWithFont:(UIFont * _Nonnull)font
                                                 lineHeight:(CGFloat)lineHeight;

/**
 属性字典

 @param font            字体
 @param lineHeight      行高
 @param lineBreakMode   折行方式
 @param firstLineIndent 首行缩进
 @param alignment       布局方式

 @return 属性字典
 */
+ (nonnull NSDictionary *)tt_attributesWithFont:(UIFont * _Nonnull)font
                                     lineHeight:(CGFloat)lineHeight
                                  lineBreakMode:(NSLineBreakMode)lineBreakMode
                                firstLineIndent:(CGFloat)firstLineIndent
                                      alignment:(NSTextAlignment)alignment;

@end

#pragma mark - Size 文字框
/** 文字框 */
@interface NSString (TT_Size)

/**
 文字框大小(限制在文字高度)
 
 @param width           最大宽度
 @param font            字体
 @param lineHeight      行高
 @param numberOfLines   限制行数(0为不限制)
 @param firstLineIndent 首行缩进
 @param alignment       布局方式
 
 @return 文字框大小
 */
- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width
                         font:(UIFont * _Nonnull)font
                   lineHeight:(CGFloat)lineHeight
                numberOfLines:(NSInteger)numberOfLines
              firstLineIndent:(CGFloat)firstLineIndent
                    alignment:(NSTextAlignment)alignment;

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width
                         font:(UIFont * _Nonnull)font
                   lineHeight:(CGFloat)lineHeight
                numberOfLines:(NSInteger)numberOfLines
              firstLineIndent:(CGFloat)firstLineIndent;

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width
                         font:(UIFont * _Nonnull)font
                   lineHeight:(CGFloat)lineHeight
                numberOfLines:(NSInteger)numberOfLines;

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width
                         font:(UIFont * _Nonnull)font
                   lineHeight:(CGFloat)lineHeight;

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width
                         font:(UIFont * _Nonnull)font
                numberOfLines:(NSInteger)numberOfLines;

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width
                         font:(UIFont * _Nonnull)font;

/**
 文本行数
 
 @param width           最大宽度
 @param font            字体
 @param lineHeight      行高
 @param numberOfLines   限制行数(0为不限制)
 @param firstLineIndent 首行缩进
 @param alignment       布局方式
 
 @return 文本行数
 */
- (NSInteger)tt_lineNumberWithMaxWidth:(CGFloat)width
                                  font:(UIFont * _Nonnull)font
                            lineHeight:(CGFloat)lineHeight
                         numberOfLines:(NSInteger)numberOfLines
                       firstLineIndent:(CGFloat)firstLineIndent
                             alignment:(NSTextAlignment)alignment;

@end

@interface NSString (ADKeyChange)

- (nonnull NSString *)tt_changeUrlWithKey:(NSString * _Nonnull)key value:(NSString * _Nonnull)value;
- (nonnull NSString *)tt_adChangeUrlWithLogExtra:(NSString * _Nonnull)logExtra;

@end
