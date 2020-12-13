//
//  FHShareWeChatTask.m
//  FHHouseShare
//
//  Created by bytedance on 2020/11/4.
//

#import "FHShareWeChatTask.h"
#import <TTLaunchDefine.h>
#import <BDUGWeChatShare.h>
#import <NewsBaseDelegate.h>

DEC_TASK("FHShareWeChatTask",FHTaskTypeSDKs,TASK_PRIORITY_HIGH);

@implementation FHShareWeChatTask

-(NSString *)taskIdentifier {
    return @"FHShareWeChatTask";
}

-(BOOL)isResident {
    return YES;
}

-(void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [BDUGWeChatShare sharedWeChatShare].delegate =(id <BDUGWechatShareDelegate>) [UIApplication sharedApplication].delegate;
    [BDUGWeChatShare registerWithID:[SharedAppDelegate weixinAppID] universalLink:@"https://i.haoduofangs.com/"];
    [BDUGWeChatShare registerWechatShareIDIfNeeded];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [BDUGWeChatShare handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [BDUGWeChatShare handleOpenUniversalLink:userActivity];
}

@end
