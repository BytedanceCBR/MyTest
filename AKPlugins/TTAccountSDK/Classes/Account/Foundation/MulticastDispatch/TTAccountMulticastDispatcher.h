//
//  TTAccountMulticastDispatcher.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 15/06/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountDefine.h"



NS_ASSUME_NONNULL_BEGIN

//
//  处理账号消息，先发送accountMessageFirstResponder，然后逐个广播TTAccountMulticastProtocol消息
//
@interface TTAccountMulticastDispatcher : NSObject

/**
 *  Dispatch 用户账号Profile发生变更
 *
 *  @param changedFields  用户信息变更字段
 *  @param error          错误描述
 *  @param bisectBlock    执行完firstResponder代理后回调
 */
+ (void)dispatchAccountProfileChanged:(NSDictionary * _Nonnull)changedFields
                                error:(NSError * _Nullable)error
                          bisectBlock:(void (^ _Nullable)(void))bisectBlock;

// 兼容老的版本
+ (void)dispatchAccountSessionExpired:(NSError * _Nonnull)error
                          bisectBlock:(void (^ _Nullable)(void))bisectBlock;

/**
 *  Dispatch 用户登录过期
 *
 *  @param userIdString 当前登录用户的ID
 *  @param error        过期错误描述；若当前是登录则userInfo中包含{@"user_id"(用户id): **}
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountSessionExpirationWithUser:(NSString * _Nonnull)userIdString
                                           error:(NSError * _Nonnull)error
                                     bisectBlock:(void (^ _Nullable)(void))bisectBlock;

/**
 *  Dispatch 登录成功
 *
 *  @param user         用户信息
 *  @param platformName 第三方授权平台名称
 *  @param reasonType   登录的方式
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountLoginSuccess:(TTAccountUserEntity * _Nonnull)user
                           platform:(NSString * _Nullable)platformName
                             reason:(TTAccountStatusChangedReasonType)reasonType
                        bisectBlock:(void (^ _Nullable)(void))bisectBlock;

+ (void)dispatchAccountLoginSuccess:(TTAccountUserEntity * _Nonnull)user
                           platform:(NSString * _Nullable)platformName
                             reason:(TTAccountStatusChangedReasonType)reasonType
                        bisectBlock:(void (^ _Nullable)(void))bisectBlock
                               wait:(BOOL)waitUntilMainThreadDone;

/**
 *  Dispatch 登出成功
 *
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountLogoutWithBisectBlock:(void (^ _Nullable)(void))bisectBlock;


/**
 *  Dispatch 成功获取用户信息
 *
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountGetUserInfoWithBisectBlock:(void (^ _Nullable)(void))bisectBlock;


/**
 *  Dispatch 账号绑定平台信息发生变更
 *
 *  @param platformName 第三方平台名
 *  @param error        错误描述，为空表示成功
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountLoginAuthPlatform:(NSString * _Nonnull)platformName
                                   error:(NSError * _Nullable)error
                             bisectBlock:(void (^ _Nullable)(void))bisectBlock;


/**
 *  Dispatch 解绑已绑定的账号平台信息
 *
 *  @param platformName 第三方平台名
 *  @param error        绑定错误描述，为空表示成功
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountLogoutAuthPlatform:(NSString * _Nonnull)platformName
                                    error:(NSError * _Nullable)error
                              bisectBlock:(void (^ _Nullable)(void))bisectBlock;


/**
 *  Dispatch 收到已绑定的账号平台过期通知
 *
 *  @param platformName 第三方平台名，多个平台拼接的字符串
 *  @param error        错误描述，若当前是登录则userInfo中包含{@"user_id"(用户id): **}
 *  @param bisectBlock  执行完firstResponder代理后回调
 */
+ (void)dispatchAccountExpireAuthPlatform:(NSString * _Nonnull)platformName
                                    error:(NSError * _Nullable)error
                              bisectBlock:(void (^ _Nullable)(void))bisectBlock;

@end

NS_ASSUME_NONNULL_END
