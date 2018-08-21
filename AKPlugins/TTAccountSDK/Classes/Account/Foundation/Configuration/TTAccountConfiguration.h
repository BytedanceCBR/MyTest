//
//  TTAccountConfiguration.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/8/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTAccountDefine.h"
#import "TTAccountLogger.h"
#import "TTAccountMonitorProtocol.h"
#import "TTAccountMulticast.h"



NS_ASSUME_NONNULL_BEGIN

/**
 账号相关的配置
 */
@interface TTAccountConfiguration : NSObject

/** 动态设置网络请求通用参数句柄 */
@property (nonatomic,   copy, nonnull) NSDictionary * _Nonnull (^networkParamsHandler)(void);


/** 动态配置APP接口所需的必要参数，installId和fromSessionKey用于请求NewSession */
FOUNDATION_EXPORT NSString *TTAccountInstallIdKey;      // installId
FOUNDATION_EXPORT NSString *TTAccountDeviceIdKey;       // deviceId
FOUNDATION_EXPORT NSString *TTAccountSessionKeyKey;     // sessionKey
FOUNDATION_EXPORT NSString *TTAccountFromSessionKeyKey; // 共享APP的sessionKey
FOUNDATION_EXPORT NSString *TTAccountSSAppIdKey;        // SSAppID
@property (nonatomic,   copy, nonnull) NSDictionary * _Nonnull (^appRequiredParamsHandler)(void);


/** 账号用户数据是否支持多线程安全访问 [Default is NO] */
@property (nonatomic, assign) BOOL multiThreadSafeEnabled;


/** 跨group访问共享的账号数据，仅仅在同一个账号下（同TEAM ID)适用；形式(TEAM ID).[***] */
@property (nonatomic,   copy, nullable) NSString *sharingKeyChainGroup;


/** 当第三方平台登录或绑定出现已绑定异常时，是否弹出alertView提示解绑 [Default is YES] */
@property (nonatomic, assign) BOOL unbindAlertEnabled;


/** 当用第三方平台登录或绑定失败时，是否弹出alertView提示，提示信息 <***账号登录|绑定异常> [Default is YES] */
@property (nonatomic, assign) BOOL showAlertWhenLoginFail;


/** 是否可通过找回密码实现登录 [Default is YES] */
@property (nonatomic, assign) BOOL byFindPasswordLoginEnabled;


/** 是否自动同步用户信息 [Default is NO]；策略是：当前是登录状态，则首次启动或从后台到前台时同步 */
@property (nonatomic, assign) BOOL autoSynchronizeUserInfo;


/** 外部设置账号相关接口的域名 */
@property (nonatomic,   copy, nullable) NSString *domain;


/** 设置账号消息第一响应者；当账号信息发生变更时，将首先发送给该代理 */
@property (nonatomic, strong, nullable) NSObject<TTAccountMessageFirstResponder> *accountMessageFirstResponder;


/** 设置埋点代理类 */
@property (nonatomic, strong, nullable) NSObject<TTAccountLogger> *loggerDelegate;


/** 设置监控代理类，加监控为了找出问题，稳定后可删掉 */
@property (nonatomic, strong, nullable) NSObject<TTAccountMonitorProtocol> *monitorDelegate;


/** 动态获取当前的ViewController句柄 */
@property (nonatomic,   copy, nullable) UIViewController * __nonnull (^visibleViewControllerHandler)(void);

@end

NS_ASSUME_NONNULL_END
