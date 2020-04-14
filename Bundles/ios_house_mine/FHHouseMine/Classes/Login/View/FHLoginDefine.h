//
//  FHLoginDefine.h
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate <NSObject>

- (void)confirm;

- (void)sendVerifyCode;
- (void)quickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha;

- (void)goToUserProtocol;

- (void)goToSecretProtocol;

//@optional
//- (void)acceptCheckBoxChange:(BOOL)selected;

/// 验证码登录
- (void)verifyCodeLoginAction;

/// 运营商一键登录
- (void)oneKeyLoginAction;

/// 苹果登录
- (void)appleLoginAction;

/// 抖音一键登录
- (void)awesomeLoginAction;

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
