//
//  TTAccountMonitorDispatcher.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 30/07/2017.
//
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface TTAccountMonitorDispatcher : NSObject

/**
 *  收到账号相关网络请求响应通知
 *
 *  @params jsonObj     http请求返回的对象
 *  @params error       http请求返回的错误描述
 *  @params urlString   http请求URL String
 */
+ (void)dispatchHttpResp:(id _Nullable)jsonObj
                   error:(NSError * _Nullable)error
             originalURL:(NSString * _Nonnull)urlString;

/**
 *  收到会话过期通知
 *
 *  @params userIdString 登录过期用户的UserID
 *  @params error        过期错误描述
 *  @params urlString    收到登录过期通知的请求URL
 */
+ (void)dispatchSessionExpirationWithUser:(NSString * _Nonnull)userIdString
                                    error:(NSError * _Nullable)error
                              originalURL:(NSString * _Nonnull)urlString;

/**
 *  收到平台过期通知
 *
 *  @params userIdString 平台过期用户的UserID
 *  @params error        平台过期错误描述
 *  @params urlString    收到平台过期通知的请求URL
 */
+ (void)dispatchPlatformExpirationWithUser:(NSString * _Nonnull)userIdString
                                  platform:(NSString * _Nonnull)joinedPlatformString
                                     error:(NSError * _Nullable)error
                               originalURL:(NSString * _Nonnull)urlString;

/**
 *  登录过程中，收到串号通知（使用手机号登录）
 *
 *  规则：若登录手机号与返回后手机号不一致，认为是串号（局限性，仅适用于手机号登录情况）
 *
 *  @params userIdString        登录成功后的UserID
 *  @params userPhoneString     登录成功后的手机号
 *  @params inputtedPhoneString 登录使用的手机号
 *  @params urlString           http请求URL
 */
+ (void)dispatchLoginWrongUser:(NSString * _Nonnull)userIdString
                wrongUserPhone:(NSString * _Nullable)userPhoneString
                 originalPhone:(NSString * _Nullable)inputtedPhoneString
                   originalURL:(NSString * _Nonnull)urlString;
@end



/** 串号CASEs */
@interface TTAccountMonitorDispatcher (WrongUserHelper)

+ (BOOL)isWrongUserForOriginalPhone:(NSString *)originalPhoneString
                   loginedUserPhone:(NSString *)userPhoneString;

+ (BOOL)isWrongUserForOriginalEmail:(NSString *)emailString
                   loginedUserEmail:(NSString *)userEmailString;

@end

NS_ASSUME_NONNULL_END
