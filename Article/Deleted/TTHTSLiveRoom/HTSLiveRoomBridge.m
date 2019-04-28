//
//  HTSLiveRoomBridge.m
//  Article
//
//  Created by Liu RiHua on 17/3/31.
//
//

#import "HTSLiveRoomBridge.h"
#import "SSWebViewController.h"
#import "TTModuleBridge.h"
#import <LiveUserModel.h>
#import <MGJRouter/MGJRouter.h>
#import <LiveRoomManager.h>
#import <HTSLiveToast.h>
#import <LiveRoomPlayerViewController.h>
#import <HTSNHResponder.h>
#import <HTSNHProjectInfo.h>
#import <HTSLiveRoomRouter+Transition.h>
#import <TTRoute/TTRoute.h>

@implementation HTSLiveRoomBridge

+ (void)load {
    @autoreleasepool {

        [MGJRouter registerURLPattern:HTSLiveRoomTransitionRanklist toHandler:^(NSDictionary *routerParameters) {
            NSMutableDictionary *userInfo = [routerParameters[MGJRouterParameterUserInfo] mutableCopy];

            LiveUserModel *user = routerParameters[MGJRouterParameterUserInfo][HTSLiveRoomTransitionUserKey];
            NSString *url = [NSString stringWithFormat:@"http://hotsoon.snssdk.com/hotsoon/in_app/user/%@/rank/fans/",user.userID];
            [userInfo setValue:url forKey:@"url"];

            UINavigationController *nav = [HTSNHResponder topNavigationControllerFor:[HTSNHResponder topViewController].view];
            [SSWebViewController openWebViewForNSURL:[NSURL URLWithString:url] title:@"粉丝贡献榜" navigationController:nav supportRotate:NO];
        }];


        [MGJRouter registerURLPattern:HTSLiveRoomTransitionURL toHandler:^(NSDictionary *routerParameters) {

            NSString *schemaURL = routerParameters[MGJRouterParameterUserInfo][HTSLiveRoomTransitionURLKey];
            NSString *title = routerParameters[MGJRouterParameterUserInfo][HTSLiveRoomTransitionTitleKey];
            if ([MGJRouter canOpenURL:schemaURL]) {
                [MGJRouter openURL:schemaURL withUserInfo:routerParameters[MGJRouterParameterUserInfo] completion:nil];
                return;
            }

            NSMutableDictionary *userInfo = [routerParameters[MGJRouterParameterUserInfo] mutableCopy];
            [userInfo setValue:schemaURL forKey:@"url"];
            [userInfo setValue:routerParameters[MGJRouterParameterUserInfo][HTSLiveRoomTransitionTitleKey] forKey:@"title"];

            UINavigationController *nav = [HTSNHResponder topNavigationControllerFor:[HTSNHResponder topViewController].view];
            [SSWebViewController openWebViewForNSURL:[NSURL URLWithString:schemaURL] title:title navigationController:nav supportRotate:NO];
        }];

        [MGJRouter registerURLPattern:@"HTSLiveRoomSchema" toHandler:^(NSDictionary *routerParameters) {
            NSDictionary *userInfo = routerParameters[MGJRouterParameterUserInfo];
            [TTRoute registerRouteEntry:userInfo[@"schema"] withObjClass:NSClassFromString(userInfo[@"VC"])];
        }];

        [MGJRouter registerURLPattern:@"HTSLiveChargeSchema" toHandler:^(NSDictionary *routerParameters) {
            NSDictionary *userInfo = routerParameters[MGJRouterParameterUserInfo];
            [TTRoute registerRouteEntry:userInfo[@"schema"] withObjClass:NSClassFromString(userInfo[@"VC"])];
        }];

        MGJRouterHandler handler = ^(NSDictionary *routerParameters) {

            void (^completion)(id result) = routerParameters[MGJRouterParameterCompletion];

            if ([[LiveRoomManager shareInstance] getIsInLiveRoom]) {
                [HTSLiveToast show:@"进入另一个直播间前请退出当前直播间~"];
                if (completion) {
                    completion(@(NO));
                }
                return;
            }

            NSMutableDictionary *paramDict = [routerParameters mutableCopy];
            if (!paramDict[@"id"] && !paramDict[@"room_id"]) {
                if (completion) {
                    completion(@(NO));
                }
                return;
            } else if (!paramDict[@"id"]) {
                paramDict[@"id"] = paramDict[@"room_id"];
            }
            [paramDict addEntriesFromDictionary:paramDict[MGJRouterParameterUserInfo]];

            LiveRoomPlayerViewController *controller;
            if ([paramDict[@"page_source"] isEqualToString:@"web"]) {
                controller = [[LiveRoomPlayerViewController alloc] initFromWebView:paramDict.copy];
            } else if ([paramDict[@"page_source"] isEqualToString:@"push"]) {
                controller = [[LiveRoomPlayerViewController alloc] initFromPushService:paramDict.copy];
            } else {
                controller = [[LiveRoomPlayerViewController alloc] initFromWebView:paramDict.copy];
            }
            controller.hidesBottomBarWhenPushed = YES;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UINavigationController *nav = [HTSNHResponder topNavigationControllerFor:[HTSNHResponder topmostView]];

                [nav pushViewController:controller animated:YES];
                if (completion) {
                    completion(@(YES));
                }
            });
        };

        NSString *scheme = [@"snssdk" stringByAppendingString:[HTSNHProjectInfo ssAppID]];
        NSString *url = [scheme stringByAppendingString:@"://room"];
        [MGJRouter registerURLPattern:url toHandler:handler];

        NSString *localUrl = [SSLocalScheme stringByAppendingString:@"room"];
        [MGJRouter registerURLPattern:localUrl toHandler:handler];
    }
}

@end
