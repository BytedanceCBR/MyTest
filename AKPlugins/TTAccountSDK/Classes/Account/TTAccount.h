//
//  TTAccount.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountDefine.h"
#import "TTAccountConfiguration.h"
#import <BDAccount/BDAccountSDK.h>
#if __has_include("TTAccountConfiguration+PlatformAccount.h")
#import "TTAccountConfiguration+PlatformAccount.h"
#endif



#define tta_IsLogin() ([[BDAccount sharedAccount] isLogin])

NS_ASSUME_NONNULL_BEGIN

/**
 *  1. 目前，收到服务端会话过期通知，会将用户登录状态置为FALSE
 *  2. 用户登出成功后，会清空cookie
 */
@interface TTAccount : NSObject
/**
 *  账号单例
 */
+ (TTAccount *)sharedAccount;

/**
 *  设置用户登录状态
 *
 *  @param  isLogin 登录状态
 */
- (void)setIsLogin:(BOOL)isLogin;

/**
 *  用户是否登录
 *
 *  @return  用户是否登录
 */
- (BOOL)isLogin;


/**
 *  设置头条平台SessionKey
 *
 *  @param  sessionKey 登录sessionKey
 */
- (void)setSessionKey:(NSString * _Nullable)sessionKey;

/**
 *  获取头条平台的SessionKey
 *
 *  @return  用户的登录sessionKey
 */
- (nullable NSString *)sessionKey;

/**
 *  返回字符串类型的用户ID
 *
 *  @return  头条用户ID字符串
 */
- (nullable NSString *)userIdString;

/**
 *  获取当前登录用户账号信息
 *
 *  @return  登录用户信息
 */
- (nullable TTAccountUserEntity *)user;

/**
 *  更新账号用户信息
 *
 *  @param  userEntity 用户信息
 */
- (void)setUser:(TTAccountUserEntity * _Nullable)userEntity;

/**
 *  获取指定的第三方账号
 *
 *  @param   platformName 第三方平台名称
 *  @return  第三方平台信息
 */
- (nullable TTAccountPlatformEntity *)connectedAccountForPlatform:(NSString * _Nonnull)platformName;

/**
 *  持久化用户信息
 */
- (void)persistence;

@end

#pragma mark - 账号SDK配置

@interface TTAccount (Configuration)
/**
 *  设置账号相关的配置参数
 *  若不手动设置将使用默认的配置
 */
@property (nonatomic, strong, class) TTAccountConfiguration *accountConf;

@end

#pragma mark - helper

@interface NSDictionary (AccountHelper)

- (BOOL)tta_boolForKey:(NSObject<NSCopying> *)key;

- (BOOL)tta_boolForEnumKey:(NSInteger)enumInt /** enumInt to @(enumInt) or @(enumInt).stringValue */;

- (NSString *)tta_stringForKey:(NSObject<NSCopying> *)key;

- (NSString *)tta_stringForEnumKey:(NSInteger)enumInt /** enumInt to @(enumInt) or @(enumInt).stringValue */;

@end

NS_ASSUME_NONNULL_END
