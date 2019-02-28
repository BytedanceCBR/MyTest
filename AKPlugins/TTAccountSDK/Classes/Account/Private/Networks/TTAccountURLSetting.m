//
//  TTAccountURLSetting.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 10/19/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountURLSetting.h"
#import "TTAccountMacros.h"
#import "TTAccount.h"



/**
 *  Default URL domains
 */
NSString * const kTTANormalBaseURLDomain   = @"ib.haoduofangs.com";
NSString * const kTTASNSBaseURLDomain      = @"isub.haoduofangs.com";
NSString * const kTTAChannelBaseURLDomain  = @"ichannel.haoduofangs.com";
NSString * const kTTASecurityBaseURLDomain = @"security.haoduofangs.com";

/**
 *  Keys of domain name
 */
NSString * const kTTANormalBaseURLDomainKey   = @"i";
NSString * const kTTASecurityBaseURLDomainKey = @"si";
NSString * const kTTASNSBaseURLDomainKey      = @"isub";
NSString * const kTTAChannelBaseURLDomainKey  = @"ichannel";


#pragma mark - domains


NS_INLINE NSDictionary *tta_baseURLDomains()
{
    static NSDictionary *domains = nil;
    if (!domains) {
        domains = @{
                    kTTANormalBaseURLDomainKey      : kTTANormalBaseURLDomain,
                    kTTASNSBaseURLDomainKey         : kTTASNSBaseURLDomain,
                    kTTASecurityBaseURLDomainKey    : kTTASecurityBaseURLDomain,
                    kTTAChannelBaseURLDomainKey     : kTTAChannelBaseURLDomain
                    };
    }
    return domains;
}

// Get specific domain
NS_INLINE NSString *tta_baseURLDomainForKey(NSString *key)
{
    NSDictionary *domains = tta_baseURLDomains();
    NSString *domain = [domains objectForKey:key];
    return domain;
}

// Get specific URL of domain
NS_INLINE NSString *tta_baseURLForKey(NSString *key)
{
    NSString *domain = tta_baseURLDomainForKey(key);
    return [NSString stringWithFormat:@"http://%@", domain];
}



@implementation TTAccountURLSetting

/**
 *  动态获取服务器域名
 */
+ (NSString *)dynamicDomain
{
    NSString *domainString = [TTAccount accountConf].domain;
    return domainString;
}

+ (NSString *)dynamicConfigURL
{
    NSString *domainString = [self dynamicDomain];
    if ([domainString hasPrefix:@"http://"] || [domainString hasPrefix:@"https://"]) {
        return domainString;
    } else if ([domainString length] > 0) {
        return [NSString stringWithFormat:@"http://%@", domainString];
    }
    return nil;
}


static NSString *kTTAccountNetworkHttpInterfaceDebugKey = @"com.account.http_interface_debug.bytedance.org";

+ (NSString *)adaptDebugEnvURLString:(NSString *)originalUrlString
{
    if (!originalUrlString) return nil;
    
#ifdef DEBUG
    NSNumber *forceHttpNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAccountNetworkHttpInterfaceDebugKey];
    if (forceHttpNumber && [forceHttpNumber boolValue] ) {
        if ([originalUrlString hasPrefix:@"https://"]) {
            return [originalUrlString stringByReplacingOccurrencesOfString:@"https:" withString:@"http:"];
        }
    }
#endif
    return originalUrlString;
}

+ (NSString *)baseURL
{
    return [self.class adaptDebugEnvURLString:[self dynamicConfigURL] ? : tta_baseURLForKey(kTTANormalBaseURLDomainKey)];
}

+ (NSString *)channelBaseURL
{
    return [self.class adaptDebugEnvURLString:[self dynamicConfigURL] ? : tta_baseURLForKey(kTTAChannelBaseURLDomainKey)];
}

+ (NSString *)SNSBaseURL
{
    return [self.class adaptDebugEnvURLString:[self dynamicConfigURL] ? : tta_baseURLForKey(kTTASNSBaseURLDomainKey)];
}

+ (NSString *)securityURL
{
    return [self.class adaptDebugEnvURLString:[self dynamicConfigURL] ? : tta_baseURLForKey(kTTASecurityBaseURLDomainKey)];
}

+ (NSString *)HTTPSBaseURL
{
    NSString *urlString = [self securityURL];
    
#ifdef DEBUG
    return urlString;
#endif
    
    if ([urlString hasPrefix:@"https://"]) {
        return urlString;
    }
    return [urlString stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
}

+ (BOOL)version2
{
    return YES;
}

#pragma mark - Full URL

+ (NSString *)TTARegisterURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTARegisterURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAPhoneRegisterV2URLPathString]]
            );
}

+ (NSString *)TTAEmailLoginURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAEmailLoginURLPathString]];
}

+ (NSString *)TTAPhoneTokenLoginURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAPhoneTokenLoginURLPathString]];
}

+ (NSString *)TTALoginURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTALoginURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAPhonePWDLoginV2URLPathString]]
            );
}

+ (NSString *)TTAQuickLoginURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAQuickLoginURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAPhoneSMSLoginV2URLPathString]]
            );
}

+ (NSString *)TTALogoutURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTALogoutURLPathString]];
}

+ (NSString *)TTABindPhoneV1URLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTABindPhoneV1URLPathString]];
}

+ (NSString *)TTABindPhoneURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTABindPhoneURLPathString]];
}

+ (NSString *)TTAUnbindPhoneURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAUnbindPhoneURLPathString]];
}

