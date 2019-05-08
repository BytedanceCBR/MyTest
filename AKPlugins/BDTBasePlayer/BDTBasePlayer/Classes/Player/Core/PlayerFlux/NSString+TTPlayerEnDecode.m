//
//  NSString+TTPlayerEnDecode.m
//  BDTBasePlayer
//
//  Created by lishuangyang on 2018/2/11.
//

#import "NSString+TTPlayerEnDecode.h"

@implementation NSString (TTPlayerEnDecode)
/**
 *  将字符串进行URL编码
 */
- (NSString *)ttPlayer_URLEncodedString
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
- (NSString *)ttPlayer_URLDecodedString
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
