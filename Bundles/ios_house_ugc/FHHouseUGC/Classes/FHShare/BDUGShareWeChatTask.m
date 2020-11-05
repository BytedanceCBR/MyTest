//
//  BDUGShareWeChatTask.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/4.
//

#import "BDUGShareWeChatTask.h"
#import <TTLaunchDefine.h>
#import <BDUGWeChatShare.h>
#import <NewsBaseDelegate.h>
#import <BDUGContainer/BDUGContainer.h>

DEC_TASK("BDUGShareWeChatTask",FHTaskTypeSDKs,TASK_PRIORITY_HIGH);

@implementation BDUGShareWeChatTask

-(NSString *)taskIdentifier {
    return @"BDUGShareWeChatTask";
}

-(BOOL)isResident {
    return YES;
}

-(void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [BDUGWeChatShare sharedWeChatShare].delegate =(id <BDUGWechatShareDelegate>) [UIApplication sharedApplication].delegate;
    [BDUGWeChatShare registerWithID:[SharedAppDelegate weixinAppID] universalLink:@"https://i.haoduofangs.com"];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [BDUGWeChatShare handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [BDUGWeChatShare handleOpenUniversalLink:userActivity];
}

@end
