//
//  TTAccount+NetworkTasks.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "TTAccount.h"



NS_ASSUME_NONNULL_BEGIN

/**
 *  @Wiki:  https://wiki.bytedance.net/pages/viewpage.action?pageId=13961678
 */
@interface TTAccount (NetworkTasks)
#pragma mark - 手机号注册
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
+ (nullable id<TTAccountSessionTask>)registerWithPhone:(NSString * _Nonnull)phoneString
                                               SMSCode:(NSString * _Nonnull)codeString
                                              password:(NSString * _Nullable)passwordString
                                               captcha:(NSString * _Nullable)captchaString
                                            completion:(void(^)(UIImage * _Nullable captchaImage /* 图形验证码 */, NSError * _Nullable error))completedBlock;


#pragma mark - 使用邮箱和密码进行登录

/**
 *  使用邮箱和密码进行登录
 *
 *  @param  emailString     邮箱
 *  @param  passwordString  密码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  注册完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)loginWithEmail:(NSString * _Nonnull)emailString
                                           password:(NSString * _Nonnull)passwordString
                                            captcha:(NSString * _Nullable)captchaString
                                         completion:(void(^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - 使用手机号和密码进行登录
/**
 *  使用手机号和密码进行登录
 *
 *  @param  phoneString     手机号
 *  @param  passwordString  密码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  登录完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)loginWithPhone:(NSString * _Nonnull)phoneString
                                           password:(NSString * _Nonnull)passwordString
                                            captcha:(NSString * _Nullable)captchaString
                                         completion:(void(^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - 手机号验证码登录
/**
 *  使用手机号和验证码进行登录
 *
 *  @param  phoneString     手机号
 *  @param  codeString      验证码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  登录完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)quickLoginWithPhone:(NSString * _Nonnull)phoneString
                                                 SMSCode:(NSString * _Nonnull)codeString
                                                 captcha:(NSString * _Nullable)captchaString
                                              completion:(void(^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - 手机号和Token登录
/**
 *  使用手机号和token进行登录
 *
 *  @param  phoneString     手机号
 *  @param  tokenString     token
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  注册完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)loginWithPhone:(NSString * _Nonnull)phoneString
                                              token:(NSString * _Nonnull)tokenString
                                            captcha:(NSString * _Nullable)captchaString
                                         completion:(void(^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - 获取短信验证码[new]
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
+ (nullable id<TTAccountSessionTask>)sendSMSCodeWithPhone:(NSString * _Nullable)phoneString /* 某些类型从sessionid中取用户，然后取绑定的手机号 */
                                                  captcha:(NSString * _Nullable)captchaString
                                              SMSCodeType:(TTASMSCodeScenarioType)codeType
                                              unbindExist:(BOOL)unbind
                                               completion:(void(^)(NSNumber * _Nullable retryTime /* 过期时间 */, UIImage * _Nullable captchaImage /* 图形验证码 */, NSError * _Nullable error))completedBlock;


#pragma mark - 验证短信验证码
/**
 *  验证短信验证码
 *
 *  @param  codeString      短信验证码
 *  @param  codeType        验证码类型
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)validateSMSCode:(NSString * _Nonnull)codeString
                                         SMSCodeType:(TTASMSCodeScenarioType)codeType
                                             captcha:(NSString * _Nullable)captchaString
                                          completion:(void(^)(UIImage * _Nullable captchaImage /* 图形验证码 */, NSError * _Nullable error))completedBlock;


#pragma mark - 绑定手机号
/**
 *  绑定手机号
 *
 *  @param  phoneString     手机号
 *  @param  codeString      验证码
 *  @param  passwordString  密码（v1可空，v2以上强制需要）
 *  @param  captchaString   图形验证码
 *  @param  unbindExisted   YES，绑定过则先解绑再绑定，否则直接解绑（已绑定过则报错）
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)bindPhoneWithPhone:(NSString * _Nonnull)phoneString
                                                SMSCode:(NSString * _Nonnull)codeString
                                               password:(NSString * _Nullable)passwordString /* v1可空，v2以上强制需要 */
                                                captcha:(NSString * _Nullable)captchaString
                                                 unbind:(BOOL)unbindExisted
                                             completion:(void (^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - 解绑手机号
/**
 *  解绑绑定的手机号
 *
 *  @param  captchaString     图片验证码
 *  @param  completedBlock    解绑完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)unbindPhoneWithCaptcha:(NSString * _Nullable)captchaString
                                                 completion:(void (^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - reset password
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
+ (nullable id<TTAccountSessionTask>)resetPasswordWithPhone:(NSString * _Nonnull)phoneString
                                                    SMSCode:(NSString * _Nonnull)codeString
                                                   password:(NSString * _Nonnull)passwordString
                                                    captcha:(NSString * _Nullable)captchaString
                                                 completion:(void(^)(UIImage * _Nullable captchaImage /* 图形验证码 */, NSError * _Nullable error))completedBlock;


#pragma mark - modify password
/**
 *  修改密码
 *
 *  @param  passwordString  新的密码
 *  @param  codeString      短信验证码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)modifyPasswordWithNewPassword:(NSString * _Nonnull)passwordString
                                                           SMSCode:(NSString * _Nonnull)codeString
                                                           captcha:(NSString * _Nullable)captchaString
                                                        completion:(void(^)(UIImage * _Nullable captchaImage /* 图形验证码 */, NSError * _Nullable error))completedBlock;


