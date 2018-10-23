//
//  TTAccountManager+AccountInterfaceTask.m
//  Article
//
//  Created by liuzuopeng on 28/05/2017.
//
//

#import "TTAccountManager+AccountInterfaceTask.h"
#import "TTAccountManager+HTSAccountBridge.h"



@implementation TTAccountManager (AccountInterfaceTask)

+ (void)startSendCodeWithPhoneNumber:(NSString *)phoneString
                             captcha:(NSString *)captchaString
                                type:(TTASMSCodeScenarioType)scenarioType
                         unbindExist:(BOOL)unbind
                          completion:(void(^)(NSNumber *retryTime, UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount sendSMSCodeWithPhone:phoneString captcha:captchaString SMSCodeType:scenarioType unbindExist:unbind completion:completedBlock];
}

+ (void)startRegisterWithPhoneNumber:(NSString *)phoneString
                                code:(NSString *)codeString
                            password:(NSString *)passwordString
                             captcha:(NSString *)captchaString
                          completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount registerWithPhone:phoneString SMSCode:codeString password:passwordString captcha:captchaString completion:completedBlock];
}

+ (void)startLoginWithPhoneNumber:(NSString *)phoneString
                         password:(NSString *)passwordString
                          captcha:(NSString *)captchaString
                       completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount loginWithPhone:phoneString password:passwordString captcha:captchaString completion:completedBlock];
}

+ (void)startLoginWithMail:(NSString *)mailString
                  password:(NSString *)passwordString
                   captcha:(NSString *)captchaString
                completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount loginWithEmail:mailString password:passwordString captcha:captchaString completion:completedBlock];
}

+ (void)startQuickLoginWithPhoneNumber:(NSString *)phoneNumber
                                  code:(NSString *)codeString
                               captcha:(NSString *)captchaString
                            completion:(void(^)(UIImage *captchaImage, NSNumber *newUser, NSError *error))completedBlock
{
    [TTAccount quickLoginWithPhone:phoneNumber SMSCode:codeString captcha:captchaString completion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error) {
        if (completedBlock) {
            completedBlock(captchaImage, @([[TTAccount sharedAccount] user].newUser), error);
        }
    }];
}

+ (void)startResetPasswordWithPhoneNumber:(NSString *)phoneString
                                     code:(NSString *)codeString
                                 password:(NSString *)passwordString
                                  captcha:(NSString *)captchaString
                               completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount resetPasswordWithPhone:phoneString SMSCode:codeString password:passwordString captcha:captchaString completion:completedBlock];
}

+ (void)startChangePasswordWithPassword:(NSString *)passwordString
                                   code:(NSString *)codeString
                                captcha:(NSString *)captchaString
                             completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount modifyPasswordWithNewPassword:passwordString SMSCode:codeString captcha:captchaString completion:completedBlock];
}

+ (void)startBindPhoneNumber:(NSString *)phoneString
                        code:(NSString *)codeString
                    password:(NSString *)passwordString
                     captcha:(NSString *)captchaString
                 unbindExist:(BOOL)unbindExist
                  completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount bindPhoneWithPhone:phoneString SMSCode:codeString password:passwordString captcha:captchaString unbind:unbindExist completion:completedBlock];
}

+ (void)startUnbindPhoneWithCode:(NSString *)codeString
                         captcha:(NSString *)captchaString
                      completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount unbindPhoneWithCaptcha:captchaString completion:completedBlock];
}

+ (void)startChangePhoneNumber:(NSString *)phoneString // new phone number
                          code:(NSString *)codeString
                       captcha:(NSString *)captchaString
                    completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount changePhoneNumber:phoneString SMSCode:codeString captcha:captchaString completion:completedBlock];
}

+ (void)startLogoutUserWithCompletion:(void(^)(BOOL success, NSError *error))completedBlock
{
    [TTAccount logout:^(BOOL success, NSError * _Nullable error) {
        if (completedBlock) {
            completedBlock(success, error);
        }
    }];
}

+ (void)startRefreshCaptchaWithScenarioType:(TTASMSCodeScenarioType)scenarioType
                                 completion:( void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    [TTAccount refreshCaptchaWithCompletion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error) {
        if (completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}

+ (void)startGetAccountUserInfoStatus:(BOOL)dispatchExpiration
                           completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    if (dispatchExpiration) {
        [TTAccount getUserInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            if (!error) {
                // TODO...
            }
            
            if (completedBlock) {
                completedBlock(userEntity, error);
            }
        }];
    } else {
        [TTAccount getUserInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            if (!error) {
                // TODO...
            }
            
            if (completedBlock) {
                completedBlock(userEntity, error);
            }
        }];
    }
}

+ (void)startGetAccountUserAuditInfoStatus:(BOOL)dispatchExpiration
                                completion:(void (^)(TTAccountUserAuditSet *userAuditSet, NSError *error))completedBlock
{
    if (dispatchExpiration) {
        [TTAccount getUserAuditInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            if (completedBlock) {
                completedBlock(!error ? userEntity.auditInfoSet : nil, error);
            }
        }];
    } else {
        [TTAccount getUserAuditInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            if (completedBlock) {
                completedBlock(!error ? userEntity.auditInfoSet : nil, error);
            }
        }];
    }
}

+ (void)startUploadUserPhoto:(UIImage *)image
                  completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    [TTAccount startUploadUserPhoto:image progress:nil completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
        if (completedBlock) {
            completedBlock(userEntity, error);
        }
    }];
}

+ (void)startUploadUserImage:(UIImage *)image
                  completion:(void(^)(TTAccountImageEntity *imageEntity, NSError *error))completedBlock
{
    if (!image || ![image isKindOfClass:[UIImage class]]) {
        if (completedBlock) {
            completedBlock(nil, [NSError errorWithDomain:TTAccountErrorDomain
                                                    code:TTAccountErrCodeClientParamsInvalid
                                                userInfo:@{NSLocalizedDescriptionKey: @"图片为空或格式不正确"}]);
        }
        return;
    }
    
    [TTAccount startUploadImage:image progress:nil completion:completedBlock];
}

+ (void)startUpdateUserInfo:(NSDictionary *)profileDict
                 startBlock:(void (^)())startBlock
                 completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    if (startBlock) {
        startBlock ();
    }
    
    [TTAccount updateUserProfileWithDict:profileDict completion:^(TTAccountUserEntity *userEntity, NSError *error) {
        if (completedBlock) {
            completedBlock(userEntity, error);
        }
    }];
}

@end
