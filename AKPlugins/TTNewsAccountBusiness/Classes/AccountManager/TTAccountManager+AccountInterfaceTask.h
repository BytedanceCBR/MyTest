//
//  TTAccountManager.h
//  Article
//
//  Created by liuzuopeng on 5/19/17.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountManager.h"



@interface TTAccountManager (AccountInterfaceTask)

+ (void)startRefreshCaptchaWithScenarioType:(TTASMSCodeScenarioType)scenarioType
                                 completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startSendCodeWithPhoneNumber:(NSString *)phoneString
                             captcha:(NSString *)captchaString
                                type:(TTASMSCodeScenarioType)scenarioType
                         unbindExist:(BOOL)unbind
                          completion:(void(^)(NSNumber *retryTime, UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startRegisterWithPhoneNumber:(NSString *)phoneString
                                code:(NSString *)codeString
                            password:(NSString *)passwordString
                             captcha:(NSString *)captchaString
                          completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startLoginWithPhoneNumber:(NSString *)phoneString
                         password:(NSString *)passwordString
                          captcha:(NSString *)captchaString
                       completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startLoginWithMail:(NSString *)mailString
                  password:(NSString *)passwordString
                   captcha:(NSString *)captchaString
                completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startQuickLoginWithPhoneNumber:(NSString *)phoneNumber
                                  code:(NSString *)codeString
                               captcha:(NSString *)captchaString
                            completion:(void(^)(UIImage *captchaImage, NSNumber *newUser, NSError *error))completedBlock;

+ (void)startResetPasswordWithPhoneNumber:(NSString *)phoneString
                                     code:(NSString *)codeString
                                 password:(NSString *)passwordString
                                  captcha:(NSString *)captchaString
                               completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startChangePasswordWithPassword:(NSString *)passwordString
                                   code:(NSString *)codeString
                                captcha:(NSString *)captchaString
                             completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startBindPhoneNumber:(NSString *)phoneString
                        code:(NSString *)codeString
                    password:(NSString *)passwordString
                     captcha:(NSString *)captchaString
                 unbindExist:(BOOL)unbindExist
                  completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startUnbindPhoneWithCode:(NSString *)codeString
                         captcha:(NSString *)captchaString
                      completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startChangePhoneNumber:(NSString *)phoneString
                          code:(NSString *)codeString
                       captcha:(NSString *)captchaString
                    completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock;

+ (void)startLogoutUserWithCompletion:(void(^)(BOOL success, NSError *error))completedBlock;

+ (void)startGetAccountUserInfoStatus:(BOOL)dispatchExpiration
                           completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

+ (void)startGetAccountUserAuditInfoStatus:(BOOL)dispatchExpiration
                                completion:(void (^)(TTAccountUserAuditSet *userAuditSet, NSError *error))completedBlock;

+ (void)startUploadUserPhoto:(UIImage *)image
                  completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

+ (void)startUploadUserImage:(UIImage *)image
                  completion:(void(^)(TTAccountImageEntity *imageEntity, NSError *error))completedBlock;

+ (void)startUpdateUserInfo:(NSDictionary *)profileDict
                 startBlock:(void (^)())startBlock
                 completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

@end



