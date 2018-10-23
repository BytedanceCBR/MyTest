//
//  TTAccountReqModel.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountReqModel.h"
#import "TTAccountRespModel.h"
#import "TTAccountURLSetting.h"
#import "NSString+TTAccountUtils.h"



#pragma mark - Request Model
/**
 *  手机号注册
 */
@implementation TTARegisterReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTARegisterURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)}; // mix_mode 表示是否采用加密方式
        self._response = NSStringFromClass([TTARegisterRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.phoneString tta_hexMixedString] forKey:@"mobile"];
    [dict setValue:[self.SMSCodeString tta_hexMixedString] forKey:@"code"];
    [dict setValue:[self.passwordString tta_hexMixedString] forKey:@"password"];
    [dict setValue:[@(self.SMSCodeType).stringValue tta_hexMixedString] forKey:@"type"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  邮箱和密码进行登录
 */
@implementation TTAEmailPasswordLoginReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTAEmailLoginURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAUserRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.emailString tta_hexMixedString] forKey:@"email"];
    [dict setValue:[self.passwordString tta_hexMixedString] forKey:@"password"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  手机号和token进行一键登录
 */
@implementation TTAPhoneTokenLoginReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTAPhoneTokenLoginURLString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAUserRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.phoneString tta_hexMixedString] forKey:@"mobile"];
    [dict setValue:[self.tokenString tta_hexMixedString] forKey:@"token"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  验证码登录(快速登录)
 */
@implementation TTAPhoneCodeLoginReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTAQuickLoginURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAUserRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.phoneString tta_hexMixedString] forKey:@"mobile"];
    [dict setValue:[self.SMSCodeString tta_hexMixedString] forKey:@"code"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  密码登录
 */
@implementation TTAPhonePasswordLoginReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTALoginURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAUserRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.phoneString tta_hexMixedString] forKey:@"mobile"];
    [dict setValue:[self.passwordString tta_hexMixedString] forKey:@"password"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  退出登录
 */
@implementation TTALogoutReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTALogoutURLPathString];
        self._method = @"GET";
        self._response = NSStringFromClass([TTALogoutRespModel class]);
    }
    return self;
}
@end



/**
 *  解绑手机号
 */
@implementation TTAUnbindMobileReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTAUnbindPhoneURLPathString];
        self._method   = @"GET";
        self._response = NSStringFromClass([TTAUnbindMobileRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [dict setValue:self.SMSCodeString forKey:@"code"];
#pragma clang diagnostic pop
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  绑定手机号
 */
@implementation TTABindMobileReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTABindPhoneURLPathString];
        self._method   = @"GET";
        self._response = NSStringFromClass([TTABindMobileRespModel class]);
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _unbind_exist = 0;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.phoneString forKey:@"mobile"];
    [dict setValue:self.SMSCodeString forKey:@"code"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    [dict setValue:@(self.unbind_exist) forKey:@"unbind_exist"];
    return dict;
}
@end



/**
 *  获取短信验证码
 */
@implementation TTAGetSMSCodeReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTAGetSMSCodeURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAGetSMSCodeRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.phoneString tta_hexMixedString] forKey:@"mobile"];
    [dict setValue:[self.oldPhoneString tta_hexMixedString] forKey:@"old_mobile"];
    [dict setValue:[@(self.SMSCodeType).stringValue tta_hexMixedString] forKey:@"type"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    [dict setValue:@(self.unbind) forKey:@"unbind_exist"];
    return dict;
}
@end



/**
 *  验证短信验证码
 */
@implementation TTAValidateSMSCodeReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host = [TTAccountURLSetting HTTPSBaseURL];
        self._uri  = [TTAccountURLSetting TTAValidateSMSCodeURLPathString];
        self._method = @"GET";
        self._response = NSStringFromClass([TTAValidateSMSCodeRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.SMSCodeString forKey:@"code"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    [dict setValue:@(self.SMSCodeType) forKey:@"type"];
    return dict;
}
@end



/**
 *  获取登录用户的信息
 */
@implementation TTAGetUserInfoReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTAGetUserInfoURLPathString];
        self._method   = @"GET";
        self._response = NSStringFromClass([TTAUserRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    return dict;
}
@end



/**
 *  刷新图片验证码
 */
@implementation TTARefreshCaptchaReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTARefreshCaptchaURLPathString];
        self._method   = @"GET";
        self._response = NSStringFromClass([TTARefreshCaptchaRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:@(self.SMSCodeType) forKey:@"type"];
    return dict;
}
@end



/**
 *  修改密码
 */
@implementation TTAModifyPasswordReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTAModifyPasswordURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAModifyPasswordRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.passwordString tta_hexMixedString] forKey:@"password"];
    [dict setValue:[self.SMSCodeString tta_hexMixedString] forKey:@"code"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  重置密码
 */
@implementation TTAResetPasswordReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host   = [TTAccountURLSetting HTTPSBaseURL];
        self._uri    = [TTAccountURLSetting TTAResetPasswordURLPathString];
        self._method = @"POST";
        self._additionGetParams = @{@"mix_mode":@(1)};
        self._response = NSStringFromClass([TTAResetPasswordRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:[self.phoneString tta_hexMixedString] forKey:@"mobile"];
    [dict setValue:[self.passwordString tta_hexMixedString] forKey:@"password"];
    [dict setValue:[self.SMSCodeString tta_hexMixedString] forKey:@"code"];
    [dict setValue:self.captchaString forKey:@"captcha"];
    return dict;
}
@end



/**
 *  更新用户信息
 */
@implementation TTAUpdateUserProfileReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTAUpdateUserProfileURLPathString];
        self._method   = @"POST";
        self._response = NSStringFromClass([TTAUpdateUserProfileRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.gender forKey:@"gender"];
    [dict setValue:self.birthday forKey:@"birthday"];
    [dict setValue:self.userDesp forKey:@"description"];
    [dict setValue:self.avatarImageURI forKey:@"avatar"];
    [dict setValue:self.bgImageURI forKey:@"bg_uri"];
    return dict;
}
@end



/**
 *  解绑（退出）已绑定的第三方平台
 */
@implementation TTALogoutThirdPartyPlatformReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTALogoutThirdPartyPlatformURLPathString];
        self._method   = @"GET";
        self._response = NSStringFromClass([TTALogoutThirdPartyPlatformRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.platform forKey:NSStringFromSelector(@selector(platform))];
    return dict;
}
@end



/**
 *  请求新的会话
 */
@implementation TTARequestNewSessionReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting SNSBaseURL];
        self._uri      = [TTAccountURLSetting TTARequestNewSessionURLPathString];
        self._method   = @"POST";
        self._response = NSStringFromClass([TTARequestNewSessionRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.from_session_key forKey:NSStringFromSelector(@selector(from_session_key))];
    [dict setValue:self.from_install_id forKey:NSStringFromSelector(@selector(from_install_id))];
    return dict;
}
@end
