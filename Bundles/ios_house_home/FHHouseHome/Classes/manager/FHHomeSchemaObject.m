//
//  FHHomeSchemaObject.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/9/9.
//

#import "FHHomeSchemaObject.h"
#import "TTRoute.h"
#import <TTTabBarProvider.h>
#import <TTTabBarManager.h>
#import <TTTabBarItem.h>
#import "UIViewController+TTMovieUtil.h"
#import "FHHomeConfigManager.h"
#import <JSONAdditions.h>
#import <TTArticleTabBarController.h>
#import <FHEnvContext.h>
#import <FHMinisdkManager.h>

@interface FHHomeSchemaObject()<TTRouteInitializeProtocol>

@end

@implementation FHHomeSchemaObject

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        //sslocal://home?tab=community
        if([paramObj.allParams.allKeys containsObject:@"tab"])
        {
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarSecond];
        }
        
        BOOL isInRootTabVC = [self isInRootTabVC];
        if([paramObj.allParams.allKeys containsObject:@"jumpList"] && !isInRootTabVC){
            //这种情况下不切换tab，直接push
        }else{
            if([paramObj.allParams.allKeys containsObject:@"select_tab"]){
                [self handleChangeTab:paramObj.allParams];
            }
        }
        
        if([paramObj.allParams.allKeys containsObject:@"jumpList"]){
            [self handleMultiPush:paramObj.allParams];
        }
        //处理春节活动过来的 ack_token
        if([FHEnvContext isSpringOpen]){
            NSString *ackToken = paramObj.allParams[@"ack_token"];
            NSString *vid = paramObj.allParams[@"vid"];
            if(ackToken){
                [[FHMinisdkManager sharedInstance] appBecomeActive:ackToken];
            }
            //执行任务
            [[FHMinisdkManager sharedInstance] excuteTask];
        }

    }
    return self;
}

//处理切换到指定tab
- (void)handleChangeTab:(NSDictionary *)params {
    if (params != nil) {
        NSString* target = params[@"select_tab"];
        if (target != nil && target.length > 0) {
            NSDictionary *userInfo = @{
                                       @"tag":target,
                                       @"needToRoot":@1
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:userInfo];
        }
    }
}

//处理push多个页面
- (void)handleMultiPush:(NSDictionary *)params {
    NSString *str = params[@"jumpList"];
    if([str isKindOfClass:[NSString class]]){
        id jsonValue = [str tt_JSONValue];
        if([jsonValue isKindOfClass:[NSArray class]]){
            NSArray *jumpList = (NSArray *)jsonValue;
            for (NSInteger i = 0; i < jumpList.count; i++) {
                NSString *urlStr = jumpList[i];
                if(!isEmptyString(urlStr)){
                    NSURL *url = [NSURL URLWithString:urlStr];
                    if(i == jumpList.count - 1){
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                    }else{
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
                            [nav pushViewController:routeObj.instance animated:NO];
                        }];
                        
                    }
                }
            }
        }
    }
}

//是否在4个tab的根vc页面
- (BOOL)isInRootTabVC {
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    
    TTArticleTabBarController * rootTabController = (TTArticleTabBarController*)mainWindow.rootViewController;
    if ([mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        if([rootTabController.selectedViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController *vc = (UINavigationController *)rootTabController.selectedViewController;
            if(vc.viewControllers.count > 1){
                return NO;
            }
        }
    }
    
    return YES;
}

@end
