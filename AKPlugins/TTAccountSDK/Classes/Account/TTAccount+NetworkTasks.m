//
//  TTAccount+Networks.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccount+NetworkTasks.h"
#import "TTAccountPhoneRegistration.h"
#import "TTAccountLogoutTask.h"
#import "TTAccountUserProfileTask.h"
#import "TTAccountNewSessionTask.h"



@implementation TTAccount (NetworkTasks)

+ (id<TTAccountSessionTask>)registerWithPhone:(NSString *)phoneString
                                      SMSCode:(NSString *)codeString
                                     password:(NSString *)passwordString
                                      captcha:(NSString *)captchaString
                                   completion:(void(^)(UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startRegisterWithPhone:phoneString SMSCode:codeString password:passwordString captcha:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)loginWithEmail:(NSString *)emailString
                                  password:(NSString *)passwordString
                                   captcha:(NSString *)captchaString
                                completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startEmailLogin:emailString password:passwordString captcha:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)loginWithPhone:(NSString *)phoneString
                                  password:(NSString *)passwordString
                                   captcha:(NSString *)captchaString
                                completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startLoginWithPhone:phoneString password:passwordString captcha:captchaString completion:^(UIImage *captchaImage, NSError *error) {
        if (completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}

+ (id<TTAccountSessionTask>)quickLoginWithPhone:(NSString *)phoneString
                                        SMSCode:(NSString *)codeString
                                        captcha:(NSString *)captchaString
                                     completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startQuickLoginWithPhone:phoneString SMSCode:codeString captcha:captchaString completion:^(UIImage *captchaImage, NSError *error) {
        if (completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}

+ (id<TTAccountSessionTask>)loginWithPhone:(NSString *)phoneString
                                     token:(NSString *)tokenString
                                   captcha:(NSString *)captchaString
                                completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startTokenLoginWithPhone:phoneString token:tokenString captcha:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)bindPhoneWithPhone:(NSString *)phoneString
                                       SMSCode:(NSString *)codeString
                                      password:(NSString *)passwordString
                                       captcha:(NSString *)captchaString
                                        unbind:(BOOL)unbindExisted
                                    completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startBindPhone:phoneString SMSCode:codeString password:passwordString captcha:captchaString unbind:unbindExisted completion:completedBlock];
}

+ (id<TTAccountSessionTask>)unbindPhoneWithCaptcha:(NSString *)captchaString
                                        completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startUnbindPhoneWithSMSCode:nil captcha:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)sendSMSCodeWithPhone:(NSString *)phoneString
                                         captcha:(NSString *)captchaString
                                     SMSCodeType:(TTASMSCodeScenarioType)codeType
                                     unbindExist:(BOOL)unbind
                                      completion:(void(^)(NSNumber *retryTime /* 过期时间 */, UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startGetSMSCodeWithPhone:phoneString captcha:captchaString SMSCodeType:codeType unbindExist:unbind completion:completedBlock];
}

+ (id<TTAccountSessionTask>)validateSMSCode:(NSString *)codeString
                                SMSCodeType:(TTASMSCodeScenarioType)codeType
                                    captcha:(NSString *)captchaString
                                 completion:(void(^)(UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startValidateSMSCode:codeString SMSCodeType:codeType captchaString:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)resetPasswordWithPhone:(NSString *)phoneString
                                           SMSCode:(NSString *)codeString
                                          password:(NSString *)passwordString
                                           captcha:(NSString *)captchaString
                                        completion:(void(^)(UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startResetPasswordWithPhone:phoneString SMSCode:codeString password:passwordString captcha:captchaString completion:completedBlock];
}

/**
 *  测试发现：retryTime后，仍然修改密码成功
 */
+ (id<TTAccountSessionTask>)modifyPasswordWithNewPassword:(NSString *)passwordString
                                                  SMSCode:(NSString *)codeString
                                                  captcha:(NSString *)captchaString
                                               completion:(void(^)(UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startModifyPasswordWithNewPassword:passwordString SMSCode:codeString captcha:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)changePhoneNumber:(NSString *)phoneString
                                      SMSCode:(NSString *)codeString
                                      captcha:(NSString *)captchaString
                                   completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startChangeUserPhone:phoneString SMSCode:codeString captcha:captchaString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)refreshCaptchaWithCompletion:(void(^)(UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    return [TTAccountPhoneRegistration startRefreshCaptchaWithCompletion:completedBlock];
}

+ (id<TTAccountSessionTask>)getUserInfoWithCompletion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startGetUserInfoWithCompletion:completedBlock];
}

+ (id<TTAccountSessionTask>)getUserInfoIgnoreDispatchWithCompletion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startGetUserInfoIgnoreDispatchWithCompletion:completedBlock];
}

+ (id<TTAccountSessionTask>)getUserAuditInfoWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startGetUserAuditInfoWithCompletion:completedBlock];
}

+ (id<TTAccountSessionTask>)getUserAuditInfoIgnoreDispatchWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startGetUserAuditInfoIgnoreDispatchWithCompletion:completedBlock];
}

+ (id<TTAccountSessionTask>)startUploadUserPhoto:(UIImage *)photo
                                        progress:(NSProgress * __autoreleasing *)progress
                                      completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [TTAccountUserProfileTask startUploadUserPhoto:photo progress:progress completion:completedBlock];
#pragma clang diagnostic pop
}

+ (id<TTAccountSessionTask>)startUploadImage:(UIImage *)image
                                    progress:(NSProgress * __autoreleasing *)progress
                                  completion:(void(^)(TTAccountImageEntity *imageEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startUploadImage:image progress:progress completion:completedBlock];
}

+ (nullable id<TTAccountSessionTask>)startUploadUserBgImage:(UIImage *)image
                                                   progress:(NSProgress * __autoreleasing *)progress
                                                 completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startUploadBgImage:image progress:progress completion:completedBlock];
}

+ (id<TTAccountSessionTask>)checkUsername:(NSString *)nameString
                               completion:(void(^)(NSString *availableName, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startCheckName:nameString completion:completedBlock];
}

+ (id<TTAccountSessionTask>)updateUserProfileWithDict:(NSDictionary *)dict
                                           completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startUpdateUserProfileWithDict:dict completion:completedBlock];
}

+ (id<TTAccountSessionTask>)updateUserExtraProfileWithDict:(NSDictionary *)dict
                                                completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountUserProfileTask startUpdateUserExtraProfileWithDict:dict completion:completedBlock];
}

+ (id<TTAccountSessionTask>)logout:(void(^)(BOOL success, NSError *error))completedBlock
{
    return [TTAccountLogoutTask requestLogout:^(BOOL success, NSError *error) {
        if (completedBlock) {
            completedBlock(success, error);
        }
    }];
}

#pragma mark - 解绑第三方账号

+ (id<TTAccountSessionTask>)logoutPlatform:(NSString *)platformName
                                completion:(void(^)(BOOL success))completedBlock
{
    return [TTAccountLogoutTask requestLogoutPlatform:platformName completion:^(BOOL success, NSError *error) {
        if (completedBlock) {
            completedBlock(success && !error);
        }
    }];
}

+ (id<TTAccountSessionTask>)requestNewSessionWithSessionKey:(NSString *)sessionKey
                                                  installId:(NSString *)installId
                                                 completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountNewSessionTask requestNewSessionWithSessionKey:sessionKey installId:installId completion:^(TTAccountUserEntity *userEntity, NSError *error) {
        if (completedBlock) {
            completedBlock(userEntity, error);
        }
    }];
}

@end
