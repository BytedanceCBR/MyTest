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

@implementation TTOpenURLTask

- (NSString *)taskIdentifier {
    return @"OpenURLTask";
}

- (BOOL)isResident {
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL ret = [[TTRoute sharedRoute] canOpenURL:url];
    if (ret && [SharedAppDelegate appTopNavigationController]) {
        [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
        [[self class] sendLaunchTrackIfNeededWithUrl:url];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
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
