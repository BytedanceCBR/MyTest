//
//  TTOAuthPlatformProtocol.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountAuthDefine.h"
#import "TTAccountAuthResponse.h"



NS_ASSUME_NONNULL_BEGIN


@protocol TTAccountAuthProtocol <NSObject>
@required
/**
 * 单例
 */
+ (instancetype)sharedInstance;

@required
/**
 *  请求登录
 *
 *  @param useCustomWap     是否使用自定义容器进行授权
 *  @param completedBlock   登录完成回调
 */
- (void)requestLoginByCustomWebView:(BOOL)useCustomWap
                         completion:(TTAccountAuthLoginCompletedBlock _Nullable)completedBlock;

/**
 *  请求登录
 *
 *  @param useCustomWap     是否使用自定义容器进行授权
 *  @param willLoginBlock   开始登录回调 （仅仅授权成功才调用该回调）
 *  @param completedBlock   登录完成回调
 */
- (void)requestLoginByCustomWebView:(BOOL)useCustomWap
                          willLogin:(TTAccountAuthWillLoginBlock _Nullable)willLoginBlock
                         completion:(TTAccountAuthLoginCompletedBlock _Nullable)completedBlock;

/**
 *  注销账户
 *
 *  @param completedBlock 登出完成回调
 */
- (void)requestLogout:(void(^)(BOOL success, NSError * _Nullable error))completedBlock;

/**
 *  使用AppID注册第三方平台
 */
+ (void)registerApp:(NSString * _Nonnull)appID;

/**
 *  打开第三方平台
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 *  第三方平台是否支持SSO登录
 */
+ (BOOL)isSupportSSO;

/**
 *  第三方平台是否支持Web SSO登录
 */
+ (BOOL)isSupportWebSSO;

/**
 *  是否支持不通过第三方平台SDK进行SSO授权登录
 */
+ (BOOL)isSupportCustomWebSSO;

/**
 *  是否安装第三方平台
 */
+ (BOOL)isAppInstalled;

/**
 *  是否App可使用的（安装且API支持）
 */
+ (BOOL)isAppAvailable;

/**
 *  第三方平台的版本
 */
+ (nonnull NSString *)currentVersion;

/**
 *  第三方APP Auth平台类型
 */
+ (TTAccountAuthType)platformType;

/**
 *  第三方Auth平台名称
 */
+ (nonnull NSString *)platformName;

/**
 *  第三方账号在头条系APP中的唯一标识（用于代替老的appID和platformName，老的方式使用appID和platformName来标识第三方账号在头条系APP中唯一性），以后将使用platformAppID来标识第三方账号在头条系APP中唯一性
 */
+ (nonnull NSString *)platformAppID;

/**
 *  显示的平台名称
 *
 *  当登录或解绑失败，显示Toast时使用
 */
+ (nonnull NSString *)displayName;

/**
 * 获取第三方APP在app store上的下载地址
 */
+ (nullable NSString *)getAppInstallUrl;

@end


NS_ASSUME_NONNULL_END
