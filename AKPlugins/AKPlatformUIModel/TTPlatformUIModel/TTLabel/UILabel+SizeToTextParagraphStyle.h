//
//  UILabel+SizeToTextParagraphStyle.h
//  Article
//
//  Created by liuzuopeng on 22/07/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface NSString (UILabelAttrsParagraphStyle)

- (CGSize)tt_sizeForLabel:(UILabel *)label
             withMaxWidth:(NSInteger)maxWidth /** 文本最大的宽度 */;

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度
 *
 *  @param label        将要计算的label
 *  @param maxWidth     限制最大的文本宽度
 *  @param lineSpacing  文本行之间的间距
 *
 *  @return 文本的大小
 */
- (CGSize)tt_sizeForLabel:(UILabel *)label
             withMaxWidth:(NSInteger)maxWidth /** 文本最大的宽度 */
              lineSpacing:(NSInteger)lineSpacing /** 行间距 */;

@end



@interface UILabel (SizeToTextParagraphStyle)

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度
 *
 *  @param label        将要计算的label
 *  @param maxWidth     限制最大的文本宽度
 *  @param lineSpacing  文本行之间的间距
 *
 *  @return 文本的大小
 */
+ (CGSize)tt_sizeForLabel:(UILabel *)label
             withMaxWidth:(NSInteger)maxWidth /** 文本最大的宽度 */
              lineSpacing:(NSInteger)lineSpacing /** 行间距 */;

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度
 *
 *  @param maxWidth 限制最大的文本宽度
 *
 *  @return 文本的大小
 */
- (CGSize)tt_sizeWithMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */;

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度，默认kernSpacing为0，用系统自带的Font间距
 *
 *  @param maxWidth     限制最大的文本宽度
 *  @param lineSpacing  文本行之间的间距
 *
 *  @return 文本的大小
 */
- (CGSize)tt_sizeWithMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */
                  lineSpacing:(NSInteger)lineSpacing /** 行间距 */;

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度
 *
 *  @param maxWidth     限制最大的文本宽度
 *  @param lineSpacing  文本行之间的间距
 *
 *  @return 文本的大小
 */
- (CGSize)tt_sizeWithMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */
                  lineSpacing:(NSInteger)lineSpacing /** 行间距 */
                  kernSpacing:(NSInteger)kernSpacing /** 单词间的间距 */;


/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度并显示
 *
 *  @param maxWidth 限制最大的文本宽度
 */
- (void)tt_sizeToFitMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */;

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度并显示，默认kernSpacing为0，用系统自带的Font间距
 *
 *  @param maxWidth     限制最大的文本宽度
 *  @param lineSpacing  文本行之间的间距
 */
- (void)tt_sizeToFitMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */
                 lineSpacing:(NSInteger)lineSpacing /** 行间距 */;

/**
 *  使用label的numberOfLines、lineBreakMode、font属性计算label文字的高度并显示
 *
 *  @param maxWidth     限制最大的文本宽度
 *  @param lineSpacing  文本行之间的间距
 *  @param kernSpacing  单词间的间距
 */
- (void)tt_sizeToFitMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */
                 lineSpacing:(NSInteger)lineSpacing /** 行间距 */
                 kernSpacing:(NSInteger)kernSpacing /** 单词间的间距 */;
@end
