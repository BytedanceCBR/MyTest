//
//  TTAccountURLSetting.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 10/19/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface TTAccountURLSetting : NSObject

#pragma mark - BASE URL

+ (NSString *)SNSBaseURL;

+ (NSString *)HTTPSBaseURL;

+ (BOOL)version2;

#pragma mark - FULL URL
//  手机号注册
+ (NSString *)TTARegisterURLString;

//  Email登录
+ (NSString *)TTAEmailLoginURLString;

//  手机号和Token登录
+ (NSString *)TTAPhoneTokenLoginURLString;

//  手机号验证码登录（快速登录）
+ (NSString *)TTAQuickLoginURLString;

//  手机号密码登录
+ (NSString *)TTALoginURLString;

//  退出登录
+ (NSString *)TTALogoutURLString;

//  绑定手机号V1
+ (NSString *)TTABindPhoneV1URLString;

//  绑定手机号
+ (NSString *)TTABindPhoneURLString;

//  解绑手机号
+ (NSString *)TTAUnbindPhoneURLString;

//  获取用户信息
+ (NSString *)TTAGetUserInfoURLString;

//  刷新图片验证码
+ (NSString *)TTARefreshCaptchaURLString;

//  获取短信验证码
+ (NSString *)TTAGetSMSCodeURLString;

//  验证短信接口
+ (NSString *)TTAValidateSMSCodeURLString;

//  修改密码
+ (NSString *)TTAModifyPasswordURLString;

//  重置密码
+ (NSString *)TTAResetPasswordURLString;

//  修改手机号
+ (NSString *)TTAChangePhoneNumberURLString;

//  检查用户名
+ (NSString *)TTACheckNameURLString;

//  获取用户审核信息
+ (NSString *)TTAGetUserAuditInfoURLString;

//  更新用户Profile
+ (NSString *)TTAUpdateUserProfileURLString;

//  更新用户Extra Profile字段（province, city, birthday, gender）
+ (NSString *)TTAUpdateUserExtraProfileURLString;

//  上传用户照片
+ (NSString *)TTAUploadUserPhotoURLString;

+ (NSString *)TTAUploadUserImageURLString;

//  上传用户封面背景图
+ (NSString *)TTAUploadUserBgImageURLString;

//  请求新的回话
+ (NSString *)TTARequestNewSessionURLString;

//  解绑第三方平台
+ (NSString *)TTALogoutThirdPartyPlatformURLString;

#pragma mark - path of URL

//  手机号注册
+ (NSString *)TTARegisterURLPathString;

//  Email登录
+ (NSString *)TTAEmailLoginURLPathString;

//  手机号和Token登录
+ (NSString *)TTAPhoneTokenLoginURLPathString;

//  快速登录（验证码登录）
+ (NSString *)TTAQuickLoginURLPathString;

//  密码登录
+ (NSString *)TTALoginURLPathString;

//  退出登录
+ (NSString *)TTALogoutURLPathString;

//  绑定手机号V1接口
+ (NSString *)TTABindPhoneV1URLPathString;

//  绑定手机号
+ (NSString *)TTABindPhoneURLPathString;

//  解绑手机号
+ (NSString *)TTAUnbindPhoneURLPathString;

//  获取登录用户的信息
+ (NSString *)TTAGetUserInfoURLPathString;

//  刷新图片验证码
+ (NSString *)TTARefreshCaptchaURLPathString;

//  验证短信验证码
+ (NSString *)TTAValidateSMSCodeURLPathString;

//  获取短信验证码
+ (NSString *)TTAGetSMSCodeURLPathString;

//  修改密码
+ (NSString *)TTAModifyPasswordURLPathString;

//  重置密码
+ (NSString *)TTAResetPasswordURLPathString;

//  修改用户手机号
+ (NSString *)TTAChangePhoneNumberURLPathString;

//  检查用户名
+ (NSString *)TTACheckNameURLPathString;

//  获取用户审核信息
+ (NSString *)TTAGetUserAuditInfoURLPathString;

//  更新用户Profile
+ (NSString *)TTAUpdateUserProfileURLPathString;

//  更新用户Extra字段（province, city, birthday, gender）
+ (NSString *)TTAUpdateUserExtraProfileURLPathString;

//  上传用户照片
+ (NSString *)TTAUploadUserPhotoURLPathString;

//  上传用户图像（NEW)
+ (NSString *)TTAUploadUserImageURLPathString;

//  上传用户封面背景图
+ (NSString *)TTAUploadUserBgImageURLPathString;

//  请求新的回话
+ (NSString *)TTARequestNewSessionURLPathString;

//  解绑第三方账号
+ (NSString *)TTALogoutThirdPartyPlatformURLPathString;

@end



@interface TTAccountURLSetting (InterfaceV2)

#pragma mark - URL Path

//  手机号注册接口
+ (NSString *)TTAPhoneRegisterV2URLPathString;

//  手机号密码登录接口
+ (NSString *)TTAPhonePWDLoginV2URLPathString;

//  验证码登录接口
+ (NSString *)TTAPhoneSMSLoginV2URLPathString;

//  手机号发送验证码接口
+ (NSString *)TTAGetSMSCodeV2URLPathString;

@end

NS_ASSUME_NONNULL_END
