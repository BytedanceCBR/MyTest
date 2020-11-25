//
//  FHShareQQTask.m
//  FHHouseShare
//
//  Created by bytedance on 2020/11/4.
//

#import "FHShareQQTask.h"
#import <TTLaunchDefine.h>
#import <BDUGQQShare.h>
#import <TTProjectLogicManager.h>
#import <NewsBaseDelegate.h>

DEC_TASK("FHShareQQTask",FHTaskTypeSDKs,TASK_PRIORITY_HIGH);

@implementation FHShareQQTask

-(NSString *)taskIdentifier {
    return @"FHShareQQTask";
}

-(BOOL)isResident {
    return YES;
}

-(void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    NSString *qqAppID = TTLogicString(@"qqOAuthAppID", nil);
    [BDUGQQShare registerWithID:qqAppID universalLink:[NSString stringWithFormat:@"https://i.haoduofangs.com/qq_conn/%@/",qqAppID]];
    [[BDUGQQShare sharedQQShare] isAvailable];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [BDUGQQShare handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [BDUGQQShare handleOpenUniversallink:userActivity.webpageURL];
}

@end
