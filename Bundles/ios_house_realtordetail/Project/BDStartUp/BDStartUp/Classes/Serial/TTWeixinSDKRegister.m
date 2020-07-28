//
//  TTWeixinSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTWeixinSDKRegister.h"

#if BD_TTShare
#import <TTShareApiConfig.h>
#import "TTWeChatShare.h"
#endif

@implementation TTWeixinSDKRegister

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
#if BD_TTShare
    //注册微信 // TODO 代理方法实现
    [TTWeChatShare sharedWeChatShare].payDelegate = (id<TTWeChatSharePayDelegate>)([UIApplication sharedApplication].delegate);
    NSString *wxApp = [BDStartUpManager sharedInstance].wxApp;
    NSAssert(wxApp.length, @"wxApp不能为空！");

    [TTShareApiConfig shareRegisterWXApp:wxApp];
#endif
}

@end

