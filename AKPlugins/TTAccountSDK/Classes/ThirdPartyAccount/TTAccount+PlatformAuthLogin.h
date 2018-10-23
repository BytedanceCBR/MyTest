//
//  TTAccount+PlatformAuthLogin.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/9/17.
//
//

#import "TTAccount.h"
#import "TTAccountAuthDefine.h"
#import "TTAccountAuthProtocol.h"
#import "TTAccountPlatformConfiguration.h"



NS_ASSUME_NONNULL_BEGIN


@interface TTAccount (PlatformAuthLogin)

#pragma mark - register

/**
 * 注册第三方平台配置，注册后不需要调用registerAppId:forPlatform:，默认会选择懒加载注册第三方APP。
 * 可通过TTAccountPlatformConfiguration的属性bootOptimization来关闭启动性能优化
 *
 * @param platformConf  第三方平台配置信息
 */
+ (void)registerPlatform:(TTAccountPlatformConfiguration *)platformConf;

/**
 * 一次性注册多个第三方平台配置
 *
 * @param platformConfs  第三方平台配置信息
 */
+ (void)registerPlatforms:(NSArray<TTAccountPlatformConfiguration *> *)platformConfs;

/**
 * 动态注册第三方平台账号登录服务
 *
 * @param cls  第三方平台账号Class对象
 */
+ (void)registerAuthAccount:(Class<TTAccountAuthProtocol> _Nonnull)cls;

#pragma mark - handle URL

/**
 * 需要在application:openURL:sourceApplication:annotation:或者application:handleOpenURL(9.0)中调用。
 *
 * @attention 必须在主线程中调用
 *
 * @param url 第三方应用打开APP时传递过来的URL
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL * _Nonnull)url;


#pragma mark - login/logout

/**
 * 向第三方平台请求授权登录，优先选择使用SDK SSO授权登录
 *
 * @param type              第三方平台类型
 * @param completedBlock    登录完成后的回调
 */
+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                     completion:(TTAccountLoginCompletedBlock _Nullable)completedBlock;

/**
 * 使用platformType登录第三方平台应用账号
 *
 * @param type              第三方平台类型
 * @param useCustomWap      是否使用自定义包装的容器授权登录
 * @param completedBlock    登录完成后的回调
 */
+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                inCustomWebView:(BOOL)useCustomWap
                     completion:(TTAccountLoginCompletedBlock _Nullable)completedBlock;

/**
 * 向第三方平台请求授权登录，优先选择使用SDK SSO授权登录
 *
 * @param type              第三方平台类型
 * @param willLoginBlock    授权成功，开始登录回调
 * @param completedBlock    登录完成后的回调
 */
+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                      willLogin:(void (^_Nullable)(NSString *_Nonnull))willLoginBlock
                     completion:(TTAccountLoginCompletedBlock _Nullable)completedBlock;

/**
 * 使用platformType登录第三方平台应用账号
 *
 * @param type              第三方平台类型
 * @param useCustomWap      是否使用自定义包装的容器授权登录
 * @param willLoginBlock    授权成功，开始登录回调
 * @param completedBlock    登录完成后的回调
 */
+ (void)requestLoginForPlatform:(TTAccountAuthType)type
                inCustomWebView:(BOOL)useCustomWap
                      willLogin:(void (^_Nullable)(NSString *_Nonnull))willLoginBlock
                     completion:(TTAccountLoginCompletedBlock _Nullable)completedBlock;


/**
 * 使用platformName登录第三方平台应用账号
 *
 * @param type              第三方平台类型
 * @param completedBlock    登出完成后回调
 */
+ (void)requestLoginForPlatformName:(NSString * _Nonnull)platformName
                         completion:(TTAccountLoginCompletedBlock _Nullable)completedBlock;

/**
 * 使用platformName登录第三方平台应用账号
 *
 * @param type              第三方平台类型
 * @param useCustomWap      是否使用自定义包装的容器授权登录
 * @param completedBlock    登录完成后的回调
 */
+ (void)requestLoginForPlatformName:(NSString * _Nonnull)platformName
                    inCustomWebView:(BOOL)useCustomWap
                         completion:(TTAccountLoginCompletedBlock _Nullable)completedBlock;

/**
 * 使用platformType登出第三方绑定账号向第三方应用请求登出
 *
 * @param type              第三方平台类型
 * @param completedBlock    登出完成后回调
 */
+ (void)requestLogoutForPlatform:(TTAccountAuthType)type
                      completion:(void (^)(BOOL success, NSError * _Nullable error))completedBlock;

/**
 * 使用platformName登出第三方绑定账号
 *
 * @param type              第三方平台类型
 * @param completedBlock    登出完成后回调
 */
+ (void)requestLogoutForPlatformName:(NSString * _Nonnull)platformName
                          completion:(void (^)(BOOL success, NSError * _Nullable error))completedBlock;