+ (NSString *)TTAGetUserInfoURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAGetUserInfoURLPathString]];
}

+ (NSString *)TTAGetSMSCodeURLString
{
    return (
            ![self.class version2] ?
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAGetSMSCodeURLPathString]] :
            [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAGetSMSCodeV2URLPathString]]
            );
}

+ (NSString *)TTAValidateSMSCodeURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAValidateSMSCodeURLPathString]];
}

+ (NSString *)TTARefreshCaptchaURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTARefreshCaptchaURLPathString]];
}

+ (NSString *)TTAModifyPasswordURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAModifyPasswordURLPathString]];
}

+ (NSString *)TTAResetPasswordURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAResetPasswordURLPathString]];
}

+ (NSString *)TTAChangePhoneNumberURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAChangePhoneNumberURLPathString]];
}

+ (NSString *)TTACheckNameURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTACheckNameURLPathString]];
}

+ (NSString *)TTAGetUserAuditInfoURLString
{
    return [NSString stringWithFormat:@"%@%@", [self HTTPSBaseURL], [self TTAGetUserAuditInfoURLPathString]];
}

+ (NSString *)TTAUpdateUserProfileURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAUpdateUserProfileURLPathString]];
}

+ (NSString *)TTAUpdateUserExtraProfileURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAUpdateUserExtraProfileURLPathString]];
}

// Old: __deprecated
+ (NSString *)TTAUploadUserPhotoURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAUploadUserPhotoURLPathString]];
}

// New
+ (NSString *)TTAUploadUserImageURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAUploadUserImageURLPathString]];
}

+ (NSString *)TTAUploadUserBgImageURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTAUploadUserBgImageURLPathString]];
}

+ (NSString *)TTARequestNewSessionURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTARequestNewSessionURLPathString]];
}

+ (NSString *)TTALogoutThirdPartyPlatformURLString
{
    return [NSString stringWithFormat:@"%@%@", [self SNSBaseURL], [self TTALogoutThirdPartyPlatformURLPathString]];
}

#pragma mark - path of URL

+ (NSString *)TTARegisterURLPathString
{
    return (@"/user/mobile/register/v2/");
}

+ (NSString *)TTAEmailLoginURLPathString
{
    return (@"/user/auth/email_login/");
}

+ (NSString *)TTAPhoneTokenLoginURLPathString
{
    return (@"/user/mobile/token_login/");
}

+ (NSString *)TTALoginURLPathString
{
    return (@"/user/mobile/login/v2/");
}

+ (NSString *)TTAQuickLoginURLPathString
{
    return (@"/user/mobile/quick_login/");
}

+ (NSString *)TTALogoutURLPathString
{
    return (@"/passport/user/logout/");
}

+ (NSString *)TTABindPhoneV1URLPathString
{
    return (@"/user/mobile/bind_mobile/v1/");
}

+ (NSString *)TTABindPhoneURLPathString
{
    return (@"/user/mobile/bind_mobile/v2/");
}

+ (NSString *)TTAUnbindPhoneURLPathString
{
    return (@"/user/mobile/unbind_mobile/");
}

+ (NSString *)TTAGetUserInfoURLPathString
{
    return (@"/passport/user/info/");
}

+ (NSString *)TTAValidateSMSCodeURLPathString
{
    return (@"/user/mobile/validate_code/");
}

+ (NSString *)TTAGetSMSCodeURLPathString
{
    return (@"/user/mobile/send_code/v2/");
}

+ (NSString *)TTARefreshCaptchaURLPathString
{
    return (@"/user/refresh_captcha/");
}

+ (NSString *)TTAModifyPasswordURLPathString
{
    return (@"/user/mobile/change_password/");
}

+ (NSString *)TTAResetPasswordURLPathString
{
    return (@"/user/mobile/reset_password/");
}

+ (NSString *)TTAChangePhoneNumberURLPathString
{
    return (@"/user/mobile/change_mobile/");
}

+ (NSString *)TTACheckNameURLPathString
{
    return (@"/2/user/check_name/");
}

+ (NSString *)TTAGetUserAuditInfoURLPathString
{
    return (@"/user/profile/audit_info/");
}

+ (NSString *)TTAUpdateUserProfileURLPathString
{
    return (@"/2/user/update/v3/");
}

+ (NSString *)TTAUpdateUserExtraProfileURLPathString
{
    return (@"/user/profile/update_extra/");
}

+ (NSString *)TTAUploadUserPhotoURLPathString
{
    return (@"/2/user/upload_photo/");
}

+ (NSString *)TTAUploadUserImageURLPathString
{
    return (@"/2/user/upload_image/");
}

+ (NSString *)TTAUploadUserBgImageURLPathString
{
    return (@"/2/user/upload_bg_img/");
}

+ (NSString *)TTARequestNewSessionURLPathString
{
    return (@"/auth/chain_login/");
}

+ (NSString *)TTALogoutThirdPartyPlatformURLPathString
{
    return (@"/2/auth/logout/");
}

@end



@implementation TTAccountURLSetting (InterfaceV2)

+ (NSString *)TTAPhoneRegisterV2URLPathString
{
    return (@"/passport/mobile/register/");
}

+ (NSString *)TTAPhonePWDLoginV2URLPathString
{
    return (@"/passport/mobile/login/");
}

+ (NSString *)TTAPhoneSMSLoginV2URLPathString
{
    return (@"/passport/mobile/sms_login/");
}

+ (NSString *)TTAGetSMSCodeV2URLPathString
{
    return (@"/passport/mobile/send_code/");
}

@end
