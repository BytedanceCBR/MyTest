//
//  TTAccountConfiguration_Priv.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/9/17.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountConfiguration.h"



NS_ASSUME_NONNULL_BEGIN

@interface TTAccountConfiguration (tta_internal)

/** 获取登录模块必要的参数 */
- (NSDictionary *)tta_appRequiredParameters;

/** 登录模块公共的网络参数 */
- (NSDictionary *)tta_commonNetworkParameters;
+ (NSDictionary *)tta_defaultURLParameters;

/** 获取当前的ViewController */
- (UIViewController *)tta_currentViewController;

+ (NSString *)tta_appBundleID;

- (NSString *)tta_ssAppID;

- (NSString *)tta_ssMID;

- (NSString *)tta_deviceID;

- (NSString *)tta_installID;

- (NSString *)tta_sharingKeyChainGroup;

@end

NS_ASSUME_NONNULL_END
