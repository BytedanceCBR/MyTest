//
//  TTAccountPhoneRegistration.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/25/17.
//
//

#import "TTAccountPhoneRegistration.h"
#import "TTAModelling.h"
#import "TTAccountRespModel.h"
#import "TTAccountNetworkManager.h"
#import "TTAccount.h"
#import "TTAccountDraft.h"
#import "TTAccountUserEntity_Priv.h"
#import "NSString+TTAccountUtils.h"
#import "TTAccountURLSetting.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountLogDispatcher.h"
#import "TTAccountMonitorDispatcher.h"



@implementation TTAccountPhoneRegistration

#pragma mark - 手机号注册

+ (id<TTAccountSessionTask>)startRegisterWithPhone:(NSString *)phoneString
                                           SMSCode:(NSString *)codeString
                                          password:(NSString *)passwordString
                                           captcha:(NSString *)captchaString
                                        completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    // clear cookie
    // [TTAccountCookie clearAccountCookie];
    
    [TTAccountDraft setDraftPhone:phoneString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
    [params setValue:[passwordString tta_hexMixedString] forKey:@"password"];
    [params setValue:[@(TTASMSCodeScenarioPhoneRegisterSubmit).stringValue tta_hexMixedString] forKey:@"type"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTARegisterURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTARegisterRespModel *aModel = [TTARegisterRespModel tta_modelWithJSON:jsonObj];
        UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
        if (completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}


#pragma mark - 使用邮箱和密码登录

+ (id<TTAccountSessionTask>)startEmailLogin:(NSString *)emailString
                                   password:(NSString *)passwordString
                                    captcha:(NSString *)captchaString
                                 completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    // clear cookie
    // [TTAccountCookie clearAccountCookie];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[emailString tta_hexMixedString] forKey:@"email"];
    [params setValue:[passwordString tta_hexMixedString] forKey:@"password"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAEmailLoginURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUserRespModel *aModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        
        TTAccountStatusChangedReasonType reasonType = TTAccountStatusChangedReasonTypeEmailLogin;
        
        if (error || ![aModel isRespSuccess]) {
            if (completedBlock) {
                UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
                completedBlock(captchaImage, error);
            }
            
            // logger
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:reasonType platform:nil];
            
            return;
        }
        
        TTAccountUserEntity *user = [[TTAccountUserEntity alloc] initWithUserModel:aModel.data];
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
        
        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:reasonType bisectBlock:^{
            if (completedBlock) {
                completedBlock(nil, nil);
            }
        }];
        
        // logger
        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:reasonType platform:nil];
        
        // Monitor
        if ([TTAccountMonitorDispatcher isWrongUserForOriginalEmail:emailString loginedUserEmail:user.email]) {
            [TTAccountMonitorDispatcher dispatchLoginWrongUser:user.userIDString wrongUserPhone:user.email originalPhone:emailString originalURL:[TTAccountURLSetting TTAEmailLoginURLString]];
        }
    }];
}



#pragma mark - 使用手机号和token进行登录

+ (id<TTAccountSessionTask>)startTokenLoginWithPhone:(NSString *)phoneString
                                               token:(NSString *)tokenString
                                             captcha:(NSString *)captchaString
                                          completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    // clear cookie
    // [TTAccountCookie clearAccountCookie];
    
    [TTAccountDraft setDraftPhone:phoneString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[tokenString tta_hexMixedString] forKey:@"token"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAPhoneTokenLoginURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUserRespModel *aModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        
        TTAccountStatusChangedReasonType reasonType = TTAccountStatusChangedReasonTypeTokenLogin;
        
        if (error || ![aModel isRespSuccess]) {
            if (completedBlock) {
                UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
                completedBlock(captchaImage, error);
            }
            
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:reasonType platform:nil];
            
            return;
        }
        
        TTAccountUserEntity *user = [[TTAccountUserEntity alloc] initWithUserModel:aModel.data];
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
        
        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:reasonType bisectBlock:^{
            if (completedBlock) {
                completedBlock(nil, nil);
            }
        }];
        
        // logger
        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:reasonType platform:nil];
        
        // Monitor
        if ([TTAccountMonitorDispatcher isWrongUserForOriginalPhone:phoneString loginedUserPhone:user.mobile]) {
            [TTAccountMonitorDispatcher dispatchLoginWrongUser:user.userIDString wrongUserPhone:user.mobile originalPhone:phoneString originalURL:[TTAccountURLSetting TTAPhoneTokenLoginURLString]];
        }
    }];
}



