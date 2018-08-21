//
//  NSString+TTAccountUtils.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 10/19/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "NSString+TTAccountUtils.h"
#import "TTAccountDefine.h"
#import "NSString+TTAccountUtils.h"



@implementation NSString (tta_ContainsString)
- (BOOL)tta_containsString:(NSString *)aString
{
    NSRange range = [self rangeOfString:aString];
    return (range.length != 0);
}
@end



@implementation NSString (tta_ImageOfBase64String)
- (UIImage *)tta_imageFromBase64String
{
    if(TTAccountIsEmptyString(self)) {
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *result = [UIImage imageWithData:data];
    return result;
}

- (NSData *)tta_imageDataFromBase64String
{
    if(TTAccountIsEmptyString(self)) {
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}
@end



@implementation NSString (tta_URLEnDecoder)
/**
 *  将字符串进行URL编码
 */
- (NSString *)tta_URLEncodedString
{
    __autoreleasing NSString *encodedString;
    NSString *originalString = (NSString *)self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (__bridge CFStringRef)originalString,
                                                                                          NULL,
                                                                                          (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                                                          kCFStringEncodingUTF8
                                                                                          );
#pragma clang diagnostic pop
    return encodedString;
}


/**
 *  将字符串进行URL解密
 */
- (NSString *)tta_URLDecodedString
{
    __autoreleasing NSString *decodedString;
    NSString *originalString = (NSString *)self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef)originalString,
                                                                                                          CFSTR(""),
                                                                                                          kCFStringEncodingUTF8
                                                                                                          );
#pragma clang diagnostic pop
    return decodedString;
}
@end



@implementation NSString (tta_HexMix)
+ (NSString *)__hexMixedStringWithString:(NSString *)string
{
    if ([string length] <= 0) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0) {
        return nil;
    }
    UInt8 bytes[data.length];
    [data getBytes:&bytes length:data.length];
    const NSInteger key = 5;
    NSMutableString *result = [NSMutableString stringWithCapacity:data.length * 2];
    for (int i = 0; i < data.length; i ++) {
        [result appendFormat:@"%02x", (UInt8)(bytes[i]^key)];
    }
    return result;
}

- (NSString *)tta_hexMixedString
{
    return [self.class __hexMixedStringWithString:self];
}
@end



@implementation NSString (tta_URLUtils)

- (NSURL *)tta_URL
{
    return [self tta_URLByAppendQueryItems:nil];
}

- (NSString *)tta_URLStringByAppendQueryItems:(NSDictionary *)items
{
    return [self tta_URLStringByAppendQueryItems:items fragment:nil];
}

- (NSString *)tta_URLStringByAppendQueryItems:(NSDictionary *)items fragment:(NSString *)fragment
{
    NSMutableString *querys = [NSMutableString stringWithCapacity:10];
    if ([items count] > 0) {
        [items enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                [querys appendFormat:@"%@=%@", key, [(NSString *)obj tta_URLEncodedString]];
                [querys appendString:@"&"];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                [querys appendFormat:@"%@=%@", key, (NSNumber *)obj];
                [querys appendString:@"&"];
            }
        }];
        if ([querys hasSuffix:@"&"]) {
            [querys deleteCharactersInRange:NSMakeRange([querys length] - 1, 1)];
        }
    }
    
    NSMutableString *retURLString = [NSMutableString stringWithString:[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if ([querys length] > 0) {
        if ([retURLString rangeOfString:@"?"].location == NSNotFound) {
            [retURLString appendString:@"?"];
        }
        else if (![retURLString hasSuffix:@"?"] && ![retURLString hasSuffix:@"&"]) {
            [retURLString appendString:@"&"];
        }
        [retURLString appendString:querys];
    }
    
    if ([fragment isKindOfClass:[NSString class]] && [fragment length] > 0) {
        [retURLString appendFormat:@"#%@", fragment];
    }
    
    return retURLString;
}

- (NSURL *)tta_URLByAppendQueryItems:(NSDictionary *)items
{
    if ([items count] <= 0) {
        return [NSURL URLWithString:self];
    }
    
    return [self tta_URLByAppendQueryItems:items fragment:nil];
}

- (NSURL *)tta_URLByAppendQueryItems:(NSDictionary *)queryItems fragment:(NSString *)fragment
{
    NSString *urlString = [self tta_URLStringByAppendQueryItems:queryItems fragment:fragment];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

- (id)tta_DeserializeJSONObject
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end



@implementation NSURL (tta_URLUtils)
- (NSURL *)tta_URLByAppendQueryItems:(NSDictionary *)items
{
    if ([items count] <= 0) {
        return self;
    }
    return [self.absoluteString tta_URLByAppendQueryItems:items];
}

- (NSDictionary *)tta_queryDictionary
{
    if (!self) return nil;
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    NSString *queryString  = self.query ? : self.host;
    NSArray *keyValuePairs = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in keyValuePairs) {
        NSArray *element = [keyValuePair componentsSeparatedByString:@"="];
        if (element.count != 2) continue;
        
        NSString *key   = [element[0] tta_URLDecodedString];
        NSString *value = [element[1] tta_URLDecodedString];
        id valueObject  = [value tta_DeserializeJSONObject];
        
        if (key.length == 0) continue;
        
        [queryDict setValue:(valueObject ? : value) forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:queryDict];
}

@end
