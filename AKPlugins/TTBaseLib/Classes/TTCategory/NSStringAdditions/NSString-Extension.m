//
//  NSString-Extension.m
//  Article
//
//  Created by 杨心雨 on 16/9/20.
//
//

#import "NSString-Extension.h"
#import "NSDictionary+TTAdditions.h"

#pragma mark - Theme 模式相关
@implementation NSString (Theme)

- (NSString *)tt_suffixHighlighted {
    return [self stringByAppendingString:@"Highlighted"];
}

- (NSString *)tt_suffixSelected {
    return [self stringByAppendingString:@"Selected"];
}

- (NSString *)tt_suffixDisabled {
    return [self stringByAppendingString:@"Disabled"];
}

@end

@implementation NSString (Attributed)

- (NSAttributedString *)tt_attributedStringWithFont:(UIFont *)font lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode firstLineIndent:(CGFloat)firstLineIndent alignment:(NSTextAlignment)alignment {
    if ([self length] <= 0) {
        return [[NSAttributedString alloc] init];
    }
    NSDictionary *attributes = [NSString tt_attributesWithFont:font lineHeight:lineHeight lineBreakMode:lineBreakMode firstLineIndent:firstLineIndent alignment:alignment];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedString setAttributes:attributes range:NSMakeRange(0, [self length])];
    
    return attributedString;
}

- (NSAttributedString *)tt_attributedStringWithFont:(UIFont *)font lineHeight:(CGFloat)lineHeight {
    return [self tt_attributedStringWithFont:font lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail firstLineIndent:0 alignment:NSTextAlignmentLeft];
}

+ (NSDictionary *)tt_attributesWithFont:(UIFont *)font lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode firstLineIndent:(CGFloat)firstLineIndent alignment:(NSTextAlignment)alignment {
    CGFloat lineHeightMultiple = lineHeight / font.lineHeight;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.alignment = alignment;
    style.lineHeightMultiple = lineHeightMultiple;
    style.minimumLineHeight = lineHeight;
    style.maximumLineHeight = lineHeight;
    style.firstLineHeadIndent = firstLineIndent;
    
    return @{NSFontAttributeName: font, NSParagraphStyleAttributeName: style};
}

@end

@implementation NSString (TT_Size)

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width font:(UIFont *)font lineHeight:(CGFloat)lineHeight numberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)firstLineIndent alignment:(NSTextAlignment)alignment {
    CGSize size = CGSizeZero;
    if ([self length] <= 0) {
        return size;
    }
    
    CGFloat constraintHeight = (numberOfLines != 0 ? numberOfLines * (lineHeight + 1) : MAXFLOAT);
    NSDictionary *attributes = [NSString tt_attributesWithFont:font lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:firstLineIndent alignment:alignment];
    
    size = [self boundingRectWithSize:CGSizeMake(width, constraintHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    size.height = ceil(size.height - (lineHeight - ceil(font.pointSize)));
    size.width = ceil(size.width);
    return size;
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width font:(UIFont *)font lineHeight:(CGFloat)lineHeight numberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)firstLineIndent {
    return [self tt_sizeWithMaxWidth:width font:font lineHeight:lineHeight numberOfLines:numberOfLines firstLineIndent:firstLineIndent alignment:NSTextAlignmentLeft];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width font:(UIFont *)font lineHeight:(CGFloat)lineHeight numberOfLines:(NSInteger)numberOfLines {
    return [self tt_sizeWithMaxWidth:width font:font lineHeight:lineHeight numberOfLines:numberOfLines firstLineIndent:0 alignment:NSTextAlignmentLeft];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width font:(UIFont *)font lineHeight:(CGFloat)lineHeight {
    return [self tt_sizeWithMaxWidth:width font:font lineHeight:lineHeight numberOfLines:1 firstLineIndent:0 alignment:NSTextAlignmentLeft];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines {
    return [self tt_sizeWithMaxWidth:width font:font lineHeight:ceil(font.lineHeight) numberOfLines:numberOfLines firstLineIndent:0 alignment:NSTextAlignmentLeft];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)width font:(UIFont *)font {
    return [self tt_sizeWithMaxWidth:width font:font lineHeight:ceil(font.lineHeight) numberOfLines:1 firstLineIndent:0 alignment:NSTextAlignmentLeft];
}

- (NSInteger)tt_lineNumberWithMaxWidth:(CGFloat)width font:(UIFont *)font lineHeight:(CGFloat)lineHeight numberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)firstLineIndent alignment:(NSTextAlignment)alignment {
    NSInteger lines = 0;
    if ([self length] <= 0) {
        return lines;
    }
    
    CGFloat constraintHeight = (numberOfLines != 0 ? numberOfLines * lineHeight : MAXFLOAT);
    NSDictionary *attributes = [NSString tt_attributesWithFont:font lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping firstLineIndent:firstLineIndent alignment:alignment];
    
    CGFloat height = [self boundingRectWithSize:CGSizeMake(width, constraintHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
    lines = (NSInteger)(height / lineHeight);
    
    return lines;
}

@end

@implementation NSString (ADKeyChange)

- (NSString *)tt_changeUrlWithKey:(NSString *)key value:(NSString *)value {
    NSRange keyRange = [self rangeOfString:[NSString stringWithFormat:@"=%@", key]];
    if (keyRange.location == NSNotFound) {
        return self;
    }
    NSUInteger loc = keyRange.location + 1;
    NSUInteger length = keyRange.length - 1;
    return [self stringByReplacingCharactersInRange:NSMakeRange(loc, length) withString:value];
}

- (NSString *)tt_adChangeUrlWithLogExtra:(NSString *)logExtra {
    NSString *result = self;
    NSError *error;
    NSData *extraData = [logExtra dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:extraData options:NSJSONReadingMutableContainers error:&error];
    if ([[dic allKeys] containsObject:@"macro"]) {
        NSDictionary *macroDic = [dic tt_dictionaryValueForKey:@"macro"];
        for (NSString *key in [macroDic allKeys]) {
            NSString *value = [macroDic tt_stringValueForKey:key];
            value = [value stringByReplacingOccurrencesOfString:@"__RANDOM__" withString:[NSString stringWithFormat:@"%08u", arc4random() % 100000000]];
            result = [result tt_changeUrlWithKey:key value:value];
        }
    }
    return result;
}

@end
