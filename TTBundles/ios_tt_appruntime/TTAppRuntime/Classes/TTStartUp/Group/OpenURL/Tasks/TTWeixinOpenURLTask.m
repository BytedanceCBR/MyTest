//
//  TTWeixinOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTWeixinOpenURLTask.h"
#import "TTWeChatShare.h"
#import "TTAccountAuthWeChat.h"
#import "TTLaunchDefine.h"
#import <TTAccountSDK/TTAccount+PlatformAuthLogin.h>

DEC_TASK("TTWeixinOpenURLTask",FHTaskTypeOpenURL,TASK_PRIORITY_HIGH+4);

@implementation TTWeixinOpenURLTask

- (NSString *)taskIdentifier {
    return @"WeixinOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    /**
     * WECHAT登录授权会清空粘贴板而分享和支付不会，所以分享和授权放前面，登录授权放后面
     */
    //TODO:后面调试完毕创建一个新的TTAccountOPENURLTask类
    BOOL accountAuthResult = [TTAccount handleOpenURL:url];
    if (accountAuthResult) {
        return accountAuthResult;
    }
    
    BOOL weChatShareResult = [TTWeChatShare handleOpenURL:url];
    BOOL weChatAuthResult  = [TTAccountAuthWeChat handleOpenURL:url];
    return weChatShareResult || weChatAuthResult;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler {
    BOOL accountAuthResult = [TTAccount continueUserActivity:userActivity restorationHandler:restorationHandler];
    if (accountAuthResult) {
        return accountAuthResult;
    }

    BOOL weChatShareResult = [TTWeChatShare continueUserActivity:userActivity restorationHandler:restorationHandler];
    BOOL weChatAuthResult  = [TTAccountAuthWeChat continueUserActivity:userActivity restorationHandler:restorationHandler];
    return weChatShareResult || weChatAuthResult;
}

@end
