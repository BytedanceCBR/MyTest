//
//  TTStringHelper.m
//  Pods
//
//  Created by zhaoqin on 8/11/16.
//
//

#import "TTStringHelper.h"
#import "TTBaseMacro.h"

@implementation TTStringHelper

+ (NSString *)URLQueryStringWithoutEncodeWithParameters:(NSDictionary *)parameters {
    NSMutableString *temp = [NSMutableString stringWithCapacity:20];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [temp appendFormat:@"%@=%@&", key, obj];
    }];
    if (temp.length > 0) {
        // 删除最后的&
        [temp deleteCharactersInRange:NSMakeRange(temp.length - 1, 1)];
    }
    return [temp copy];
}

+ (NSString *)URLQueryStringWithParameters:(NSDictionary *)parameters {
    NSString *temp = [self URLQueryStringWithoutEncodeWithParameters:parameters];
    return [[temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
}

+ (NSDictionary*)parametersOfURLString:(NSString*)urlString {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *patterns = [urlString componentsSeparatedByString:@"&"];
    for(NSString *pattern in patterns) {
        NSArray *part = [pattern componentsSeparatedByString:@"="];
        if([part count] == 2) {
            [result setObject:[part objectAtIndex:1] forKey:[part objectAtIndex:0]];
        }
    }
    return result;
}

+ (NSString *)parseStringInDict:(NSDictionary *)dict forKey:(NSString *)keyName {
    NSString * dictItem = [dict objectForKey:keyName];
    if (!dictItem) {
        return nil;
    }
    NSString * dictStr = [NSString stringWithFormat:@"%@", dictItem];
    if ([dictStr length] > 0) {
        return [NSString stringWithString:dictStr];
    }
    return nil;
}

+ (NSNumber *)parseNumberInDict:(NSDictionary *)dict forKey:(NSString *)keyName {
    if (![dict objectForKey:keyName]) {
        return nil;
    }
    NSNumber * result = [NSNumber numberWithLongLong:[[dict objectForKey:keyName] longLongValue]];
    return result;
}

+ (NSString *)decodeStringFromBase64Str:(NSString *)str {
    NSData *data = nil;
    for (int i = 0; i < 2; i++) {
        data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (data) {
            break;
        }
        str = [str stringByAppendingString:@"="];
    }
    NSString *string =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

+ (NSURL *)URLWithURLString:(NSString *)str {
    return [self URLWithString:str relativeToURL:nil];
}

+ (NSURL *)URLWithString:(NSString *)str relativeToURL:(NSURL *)url {
    if (isEmptyString(str)) {
        return nil;
    }
    NSString *fixStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *u = nil;
    if (url) {
        u = [NSURL URLWithString:fixStr relativeToURL:url];
    }
    else {
        u = [NSURL URLWithString:fixStr];
    }
    if (!u) {
        //直接创建url失败，则进行query encode尝试
        NSString *sourceString = fixStr;
        NSRange fragmentRange = [fixStr rangeOfString:@"#"];
        NSString *fragment = nil;
        if (fragmentRange.location != NSNotFound) {
            sourceString = [fixStr substringToIndex:fragmentRange.location];
            fragment = [fixStr substringFromIndex:fragmentRange.location];
        }
        NSArray *substrings = [sourceString componentsSeparatedByString:@"?"];
        if ([substrings count] > 1) {
            NSString *beforeQuery = [substrings objectAtIndex:0];
            NSString *queryString = [substrings objectAtIndex:1];
            NSArray *paramsList = [queryString componentsSeparatedByString:@"&"];
            NSMutableDictionary *encodedQueryParams = [NSMutableDictionary dictionary];
            [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
                NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
                if ([keyAndValue count] > 1) {
                    NSString *key = [keyAndValue objectAtIndex:0];
                    NSString *value = [keyAndValue objectAtIndex:1];
//                    value = [TTStringHelper recursiveDecodeForString:value];
                    [self _decodeWithEncodedURLString:&value];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    CFStringRef cfValue = (__bridge CFStringRef)value;
                    CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(
                                                                                       kCFAllocatorDefault,
                                                                                       cfValue,
                                                                                       NULL,
                                                                                       CFSTR(":/?#@!$&'(){}*+="),
                                                                                       kCFStringEncodingUTF8);
#pragma clang diagnostic pop
                    value = (__bridge_transfer NSString *)encodedValue;
                    [encodedQueryParams setValue:value forKey:key];
                }
            }];
            
            NSString *encodedQuery = [self URLQueryStringWithoutEncodeWithParameters:encodedQueryParams];
            NSString *encodedURLString = [[[beforeQuery stringByAppendingString:@"?"] stringByAppendingString:encodedQuery] stringByAppendingString:fragment?:@""];
            
            if (url) {
                u = [NSURL URLWithString:encodedURLString relativeToURL:url];
            }
            else {
                u = [NSURL URLWithString:encodedURLString];
            }
        }
        /*    
         *   http://p1.meituan.net/adunion/a1c87dd93958f3e7adbeb0ecf1c5c166118613.jpg@228w|0_2_0_150az
         *   上面的链接没有命中特殊字符串转义逻辑，在上溯逻辑之后再尝试转义之后转url。。。       --yingjie
         */
        if (!u) {
            u = [NSURL URLWithString:[fixStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSAssert(u, @"url构造出现问题，请确保格式合法，或联系专业人士");
    }
    return u;
}

//+ (NSString *)recursiveDecodeForString:(NSString *)possibleEncodedString
//{
//    NSString *recursiveDecodedString = nil;
//    do {
//        recursiveDecodedString = [possibleEncodedString copy];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        CFStringRef decodedStringRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)possibleEncodedString, CFSTR(""), kCFStringEncodingUTF8);
//#pragma clang diagnostic pop
//        possibleEncodedString = (__bridge_transfer NSString *)decodedStringRef;
//    } while (nil != possibleEncodedString && ![possibleEncodedString isEqualToString:recursiveDecodedString]);
//    return recursiveDecodedString;
//}

+ (void)_decodeWithEncodedURLString:(NSString **)urlString
{
    if ([*urlString rangeOfString:@"%"].length == 0){
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    *urlString = (__bridge_transfer NSString *)(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)*urlString, CFSTR(""), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

@end
