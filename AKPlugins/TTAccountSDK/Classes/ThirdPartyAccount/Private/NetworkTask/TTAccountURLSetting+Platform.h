//
//  TTAccountURLSetting+Platform.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/8/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountURLSetting.h"



NS_ASSUME_NONNULL_BEGIN

/**
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=15141286#OAUTH2授权登录-1.登录地址
 *         https://wiki.bytedance.net/pages/viewpage.action?pageId=52903405
 *         https://wiki.bytedance.net/pages/viewpage.action?pageId=53809581#id-用户登录相关API-WAPOAUTHAPI
 */
@interface TTAccountURLSetting (TTThirdPartyPlatform)

#pragma mark - Full URL

/** 使用第三方SDK(SNSSDK)进行第三方平台授权相关的接口 */
+ (NSString *)TTASNSSDKAuthCallbackURLString;

+ (NSString *)TTASNSSDKSwitchBindURLString;

/** 使用自定义WAP进行第三方平台授权相关的接口 */
+ (NSString *)TTACustomWAPLoginURLString;

+ (NSString *)TTACustomWAPLoginSuccessURLString;

+ (NSString *)TTACustomWAPLoginContinueURLString;

+ (NSString *)TTAShareAppToSNSPlatformURLString;


#pragma mark - URL Path

/** SNSSDK -- 第三方平台SDK */
/** 使用第三方平台自带SDK授权成功后，调用web服务端绑定头条用户信息的接口 */
+ (NSString *)TTASNSSDKAuthCallbackURLPathString;

/** 使用第三方平台自带SDK授权成功后，在和头条用户信息绑定时发现已经被绑定，进行解绑的接口 */
+ (NSString *)TTASNSSDKSwitchBindURLPathString;

/** 使用自定义WAP授权第三方平台时请求web服务器的接口 */
+ (NSString *)TTACustomWAPLoginURLPathString;

/** 使用自定义WAP授权第三方平台时，第三方平台调用的回调地址 */
+ (NSString *)TTACustomWAPLoginSuccessURLPathString;

/** 使用自定义WAP授权第三方平台时，可能出现已绑定的错误，此时用户授权已完成，所以用auth_token来保持用户授权状态，在用户做出选择后不用再次授权就可以登录 (解绑) */
+ (NSString *)TTACustomWAPLoginContinueURLPathString;

+ (NSString *)TTAShareAppToSNSPlatformURLPathString;

@end



@interface TTAccountURLSetting (PlatformInterfaceV2)

#pragma mark - URL PATH

//  第三方登录: 主要获取第三方wap授权页面
+ (NSString *)TTAPlatformAuthWapLoginV2URLPathString;

//  第三方登录
+ (NSString *)TTAPlatformAuthLoginV2URLPathString;

//  第三方绑定
+ (NSString *)TTAPlatformAuthBindV2URLPathString;

//  第三方平台登录或绑定时解绑接口
+ (NSString *)TTAPlatformAuthSwitchBindV2URLPathString;

@end

NS_ASSUME_NONNULL_END
