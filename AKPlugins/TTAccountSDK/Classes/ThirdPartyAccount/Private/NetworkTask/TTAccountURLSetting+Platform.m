//
//  TTAccountURLSetting+Platform.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/8/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountURLSetting+Platform.h"
#import "TTAccount.h"



@implementation TTAccountURLSetting (TTThirdPartyPlatform)

#pragma mark - Full URL

+ (NSString *)TTASNSSDKAuthCallbackURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTASNSSDKAuthCallbackURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], ([[TTAccount sharedAccount] isLogin] ? [self TTAPlatformAuthBindV2URLPathString] : [self TTAPlatformAuthLoginV2URLPathString])]
            );
}

+ (NSString *)TTASNSSDKSwitchBindURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTASNSSDKSwitchBindURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAPlatformAuthSwitchBindV2URLPathString]]
            );
}

+ (NSString *)TTACustomWAPLoginURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTACustomWAPLoginURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAPlatformAuthWapLoginV2URLPathString]]
            );
    
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTACustomWAPLoginURLPathString]];
}

+ (NSString *)TTACustomWAPLoginSuccessURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTACustomWAPLoginContinueURLPathString]];
}

+ (NSString *)TTACustomWAPLoginContinueURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTACustomWAPLoginContinueURLPathString]];
}

+ (NSString *)TTAShareAppToSNSPlatformURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAShareAppToSNSPlatformURLPathString]];
}


#pragma mark - URL Path

+ (NSString *)TTASNSSDKAuthCallbackURLPathString
{
    return [NSString stringWithFormat:@"/2/auth/sso_callback/v2/"];
}

+ (NSString *)TTASNSSDKSwitchBindURLPathString
{
    return [NSString stringWithFormat:@"/2/auth/sso_switch_bind/"];
}

+ (NSString *)TTACustomWAPLoginURLPathString
{
    return [NSString stringWithFormat:@"/2/auth/login/v2/"];
}

+ (NSString *)TTACustomWAPLoginSuccessURLPathString
{
    return [NSString stringWithFormat:@"/auth/login_success/"];
}

+ (NSString *)TTACustomWAPLoginContinueURLPathString
{
    return [NSString stringWithFormat:@"/2/auth/login_continue/"];
}

#pragma mark - share app to third party platform

+ (NSString *)TTAShareAppToSNSPlatformURLPathString
{
    return [NSString stringWithFormat:@"/2/data/v2/app_share/"];
}

@end



@implementation TTAccountURLSetting (PlatformInterfaceV2)

#pragma mark - URL PATH

+ (NSString *)TTAPlatformAuthWapLoginV2URLPathString
{
    return (@"/passport/auth/wap_login/");
}

+ (NSString *)TTAPlatformAuthLoginV2URLPathString
{
    return (@"/passport/auth/login/");
}

+ (NSString *)TTAPlatformAuthBindV2URLPathString
{
    return (@"/passport/auth/bind/");
}

+ (NSString *)TTAPlatformAuthSwitchBindV2URLPathString
{
    return (@"/passport/auth/switch_bind/");
}

@end
