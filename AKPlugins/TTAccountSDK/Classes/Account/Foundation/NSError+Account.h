//
//  NSError+Account.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface NSError (Account)

/**
 session_expired: 回话过期
 
 @return 是回话过期错误返回YES，否则返回NO
 */
- (BOOL)isSessionExpired;


/**
 expired_platform: 平台过期
 
 @return 是平台过期错误返回YES，否则返回NO
 */
- (BOOL)isPlatformExpired;


/**
 connect_switch：当前账号绑定冲突，第三方账号已绑定头条其他账号

 @return 是当前账号冲突返回YES，否则返回NO
 */
- (BOOL)isLoginAccountConflict;


/**
  connect_exist：第三方授权账号绑定冲突，已有第三方授权账号绑定过头条当前账号

 @return 是第三方账号冲突返回YES，否则返回NO
 */
- (BOOL)isAuthAccountConflict;


/**
 login_failed/auth_failed：第三方账号授权登录或绑定失败
 
 @return 授权失败返回YES，否则返回NO
 */
- (BOOL)isAuthFailed;


/**
 是否服务端进行302重定向

 @return 重定向返回YES，否则返回NO
 */
- (BOOL)isRedirectURL;


/**
 服务端或服务端返回数据错误

 @return 服务端错误返回YES，否则返回NO
 */
- (BOOL)isServerError;


/**
 客户端数据缺失或异常错误
 
 @return 客户端错误返回YES，否则返回NO
 */

- (BOOL)isClientError;


/**
 网络错误（连接异常、超时等）

 @return 是网络错误返回YES，否则返回NO
 */
- (BOOL)isNetworkError;

@end

NS_ASSUME_NONNULL_END
