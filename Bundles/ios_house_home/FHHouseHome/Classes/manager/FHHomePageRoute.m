//
//  FHHomePageRoute.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/1/6.
//

#import "FHHomePageRoute.h"
#import "TTRoute.h"
#import "FHHomeConfigManager.h"
#import "TTUIResponderHelper.h"
#import "UIViewController+TTMovieUtil.h"
#import "UIViewController+Tree.h"

@interface FHHomePageRoute() <TTRouteInitializeProtocol>

@end

@implementation FHHomePageRoute

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        
        UIViewController *currentVC = [UIViewController ttmu_currentViewController];
        [currentVC.navigationController popToRootViewControllerAnimated:YES];
        
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarFirst];
        
        [[FHHomeConfigManager sharedInstance] openCategoryFeedStart];
        
    }
    return self;
}

/**
 非 vc 打开方式
 */
- (void)customOpenTargetWithParamObj:(nullable TTRouteParamObj *)paramObj
{
    
}

@end
