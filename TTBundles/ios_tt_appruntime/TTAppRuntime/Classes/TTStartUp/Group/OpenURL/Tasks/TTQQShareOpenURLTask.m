//
//  TTQQShareOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTQQShareOpenURLTask.h"
#import <TTQQShare.h>
//#import <TTAccountAuthTencent.h>

@implementation TTQQShareOpenURLTask

- (NSString *)taskIdentifier {
    return @"QQShareOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    /**
     * TencentQQ分享回调会清空粘贴板而登录不会，所以登录授权放前面，分享放后面
     */
//    BOOL tencentQQAuthResult = [TTAccountAuthTencent handleOpenURL:url];
    BOOL tencentQQShareResult= [TTQQShare handleOpenURL:url];
//    return tencentQQAuthResult || tencentQQShareResult;
    return tencentQQShareResult;
}

@end
