//
//  TTAccountLogDispatcher.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 13/06/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountLogDispatcher.h"
#import "TTAccount.h"
#import "TTAccountLogger.h"



@implementation TTAccountLogDispatcher

+ (void)dispatchAccountLoginSuccessWithReason:(TTAccountStatusChangedReasonType)reasonType
                                     platform:(NSString *)platformNameString
{
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountLoginSuccess:platform:)]) {
        [[TTAccount accountConf].loggerDelegate accountLoginSuccess:reasonType platform:platformNameString];
    }
}

+ (void)dispatchAccountLoginFailureWithReason:(TTAccountStatusChangedReasonType)reasonType
                                     platform:(NSString *)platformNameString
{
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountLoginFailure:platform:)]) {
        [[TTAccount accountConf].loggerDelegate accountLoginFailure:reasonType platform:platformNameString];
    }
}

+ (void)dispatchAccountSessionExpired:(NSError *)error
                           withUserID:(NSString *)userIDString
{
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountSessionExpired:withUserID:)]) {
        [[TTAccount accountConf].loggerDelegate accountSessionExpired:error withUserID:userIDString];
    }
}

+ (void)dispatchAccountPlatformExpired:(NSError *)error
                          withPlatform:(NSString *)joinedPlatformString
{
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountPlatformExpired:withPlatform:)]) {
        [[TTAccount accountConf].loggerDelegate accountPlatformExpired:error withPlatform:joinedPlatformString];
    }
}

+ (void)dispatchAccountLogoutSuccess
{
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountLogoutSuccess)]) {
        [[TTAccount accountConf].loggerDelegate accountLogoutSuccess];
    }
}

+ (void)dispatchAccountLogoutFailure
{
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountLogoutFailure)]) {
        [[TTAccount accountConf].loggerDelegate accountLogoutFailure];
    }
}

@end
