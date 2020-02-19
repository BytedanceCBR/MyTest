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
#import <BDTFactoryConfigurator/BDTFactoryConfigurator.h>
#import "TTModuleBridge.h"
#import "NSDictionary+TTAdditions.h"
#import <TTLabelTextHelper.h>

@implementation NSString (UGCUtils)

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.stringify" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSAttributedString *text = (NSAttributedString *)[params valueForKey:@"stringifyText"];
        NSString *result = nil;
        if ([text isKindOfClass:[NSAttributedString class]]) {
            result = [TTUGCEmojiParser stringify:text];
        }
        return result;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.parseInTextKitContext" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSString *text = (NSString *)[params valueForKey:@"text"];
        CGFloat fontSize = (CGFloat) [(NSNumber *)[params valueForKey:@"fontSize"] doubleValue];
        NSAttributedString *result = nil;
        if (!isEmptyString(text)) {
            result = [TTUGCEmojiParser parseInTextKitContext:text fontSize:fontSize];
        }
        return result;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.stringify.ignoreCustomEmojis" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSAttributedString *text = (NSAttributedString *)[params valueForKey:@"stringifyText"];
        BOOL ignoreCustomEmojis = [params tt_boolValueForKey:@"ignoreCustomEmojis"];
        NSString *result = nil;
        if ([text isKindOfClass:[NSAttributedString class]]) {
            result = [TTUGCEmojiParser stringify:text ignoreCustomEmojis:ignoreCustomEmojis];
        }
        return result;
    }];
    
    [[BDTFactoryConfigurator sharedConfigurator] registerFactoryBlock:^NSAttributedString *(NSString *name, NSDictionary *info) {
        if ([name isEqualToString:@"TTUGCEmojiParser/parseInTextKitContext"]) {
            NSString *text = (NSString *)[info valueForKey:@"text"];
            CGFloat fontSize = (CGFloat) [(NSNumber *)[info valueForKey:@"fontSize"] doubleValue];
            NSAttributedString *result = nil;
            if (!isEmptyString(text)) {
                result = [TTUGCEmojiParser parseInTextKitContext:text fontSize:fontSize];
            }
            return result;
        }
        return nil;
    } forKey:@"TTUGC"];
    
    [[BDTFactoryConfigurator sharedConfigurator] registerFactoryBlock:^NSAttributedString *(NSString *name, NSDictionary *info) {
        if ([name isEqualToString:@"TTUGCEmojiParser/parseInCoreTextContext"]) {
            NSString *text = (NSString *)[info valueForKey:@"text"];
            CGFloat fontSize = (CGFloat) [(NSNumber *)[info valueForKey:@"fontSize"] doubleValue];
            NSAttributedString *result = nil;
            if (!isEmptyString(text)) {
                result = [TTUGCEmojiParser parseInCoreTextContext:text fontSize:fontSize];
            }
            return result;
        }
        return nil;
    } forKey:@"TTUGC"];
    
//    TTLabelTextHelper.emojiParseInTextKitBlock = ^NSAttributedString *(NSString *text, CGFloat fontSize) {
//        NSAttributedString *result = nil;
//        if (!isEmptyString(text)) {
//            result = [TTUGCEmojiParser parseInTextKitContext:text fontSize:fontSize];
//        }
//        return result;
//    };
}

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
        if (codeUnit < self.length) {
            result = [self rangeOfComposedCharacterSequenceAtIndex:codeUnit];
            codeUnit += result.length;
        }
    }

    return result;
}

- (NSDictionary *)attributedInfoWithFontSize:(CGFloat)fontSize colorName:(NSString *)colorName {
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInTextKitContext:self fontSize:fontSize];
    NSRange range = NSMakeRange(0, attrStr.length);
    return @{kSSThemedLabelText : attrStr, NSStringFromRange(range) : colorName};
}

+ (NSString *)hexStringWithColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}
@end