#pragma mark - 修改手机号
/**
 *  修改用户手机号
 *
 *  @param  phoneString     新的手机号
 *  @param  codeString      短信验证码
 *  @param  captchaString   图形验证码
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)changePhoneNumber:(NSString * _Nonnull)phoneString
                                               SMSCode:(NSString * _Nonnull)codeString
                                               captcha:(NSString * _Nullable)captchaString
                                            completion:(void(^)(UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;


#pragma mark - 刷新图片验证码
/**
 *  刷新并获取新的图形验证码
 *
 *  codeType                验证码类型 （经和服务端确认不需要该参数）
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)refreshCaptchaWithCompletion:(void(^)(UIImage * _Nullable captchaImage /* 图形验证码 */, NSError * _Nullable error))completedBlock;


#pragma mark - 获取用户信息
/**
 *  获取用户信息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)getUserInfoWithCompletion:(void (^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 获取用户信息，不发送错误通知
/**
 *  获取用户信息，若收到会话过期不发送错误通知消息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)getUserInfoIgnoreDispatchWithCompletion:(void (^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 获取用户审核相关信息
/**
 *  获取用户审核相关信息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)getUserAuditInfoWithCompletion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 获取用户审核（PGC、UGC）相关信息，不发送错误通知
/**
 *  获取用户审核相关信息，若收到会话过期不发送错误通知消息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)getUserAuditInfoIgnoreDispatchWithCompletion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 上传用户图像
/**
 *  上传用户图像，返回URL
 *
 *  @param  photo           图片对象
 *  @param  progress        上传图片进度回调
 *  @param  completedBlock  上传图片完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)startUploadUserPhoto:(UIImage * _Nonnull)photo
                                                 progress:(NSProgress * _Nullable __autoreleasing * _Nullable)progress
                                               completion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;

/**
 *  上传图像接口，返回URI，并不会更新当前用户信息
 *
 *  @param  image           图片对象
 *  @param  progress        上传图片进度回调
 *  @param  completedBlock  上传图片完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)startUploadImage:(UIImage * _Nonnull)image
                                             progress:(NSProgress * __autoreleasing _Nullable * _Nullable)progress
                                           completion:(void(^)(TTAccountImageEntity * _Nullable imageEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 上传用户封面图
/**
 *  上传封面背景图
 *
 *  @param  image           图片对象
 *  @param  progress        上传图片进度回调
 *  @param  completedBlock  上传图片完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)startUploadUserBgImage:(UIImage * _Nonnull)image
                                                   progress:(NSProgress * _Nullable __autoreleasing * _Nullable)progress
                                                 completion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 检查用户是否合法
/**
 *  检查用户名是否冲突，并返回推荐的名字
 *
 *  @param  nameString      用户名字符串
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)checkUsername:(NSString * _Nonnull)nameString
                                        completion:(void(^)(NSString * _Nullable availableName, NSError * _Nullable error))completedBlock;


#pragma mark - 更新用户信息
/**
 *  更新用户信息
 *
 *  @param  dict            用户信息字段
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 *
 *  dict字段描述如下: {
 *      TTAccountUserNameKey: ***,
 *      TTAccountUserDescriptionKey: ***,
 *      TTAccountUserAvatarKey: ***,
 *  }
 *
 */
+ (nullable id<TTAccountSessionTask>)updateUserProfileWithDict:(NSDictionary * _Nonnull)dict
                                                    completion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;

/**
 *  更新用户信息
 *
 *  @param  dict            用户信息字段
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 *
 *  dict字段描述如下: {
 *          TTAccountUserGenderKey: ***,
 *          TTAccountUserBirthdayKey: ***,
 *          TTAccountUserProvinceKey: ***,
 *          TTAccountUserCityKey: ***,
 *          TTAccountUserIndustryKey: ***,
 *  }
 */
+ (nullable id<TTAccountSessionTask>)updateUserExtraProfileWithDict:(NSDictionary * _Nonnull)dict
                                                         completion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;


#pragma mark - 退出头条账号
/**
 *  退出当前登录账户
 *
 *  @param completedBlock   完成后的回调
 *  @return HTTP请求任务
 */

+ (nullable id<TTAccountSessionTask>)logout:(void(^)(BOOL success, NSError * _Nullable error))completedBlock;


#pragma mark - 注销F项目账号
/**
 *  退出当前登录账户
 *
 *  @param completedBlock   完成后的回调
 *  @return HTTP请求任务
 */

+ (nullable id<TTAccountSessionTask>)logoutAndClearCookie:(void(^)(BOOL success, NSError * _Nullable error))completedBlock;

#pragma mark - 退出【解绑】已绑定的第三方平台
/**
 *  退出绑定的第三方平台账号
 *
 *  @param platformName     第三方平台名称
 *  @param completedBlock   完成后的回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)logoutPlatform:(NSString * _Nonnull)platformName
                                         completion:(void(^)(BOOL success))completedBlock;


#pragma mark - 请求新的会话，用其他应用的session换取新的session给当前应用
/**
 *  用SessionKey和InstallId请求新的会话进行登录
 *
 *  @param  sessionKey     共享的SessionKey
 *  @param  installId      当前APP的InstallId
 *  @param  completedBlock 注册完成回调
 *  @return HTTP请求任务
 */
+ (nullable id<TTAccountSessionTask>)requestNewSessionWithSessionKey:(NSString * _Nonnull)sessionKey
                                                           installId:(NSString * _Nonnull)installId
                                                          completion:(void(^)(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error))completedBlock;
@end

NS_ASSUME_NONNULL_END
