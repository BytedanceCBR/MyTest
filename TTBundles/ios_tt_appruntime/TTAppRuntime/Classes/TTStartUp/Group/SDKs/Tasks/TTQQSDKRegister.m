//
//  TTQQSDKRegister.m
//  Article
//
//  Created by 王霖 on 2017/7/26.
//
//

#import "TTQQSDKRegister.h"
#import <TTShareApiConfig.h>
#import "NewsBaseDelegate.h"
#import "TTProjectLogicManager.h"

@implementation TTQQSDKRegister

- (NSString *)taskIdentifier {
    return @"qqSDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //注册QQ
    [TTShareApiConfig shareRegisterQQApp:TTLogicString(@"qqOAuthAppID", nil)];
}

@end
