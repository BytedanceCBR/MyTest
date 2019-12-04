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
    }
    return self;
}
@end
