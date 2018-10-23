//
//  TTAccountReqModel.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountBaseModel.h"



/**
 *  名词解析
 *  1. 验证码/Captcha -- 图片验证码，用于反垃圾的
 *  2. 激活码/Code    -- 手机激活(验证)码，通过手机短信息发给用户的号码，可用于注册、绑定、解绑、修改密码等操作。
 *
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=13961678#id-
 *         https://wiki.bytedance.net/pages/viewpage.action?pageId=524948#id-享评SDK-获取当前登录用户的个人信息
 */
#pragma mark - Request Model
/**
 *  手机号注册
 */
@interface TTARegisterReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *phoneString;    // 手机号字符串
@property (nonatomic,   copy) NSString *passwordString; // 密码字符串
@property (nonatomic,   copy) NSString *captchaString;  // 图片验证码对应字符串
@property (nonatomic,   copy) NSString *SMSCodeString;  // 短信验证码
@property (nonatomic, assign) NSInteger SMSCodeType;    // 需要发送验证码的类型
@end



/**
 *  邮箱和密码进行登录
 */
@interface TTAEmailPasswordLoginReqModel : TTABaseReqModel
@property (nonatomic, copy) NSString *emailString;   // Email字符串
@property (nonatomic, copy) NSString *passwordString;// 密码字符串
@property (nonatomic, copy) NSString *captchaString; // 图片验证码对应字符串
@end



/**
 *  手机号和token进行一键登录
 */
@interface TTAPhoneTokenLoginReqModel : TTABaseReqModel
@property (nonatomic, copy) NSString *phoneString;   // 手机号字符串
@property (nonatomic, copy) NSString *tokenString;   // token字符串
@property (nonatomic, copy) NSString *captchaString; // 图片验证码对应字符串
@end



/**
 *  手机号和短信验证码进行登录，如果未注册则同时注册新账号
 */
@interface TTAPhoneCodeLoginReqModel : TTABaseReqModel
@property (nonatomic, copy) NSString *phoneString;   // 手机号字符串
@property (nonatomic, copy) NSString *SMSCodeString; // 验证码字符串
@property (nonatomic, copy) NSString *captchaString; // 图片验证码对应字符串
@end



/**
 *  手机号和密码进行登录
 */
@interface TTAPhonePasswordLoginReqModel : TTABaseReqModel
@property (nonatomic, copy) NSString *phoneString;    // 手机号字符串
@property (nonatomic, copy) NSString *passwordString; // 密码字符串
@property (nonatomic, copy) NSString *captchaString;  // 图片验证码对应字符串
@end



/**
 *  退出登录
 */
@interface TTALogoutReqModel : TTABaseReqModel
@end



/**
 *  解绑手机号
 */
@interface TTAUnbindMobileReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *SMSCodeString __deprecated; // 手机激活码
@property (nonatomic,   copy) NSString *captchaString; // 验证码【Optional】
@end



/**
 *  绑定手机号
 */
@interface TTABindMobileReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *phoneString;    // 手机号
@property (nonatomic,   copy) NSString *SMSCodeString;  // 手机激活码
@property (nonatomic,   copy) NSString *captchaString;  // 验证码

//  绑定手机号时，是否解绑手机号当前绑定关系，0表示不解绑，1表示解绑
@property (nonatomic, assign) NSInteger unbind_exist;   // 解绑已有账号
@end



/**
 *  获取短信验证码
 */
@interface TTAGetSMSCodeReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *phoneString;    // 手机号字符串
@property (nonatomic,   copy) NSString *oldPhoneString; // 老的手机号字符串
@property (nonatomic,   copy) NSString *captchaString;  // 图片验证码对应字符串
@property (nonatomic, assign) NSInteger SMSCodeType;    // 需要发送验证码的类型
@property (nonatomic, assign) BOOL unbind;              // 是否解绑
@end



/**
 *  验证短信验证码
 */
@interface TTAValidateSMSCodeReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *SMSCodeString;  // 短信验证码
@property (nonatomic,   copy) NSString *captchaString;  // 图片验证码对应字符串
@property (nonatomic, assign) NSInteger SMSCodeType;    // 需要发送短信验证码的类型
@end



/**
 *  获取登录用户的信息
 */
@interface TTAGetUserInfoReqModel : TTABaseReqModel
@end



/**
 *  刷新图片验证码
 */
@interface TTARefreshCaptchaReqModel : TTABaseReqModel
@property (nonatomic, assign) NSInteger SMSCodeType; // 需要发送验证码的类型
@end



/**
 *  修改密码
 */
@interface TTAModifyPasswordReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *passwordString; // 密码字符串
@property (nonatomic,   copy) NSString *captchaString;  // 图片验证码对应字符串
@property (nonatomic,   copy) NSString *SMSCodeString;
@end



/**
 *  重置密码
 */
@interface TTAResetPasswordReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *phoneString;    // 手机号字符串
@property (nonatomic,   copy) NSString *passwordString; // 密码字符串
@property (nonatomic,   copy) NSString *captchaString;  // 图片验证码对应字符串
@property (nonatomic,   copy) NSString *SMSCodeString;  // 激活码
@end



/**
 *  更新用户信息
 */
@interface TTAUpdateUserProfileReqModel : TTABaseReqModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *userDesp;
@property (nonatomic, copy) NSString *avatarImageURI;
@property (nonatomic, copy) NSString *bgImageURI;
@end



/**
 *  解绑（退出）已绑定的第三方平台
 */
@interface TTALogoutThirdPartyPlatformReqModel : TTABaseReqModel
@property (nonatomic, copy) NSString *platform; // 第三方平台名称
@end



/**
 *  请求新的会话
 */
@interface TTARequestNewSessionReqModel : TTABaseReqModel
/** 原应用 session_key. 用于获取登录用户信息, 设置到新的session里面 */
@property (nonatomic, copy) NSString *from_session_key;
/** 原应用 install_id, 用于后台记录来源信息 */
@property (nonatomic, copy) NSString *from_install_id;
@end
