//
//  TTOriginalLogo.h
//  Article
//
//  Created by Yang Xinyu on 12/9/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSThemed.h"

/**
 *  添加一个特定的标签
 */
@interface TTOriginalLogo : NSObject

/**
 *  在固定大小的Label上添加标签 需刷新UI
 *
 *  @param label        需要添加标签的Label
 *  @param text         标签的文字
 *  @param logoSize     标签的大小
 *  @param space        标签与Label上文字的间距
 *  @param textFontSize 标签文字Font
 *  @param textColor    标签文字颜色 kColorText
 *  @param lineColor    描边颜色 kColorLine
 *  @param cornerRadius 标签圆角半径
 *  @param lineNumber   Label最大的文字行数（只处理1、2）
 */
+ (void)addOriginalLogoOnLabel:(UILabel *)label
                      withText:(NSString *)text
                     frameSize:(CGSize)logoSize
                         space:(CGFloat)space
                  textFontSize:(CGFloat)textFontSize
                  textColorKey:(NSString *)textColor
                  lineColorKey:(NSString *)lineColor
                  cornerRadius:(CGFloat)cornerRadius
                    lineNumber:(int)lineNumber
                    lineHeight:(CGFloat)lineHeight;

/**
 *  在可变大小的Label上添加标签 需刷新UI
 *
 *  @param label        需要添加标签的Label
 *  @param maxSize      Label可以达到的最大frame
 *  @param text         标签的文字
 *  @param logoSize     标签的大小
 *  @param spacing      标签与Label上文字的间距
 *  @param textFontSize 标签文字Font
 *  @param textColor    标签文字颜色 kColorText
 *  @param lineColor    描边颜色 kColorLine
 *  @param cornerRadius 标签圆角半径
 *  @param lineNumber   Label最大的文字行数（只处理1、2）
 */
+ (void)addOriginalLogoOnLabel:(UILabel *)label
                 withLabelSize:(CGSize)maxSize
                          text:(NSString *)text
                     frameSize:(CGSize)logoSize
                         space:(CGFloat)spacing
                  textFontSize:(CGFloat)textFontSize
                  textColorKey:(NSString *)textColor
                  lineColorKey:(NSString *)lineColor
                  cornerRadius:(CGFloat)cornerRadius
                    lineNumber:(int)lineNumber
                    lineHeight:(CGFloat)lineHeight;


+ (SSThemedLabel *)originalLabelWithRect:(CGRect)rect
                                    text:(NSString *)text
                            textFontSize:(CGFloat)textFontSize
                            textColorKey:(NSString *)textColor
                            lineColorKey:(NSString *)lineColor
                            cornerRadius:(CGFloat)cornerRadius;
/**
 *  清除所有subView，用于cell复用
 */
+ (void)removeAllOriginalLogoSubLabelsForLabel:(UILabel *)label;

@end
