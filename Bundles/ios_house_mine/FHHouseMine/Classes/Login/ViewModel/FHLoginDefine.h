//
//  FHLoginDefine.h
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate <NSObject>

#pragma mark - Action
///返回上一级VC
- (void)popLastViewController;

- (void)goToUserProtocol;

- (void)goToSecretProtocol;

/// 跳转手机登录，内部判断是否支持运营商一键登录，不支持跳转输入手机号界面
- (void)goToMobileLogin;

/// 跳转输入手机号界面
- (void)goToMobileInput;

/// 发送验证码
/// @param mobileNumber 手机号
/// @param needPush 需要跳转输入验证码页面 needPush:true 如果重新发送验证码:needPush:false
- (void)sendVerifyCode:(NSString *)mobileNumber needPush:(BOOL )needPush;

#pragma mark - Login

- (void)mobileLogin:(NSString *)mobileNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha;

/// 运营商一键登录
- (void)oneKeyLoginAction;

/// 苹果登录
- (void)appleLoginAction;

/// 抖音一键登录
- (void)awesomeLoginAction;

#pragma mark - Bind
- (void)bindCancelAction;

- (void)oneKeyBindAction;

- (void)mobileBind:(NSString *)mobileNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha;

//@optional
//- (void)acceptCheckBoxChange:(BOOL)selected;
//- (void)confirm;
/// 验证码
//- (void)verifyCodeLoginAction;

@end

typedef NS_ENUM(NSUInteger, FHLoginViewType) {
    FHLoginViewTypeOneKey = 0,
    FHLoginViewTypeMobile = 1,
    FHLoginViewTypeVerify = 2,
    FHLoginViewTypeDouYin = 3
};

typedef NS_ENUM(NSUInteger, FHLoginProcessType) {
    FHLoginProcessOrigin = 0, //线上策略，优先运营商一键登录 -> 手机号验证码登录
    FHLoginProcessTestA = 1, //优先运营商一键登录 -> 抖音一键登录 -> 手机号验证码登录
    FHLoginProcessTestB = 2, //优先抖音一键登录 -> 运营商一键登录 -> 手机号验证码登录
};

@interface FHLoginDefine : NSObject

@end

NS_ASSUME_NONNULL_END
