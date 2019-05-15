//
//  TTShareModuleBridgeTask.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTShareModuleBridgeTask.h"
#import "TTShareModuleBridge.h"

@implementation TTShareModuleBridgeTask

- (NSString *)taskIdentifier {
    return @"ShareModuleBridge";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //注册share module bridge供插件使用分享功能
    [[TTShareModuleBridge shareInstance] registerShareAction];
}

@end
