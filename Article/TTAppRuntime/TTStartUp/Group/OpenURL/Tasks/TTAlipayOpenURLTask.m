//
//  TTAlipayOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTAlipayOpenURLTask.h"
#import <TTAliShare.h>

@implementation TTAlipayOpenURLTask

- (NSString *)taskIdentifier {
    return @"AlipayOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    [[SSTrackerSessionHandler sharedHandler] handleLaunchURL:url];
    //处理支付宝通过URL启动App时传递的数据
    return [TTAliShare handleOpenURL:url];
}

@end
