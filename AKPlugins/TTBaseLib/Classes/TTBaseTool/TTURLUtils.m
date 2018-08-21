//
//  TTURLUtils.m
//  TestTab
//
//  Created by ZhangLeonardo on 15/10/16.
//  Copyright © 2015年 ZhangLeonardo. All rights reserved.
//

#import "TTURLUtils.h"

@implementation TTURLUtils

#pragma mark -- 构造

+ (NSURL *)URLWithString:(NSString *)URLString
{
    return [NSURL URLWithString:URLString];
}

+ (NSURL *)URLWithString:(NSString *)URLString queryItems:(NSDictionary *)queryItems
{
    return [self URLWithString:URLString queryItems:queryItems fragment:nil];
}

+ (NSURL *)URLWithString:(NSString *)URLString queryItems:(NSDictionary *)queryItems fragment:(NSString *)fragment
{
    NSMutableString * querys = [NSMutableString stringWithCapacity:10];
    if ([queryItems count] > 0) {
        [queryItems enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                [querys appendFormat:@"%@=%@", key, [self queryItemAddingPercentEscapes:obj]];
                [querys appendString:@"&"];
            }
        }];
        if ([querys hasSuffix:@"&"]) {
            [querys deleteCharactersInRange:NSMakeRange([querys length] - 1, 1)];
        }
    }
    
    NSMutableString * resultURL = [NSMutableString stringWithString:URLString];
    if ([querys length] > 0) {
        if ([resultURL rangeOfString:@"?"].location == NSNotFound) {
            [resultURL appendString:@"?"];
        }
        else if (![resultURL hasSuffix:@"?"] && ![resultURL hasSuffix:@"&"]) {
            [resultURL appendString:@"&"];
        }
        [resultURL appendString:querys];
    }
    
    if ([fragment isKindOfClass:[NSString class]] && [fragment length] > 0) {
        [resultURL appendFormat:@"#%@", fragment];
    }
    
    NSURL * URL = [self URLWithString:resultURL];
    return URL;
}

+ (NSString *)queryItemAddingPercentEscapes:(NSString *)queryItem
{
    if ([queryItem isKindOfClass:[NSNumber class]]) {
        queryItem = ((NSNumber *)queryItem).stringValue;
    }
    CFStringRef originalString = (__bridge CFStringRef)queryItem;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                        kCFAllocatorDefault,
                                                                        originalString,
                                                                        NULL,
                                                                        CFSTR(":/?#@!$&'(){}*+="),
                                                                        kCFStringEncodingUTF8);
#pragma clang diagnostic pop
    return (__bridge_transfer NSString *)encodedString;
}

+ (NSURL *)URLByInsertOrUpdateParameters:(NSDictionary *)parameters toURL:(NSURL *)URL {
    NSMutableDictionary *dictionary = [[self queryItemsForURL:URL] mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dictionary setValue:obj forKey:key];
    }];
    // 将URL替换成最新的
    NSString *query = [self _URLQueryStringWithParameters:dictionary];
    NSString *absoluteString = [URL.absoluteString stringByReplacingOccurrencesOfString:URL.query withString:query];
    return [NSURL URLWithString:absoluteString];
}

+ (NSString *)_URLQueryStringWithParameters:(NSDictionary *)parameters {
    NSMutableString *temp = [NSMutableString stringWithCapacity:20];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [temp appendFormat:@"%@=%@&", key, obj];
    }];
    if (temp.length > 0) {
        // 删除最后的&
        [temp deleteCharactersInRange:NSMakeRange(temp.length - 1, 1)];
    }
    return [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -- 解析

+ (NSString *)hostForURL:(NSURL *)URL
{
    return [URL host];
}

+ (NSString *)pathForURL:(NSURL *)URL
{
    return [URL path];
}

+ (NSString *)fragmentForURL:(NSURL *)URL
{
    return [URL fragment];
}

+ (NSDictionary *)queryItemsForURL:(NSURL *)URL
{
    NSString * query = [URL query];
    if ([query length] == 0) {
        return nil;
    }
    
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray *paramsList = [query componentsSeparatedByString:@"&"];
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyAndValue = [obj componentsSeparatedByString:@"="];
        if ([keyAndValue count] > 1) {
            NSString *paramKey = [keyAndValue objectAtIndex:0];
            NSString *paramValue = [keyAndValue objectAtIndex:1];
            if ([paramValue rangeOfString:@"%"].length > 0) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                CFStringRef decodedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                    kCFAllocatorDefault,
                                                                                                    (__bridge CFStringRef)paramValue,
                                                                                                    CFSTR(""),
                                                                                                    kCFStringEncodingUTF8);
#pragma clang diagnostic pop
                paramValue = (__bridge_transfer NSString *)decodedString;
            }
            
            [result setValue:paramValue forKey:paramKey];
        }
    }];
    
    return result;
}

+ (NSDictionary *)queryItemsWithoutDecodingForURL:(nonnull NSURL *)URL
{
    NSString * query = [URL query];
    if ([query length] == 0) {
        return nil;
    }
    
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray *paramsList = [query componentsSeparatedByString:@"&"];
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyAndValue = [obj componentsSeparatedByString:@"="];
        if ([keyAndValue count] > 1) {
            NSString *paramKey = [keyAndValue objectAtIndex:0];
            NSString *paramValue = [keyAndValue objectAtIndex:1];
            [result setValue:paramValue forKey:paramKey];
        }
    }];
    
    return result;
}

@end
