//
//  TTAccountPhoneRegistration.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/25/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "TTAccountDefine.h"



@interface TTAccountPhoneRegistration : NSObject
/**
 *  使用手机号注册新账号
 *
 *  @param  phoneString     手机号
 *  @param  codeString      短信验证码
 *  @param  passwordString  密码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  注册完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startRegisterWithPhone:(NSString *)phoneString
                                           SMSCode:(NSString *)codeString
                                          password:(NSString *)passwordString
                                           captcha:(NSString *)captchaString
                                        completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;

/**
 *  使用邮箱和密码进行登录
 *
 *  @param  emailString     邮箱
 *  @param  passwordString  密码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  注册完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startEmailLogin:(NSString *)emailString
                                   password:(NSString *)passwordString
                                    captcha:(NSString *)captchaString
                                 completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  使用手机号和token进行登录
 *
 *  @param  phoneString     手机号
 *  @param  tokenString     token
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  注册完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startTokenLoginWithPhone:(NSString *)phoneString
                                               token:(NSString *)tokenString
                                             captcha:(NSString *)captchaString
                                          completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  使用手机号和密码进行登录
 *
 *  @param  phoneString     手机号
 *  @param  passwordString  密码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  登录完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startLoginWithPhone:(NSString *)phoneString
                                       password:(NSString *)passwordString
                                        captcha:(NSString *)captchaString
                                     completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  使用手机号和验证码进行登录
 *
 *  @param  phoneString     手机号
 *  @param  codeString      验证码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  登录完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startQuickLoginWithPhone:(NSString *)phoneString
                                             SMSCode:(NSString *)codeString
                                             captcha:(NSString *)captchaString
                                          completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  获取短信认证码【Deprecated】
 *
 *  @param  oldPhoneString  旧手机号
 *  @param  newPhoneString  新手机号
 *  @param  captchaString   图形验证码
 *  @param  codeType        验证码类型
 *  @param  unbind          是否解绑已有的绑定关系（0不解绑，1解绑）
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startGetSMSCodeWithOldPhone:(NSString *)oldPhoneString
                                               newPhone:(NSString *)newPhoneString
                                                captcha:(NSString *)captchaString
                                            SMSCodeType:(TTASMSCodeScenarioType)codeType
                                            unbindExist:(BOOL)unbind
                                             completion:(void(^)(NSNumber *retryTime /* 过期时间 */, UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock __deprecated_msg("Method deprecated. Use `startGetSMSCodeWithPhone:captcha:SMSCodeType:unbindExist:completion:`");


/**
 *  获取短信认证码【New】
 *
 *  @param  phoneString     新手机号
 *  @param  captchaString   图形验证码
 *  @param  codeType        验证码类型
 *  @param  unbind          是否解绑已有的绑定关系（0不解绑，1解绑）
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startGetSMSCodeWithPhone:(NSString *)phoneString
                                             captcha:(NSString *)captchaString
                                         SMSCodeType:(TTASMSCodeScenarioType)codeType
                                         unbindExist:(BOOL)unbind
                                          completion:(void(^)(NSNumber *retryTime /* 过期时间 */, UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock;



/**
 *  验证短信验证码
 *
 *  @param  codeString      短信验证码
 *  @param  codeType        验证码类型
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startValidateSMSCode:(NSString *)codeString
                                     SMSCodeType:(TTASMSCodeScenarioType)codeType
                                   captchaString:(NSString *)captchaString
                                      completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  重置密码/找回密码
 *
 *  @param  phoneString     手机号
 *  @param  codeString      短信验证码
 *  @param  passwordString  密码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startResetPasswordWithPhone:(NSString *)phoneString
                                                SMSCode:(NSString *)codeString
                                               password:(NSString *)passwordString
                                                captcha:(NSString *)captchaString
                                             completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  修改密码
 *
 *  @param  passwordString  新的密码
 *  @param  codeString      短信验证码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startModifyPasswordWithNewPassword:(NSString *)passwordString
                                                       SMSCode:(NSString *)codeString
                                                       captcha:(NSString *)captchaString
                                                    completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  修改用户手机号
 *
 *  @param  phoneString     新的手机号
 *  @param  codeString      短信验证码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startChangeUserPhone:(NSString *)phoneString
                                         SMSCode:(NSString *)codeString
                                         captcha:(NSString *)captchaString
                                      completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  刷新并获取新的图形验证码
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startRefreshCaptchaWithCompletion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  绑定手机号. 密码为空使用V1接口，否则使用V2接口
 *
 *  @param  phoneString     手机号
 *  @param  codeString      验证码
 *  @param  passwordString  密码（v1可空，v2以上强制需要）
 *  @param  captchaString   图形验证码
 *  @param  unbindExisted   YES，绑定过则先解绑再绑定，否则直接解绑（已绑定过则报错）
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startBindPhone:(NSString *)phoneString
                                   SMSCode:(NSString *)codeString
                                  password:(NSString *)passwordString
                                   captcha:(NSString *)captchaString
                                    unbind:(BOOL)unbindExisted
                                completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;


/**
 *  解绑绑定的手机号
 *
 *  @param  captchaString     图片验证码
 *  @param  completedBlock    解绑完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startUnbindPhoneWithSMSCode:(NSString *)codeString
                                                captcha:(NSString *)captchaString
                                             completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;


@end
