//
//  TTWeixinOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTWeixinOpenURLTask.h"
#import <TTWeChatShare.h>
#import <TTAccountAuthWeChat.h>

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
    BOOL weChatShareResult = [TTWeChatShare handleOpenURL:url];
    BOOL weChatAuthResult  = [TTAccountAuthWeChat handleOpenURL:url];
    return weChatShareResult || weChatAuthResult;
}

@end
