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
#import "FHEnvContext.h"
#import "TTLaunchDefine.h"
#import <FHMinisdkManager.h>

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
    
    [FHEnvContext sharedInstance].refreshConfigRequestType = @"link_launch";
    // 部分页面不支持Push跳转
    if (kFHInAppPushTipsHidden) {
        return NO;
    }
    
    BOOL ret = [[TTRoute sharedRoute] canOpenURL:url];
    if ([url.host isEqualToString:@"main"] || [url.host isEqualToString:@"home"] || [url.host isEqualToString:@"spring"]){
        
        if([url.host isEqualToString:@"spring"]){
            //正在显示登录页时候直接返回
            if([FHMinisdkManager sharedInstance].isShowing){
                return NO;
            }
            
            //报一个拉活进入的埋点
            [[FHMinisdkManager sharedInstance] addActivationLog];
            
            if(ret){
                NSString *defaultTabName = [FHEnvContext defaultTabName];
                //需要切换tab
                if ([FHEnvContext isUGCOpen] && [FHEnvContext isUGCAdUser]) {
                    [[FHEnvContext sharedInstance] jumpUGCTab];
                }else if(defaultTabName.length > 0){
                    [[FHEnvContext sharedInstance] jumpTab:defaultTabName];
                }else{
                    if (![FHEnvContext isCurrentCityNormalOpen]) {
                        [[FHEnvContext sharedInstance] jumpUGCTab];
                    }else{
                        [[FHEnvContext sharedInstance] jumpMainTab];
                    }
                }
            }else{
                //这里加这句话是因为第一次安装时候，上面Route不起作用，进不去
                [FHMinisdkManager sharedInstance].isSpring = YES;
            }
            [FHMinisdkManager sharedInstance].url = url;
        }
        
        //这三种必须分开判断，要不然直接crash
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
        wrapperTrackEvent(@"launch", params[@"growth_from"]);
        SSLog(@">>>> Launch: growth_from : %@",params);
    }
    
    SSLog(@">>>> Launch : openURL: %@",openURLString);
}

@end
