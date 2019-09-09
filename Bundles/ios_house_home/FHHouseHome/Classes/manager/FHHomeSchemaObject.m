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
        if([paramObj.allParams.allKeys containsObject:@"tab"])
        {            
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarSecond];
        }
    }
    return self;
}
@end
