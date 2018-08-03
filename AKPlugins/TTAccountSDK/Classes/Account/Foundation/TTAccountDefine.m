//
//  TTAccountDefine.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/7/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountDefine.h"



NSString * const TTAccountErrorDomain
= @"toutiao.account.error.domain";
NSString * const TTAccountErrorKey
= @"toutiao.account.error";
NSString * const TTAccountStatusCodeKey
= @"toutiao.account.status_code";
NSString * const TTAccountErrMsgKey
= @"toutiao.account.errmsg_key";
NSString * const TTAccountAuthPlatformNameKey
= @"toutiao.account.auth_platform_name";
NSString * const TTAccountNotificationEventNameKey
= @"toutiao.account.event_name";



NSString *TTAccountStatusChangedReasonKey
= @"toutiao.account.status_changed_reason";



/**
 *  用户信息变更
 */
NSString * const TTAccountUserNameKey
= @"name";
NSString * const TTAccountUserPhoneKey
= @"mobile";
NSString * const TTAccountUserAvatarKey
= @"avatar";
NSString * const TTAccountUserBackgroundImageKey
= @"bg_image";
NSString * const TTAccountUserDescriptionKey
= @"description";
NSString * const TTAccountUserGenderKey
= @"gender";
NSString * const TTAccountUserBirthdayKey
= @"birthday";
NSString * const TTAccountUserProvinceKey
= @"province";
NSString * const TTAccountUserCityKey
= @"city";
NSString * const TTAccountUserIndustryKey
= @"industry";



#pragma mark -  error description

NSString *TTAccountGetErrorCodeDescription(TTAccountErrCode errcode)
{
    static NSDictionary<NSNumber *, NSString *> *errDespMapper;
    if (!errDespMapper) {
        errDespMapper = @{
                          @(TTAccountErrCodeUnknown)                        : @"未知错误",
                          @(TTAccountSuccess)                               : @"success",
                          
                          @(TTAccountErrCodeAuthCommon)                     : @"普通授权错误",
                          @(TTAccountErrCodeAuthURAppId)                    : @"没有注册AppID",
                          @(TTAccountErrCodeAuthUserCancel)                 : @"用户主动取消授权",
                          @(TTAccountErrCodeAuthSendFail)                   : @"发送授权请求失败",
                          @(TTAccountErrCodeAuthNetworkFail)                : @"网络错误",
                          @(TTAccountErrCodeAuthDeny)                       : @"授权失败",
                          @(TTAccountErrCodeAuthUnsupport)                  : @"平台不支持",
                          @(TTAccountErrCodeAuthCancelInstall)              : @"取消应用下载",
                          @(TTAccountErrCodeAuthCSRFAttack)                 : @"csrf攻击",
                          
                          @(TTAccountErrCodeClientParamsInvalid)            : @"客户端参数不合法",
                          @(TTAccountErrCodeUserNotLogin)                   : @"用户没有登录",
                          @(TTAccountErrCodeHasRegistered)                  : @"已注册",
                          @(TTAccountErrCodePhoneIsEmpty)                   : @"手机号为空",
                          @(TTAccountErrCodePhoneError)                     : @"手机号错误",
                          @(TTAccountErrCodeBindPhoneError)                 : @"手机号绑定错误",
                          @(TTAccountErrCodeUnbindPhoneError)               : @"解绑手机号错误",
                          @(TTAccountErrCodeBindPhoneNotExist)              : @"绑定不存在",
                          @(TTAccountErrCodePhoneHasBound)                  : @"该手机号已绑定",
                          @(TTAccountErrCodeUnregistered)                   : @"未注册",
                          @(TTAccountErrCodePasswordError)                  : @"密码错误",
                          @(TTAccountErrCodePasswordIsEmpty)                : @"密码为空",
                          @(TTAccountErrCodeUserNotExist)                   : @"用户不存在",
                          @(TTAccountErrCodePasswordAuthFailed)             : @"密码验证失败",
                          @(TTAccountErrCodeUserIdIsEmpty)                  : @"用户id为空",
                          @(TTAccountErrCodeEmailIsEmpty)                   : @"邮箱为空",
                          @(TTAccountErrCodeGetSMSCodeTypeError)            : @"获取验证码类型错误",
                          @(TTAccountErrCodeSMSCodeNotExistOrExpired)       : @"验证码不存在或已过期",
                          @(TTAccountErrCodeOneKeyLoginRetryLater)          : @"一键登录中稍后重试",
                          @(TTAccountErrCodeOneKeyLoginFailed)              : @"一键登录失败",
                          @(TTAccountErrCodeOneKeyLoginGetSMSCodeTimeout)   : @"一键登录获取短信超时",
                          @(TTAccountErrCodeOneKeyLoginSuccess)             : @"一键登录成功",
                          @(TTAccountErrCodeThirdPartyUnauthorized)         : @"未认证的第三方",
                          @(TTAccountErrCodeOneKeyLoginGetSMSCodeSuccess)   : @"一键登录验证码获取成功",
                          @(TTAccountErrCodeClientAuthParamIsEmpty)         : @"未传入认证client参数",
                          @(TTAccountErrCodeThirdSecretMissing)             : @"缺少第三方secret",
                          @(TTAccountErrCodeCaptchaMissing)                 : @"需要图片验证码 同时返回captcha的值",
                          @(TTAccountErrCodeCaptchaError)                   : @"图片验证码错误 同时返回新的captcha的值",
                          @(TTAccountErrCodeCaptchaExpired)                 : @"图片验证码失效 同时返回新的captcha的值",
                          
                          @(TTAccountErrCodeSMSCodeMissing)                 : @"缺少验证码",
                          @(TTAccountErrCodeSMSCodeError)                   : @"验证码错误",
                          @(TTAccountErrCodeSMSCodeExpired)                 : @"验证码过期",
                          @(TTAccountErrCodeSMSCodeTypeError)               : @"验证码类型错误",
                          @(TTAccountErrCodeSMSCodeSendError)               : @"验证码发送错误",
                          @(TTAccountErrCodeSMSCodeFreqError)               : @"验证码频率控制错误",
                          
                          @(TTAccountErrCodeNetworkFailure)                 : @"当前网络不可用，请稍后重试",
                          
                          @(TTAccountErrCodeServerDataFormatInvalid)        : @"数据出现问题，请稍后再试",
                          @(TTAccountErrCodeServerException     )           : @"服务异常，请稍后重试",
                          
                          @(TTAccountErrCodeAuthorizationFailed)            : @"用户验证失败，请重新登录",
                          @(TTAccountErrCodeSessionExpired      )           : @"帐号已过期，请重新登录",
                          @(TTAccountErrCodePlatformExpired     )           : @"第三方平台授权过期",
                          @(TTAccountErrCodeUserNotExisted      )           : @"用户不存在",
                          @(TTAccountErrCodeNameExisted         )           : @"name_existed",
                          @(TTAccountErrCodeMissingSessionKey   )           : @"Missing Session Key",
                          @(TTAccountErrCodeAccountBoundForbid  )           : @"此账号已存在绑定！为了保证账号安全，请您退出和原账号的绑定以继续。",
                          @(TTAccountErrCodeAuthPlatformBoundForbid)        : @"第三方账号绑定冲突，已有第三方授权账号绑定当前头条账号",
                          };
    }
    NSString *errDesp = [errDespMapper objectForKey:@(errcode)];
    return errDesp;
}
