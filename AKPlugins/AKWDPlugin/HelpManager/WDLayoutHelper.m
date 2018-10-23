//
//  WDLayoutHelper.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/19.
//

#import "WDLayoutHelper.h"
#import "WDDefines.h"

@implementation WDLayoutHelper

#pragma mark - 获取带行高设置的attributedString

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               lineHeight:(CGFloat)lineHeight {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:NO lineHeight:lineHeight];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:0];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineBreakMode:lineBreakMode firstLineIndent:0];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent {
    return [self attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:0 paragraphSpace:0 lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 获取带行高，行间距设置的attributedString

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:NO lineHeight:lineHeight lineSpace:lineSpace];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:lineSpace lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:0];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent {
    return [self attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:lineSpace paragraphSpace:0 lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 获取带行高，段间距设置的attributedString

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               lineHeight:(CGFloat)lineHeight
                                           paragraphSpace:(CGFloat)paragraphSpace {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:NO lineHeight:lineHeight paragraphSpace:paragraphSpace];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                           paragraphSpace:(CGFloat)paragraphSpace {
    return [WDLayoutHelper attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight paragraphSpace:paragraphSpace lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:0];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                           paragraphSpace:(CGFloat)paragraphSpace
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent {
    return [self attributedStringWithString:string fontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:0 paragraphSpace:paragraphSpace lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 获取attributedString唯一方法

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                               isBoldFont:(BOOL)isBold
                                               lineHeight:(CGFloat)lineHeight
                                                lineSpace:(CGFloat)lineSpace
                                           paragraphSpace:(CGFloat)paragraphSpace
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                          firstLineIndent:(CGFloat)indent {
    if (isEmptyString(string)) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    NSDictionary *attributes = [self attributesWithFontSize:fontSize
                                                 isBoldFont:isBold
                                                 lineHeight:lineHeight
                                                  lineSpace:lineSpace
                                             paragraphSpace:paragraphSpace
                                              lineBreakMode:lineBreakMode
                                            firstLineIndent:indent];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

#pragma mark - 计算文字高度

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
       maxNumberOfLines:(NSInteger)numberOfLines {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:NO lineWidth:lineWidth lineHeight:lineHeight maxNumberOfLines:numberOfLines];
}

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
       maxNumberOfLines:(NSInteger)numberOfLines {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:isBold lineWidth:lineWidth lineHeight:lineHeight maxNumberOfLines:numberOfLines lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:0];
}

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:isBold lineWidth:lineWidth lineHeight:lineHeight lineSpace:0 paragraphSpace:0 maxNumberOfLines:numberOfLines lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 计算带行间距文字高度

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
       maxNumberOfLines:(NSInteger)numberOfLines {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:NO lineWidth:lineWidth lineHeight:lineHeight lineSpace:lineSpace maxNumberOfLines:numberOfLines];
}

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
       maxNumberOfLines:(NSInteger)numberOfLines {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:NO lineWidth:lineWidth lineHeight:lineHeight lineSpace:lineSpace maxNumberOfLines:numberOfLines lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:0];
}

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:isBold lineWidth:lineWidth lineHeight:lineHeight lineSpace:lineSpace paragraphSpace:0 maxNumberOfLines:numberOfLines lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 计算带段间距文字高度

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:NO lineWidth:lineWidth lineHeight:lineHeight paragraphSpace:paragraphSpace maxNumberOfLines:numberOfLines];
}

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:NO lineWidth:lineWidth lineHeight:lineHeight paragraphSpace:paragraphSpace maxNumberOfLines:numberOfLines lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:0];
}

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent {
    return [WDLayoutHelper heightOfText:text fontSize:fontSize isBoldFont:isBold lineWidth:lineWidth lineHeight:lineHeight lineSpace:0 paragraphSpace:paragraphSpace maxNumberOfLines:numberOfLines lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 计算文字高度唯一方法

+ (CGFloat)heightOfText:(NSString *)text
               fontSize:(CGFloat)fontSize
             isBoldFont:(BOOL)isBold
              lineWidth:(CGFloat)lineWidth
             lineHeight:(CGFloat)lineHeight
              lineSpace:(CGFloat)lineSpace
         paragraphSpace:(CGFloat)paragraphSpace
       maxNumberOfLines:(NSInteger)numberOfLines
          lineBreakMode:(NSLineBreakMode)lineBreakMode
        firstLineIndent:(CGFloat)indent {
    if (isEmptyString(text)) {
        return 0;
    }
    NSDictionary *attributes = [self attributesWithFontSize:fontSize
                                                 isBoldFont:isBold
                                                 lineHeight:lineHeight
                                                  lineSpace:lineSpace
                                             paragraphSpace:paragraphSpace
                                              lineBreakMode:lineBreakMode
                                            firstLineIndent:indent];
    // + 1 是原来的逻辑
    CGFloat constraintHeight = numberOfLines ? numberOfLines * (lineHeight + 1) : 9999.f;
    CGSize size = [text boundingRectWithSize:CGSizeMake(lineWidth, constraintHeight)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil].size;
    return ceil(size.height);
}

#pragma mark - 获得attribute字典

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                                multiple:(CGFloat)multiple {
    UIFont *font = isBold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    style.lineHeightMultiple = multiple;
    style.minimumLineHeight = font.lineHeight * multiple;
    style.maximumLineHeight = font.lineHeight * multiple;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    return attributes;
}

#pragma mark - 获得带行高attribute字典

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping];
}

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                           lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineBreakMode:lineBreakMode firstLineIndent:0];
}

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:0 paragraphSpace:0 lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 获得有行间距attribute字典

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:lineSpace lineBreakMode:NSLineBreakByWordWrapping];
}

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:lineSpace lineBreakMode:lineBreakMode firstLineIndent:0];
}

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:lineSpace paragraphSpace:0 lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 获得有段间距attribute字典

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                          paragraphSpace:(CGFloat)paragraphSpace {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight paragraphSpace:paragraphSpace lineBreakMode:NSLineBreakByWordWrapping];
}

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                          paragraphSpace:(CGFloat)paragraphSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight paragraphSpace:paragraphSpace lineBreakMode:lineBreakMode firstLineIndent:0];
}

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                          paragraphSpace:(CGFloat)paragraphSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent {
    return [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:isBold lineHeight:lineHeight lineSpace:0 paragraphSpace:paragraphSpace lineBreakMode:lineBreakMode firstLineIndent:indent];
}

#pragma mark - 获得attribute字典唯一方法

+ (NSDictionary *)attributesWithFontSize:(CGFloat)fontSize
                              isBoldFont:(BOOL)isBold
                              lineHeight:(CGFloat)lineHeight
                               lineSpace:(CGFloat)lineSpace
                          paragraphSpace:(CGFloat)paragraphSpace
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         firstLineIndent:(CGFloat)indent {
    UIFont *font = isBold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    CGFloat lineHeightMultiple = lineHeight / font.lineHeight;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    if (lineSpace) {
        style.lineSpacing = lineSpace;
    }
    if (paragraphSpace) {
        style.paragraphSpacing = paragraphSpace;
    }
    style.lineBreakMode = lineBreakMode;
    style.alignment = NSTextAlignmentLeft;
    style.lineHeightMultiple = lineHeightMultiple;
    style.minimumLineHeight = lineHeight;
    style.maximumLineHeight = lineHeight;
    if (indent > 0) {
        style.firstLineHeadIndent = indent;
    }
    NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    return attributes;
}

@end
