//
//  WDLayoutHelper.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/19.
//

#import <Foundation/Foundation.h>

/*
 * 1.19 布局帮助类，
 */


@interface WDLayoutHelper : NSObject

/*
 *  获取带行高设置的attributedString
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               lineHeight:(CGFloat)lineHeight;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent;

/*
 *  获取带行高，行间距设置的attributedString
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent;

/*
 *  获取带行高，段间距设置的attributedString
 */
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               lineHeight:(CGFloat)lineHeight
                                           paragraphSpace:(CGFloat)paragraphSpace;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                           paragraphSpace:(CGFloat)paragraphSpace;

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                           paragraphSpace:(CGFloat)paragraphSpace
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent;
/*
 * 计算带行高文字高度
 */
+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
       maxNumberOfLines:(NSInteger)numberOfLines;

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
       maxNumberOfLines:(NSInteger)numberOfLines;

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent;

/*
 * 计算带行间距文字高度
 */
+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
       maxNumberOfLines:(NSInteger)numberOfLines;

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
       maxNumberOfLines:(NSInteger)numberOfLines;

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent;

/*
 * 计算带段间距文字高度
 */
+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines;

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines;

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent;

/*
 * 获得attribute字典
 */
+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                                multiple:(CGFloat)multiple;

/*
 * 获得带行高attribute字典
 */
+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight;

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                           lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent;

/*
 * 获得有行间距attribute字典
 */
+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace;

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent;

/*
 * 获得有段间距attribute字典
 */
+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                          paragraphSpace:(CGFloat)paragraphSpace;

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                          paragraphSpace:(CGFloat)paragraphSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                          paragraphSpace:(CGFloat)paragraphSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent;

@end
