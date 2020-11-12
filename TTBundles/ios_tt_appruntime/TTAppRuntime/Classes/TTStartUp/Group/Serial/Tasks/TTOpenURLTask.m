//
#import <BDTrackerProtocol/BDTrackerProtocol.h>
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
#import "FHEnvContext.h"
#import "TTLaunchDefine.h"
#import <FHShareManager.h>

DEC_TASK("TTOpenURLTask",FHTaskTypeOpenURL,TASK_PRIORITY_MEDIUM);

extern BOOL kFHInAppPushTipsHidden;

@implementation TTOpenURLTask

- (NSString *)taskIdentifier {
    return @"OpenURLTask";
}

- (BOOL)isResident {
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if([TTSandBoxHelper isInHouseApp] && [url.absoluteString containsString:@"fhsharemanager"]) {
        return [[FHShareManager shareInstance] openSnssdkUrlWith:url];
    }
    
    [FHEnvContext sharedInstance].refreshConfigRequestType = @"link_launch";
    // 部分页面不支持Push跳转
    if (kFHInAppPushTipsHidden) {
        return NO;
    }
    
    BOOL ret = [[TTRoute sharedRoute] canOpenURL:url];
    if ([url.host isEqualToString:@"main"] || [url.host isEqualToString:@"home"]){
        [[TTRoute sharedRoute] openURL:url userInfo:nil objHandler:nil];
        //snssdk1370://main?select_tab=tab_message
    }else{
        if (ret && [SharedAppDelegate appTopNavigationController]) {
            [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
            [[self class] sendLaunchTrackIfNeededWithUrl:url];
            [[TTRoute sharedRoute] openURLByPushViewController:url];
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
        [BDTrackerProtocol event:@"launch" label:params[@"growth_from"]];
        SSLog(@">>>> Launch: growth_from : %@",params);
    }
    
    SSLog(@">>>> Launch : openURL: %@",openURLString);
}

@end