#pragma mark - 手机号密码登录

+ (id<TTAccountSessionTask>)startLoginWithPhone:(NSString *)phoneString
                                       password:(NSString *)passwordString
                                        captcha:(NSString *)captchaString
                                     completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    // clear cookie
    // [TTAccountCookie clearAccountCookie];
    
    [TTAccountDraft setDraftPhone:phoneString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[passwordString tta_hexMixedString] forKey:@"password"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTALoginURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUserRespModel *aModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        
        TTAccountStatusChangedReasonType reasonType = TTAccountStatusChangedReasonTypePasswordLogin;
        
        if (error || ![aModel isRespSuccess]) {
            if (completedBlock) {
                UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
                completedBlock(captchaImage, error);
            }
            
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:reasonType platform:nil];
            
            return;
        }
        
        TTAccountUserEntity *user = [[TTAccountUserEntity alloc] initWithUserModel:aModel.data];
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
        
        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:reasonType bisectBlock:^{
            if (completedBlock) {
                completedBlock(nil, nil);
            }
        }];
        
        // logger
        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:reasonType platform:nil];
        
        // Monitor
        if ([TTAccountMonitorDispatcher isWrongUserForOriginalPhone:phoneString loginedUserPhone:user.mobile]) {
            [TTAccountMonitorDispatcher dispatchLoginWrongUser:user.userIDString wrongUserPhone:user.mobile originalPhone:phoneString originalURL:[TTAccountURLSetting TTALoginURLString]];
        }
    }];
}



#pragma mark - 手机号验证码登录

+ (id<TTAccountSessionTask>)startQuickLoginWithPhone:(NSString *)phoneString
                                             SMSCode:(NSString *)codeString
                                             captcha:(NSString *)captchaString
                                          completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    // clear cookie
    //    [TTAccountCookie clearAccountCookie];
    
    [TTAccountDraft setDraftPhone:phoneString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAQuickLoginURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUserRespModel *aModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        
        TTAccountStatusChangedReasonType reasonType = TTAccountStatusChangedReasonTypeSMSCodeLogin;
        
        if (error || ![aModel isRespSuccess]) {
            if (completedBlock) {
                UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
                completedBlock(captchaImage, error);
            }
            
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:reasonType platform:nil];
            
            return;
        }
        
        TTAccountUserEntity *user = [[TTAccountUserEntity alloc] initWithUserModel:aModel.data];
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
        
        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:reasonType bisectBlock:^{
            if (completedBlock) {
                completedBlock(nil, nil);
            }
        }];
        
        // logger
        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:reasonType platform:nil];
        
        // Monitor
        if ([TTAccountMonitorDispatcher isWrongUserForOriginalPhone:phoneString loginedUserPhone:user.mobile]) {
            [TTAccountMonitorDispatcher dispatchLoginWrongUser:user.userIDString wrongUserPhone:user.mobile originalPhone:phoneString originalURL:[TTAccountURLSetting TTAQuickLoginURLString]];
        }
    }];
}



#pragma mark - 获取手机短信验证码

+ (id<TTAccountSessionTask>)startGetSMSCodeWithOldPhone:(NSString *)oldPhoneString
                                               newPhone:(NSString *)newPhoneString
                                                captcha:(NSString *)captchaString
                                            SMSCodeType:(TTASMSCodeScenarioType)codeType
                                            unbindExist:(BOOL)unbind
                                             completion:(void(^)(NSNumber *retryTime /* 过期时间 */, UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[newPhoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[oldPhoneString tta_hexMixedString] forKey:@"old_mobile"];
    [params setValue:[@(codeType).stringValue tta_hexMixedString] forKey:@"type"];
    [params setValue:captchaString forKey:@"captcha"];
    [params setValue:@(unbind ? 1 : 0) forKey:@"unbind_exist"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAGetSMSCodeURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAGetSMSCodeRespModel *aModel = [TTAGetSMSCodeRespModel tta_modelWithJSON:jsonObj];
        NSNumber *retryTime   = aModel.data.retry_time;
        UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
        if (completedBlock) {
            completedBlock(retryTime, captchaImage, error);
        }
    }];
}



