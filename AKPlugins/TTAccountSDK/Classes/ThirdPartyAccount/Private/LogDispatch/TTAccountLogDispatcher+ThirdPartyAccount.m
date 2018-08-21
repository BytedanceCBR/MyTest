//
//  TTAccountLogDispatcher+ThirdPartyAccount.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 13/06/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountLogDispatcher+ThirdPartyAccount.h"
#import "TTAccount.h"
#import "TTAccountLogger.h"
#import "TTAccountAuthLogger.h"



#define TTAccountAuthLoginLogger(logger)         ((id<TTAccountAuthLoginLogger>)logger)
#define TTAccountAuthLoginCallbackLogger(logger) ((id<TTAccountAuthLoginCallbackLogger>)logger)


@implementation TTAccountLogDispatcher (AuthPlatformAccount)

+ (void)dispatchAccountAuthPlatform:(TTAccountAuthType)platformType
                          bySDKAuth:(BOOL)isSDKAuth
                            success:(BOOL)success
                            context:(NSDictionary *)contextInfo
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (isSDKAuth) {
        if (success) {
            if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(SDKAuthForPlatform:didSuccessWithRespContext:)]) {
                [TTAccountAuthLoginLogger([TTAccount accountConf].loggerDelegate) SDKAuthForPlatform:platformType
                                                                           didSuccessWithRespContext:contextInfo];
            }
        } else {
            if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(SDKAuthForPlatform:didFailWithRespContext:)]) {
                [TTAccountAuthLoginLogger([TTAccount accountConf].loggerDelegate) SDKAuthForPlatform:platformType
                                                                              didFailWithRespContext:contextInfo];
            }
        }
    } else {
        if (success) {
            if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(customWapAuthForPlatform:didSuccessWithRespContext:)]) {
                [TTAccountAuthLoginLogger([TTAccount accountConf].loggerDelegate) customWapAuthForPlatform:platformType
                                                                                 didSuccessWithRespContext:contextInfo];
            }
        } else {
            if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(customWapAuthForPlatform:didFailWithRespContext:)]) {
                [TTAccountAuthLoginLogger([TTAccount accountConf].loggerDelegate) customWapAuthForPlatform:platformType
                                                                                    didFailWithRespContext:contextInfo];
            }
        }
    }
#pragma clang diagnostic pop
}

+ (void)dispatchDidTapCustomWapSNSBarWithChecked:(BOOL)selected
                                     forPlatform:(TTAccountAuthType)platformType
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(customWapLoginDidTapSNSBarWithChecked:forPlatform:)]) {
        [TTAccountAuthLoginLogger([TTAccount accountConf].loggerDelegate) customWapLoginDidTapSNSBarWithChecked:selected
                                                                                                    forPlatform:platformType];
    }
#pragma clang diagnostic pop
}

+ (void)dispatchCustomWapAuthCallbackAndRedirectToURL:(NSString *)urlString
                                          forPlatform:(TTAccountAuthType)platformType
                                                error:(NSError *)error
                                              context:(NSDictionary *)extraDict
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(customWapAuthCallbackAndRedirectToURL:forPlatform:error:context:)]) {
        
        [TTAccountAuthLoginLogger([TTAccount accountConf].loggerDelegate) customWapAuthCallbackAndRedirectToURL:urlString
                                                                                                    forPlatform:platformType
                                                                                                          error:error
                                                                                                        context:extraDict];
    }
#pragma clang diagnostic pop
}

+ (void)dispatchAccountAuthPlatformBoundForbidError
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(accountAuthPlatformBoundForbidError)]) {
        [TTAccountAuthLoginCallbackLogger([TTAccount accountConf].loggerDelegate) accountAuthPlatformBoundForbidError];
    }
#pragma clang diagnostic pop
}

+ (void)dispatchDropOriginalAccountAlertViewDidCancel:(BOOL)cancelled
                                          forPlatform:(TTAccountAuthType)platformType
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(dropOriginalAccountAlertViewDidCancel:forPlatform:)]) {
        [TTAccountAuthLoginCallbackLogger([TTAccount accountConf].loggerDelegate) dropOriginalAccountAlertViewDidCancel:cancelled
                                                                                                            forPlatform:platformType];
        
    }
#pragma clang diagnostic pop
}

+ (void)dispatchSwitchBindAlertViewDidCancel:(BOOL)cancelled
                                 forPlatform:(TTAccountAuthType)platformType
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(switchBindAlertViewDidCancel:forPlatform:)]) {
        [TTAccountAuthLoginCallbackLogger([TTAccount accountConf].loggerDelegate) switchBindAlertViewDidCancel:cancelled
                                                                                                   forPlatform:platformType];
    }
#pragma clang diagnostic pop
}

+ (void)dispatchSSOSwitchBindDidCompleteWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(SSOSwitchBindDidCompleteWithError:)]) {
        [TTAccountAuthLoginCallbackLogger([TTAccount accountConf].loggerDelegate) SSOSwitchBindDidCompleteWithError:error];
    }
#pragma clang diagnostic pop
}

+ (void)dispatchCustomWebSSOSwitchBindDidCompleteWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[TTAccount accountConf].loggerDelegate respondsToSelector:@selector(customWebSSOSwitchBindDidCompleteWithError:)]) {
        [TTAccountAuthLoginCallbackLogger([TTAccount accountConf].loggerDelegate) customWebSSOSwitchBindDidCompleteWithError:error];
    }
#pragma clang diagnostic pop
}

@end