#pragma mark - Platform Info

/**
 * 获取平台名称对应类型
 *
 * @param   platformName 第三方账号在头条对应的应用名称
 * @return  返回平台类型
 */
+ (TTAccountAuthType)accountAuthTypeForPlatform:(NSString * _Nonnull)platformName;

/**
 * 获取平台类型的名称
 *
 * @param   type 第三方平台类型
 * @return  返回平台名称
 */
+ (nullable NSString *)platformNameForAccountAuthType:(TTAccountAuthType)type;

/**
 * 获取第三方平台在头条平台的platformAppId
 *
 * @param   type 第三方平台类型
 * @return  返回平台APPID
 */
+ (nullable NSString *)platformAppIdForAccountAuthType:(TTAccountAuthType)type;

/**
 * 第三方平台是否支持SSO授权登录
 *
 * @param  type       第三方平台类型
 * @return 支持返回YES，否则返回NO
 */
+ (BOOL)canSSOForPlatform:(TTAccountAuthType)type;

/**
 * 第三方平台是否支持WAP授权登录
 *
 * @param  type       第三方平台类型
 * @return 支持返回YES，否则返回NO
 */
+ (BOOL)canWebSSOForPlatform:(TTAccountAuthType)type;

/**
 * 是否支持在自定义容器中对第三方平台进行授权登录
 *
 * @param  type       第三方平台类型
 * @return 支持返回YES，否则返回NO
 */
+ (BOOL)canCustomWebSSOForPlatform:(TTAccountAuthType)type;

/**
 * 第三方应用是否安装
 *
 * @param  type       第三方平台类型
 * @return 安装返回YES，否则返回NO
 */
+ (BOOL)isAppInstalledForPlatform:(TTAccountAuthType)type;

/**
 * 显示的本地第三方应用名称
 *
 * @param  type       第三方平台类型
 * @return 返回第三方应用本地化名称
 */
+ (nonnull NSString *)localizedDisplayNameForPlatform:(TTAccountAuthType)type;

/**
 * 获取第三方应用在App Store上的下载地址
 *
 * @param  type       第三方平台类型
 * @return 存在返回对应安装地址，否则返回nil
 */
+ (nullable NSString *)getAppInstallUrlForPlatform:(TTAccountAuthType)type;

#pragma mark - 第三方账号通过sso_callback登录（生成新的账号或登录已有三方账号）或绑定至当前登录账号
/**
 *  使用第三方平台授权信息登录头条账号系统
 *
 *  @param params         第三方平台返回信息
 *  @param willLoginBlock 授权成功，开始登录或者绑定回调；授权失败不回调
 *  @param completedBlock 登录或绑定完成回调
 *  @return HTTP请求任务
 *
 *  参数params的Key描述如下：
 *  key包括: {
 *      @"platform_name",   第三方平台在头条账号体系中指定的名称。老的方案使用，将被platform_app_id替代。
 *      @"platform_app_id", 第三方平台在头条账号体系中指定的平台appid，用于唯一绑定头条系产品与第三方产品。
 *      @"code",            第三方平台通过authorizationCode授权后返回的code，用于换取access_token。 [微信、腾讯微博、电信天翼、火山、抖音]
 *      @"access_token",    第三方平台通过token授权后返回的在三方后台获取用户资源的唯一标识。 [腾讯QQ、新浪微博]
 *      @"refresh_token",   第三方平台通过token授权后同access_token一起返回的refresh_token，用于刷新access_token。 [新浪微博]
 *      @"expires_in",      第三方平台通过token授权后返回的access_token有效期字段。 [腾讯QQ、新浪微博]
 *      @"uid",             第三方平台授权后返回的uid，是平台对该用户的唯一标识。 [新浪微博]
 *      @"openid",          第三方平台授权后返回的openid，是平台对该用户的唯一标识。 [腾讯QQ、]
 *  }
 */
+ (nullable id<TTAccountSessionTask>)loginWithSSOCallback:(NSDictionary * _Nonnull)params
                                              forPlatform:(NSInteger)platformType
                                                willLogin:(void (^_Nullable)(NSString *_Nonnull))willLoginBlock
                                               completion:(void(^)(BOOL success /** 操作是否成功 */, BOOL loginOrBind /** 登录还是绑定 */, NSError * _Nullable error))completedBlock;

@end



@interface TTAccount (PlatformAuthLogin_Deprecated)

#pragma mark - register
/**
 * 注册并将appId绑定到第三方平台SDK
 *
 * @param appId  第三方平台申请的appId
 * @param type   第三方平台类型
 */
+ (void)registerAppId:(NSString * _Nonnull)appId
          forPlatform:(TTAccountAuthType)type __deprecated __deprecated_msg("Method deprecated. Use `[TTAccount registerPlatform:] instead`");

@end


NS_ASSUME_NONNULL_END
