//
//  FHUserInfoManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHUserInfoManager.h"
#import "FHEnvContext.h"
#import <TTAccountSDK/TTAccount.h>
#import <TTAccountSDK/TTAccountUserEntity.h>
#import "FHGeneralBizConfig.h"

@implementation FHUserInfoManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

+ (NSString *)getPhoneNumberIfExist {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    NSString *phoneNumber = @"";
    if ([phoneCache isKindOfClass:[NSString class]]) {
        phoneNumber = (NSString *)phoneCache;
    }
    if (!phoneNumber.length && [TTAccount sharedAccount].isLogin) {
        phoneNumber = [TTAccount sharedAccount].user.mobile;
    }
    return phoneNumber;
}

+ (NSString *)formattMaskPhoneNumber:(NSString *)phoneNumber {
    if (phoneNumber.length >= 11) {
        //151*****010
        NSString *maskPhoneNumber = [NSString stringWithFormat:@"%@*****%@",[phoneNumber substringWithRange:NSMakeRange(0, 3)],[phoneNumber substringWithRange:NSMakeRange(8, 3)]];
        return maskPhoneNumber;
    }
    return @"";
}

+ (BOOL)isLoginPhoneNumber:(NSString *)phoneNumber {
    if (phoneNumber.length && [TTAccount sharedAccount].isLogin && [phoneNumber isEqualToString:[TTAccount sharedAccount].user.mobile]) {
        return YES;
    }
    return NO;
}

+ (BOOL)checkPureIntFormatted:(NSString *)phoneNumber {
    if ([self isLoginPhoneNumber:phoneNumber]) {
        return YES;
    }
    NSScanner* scan = [NSScanner scannerWithString:phoneNumber];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (void)savePhoneNumber:(NSString *)phoneNumber {
    //判断如果是带掩码的，则为登录态掩码手机号，不需要存储
    if (!phoneNumber.length) {
        return;
    }
    if ([TTAccount sharedAccount].isLogin && [[TTAccount sharedAccount].user.mobile isEqualToString:phoneNumber]) {
        return;
    }
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPhoneNumberCacheKey];
}

@end
