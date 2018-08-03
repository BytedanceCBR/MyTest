//
//  TTSpotlightTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTSpotLightTask.h"
#import "TTStartupTask.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "TTTrackerSessionHandler.h"
#import "TTRoute.h"
#import "ArticleDetailHeader.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"

@implementation TTSpotlightTask

- (NSString *)taskIdentifier {
    return @"Spotlight";
}

- (BOOL)isResident {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
#pragma clang diagnostic pop
        [[TTTrackerSessionHandler sharedHandler] setLaunchFrom:TTTrackerLaunchFromSpotlight];
        
        //延迟1秒 要不截图会截黑色
        NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
        [statParams setValue:@(NewsGoDetailFromSourceSpotlightSearchResult) forKey:kNewsGoDetailFromSourceKey];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        NSString * detailURL = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
#pragma clang diagnostic pop
        //通过spotlight打开文章不出开屏广告
//        [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
        [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
        [[TTMonitor shareManager] trackService:@"spotight_active" status:1 extra:nil];
        
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
        [extraDict setValue:detailURL forKey:@"url"];
        wrapperTrackEventWithCustomKeys(@"activity_type", @"spotlight", nil, nil, extraDict);
    }
    return YES;
}

@end
