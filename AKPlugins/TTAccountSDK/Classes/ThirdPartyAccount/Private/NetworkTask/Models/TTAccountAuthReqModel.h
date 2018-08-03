//
//  TTAccountAuthReqModel.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountBaseModel.h"



/**
 *  @Wiki:  https://wiki.bytedance.net/pages/viewpage.action?pageId=1148503#id-享评SDK2.0-享评SDK2.0-客户端SNSSSO成功后回调
 *          https://wiki.bytedance.net/pages/viewpage.action?pageId=53809581#id-用户登录相关API-SSO回调/sso_callback
 */
/**
 *  SSO登录成功后，回调请求(接口: sso_callback)
 */
@interface TTASNSSDKAuthCallbackReqModel : TTABaseReqModel
@property (nonatomic,   copy) NSString *aid;      // app_id, 包含在通用参数里面
@property (nonatomic,   copy) NSString *platform; // 第三方平台名称
@property (nonatomic,   copy) NSString *mid;      // member_id

/**
 *  qq_weibo    没有
 *  sina_weibo  必须
 *  qzone_sns   没有
 */
@property (nonatomic,   copy) NSString *uid;      // 用户该平台唯一标识符. 新浪授权对应当前授权用户的uid.

// WeChat
@property (nonatomic,   copy) NSString *code;     // 第三方平台[微信]授权返回的code
// Tencent
@property (nonatomic,   copy) NSString *access_token; // [Tencent|SinaWeibo] /** Access Token凭证，用于后续访问各开放接口 */
@property (nonatomic,   copy) NSString *expires_in;   // [Tencent|SinaWeibo] /** Access Token的失效期 */
@property (nonatomic,   copy) NSString *openid;       /** 用户授权登录后对该用户的唯一标识 */
// SinaWeibo
@property (nonatomic,   copy) NSString *refresh_token; /** 用户授权登录后对该用户的唯一标识 */
@end



/**
 *  使用第三方平台SDK认证时，出现第三方平台已被绑定，后台要求改变绑定的ResponseModel
 *  场景如下：1. 例如微信绑定了手机A，然后使用手机B登录；再绑定微信时，就会提示微信已绑定到某某手机号，请先解绑；
 *          2. 手机A登录，然后微博登录；再用手机A登录并绑定微博时，会出现微博已绑定，请先解绑
 */
@interface TTASNSSDKAuthSwitchBindReqModel : TTABaseReqModel
/** 第三方平台返回的code */
@property (nonatomic,   copy) NSString *code;
/** 第三方平台名称 */
@property (nonatomic,   copy) NSString *platform;
/** 服务端返回的第三方平台认证的token(auth_token) */
@property (nonatomic,   copy) NSString *auth_token;
/**
 *  mid即member_id，新应用请保持member_id与aid一致
 *  https://wiki.bytedance.net/pages/viewpage.action?pageId=1149590
 */
@property (nonatomic,   copy) NSString *mid;
@end



/**
 *  使用自定义WAP授权第三方平台时，出现第三方平台已被绑定，后台要求改变绑定的ResponseModel
 *  场景如下：1. 例如微信绑定了手机A，然后使用手机B登录；再绑定微信时，就会提示微信已绑定到某某手机号，请先解绑；
 *          2. 手机A登录，然后微博登录；再用手机A登录并绑定微博时，会出现微博已绑定，请先解绑
 */
@interface TTACustomWAPAuthSwitchBindReqModel : TTABaseReqModel
/** 服务端返回的第三方平台认证的token(auth_token) */
@property (nonatomic,   copy) NSString *auth_token;
/** 第三方平台名称 */
@property (nonatomic,   copy) NSString *platform;
/**
 *  mid即member_id，新应用请保持member_id与aid一致
 *  https://wiki.bytedance.net/pages/viewpage.action?pageId=1149590
 */
@property (nonatomic,   copy) NSString *mid;
@property (nonatomic, assign) BOOL      unbind_exist;
@end



/**
 *  绑定该App官方账号到认证的第三方平台
 */
@interface TTShareAppToSNSPlatformReqModel : TTABaseReqModel
/** 第三方平台名称 */
@property (nonatomic,   copy) NSString *platform;
/** 设置的device_id */
@property (nonatomic,   copy) NSString *device_id;
@end


