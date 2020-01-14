//
//  TTQQSDKRegister.m
//  Article
//
//  Created by 王霖 on 2017/7/26.
//
//

#import "TTQQSDKRegister.h"
#import "TTShareApiConfig.h"
#import "NewsBaseDelegate.h"
#import "TTProjectLogicManager.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTQQSDKRegister",FHTaskTypeSDKs,TASK_PRIORITY_HIGH+2);

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
