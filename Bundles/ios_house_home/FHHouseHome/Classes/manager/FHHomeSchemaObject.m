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
        
        if([paramObj.allParams.allKeys containsObject:@"select_tab"])
        {
            NSDictionary* params = paramObj.allParams;
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

        //为运营活动准备的测试代码，后续会完善 by xsm
        
//        NSURL *url2 = [NSURL URLWithString:@"sslocal://ugc_community_detail?community_id=6703403120271032580"];
//        [[TTRoute sharedRoute] openURLByPushViewController:url2 userInfo:nil pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
//            [nav pushViewController:routeObj.instance animated:NO];
//        }];
//
//        NSURL *url3 = [NSURL URLWithString:@"sslocal://thread_detail?fid=6564242300&gd_ext_json=%7B%22category_id%22%3A%22f_project_social%22%2C%22enter_from%22%3A%22click_f_project_social%22%2C%22group_type%22%3A%22forum_post%22%2C%22log_pb%22%3A%22%7B%5C%22from_gid%5C%22%3A0%2C%5C%22impr_id%5C%22%3A%5C%22201912151447510101290431421A001E12%5C%22%2C%5C%22post_gid%5C%22%3A1647008365290510%2C%5C%22recommend_type%5C%22%3A%5C%22%5C%22%2C%5C%22repost_gid%5C%22%3A0%2C%5C%22with_quote%5C%22%3A0%7D%22%2C%22refer%22%3A%221%22%7D&tid=1647008365290510"];
//        [[TTRoute sharedRoute] openURLByPushViewController:url3 userInfo:nil];
        
    }
    return self;
}
@end
