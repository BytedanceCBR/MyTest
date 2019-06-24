//
//  TTOpenURLTask.m
//  Article
//
//  Created by 春晖 on 2019/3/4.
//

#import "TTOpenURLTask.h"
#import <TTRoute/TTRoute.h>
#import "NewsBaseDelegate.h"
#import "SSADManager.h"
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <FHEnvContext.h>
#import "TTLaunchDefine.h"

DEC_TASK("TTOpenURLTask",FHTaskTypeOpenURL,TASK_PRIORITY_MEDIUM);

@implementation TTOpenURLTask

- (NSString *)taskIdentifier {
    return @"OpenURLTask";
}

- (BOOL)isResident {
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [FHEnvContext sharedInstance].refreshConfigRequestType = @"link_launch";
    BOOL ret = [[TTRoute sharedRoute] canOpenURL:url];
    if (ret && [SharedAppDelegate appTopNavigationController]) {
        [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
        [[self class] sendLaunchTrackIfNeededWithUrl:url];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }else if ([url.host isEqualToString:@"main"]){
        //snssdk1370://main?select_tab=tab_message
        TTRouteParamObj* obj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        NSDictionary* params = [obj queryParams];
        if (params != nil) {
            NSString* target = params[@"select_tab"];
            if (target != nil && target.length > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:@{@"tag": target}];
            }
        }
    }
    
    return ret;
}

+ (void)sendLaunchTrackIfNeededWithUrl:(NSURL *)openURL {
    NSString *openURLString = [openURL absoluteString];
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:openURLString]];
    
    NSString *page = paramObj.host;
    NSDictionary *params = paramObj.queryParams;
    if ([page isEqualToString:@"home"] && params[@"growth_from"]) {
        wrapperTrackEvent(@"launch", params[@"growth_from"]);
        SSLog(@">>>> Launch: growth_from : %@",params);
    }
    
    SSLog(@">>>> Launch : openURL: %@",openURLString);
}

@end
