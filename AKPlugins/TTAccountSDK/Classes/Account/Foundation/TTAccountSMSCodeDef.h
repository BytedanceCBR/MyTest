//
//  TTAccountSMSCodeDef.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 06/07/2017.
//
//

#ifndef TTAccountSMSCodeDef_h
#define TTAccountSMSCodeDef_h



#pragma mark - 短信验证码类型
/**
 *  名词解析
 *  1. 验证码/Captcha -- 图片验证码，用于反垃圾的
 *  2. 激活码/SMSCode -- 手机激活(验证)码，通过手机短信息发给用户的号码，可用于注册、绑定、解绑、修改密码等操作。
 *
 *  短信验证码请求类型
 *
 *  手机号注册各类事件码定义如下：每个api不一定全部包含相应的类型，实现api时请根据实际业务按类型进行处理
 *
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=13961678#id-
 */
typedef NS_ENUM(NSInteger, TTASMSCodeScenarioType) {
    TTASMSCodeScenarioPhoneRegister        = 1,  // 注册
    TTASMSCodeScenarioPhoneRegisterRetry   = 2,  // 注册重发
    TTASMSCodeScenarioPhoneRegisterSubmit  = 3,  // 注册提交
    TTASMSCodeScenarioForgetPassword       = 4,  // 找回密码(重置密码)
    TTASMSCodeScenarioFindPassword         = TTASMSCodeScenarioForgetPassword,
    TTASMSCodeScenarioForgetPasswordRetry  = 5,  // 找回密码重发
    TTASMSCodeScenarioFindPasswordRetry    = TTASMSCodeScenarioForgetPasswordRetry,
    TTASMSCodeScenarioForgetPasswordSubmit = 6,  // 找回密码提交
    TTASMSCodeScenarioFindPasswordSubmit   = TTASMSCodeScenarioForgetPasswordSubmit,
    TTASMSCodeScenarioPhoneLogin           = 7,  // 手机号验证码登录
    TTASMSCodeScenarioBindPhone            = 8,  // 绑定手机号
    TTASMSCodeScenarioBindPhoneRetry       = 9,  // 绑定手机号重发
    TTASMSCodeScenarioBindPhoneSubmit      = 10, // 绑定手机号提交
    TTASMSCodeScenarioCancelBindPhone      = 11, // 取消绑定
    TTASMSCodeScenarioCancelBindPhoneRetry = 12, // 取消绑定重发
    TTASMSCodeScenarioModifyPassword       = 13, // 修改密码请求
    TTASMSCodeScenarioChangePassword       = TTASMSCodeScenarioModifyPassword,
    TTASMSCodeScenarioModifyPasswordRetry  = 14, // 修改密码重发
    TTASMSCodeScenarioChangePasswordRetry  = TTASMSCodeScenarioModifyPasswordRetry,
    TTASMSCodeScenarioModifyPasswordSubmit = 15, // 修改密码提交
    TTASMSCodeScenarioChangePasswordSubmit = TTASMSCodeScenarioModifyPasswordSubmit,
    
    /**
     *  16 - 19被WAP占用
     *
     *  TTASMSCodeScenarioRegisterWap         = 16, // Wap/Web手机号注册
     *  TTASMSCodeScenarioBindMobileWap       = 17, // ap/Web手机号绑定
     *  TTASMSCodeScenarioRegisterNew         = 18, //
     *  TTASMSCodeScenarioLoginPasswordNotify = 19, // 首次注册下发登录密码，用于SDK一键登录
     */
    
    TTASMSCodeScenarioChangePhone               = 20, // 更换手机号
    TTASMSCodeScenarioChangePhoneRetry          = 21, // 更换手机号重发
    TTASMSCodeScenarioIdentityVerification      = 22, // 安全确认
    TTASMSCodeScenarioIdentityVerificationRetry = 23, // 安全确认重发
    TTASMSCodeScenarioQuickLogin                = 24, // 快速登录，如果没有注册，则注册新用户后登录
    TTASMSCodeScenarioQuickLoginRetry           = 25, // 快速登录重发
};



#endif /* TTAccountSMSCodeDef_h */
