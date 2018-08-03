//
//  TTAccountAuthLogger.h
//  TTAccountDemo
//
//  Created by liuzuopeng on 5/3/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountLogger.h"



NS_ASSUME_NONNULL_BEGIN

/**
 *  第三方登录埋点统计Protocol
 */
@protocol TTAccountAuthLoginLogger <TTAccountLogger>
@optional
/**
 *  第三方平台 SDK SSO授权成功（包括跳转APP和SDK内置WAP容器）
 *
 *  WeChat      支持SDK SSO    不支持SDK WebSSO
 *  Tencent     支持SDK SSO    支持SDK WebSSO
 *  TencentWB   不支持SDK SSO  不支持SDK WebSSO
 *  SinaWeibo   支持SDK SSO    支持SDK WebSSO
 *  TianYi      不支持SDK SSO  不支持SDK WebSSO
 *  DouYin      支持SDK SSO    不支持SDK WebSSO
 *  HuoShan     支持SDK SSO    不支持SDK WebSSO
 *
 * @param   NSInteger   第三方授权平台类型。参考 TTAccountAuthType
 * @param   respContext 一些具体的平台相关信息
 */
- (void)SDKAuthForPlatform:(NSInteger)platformType
 didSuccessWithRespContext:(NSDictionary * _Nullable)respContext;

/**
 *  第三方平台 SDK SSO授权失败（包括跳转APP和SDK内置WAP容器）
 *
 * @param   NSInteger   第三方授权平台类型。参考 TTAccountAuthType
 * @param   respContext 一些具体的平台相关信息
 */
- (void)SDKAuthForPlatform:(NSInteger)platformType
    didFailWithRespContext:(NSDictionary * _Nullable)respContext;

/**
 *  第三方平台 自定义Wap容器授权登录，授权成功
 *
 *  WeChat      不支持Custom Wap SSO
 *  Tencent     支持Custom Wap SSO
 *  TencentWB   支持Custom Wap SSO
 *  SinaWeibo   支持Custom Wap SSO
 *  TianYi      支持Custom Wap SSO
 *  DouYin      不支持Custom Wap SSO
 *  HuoShan     不支持Custom Wap SSO
 *
 * @param   NSInteger   第三方授权平台类型。参考 TTAccountAuthType
 * @param   respContext 一些具体的平台相关信息
 */
- (void)customWapAuthForPlatform:(NSInteger)platformType
       didSuccessWithRespContext:(NSDictionary * _Nullable)respContext;

/**
 *  第三方平台 自定义Wap容器授权登录，授权失败
 *
 * @param   NSInteger   第三方授权平台类型。参考 TTAccountAuthType
 * @param   respContext 一些具体的平台相关信息
 */
- (void)customWapAuthForPlatform:(NSInteger)platformType
          didFailWithRespContext:(NSDictionary * _Nullable)respContext;

/** 点击自定义WAP登录的SNSBar上Checkbox回调 */
- (void)customWapLoginDidTapSNSBarWithChecked:(BOOL)selected
                                  forPlatform:(NSInteger)type;


/** 自定义WAP授权登录第三方平台，第三方平台回调至客户端并重定向到服务端的回调 */
- (void)customWapAuthCallbackAndRedirectToURL:(NSString * _Nullable)urlString
                                  forPlatform:(NSInteger)platformType
                                        error:(NSError * _Nullable)error
                                      context:(NSDictionary * _Nullable)contextDict;
@end



/**
 *  与服务端交互相关埋点
 */
@protocol TTAccountAuthLoginCallbackLogger <TTAccountLogger>
@optional
/**
 *  第三方平台授权登录头条时，出现绑定头条账号错误（该三方平台帐号已绑定到头条另一个账号）
 */
- (void)accountAuthPlatformBoundForbidError;


/**
 *  放弃原账号AlertView
 */
- (void)dropOriginalAccountAlertViewDidCancel:(BOOL)cancelled
                                  forPlatform:(NSInteger)platformType;


/**
 *  切换绑定AlertView
 */
- (void)switchBindAlertViewDidCancel:(BOOL)cancelled
                         forPlatform:(NSInteger)platformType;


/**
 *  SDK SSO(WEB SSO)切换绑定完成回调接口
 */
- (void)SSOSwitchBindDidCompleteWithError:(NSError * _Nullable)error;


/**
 *  Custom WEB SSO换绑定完成回调接口
 */
- (void)customWebSSOSwitchBindDidCompleteWithError:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
