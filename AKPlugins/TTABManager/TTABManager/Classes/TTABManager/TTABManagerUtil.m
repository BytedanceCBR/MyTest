//
//  TTABManagerUtil.m
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/24.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTABManagerUtil.h"
#import "TTABDefine.h"

extern const NSInteger kTTABTestMaxRegion;

@implementation TTABManagerUtil

+ (NSInteger)genARandomNumber
{
    int randomValue = arc4random() % (kTTABTestMaxRegion + 1);
    return randomValue;
}

+ (NSDictionary *)readABJSON
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTABResources" ofType:@"bundle"];
    NSBundle *abBundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *path = [abBundle pathForResource:@"ab" ofType:@"json"];
    NSString *content = nil;
    NSError *error = nil;
    if (path) {
        content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    }
    if (error) {
        content = nil;
        return nil;
    }
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (!data || ![data isKindOfClass:[NSData class]]) return nil;
    
    NSDictionary *result = nil;
    @try {
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error) return nil;
    } @catch (NSException *exception) {
    } @finally {
    }
    return result;
}

+ (NSString *)appVersion
{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return version;
}

static NSString *abManager_channel_name = nil;

+ (NSString *)channelName
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        abManager_channel_name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
    });
    return abManager_channel_name;
}

+ (NSString *)_rmSuffix:(NSString *)suffix forStr:(NSString *)str
{
    if (isEmptyString_forABManager(suffix) || isEmptyString_forABManager(str)) {
        return str;
    }
    NSString * result = str;
    while ([result hasSuffix:suffix]) {
        result = [result substringToIndex:[result length] - [suffix length]];
    }
    return result;
}

+ (TTABVersionCompareType)compareVersion:(NSString *)leftVersion toVersion:(NSString *)rightVersion
{
    leftVersion = [self _rmSuffix:@".0" forStr:leftVersion];
    rightVersion = [self _rmSuffix:@".0" forStr:rightVersion];
    
    if (isEmptyString_forABManager(leftVersion) || isEmptyString_forABManager(rightVersion)) {
        NSLog(@"ABManager version compare error");
        return TTABVersionCompareTypeEqualTo;
    }
    
    if ([leftVersion isEqualToString:rightVersion]) {
        return TTABVersionCompareTypeEqualTo;
    }
    
    NSArray<NSString *> * leftComponents = [leftVersion componentsSeparatedByString:@"."];
    NSArray<NSString *> * rightComponents = [rightVersion componentsSeparatedByString:@"."];
    
    for (int i = 0; i < MIN([leftComponents count], [rightComponents count]); i++) {
        NSInteger leftPart = 0;
        NSString *leftCompString = leftComponents[i];
        if (leftCompString && [leftCompString respondsToSelector:@selector(longLongValue)]) {
            leftPart = [leftComponents[i] longLongValue];
        }
        
        NSInteger rightPart = 0;
        NSString *rightCompString = rightComponents[i];
        if (rightCompString && [rightCompString respondsToSelector:@selector(longLongValue)]) {
            rightPart = [rightCompString longLongValue];
        }
        
        if (leftPart < rightPart) {
            return TTABVersionCompareTypeLessThan;
        }
        else if (leftPart > rightPart) {
            return TTABVersionCompareTypeGreateThan;
        }
        else { // equal
            continue;
        }
    }
    
    if ([leftComponents count] > [rightComponents count]) {
        return TTABVersionCompareTypeGreateThan;
    }
    else {
        return TTABVersionCompareTypeLessThan;
    }
}

+ (NSString *)ABTestClient
{
    NSMutableString * abClient = [NSMutableString stringWithCapacity:10];
    
    [abClient appendFormat:@"a1"];
    
#ifndef TTModule
    [abClient appendFormat:@",f2"];
    [abClient appendFormat:@",f7"];
#endif
    [abClient appendFormat:@",e1"];
    
    return abClient;
}

@end