+ (id<TTAccountSessionTask>)startGetSMSCodeWithPhone:(NSString *)phoneString
                                             captcha:(NSString *)captchaString
                                         SMSCodeType:(TTASMSCodeScenarioType)codeType
                                         unbindExist:(BOOL)unbind
                                          completion:(void(^)(NSNumber *retryTime /* 过期时间 */, UIImage *captchaImage /* 图形验证码 */, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[@(codeType).stringValue tta_hexMixedString] forKey:@"type"];
    [params setValue:captchaString forKey:@"captcha"];
    [params setValue:@(unbind ? 1 : 0) forKey:@"unbind_exist"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAGetSMSCodeURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAGetSMSCodeRespModel *aModel = [TTAGetSMSCodeRespModel tta_modelWithJSON:jsonObj];
        NSNumber *retryTime   = aModel.data.retry_time;
        UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
        if (completedBlock) {
            completedBlock(retryTime, captchaImage, error);
        }
    }];
}



#pragma mark - validate SMS code
// 使用中发现该接口不支持mix_mode = 1
+ (id<TTAccountSessionTask>)startValidateSMSCode:(NSString *)codeString
                                     SMSCodeType:(TTASMSCodeScenarioType)codeType
                                   captchaString:(NSString *)captchaString
                                      completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:codeString forKey:@"code"];
    [params setValue:captchaString forKey:@"captcha"];
    [params setValue:@(codeType) forKey:@"type"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTAValidateSMSCodeURLString] params:params extraGetParams:@{@"mix_mode":@(0)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAValidateSMSCodeRespModel *aModel = [TTAValidateSMSCodeRespModel tta_modelWithJSON:jsonObj];
        if (completedBlock) {
            UIImage *captchaImage = [aModel.data.captcha tta_imageFromBase64String];
            completedBlock(captchaImage, error);
        }
    }];
}



#pragma mark - reset/find password

+ (id<TTAccountSessionTask>)startResetPasswordWithPhone:(NSString *)phoneString
                                                SMSCode:(NSString *)codeString
                                               password:(NSString *)passwordString
                                                captcha:(NSString *)captchaString
                                             completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[passwordString tta_hexMixedString] forKey:@"password"];
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAResetPasswordURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAResetPasswordRespModel *respModel = [TTAResetPasswordRespModel tta_modelWithJSON:jsonObj];
        
        if (![TTAccount accountConf] || [TTAccount accountConf].byFindPasswordLoginEnabled) {
            TTAccountStatusChangedReasonType reasonType = TTAccountStatusChangedReasonTypeFindPasswordLogin;
            
            if (error || ![respModel isRespSuccess]) {
                if (completedBlock) {
                    UIImage *captchaImage = [respModel.data.captcha tta_imageFromBase64String];
                    completedBlock(captchaImage, error);
                }
                
                // logger
                [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:reasonType platform:nil];
                
                return;
            }
            
            TTAccountUserEntity *user = [[TTAccountUserEntity alloc] initWithUserModel:respModel.data];
            if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
                [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
                [[TTAccount sharedAccount] setIsLogin:YES];
            }
#pragma clang diagnostic pop
            
            [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:reasonType bisectBlock:^{
                if (completedBlock) {
                    completedBlock(nil, nil);
                }
            }];
            
            // logger
            [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:reasonType platform:nil];
            
            // Monitor
            if ([TTAccountMonitorDispatcher isWrongUserForOriginalPhone:phoneString loginedUserPhone:user.mobile]) {
                [TTAccountMonitorDispatcher dispatchLoginWrongUser:user.userIDString wrongUserPhone:user.mobile originalPhone:phoneString originalURL:[TTAccountURLSetting TTAResetPasswordURLString]];
            }
            
        } else {
            UIImage *captchaImage = [respModel.data.captcha tta_imageFromBase64String];
            if (completedBlock) {
                completedBlock(captchaImage, error);
            }
        }
    }];
}



#pragma mark - modify password

+ (id<TTAccountSessionTask>)startModifyPasswordWithNewPassword:(NSString *)passwordString
                                                       SMSCode:(NSString *)codeString
                                                       captcha:(NSString *)captchaString
                                                    completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[passwordString tta_hexMixedString] forKey:@"password"];
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAModifyPasswordURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAModifyPasswordRespModel *respModel = [TTAModifyPasswordRespModel tta_modelWithJSON:jsonObj];
        UIImage *captchaImage = [respModel.data.captcha tta_imageFromBase64String];
        if (completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}



#pragma mark - 修改用户手机号

