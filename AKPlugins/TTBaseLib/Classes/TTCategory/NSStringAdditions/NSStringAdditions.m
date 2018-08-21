//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "NSStringAdditions.h"
#import <CoreText/CTFramesetter.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(SSNSStringAdditions)

- (NSString *)stringCachePath {
    NSString* documentsPath = nil;
    
	if (!documentsPath) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		documentsPath = [dirs objectAtIndex:0];
	}
	
	return [documentsPath stringByAppendingPathComponent:self];
}

- (NSString *)stringDocumentsPath {
	static NSString* documentsPath = nil;

	if (!documentsPath) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [dirs objectAtIndex:0];
	}
	
	return [documentsPath stringByAppendingPathComponent:self];
}

- (NSString *)MD5HashString
{
    const char *str = [self UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}


- (NSString*)trimmed
{
    NSInteger i = 0;
    while (i < self.length && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    
	NSString *result = [self substringFromIndex:i];
	i = result.length - 1;
	while (i >=0 && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[result characterAtIndex:i]]) {
        i--;
    }
	
	result = [result substringToIndex:i+1];
	return result;
}


- (NSString*)SHA256String
{
    NSData *dataIn = [self dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (int)dataIn.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString*)SHA1String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

/**
 *    @brief    字符串转换成16进制
 *
 */
+ (NSString *)hexStringFromString:(NSString *)string

{
    NSUInteger len = [string length];
    unichar *chars = malloc(len * sizeof(unichar));
    [string getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);
    
    return hexString;
}

- (CGSize)sizeWithFontCompatible:(UIFont *)font
{
    if([self respondsToSelector:@selector(sizeWithAttributes:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font};
        CGSize stringSize = [self sizeWithAttributes:dictionaryAttributes];
        return CGSizeMake(ceil(stringSize.width), ceil(stringSize.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [self sizeWithFont:font];
#pragma clang diagnostic pop
    }
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constrainedSize paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    if (self.length == 0) {
        return CGSizeZero;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    if (paragraphStyle) {
        [style setParagraphStyle:paragraphStyle];
    }
    else {
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentLeft;
        style.baseWritingDirection = NSWritingDirectionLeftToRight;
        style.lineHeightMultiple = 1.0;
        if (font) {
            style.maximumLineHeight = font.lineHeight;
            style.minimumLineHeight = font.lineHeight;
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:font forKey:NSFontAttributeName];
    [dict setValue:style forKey:NSParagraphStyleAttributeName];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self attributes:dict];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CFRange fitRange = CFRangeMake(0, 0);
    CGSize size =
    CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), NULL, constrainedSize, &fitRange);
    CFRelease(framesetter);
    return CGSizeMake(size.width + 2, size.height);
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)regex {
    return [self componentsSeparatedByRegex:regex regexRanges:nil];
}


- (NSArray *)componentsSeparatedByRegex:(NSString *)regex regexRanges:(NSArray **)ranges {
    return [self componentsSeparatedByRegex:regex ranges:nil checkingResults:ranges];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)regex ranges:(NSArray **)_ranges checkingResults:(NSArray **)__ranges {
    NSError *error;
    NSRegularExpression *regularExpression =
    [NSRegularExpression regularExpressionWithPattern:regex
                                              options:NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionDotMatchesLineSeparators
                                                error:&error];
    if (error) {
        return nil;
    }
    NSMutableArray *substrings = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *subranges = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *checkingResults = [NSMutableArray arrayWithCapacity:2];
    [regularExpression enumerateMatchesInString:self
                                        options:NSMatchingReportCompletion
                                          range:NSMakeRange(0, self.length)
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                         NSRange range = [result rangeAtIndex:0];
                                         if (range.length > 0) {
                                             [ranges addObject:NSStringFromRange([result rangeAtIndex:0])];
                                             [checkingResults addObject:result];
                                         }
                                     }];
    /// 根据正则表达的区间
    __block NSUInteger location = 0;
    [ranges enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSRange range = NSRangeFromString(obj);
        if (range.location != NSNotFound) {
            NSRange subrange = NSMakeRange(location, range.location - location);
            location = range.location + range.length;
            if (subrange.length > 0) {
                NSString *substring = [self substringWithRange:subrange];
                [subranges addObject:NSStringFromRange(subrange)];
                [substrings addObject:substring];
            }
        }
    }];
    if (location < self.length) {
        NSRange subrange = NSMakeRange(location, self.length - location);
        NSString *substring = [self substringWithRange:subrange];
        [subranges addObject:NSStringFromRange(subrange)];
        [substrings addObject:substring];
    }
    if (_ranges) {
        *_ranges = [subranges copy];
    }
    if (__ranges) {
        *__ranges = [checkingResults copy];
    }
    return substrings;
}
@end

@implementation NSString (JSONExtension)

- (id)JSONValue {
    return [self.class _objectWithJSONString:self error:nil];
}

+ (id)_objectWithJSONString:(NSString *)inJSON error:(NSError **)outError {
    NSData *data = [inJSON dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        return nil;
    }
    return object;
}

@end
