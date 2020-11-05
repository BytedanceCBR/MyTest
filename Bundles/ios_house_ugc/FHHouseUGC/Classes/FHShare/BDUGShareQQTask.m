//
//  BDUGShareQQTask.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/4.
//

#import "BDUGShareQQTask.h"
#import <TTLaunchDefine.h>
#import <BDUGQQShare.h>
#import <TTProjectLogicManager.h>
#import <NewsBaseDelegate.h>

DEC_TASK("BDUGShareQQTask",FHTaskTypeSDKs,TASK_PRIORITY_HIGH);

@implementation BDUGShareQQTask

-(NSString *)taskIdentifier {
    return @"BDUGShareQQTask";
}

-(BOOL)isResident {
    return YES;
}

-(void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [BDUGQQShare registerWithID:TTLogicString(@"qqOAuthAppID", nil) universalLink:nil];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [BDUGQQShare handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [BDUGQQShare handleOpenUniversallink:userActivity.webpageURL];
}

@end
