//
//  TTWeixinSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTWeixinSDKRegister.h"
#import <TTShareApiConfig.h>
#import "NewsBaseDelegate.h"
//#import "TTDingTalkSDKRegister.h"
#import "TTWeChatShare.h"
//#import "SSPayManager.h"

@implementation TTWeixinSDKRegister

- (NSString *)taskIdentifier {
    return @"WeixinSDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //注册微信
    if ([SharedAppDelegate conformsToProtocol:@protocol(TTWeChatSharePayDelegate)]) {
        [TTWeChatShare sharedWeChatShare].payDelegate = (id<TTWeChatSharePayDelegate>)SharedAppDelegate;
    }
    [TTShareApiConfig shareRegisterWXApp:[SharedAppDelegate weixinAppID]];
//    [SSPayManager registerWxAppID:[SharedAppDelegate weixinAppID]];
}

@end
