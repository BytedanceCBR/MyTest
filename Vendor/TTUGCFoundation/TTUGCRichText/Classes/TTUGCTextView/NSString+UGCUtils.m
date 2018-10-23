//
//  NSString+UGCUtils.m
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//

#import "NSString+UGCUtils.h"
#import "TTUGCEmojiParser.h"
#import "TTBaseMacro.h"
#import "SSThemed.h"

@implementation NSString (UGCUtils)

- (NSString *)ellipsisStringWithFont:(UIFont *)font constraintsWidth:(CGFloat)constraintsWidth {
    if (isEmptyString(self)) {
        return self;
    }

    NSString *ellipsis = @"...";

    NSDictionary *attributes = font ? @{
        NSFontAttributeName: font
    } : nil;

    NSMutableString *truncatedString = [self mutableCopy];

    NSRange range = NSMakeRange(self.length, 1);

    // 执行截断操作
    if ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth) {
        // 扣除 ellipsis 宽度，这部分之后会加回来
        constraintsWidth -= [ellipsis sizeWithAttributes:attributes].width;

        // 单字符方式从后往前删除
        range.length = 1;

        while ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth && range.location > 0) {
            range.location -= 1;
            [truncatedString deleteCharactersInRange:range];
        }

        // 添加 ellipsis
        range.length = 0;
        [truncatedString replaceCharactersInRange:range withString:ellipsis];
    }

    return [truncatedString copy];
}

- (NSRange)rangeOfComposedCharacterSequenceAtCodePoint:(NSUInteger)codePoint {
    NSUInteger codeUnit = 0;
    NSRange result = NSMakeRange(0, 0);
    for (NSUInteger index = 0; index <= codePoint; index++) {
        result = [self rangeOfComposedCharacterSequenceAtIndex:codeUnit];
        codeUnit += result.length;
    }

    return result;
}

- (NSDictionary *)attributedInfoWithFontSize:(CGFloat)fontSize colorName:(NSString *)colorName {
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInTextKitContext:self fontSize:fontSize];
    NSRange range = NSMakeRange(0, attrStr.length);
    return @{kSSThemedLabelText : attrStr, NSStringFromRange(range) : colorName};
}
@end