// 这个接口在Wiki上没有找到文档，直接参考头条主端
+ (id<TTAccountSessionTask>)startChangeUserPhone:(NSString *)phoneString
                                         SMSCode:(NSString *)codeString
                                         captcha:(NSString *)captchaString
                                      completion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTAChangePhoneNumberURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        UIImage *captchaImage = nil;
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)jsonObj;
            if ([[resultDict allKeys] containsObject:@"data"] &&
                [[resultDict valueForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = (NSDictionary *)[resultDict valueForKey:@"data"];
                NSString *captchaBase64String = [dataDict valueForKey:@"captcha"];
                if (captchaBase64String && [captchaBase64String isKindOfClass:[NSString class]]) {
                    captchaImage = [captchaString tta_imageFromBase64String];
                }
            }
        }
        
        if (!error && !captchaImage) {
            [TTAccountDraft setDraftPhone:phoneString];
            [TTAccount sharedAccount].user.mobile = phoneString;
            
            NSMutableDictionary *changedProfileFields = [NSMutableDictionary dictionaryWithCapacity:4];
            [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserPhone)];
            
            [TTAccountMulticastDispatcher dispatchAccountProfileChanged:changedProfileFields error:error bisectBlock:^{
                if (completedBlock) {
                    completedBlock(captchaImage, error);
                }
            }];
        } else {
            if (completedBlock) {
                completedBlock(captchaImage, error);
            }
        }
    }];
}



#pragma mark - 刷新图片验证码

+ (id<TTAccountSessionTask>)startRefreshCaptchaWithCompletion:(void(^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTARefreshCaptchaURLString] params:dict needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTARefreshCaptchaRespModel *respModel = [TTARefreshCaptchaRespModel tta_modelWithJSON:jsonObj];
        UIImage *captchaImage = [respModel.data.captcha tta_imageFromBase64String];
        if (completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}



#pragma mark - bind phone

+ (id<TTAccountSessionTask>)startBindPhone:(NSString *)phoneString
                                   SMSCode:(NSString *)codeString
                                  password:(NSString *)passwordString
                                   captcha:(NSString *)captchaString
                                    unbind:(BOOL)unbindExisted
                                completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[phoneString tta_hexMixedString] forKey:@"mobile"];
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
    [params setValue:[passwordString tta_hexMixedString] forKey:@"password"];
    [params setValue:captchaString forKey:@"captcha"];
    [params setValue:@(unbindExisted ? 1 : 0) forKey:@"unbind_exist"];
    
    NSString *urlString = ([passwordString length] > 0) ? [TTAccountURLSetting TTABindPhoneURLString] : [TTAccountURLSetting TTABindPhoneV1URLString];
    return [TTAccountNetworkManager getRequestForJSONWithURL:urlString params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTABindMobileRespModel *respMdl = [TTABindMobileRespModel tta_modelWithJSON:jsonObj];
        UIImage *captchaImage = [respMdl.data.captcha tta_imageFromBase64String];
        
        if (!error && !captchaImage) {
            TTAccountUserEntity *updatedUser = [[TTAccountUserEntity alloc] initWithUserModel:respMdl.data];
            if (updatedUser) {
                [[TTAccount sharedAccount] setUser:updatedUser];
                [[TTAccount sharedAccount] persistence];
                
                [TTAccountDraft setDraftPhone:phoneString];
                
                NSMutableDictionary *changedProfileFields = [NSMutableDictionary dictionaryWithCapacity:4];
                [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserPhone)];
                
                [TTAccountMulticastDispatcher dispatchAccountProfileChanged:changedProfileFields error:error bisectBlock:^{
                    if (completedBlock) {
                        completedBlock(captchaImage, error);
                    }
                }];
            }
        } else {
            if(completedBlock) {
                completedBlock(captchaImage, error);
            }
        }
    }];
}



#pragma mark - unbind phone

+ (id<TTAccountSessionTask>)startUnbindPhoneWithSMSCode:(NSString *)codeString
                                                captcha:(NSString *)captchaString
                                             completion:(void (^)(UIImage *captchaImage, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [params setValue:[codeString tta_hexMixedString] forKey:@"code"];
#pragma clang diagnostic pop
    [params setValue:captchaString forKey:@"captcha"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTAUnbindPhoneURLString] params:params extraGetParams:@{@"mix_mode":@(1)} needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUnbindMobileRespModel *respMdl = [TTAUnbindMobileRespModel tta_modelWithJSON:jsonObj];
        UIImage *captchaImage = [respMdl.data.captcha tta_imageFromBase64String];
        if(completedBlock) {
            completedBlock(captchaImage, error);
        }
    }];
}

@end
