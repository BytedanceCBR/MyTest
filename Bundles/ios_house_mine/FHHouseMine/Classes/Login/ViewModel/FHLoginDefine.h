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
- (void)goToOneKeyLogin;

/// 跳转输入手机号界面
- (void)goToMobileLogin;

/// 跳转一键绑定界面 不支持一键绑定跳转手机号绑定界面


/// 跳转手机号绑定界面
- (void)goToMobileBind;

/// 发送验证码
/// @param mobileNumber 手机号
/// @param needPush 需要跳转输入验证码页面 needPush:true 如果重新发送验证码:needPush:false
/// @param isForBindMobile ture:绑定手机号发送验证码 false:手机号验证码登录发送验证码
- (void)sendVerifyCode:(NSString *)mobileNumber needPush:(BOOL )needPush isForBindMobile:(BOOL )isForBindMobile;

#pragma mark - Login
/// 运营商一键登录
- (void)oneKeyLoginAction;

/// 苹果登录
- (void)appleLoginAction;

/// 抖音一键登录
- (void)douyinLoginActionByIcon:(BOOL )isDouyinIcon;

- (void)mobileLogin:(NSString *)mobileNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha;

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

typedef NS_ENUM(NSUInteger, FHBindViewType) {
    FHBindViewTypeOneKey = 0,
    FHBindViewTypeMobile = 1,
    FHBindViewTypeVerify = 2,
};

typedef NS_ENUM(NSUInteger, FHLoginProcessType) {
    FHLoginProcessOrigin = 0, //线上策略，优先运营商一键登录 -> 手机号验证码登录
    FHLoginProcessTestA = 1, //优先运营商一键登录 -> 抖音一键登录 -> 手机号验证码登录
    FHLoginProcessTestB = 2, //优先抖音一键登录 -> 运营商一键登录 -> 手机号验证码登录
};

FOUNDATION_EXPORT NSString *const FHLoginTrackLastLoginMethodKey;
FOUNDATION_EXPORT NSString *const FHLoginTrackLoginSuggestMethodKey;

@interface FHLoginTrackHelper : NSObject

+ (void)loginShow:(NSDictionary *)dict;

+ (void)loginSubmit:(NSDictionary *)dict;

+ (void)loginResult:(NSDictionary *)dict error:(NSError *)error;

+ (void)loginMore:(NSDictionary *)dict;

+ (void)loginExit:(NSDictionary *)dict;

+ (void)loginPopup:(NSDictionary *)dict error:(NSError *)error;

+ (void)loginPopupClick:(NSDictionary *)dict error:(NSError *)error;

+ (void)bindShow:(NSDictionary *)dict;

+ (void)bindSubmit:(NSDictionary *)dict;

+ (void)bindResult:(NSDictionary *)dict error:(NSError *)error;

+ (void)bindExit:(NSDictionary *)dict;

+ (void)bindSendSMS:(NSDictionary *)dict error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
