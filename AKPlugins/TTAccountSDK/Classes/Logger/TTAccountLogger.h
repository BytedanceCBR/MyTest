//
//  TTAccountLogger.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountDefine.h"



@protocol TTAccountLogger <NSObject>
@optional

/**
 *  登录成功
 *
 *  @param reasonType   成功登录方式
 *  @param platformName 第三方授权平台名称
 */
- (void)accountLoginSuccess:(TTAccountStatusChangedReasonType)reasonType
                   platform:(NSString *)platformName;

/**
 *  登录失败
 *
 *  @param reasonType   登录失败原因
 *  @param platformName 第三方授权平台名称
 */
- (void)accountLoginFailure:(TTAccountStatusChangedReasonType)reasonType
                   platform:(NSString *)platformName;

/**
 *  登录会话过期
 *
 *  @param error    错误描述
 *  @param userIDString 当前登录用户的UserID，存在表示当前是登录否则非登录（异常点）
 */
- (void)accountSessionExpired:(NSError *)error
                   withUserID:(NSString *)userIDString;

/**
 *  平台过期
 *
 *  @param error    错误描述
 *  @param joinedPlatformString 过期的平台，可能包括多个由逗号分隔
 */
- (void)accountPlatformExpired:(NSError *)error
                  withPlatform:(NSString *)joinedPlatformString;

/**
 *  退出成功
 */
- (void)accountLogoutSuccess;

/**
 *  退出失败
 */
- (void)accountLogoutFailure;

@end
