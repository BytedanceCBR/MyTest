//
//  PhoneRegistrationManager.h
//  Article
//
//  Created by Dianwei on 14-7-4.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, PhoneRegistrationScenarioType)
{
    PhoneRegistrationScenarioRegister           = 1, // 注册
    PhoneRegistrationScenarioRegisterResend     = 2, //注册重发
    PhoneRegistrationScenarioFindPassword = 3, // 找回密码
    PhoneRegistrationScenarioFindPasswordResend = 4, // 找回密码重发
    PhoneRegistrationScenarioBind               = 5, //绑定
    PhoneRegistrationScenarioBindResend         = 6, // 绑定重发
    PhoneRegistrationScenarioCancelBind         = 7, // 取消绑定
    PhoneRegistrationScenarioCancelBindResend   = 8 // 取消绑定重发
};

@interface PhoneRegistrationManager : NSObject
- (void)startSendCodeWithPhoneNumber:(NSString*)phoneNumber
                             captcha:(NSString*)captcha
                                type:(PhoneRegistrationScenarioType)type
                         finishBlock:(void(^)(NSError *error, NSNumber *retryTime, UIImage *captcha))finishBlock;


- (void)startRegisterWithPhoneNumber:(NSString*)phoneNumber
                                code:(NSString*)code
                             captcha:(NSString*)captcha
                         finishBlock:(void(^)(NSError *error, UIImage *captcha))finishBlock;

- (void)startRefreshCaptchaWithFinishBlock:(void(^)(NSError *error, UIImage *captcha))finishBlock;


@end
