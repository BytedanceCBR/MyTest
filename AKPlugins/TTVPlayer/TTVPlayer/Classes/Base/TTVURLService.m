//
//  TTVURLService.m
//  Article
//
//  Created by liuty on 2017/1/4.
//
//

#import "TTVURLService.h"
#import <CommonCrypto/CommonDigest.h>
#import <TTNetworkManager/TTNetworkUtil.h>

//#import <TTExtensions.h>
#define kToutiaoVideoUserKey @"kToutiaoVideoUserKey"
#define kToutiaoVideoSecretKey @"kToutiaoVideoSecretKey"
#define kToutiaoHostKey @"kToutiaoHostKey"
#define kToutiaoPrametersKey @"kToutiaoPrametersKey"

@implementation TTVURLService

static NSMutableDictionary *ttv_common = nil;
+ (NSMutableDictionary *)staticDic
{
    if (!ttv_common) {
        ttv_common = [NSMutableDictionary dictionary];
    }
    return ttv_common;
}

+ (void)setToutiaoVideoUserKey:(NSString *)toutiaoVideoUserKey
{
    [self staticDic][kToutiaoVideoUserKey] = toutiaoVideoUserKey;
}

+ (void)setToutiaoVideoSecretKey:(NSString *)toutiaoVideoSecretKey
{
    [self staticDic][kToutiaoVideoSecretKey] = toutiaoVideoSecretKey;
}

+ (void)setHost:(NSString *)host
{
    [self staticDic][kToutiaoHostKey] = host;
}

+ (void)setCommonParameters:(NSDictionary *)commonParameters
{
    [self staticDic][kToutiaoPrametersKey] = commonParameters;

}

+ (NSString *)toutiaoVideoAPIVersion {
    return @"1";
}

+ (NSString *)toutiaoVideoAPIURL
{
    return [NSString stringWithFormat:@"%@/video/play/%@", [self staticDic][kToutiaoHostKey], [self toutiaoVideoAPIVersion]];
}

+ (NSString *)urlWithVideoId:(NSString *)videoId
{
    long long ts = [self currentTs];
    NSString *sign = [self signFromVideoID:videoId ts:ts];
    NSString *userStr = [self toutiaoVideoUser];
    NSString *videoType = @"mp4";
    NSString *apiPrefix = [[self class] toutiaoVideoAPIURL];
    // 有传入的 host 不带 https，这里应该叫做 baseUrl
    if (![apiPrefix hasPrefix:@"http"] && ![apiPrefix hasPrefix:@"https"]) {
        apiPrefix = [@"https://" stringByAppendingString:apiPrefix];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@", apiPrefix, userStr, @(ts), sign, videoType, videoId];
    NSDictionary *commonParams = [self staticDic][kToutiaoPrametersKey];
    NSString *transformedURL = [TTNetworkUtil URLString:url appendCommonParams:commonParams];
    
    return transformedURL ?:url;
}

+ (NSString *)urlForV1WithVideoId:(NSString *)videoId {
    return [self urlForV1WithVideoId:videoId businessToken:nil];
}

+ (NSString *)urlForV1WithVideoId:(NSString *)videoId businessToken:(NSString *)businessToken {
    if ([businessToken isKindOfClass:[NSString class]] && businessToken.length > 0) {
        return [NSString stringWithFormat:@"%@?action=GetPlayInfo&video_id=%@&ptoken=%@", [self staticDic][kToutiaoHostKey], videoId, businessToken];
    } else {
        return [NSString stringWithFormat:@"%@?action=GetPlayInfo_VIP&video_id=%@", [self staticDic][kToutiaoHostKey], videoId];
    }
}

+ (long long)currentTs
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return (long long)interval;
}

/**
 sign⽣生成规则可以分为4个步骤:
 1.把其它所有参数按key升序排序。
 2.把key和它对应的value拼接成⼀一个字符串。按步骤1中顺序,把所有键值对字符串拼接成⼀一个字符串。
 3.把分配给的secretkey拼接在第2步骤得到的字符串后⾯面。
 4.计算第3步骤字符串的md5值,使⽤用md5值的16进制字符串作为sign的值。
 */
+ (NSString *)signFromVideoID:(NSString *)videoID ts:(long long)ts
{
    if (!videoID || videoID.length == 0) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:40];
    [string appendFormat:@"ts%lli", ts];
    [string appendFormat:@"user%@", [self toutiaoVideoUser]];
    [string appendFormat:@"version%@", @"1"];
    [string appendFormat:@"video%@", videoID];
    [string appendFormat:@"vtype%@", @"mp4"];
    [string appendString:[self toutiaoVideoSecretKey]];
    NSString *sign = [self MD5HashString:string];
    return sign;
}

#pragma mark -- toutiao user key

+ (NSString *)toutiaoVideoUser
{
    NSString *userKey = [self staticDic][kToutiaoVideoUserKey];
    if (!userKey || userKey.length == 0) {
        return @"toutiao";
    }
    return userKey;
}

#pragma mark -- toutiao secret key

+ (NSString *)toutiaoVideoSecretKey
{
    NSString *toutiaoVideoSecretKey = [self staticDic][kToutiaoVideoSecretKey];
    if (!toutiaoVideoSecretKey || toutiaoVideoSecretKey.length == 0) {
        return @"17601e2231500d8c3389dd5d6afd08de";
    }
    return toutiaoVideoSecretKey;
}

+ (NSString *)MD5HashString:(NSString *)string
{
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}



@end
