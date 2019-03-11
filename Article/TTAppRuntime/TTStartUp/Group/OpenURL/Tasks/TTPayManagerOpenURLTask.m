//
//  TTPayManagerOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTPayManagerOpenURLTask.h"
//#import "SSPayManager.h"
#import "TTRoute.h"
#import "NewsBaseDelegate.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"

@implementation TTPayManagerOpenURLTask

- (NSString *)taskIdentifier {
    return @"PayManagerOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    BOOL ret = [[SSPayManager sharedPayManager] canHandleOpenURL:url];
//    if (!ret) {
//        ret = [[TTRoute sharedRoute] canOpenURL:url];
//        if (ret && [SharedAppDelegate appTopNavigationController]) {
////            [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
//            [TTAdSplashManager shareInstance].splashADShowType = TTAdSplashShowTypeHide;
//            [[self class] sendLaunchTrackIfNeededWithUrl:url];
//            [[TTRoute sharedRoute] openURLByPushViewController:url];
//        }
//    }
//    return ret;
    return NO;
}

//+ (void)sendLaunchTrackIfNeededWithUrl:(NSURL *)openURL {
//    NSString *openURLString = [openURL absoluteString];
//    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:openURLString]];
//
//    NSString *page = paramObj.host;
//    NSDictionary *params = paramObj.queryParams;
//    if ([page isEqualToString:@"home"] && params[@"growth_from"]) {
//        wrapperTrackEvent(@"launch", params[@"growth_from"]);
//        SSLog(@">>>> Launch: growth_from : %@",params);
//    }
//    
//    SSLog(@">>>> Launch : openURL: %@",openURLString);
//}

@end
