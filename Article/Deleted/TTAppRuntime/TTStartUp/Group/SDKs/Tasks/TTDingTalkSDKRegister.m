//
//  TTDingTalkSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTDingTalkSDKRegister.h"
#import <TTShareApiConfig.h>
#import "NewsBaseDelegate.h"

@implementation TTDingTalkSDKRegister

- (NSString *)taskIdentifier {
    return @"DingTalkSDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    // 钉钉SDK分享，注册钉钉
    [TTShareApiConfig shareRegisterDingTalk:[SharedAppDelegate dingtalkAppID]];
}

@end
