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

- (void)goToUserProtocol;

- (void)goToSecretProtocol;

//@optional
//- (void)acceptCheckBoxChange:(BOOL)selected;

/// 验证码登录
- (void)otherLoginAction;

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

@interface FHLoginDefine : NSObject

@end

NS_ASSUME_NONNULL_END
