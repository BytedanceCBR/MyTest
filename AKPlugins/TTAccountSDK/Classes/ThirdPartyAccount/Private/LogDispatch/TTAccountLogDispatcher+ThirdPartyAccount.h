//
//  TTAccountLogDispatcher+ThirdPartyAccount.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 13/06/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountLogDispatcher.h"
#import "TTAccountAuthDefine.h"



@interface TTAccountLogDispatcher (AuthPlatformAccount)

/**
 *  第三方平台授权完成（成功或失败）
 */
+ (void)dispatchAccountAuthPlatform:(NSInteger)platformType
                          bySDKAuth:(BOOL)isSDKAuth
                            success:(BOOL)success
                            context:(NSDictionary *)contextInfo;


/**
 *  点击自定义Wap授权弹窗中SNSBar
 */
+ (void)dispatchDidTapCustomWapSNSBarWithChecked:(BOOL)selected
                                     forPlatform:(NSInteger)platformType;


/**
 *  自定义Wap授权登录，重定向snssdk**://回调
 */
+ (void)dispatchCustomWapAuthCallbackAndRedirectToURL:(NSString *)urlString
                                          forPlatform:(NSInteger)platformType
                                                error:(NSError *)error
                                              context:(NSDictionary *)extraDict;


/**
 *  第三方平台登录时出现已绑定，需要解绑错误
 */
+ (void)dispatchAccountAuthPlatformBoundForbidError;


/**
 *  放弃原账号AlertView
 */
+ (void)dispatchDropOriginalAccountAlertViewDidCancel:(BOOL)cancelled
                                          forPlatform:(NSInteger)platformType;


/**
 *  切换绑定AlertView
 */
+ (void)dispatchSwitchBindAlertViewDidCancel:(BOOL)cancelled
                                 forPlatform:(NSInteger)platformType;


/**
 *  SDK SSO(WEB SSO)切换绑定完成回调接口
 */
+ (void)dispatchSSOSwitchBindDidCompleteWithError:(NSError *)error;


/**
 *  Custom WEB SSO换绑定完成回调接口
 */
+ (void)dispatchCustomWebSSOSwitchBindDidCompleteWithError:(NSError *)error;

@end
