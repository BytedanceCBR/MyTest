//
//  TTWeixinSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTWeixinSDKRegister.h"
#import "TTShareApiConfig.h"
#import "NewsBaseDelegate.h"
//#import "TTDingTalkSDKRegister.h"
#import "TTWeChatShare.h"
//#import "SSPayManager.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTWeixinSDKRegister",FHTaskTypeSDKs,TASK_PRIORITY_HIGH);

@implementation TTWeixinSDKRegister

- (NSString *)taskIdentifier {
    return @"WeixinSDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //注册微信
    //这里发现没有用到，先注释掉
//    if ([SharedAppDelegate conformsToProtocol:@protocol(TTWeChatSharePayDelegate)]) {
//        [TTWeChatShare sharedWeChatShare].payDelegate = (id<TTWeChatSharePayDelegate>)SharedAppDelegate;
//    }
    
    //注册部分耗时0.15ms，基本可以忽略
    [TTShareApiConfig shareRegisterWXApp:[SharedAppDelegate weixinAppID]];
}

@end
