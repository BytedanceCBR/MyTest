//
//  TTAliPaySDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTAliPaySDKRegister.h"
#import "TTAliShare.h"
#import "TTProjectLogicManager.h"

@implementation TTAliPaySDKRegister

- (NSString *)taskIdentifier {
    return @"AliPaySDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //  使用自支付宝开放平台申请的appId注册应用信息
    NSString *zhifubaoAuthAppID = TTLogicString(@"zhifubaoAuthAppID", @"");
    [TTAliShare registerWithID:zhifubaoAuthAppID];
}

@end
