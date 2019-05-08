//
//  TTVVideoURLParser.m
//  Article
//
//  Created by 潘祥
//
//

#import "TTVVideoURLParser.h"
#import <CommonCrypto/CommonDigest.h>
#import "TTVPlayerControllerState.h"
#import "TTVVideoURLSettingUtility.h"
#import "TTVPlayerSettingUtility.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIButton+TTAdditions.h"

/**
 sign⽣生成规则可以分为4个步骤:
 1.把其它所有参数按key升序排序。
 2.把key和它对应的value拼接成⼀一个字符串。按步骤1中顺序,把所有键值对字符串拼接成⼀一个字符串。
 3.把分配给的secretkey拼接在第2步骤得到的字符串后⾯面。
 4.计算第3步骤字符串的md5值,使⽤用md5值的16进制字符串作为sign的值。
 */

@implementation TTVVideoURLParser

#pragma mark - utility

+ (NSString *)urlWithVideoID:(NSString *)videoID categoryID:(NSString *)categoryID itemId:(NSString *)itemId adID:(NSString *)adID sp:(TTVPlayerSP)sp base:(NSDictionary *)base
{
    if (isEmptyString(videoID)) {
        return nil;
    }
    NSString *_videoRequestUrl = nil;
    long long ts = [self.class currentTs];
    NSString *sign = [self.class leTVSignFromVideoID:videoID ts:ts sp:sp];
    NSString *userKey = [self.class userKeyForSP:sp];
    NSString *videoType = [self.class videoTypeForSP:sp];
    NSString *api = [self.class apiForSP:sp];
    if (sp == TTVPlayerSPToutiao) {
        _videoRequestUrl = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@?play_type=1", api, userKey, @(ts), sign, videoType, videoID];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:base];
        [dic setValue:categoryID forKey:@"category"];
        [dic setValue:itemId forKey:@"item_id"];
        [dic setValue:adID forKey:@"ad_id"];
        for (NSString *key in [dic allKeys]) {
            if ([dic valueForKey:key]) {
                _videoRequestUrl = [_videoRequestUrl stringByAppendingFormat:@"&%@=%@",key,[dic valueForKey:key]];
            }
        }
    } else {
        _videoRequestUrl = [NSString stringWithFormat:@"%@?sign=%@&ts=%@&user=%@&video=%@&vtype=%@", api, sign, @(ts), userKey, videoID, videoType];
    }
    _videoRequestUrl = [_videoRequestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return _videoRequestUrl;
}

+ (NSString *)MD5HashString:(NSString *)string
{
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}


+ (long long)currentTs {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return (long long)interval;
}

+ (NSString *)leTVSignFromVideoID:(NSString *)videoID ts:(long long)ts sp:(TTVPlayerSP)sp {
    if (isEmptyString(videoID)) {
        return nil;
    }
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"ts%lli", ts];
    [string appendFormat:@"user%@",[self userKeyForSP:sp]];
    if (sp == TTVPlayerSPToutiao) {
        [string appendFormat:@"version%@", [TTVVideoURLSettingUtility toutiaoPlayApiVersion]];
    }
    [string appendFormat:@"video%@",videoID];
    [string appendFormat:@"vtype%@", [self videoTypeForSP:sp]];
    [string appendString:[self secretKeyForSP:sp]];
    NSString *sign = [self MD5HashString:string];
    return sign;
}

+ (NSString *)userKeyForSP:(TTVPlayerSP)sp {
    if (sp == TTVPlayerSPLeTV) {
        return [TTVPlayerSettingUtility leTVUserKey];
    } else if (sp == TTVPlayerSPToutiao) {
        return [TTVPlayerSettingUtility toutiaoUserKey];
    }
    return nil;
}

+ (NSString *)secretKeyForSP:(TTVPlayerSP)sp {
    if (sp == TTVPlayerSPLeTV) {
        return [TTVPlayerSettingUtility leTVSecretKey];
    } else if (sp == TTVPlayerSPToutiao) {
        return [TTVPlayerSettingUtility toutiaoSecretKey];
    }
    return nil;
}

+ (NSString *)apiForSP:(TTVPlayerSP)sp {
    if (sp == TTVPlayerSPLeTV) {
        return [TTVVideoURLSettingUtility leTVPlayApi];
    } else if (sp == TTVPlayerSPToutiao) {
        return [TTVVideoURLSettingUtility toutiaoPlayApi];
    }
    return nil;
}

+ (NSString *)videoTypeForSP:(TTVPlayerSP)sp {
    if (sp == TTVPlayerSPLeTV) {
        return [TTVPlayerSettingUtility leTVVideoType];
    } else if (sp == TTVPlayerSPToutiao) {
        return [TTVPlayerSettingUtility toutiaoVideoType];
    }
    return nil;
}


@end
