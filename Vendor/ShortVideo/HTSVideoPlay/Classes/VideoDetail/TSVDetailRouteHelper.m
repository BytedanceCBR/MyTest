//
//  TSVDetailRouteHelper.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/12/18.
//

#import "TSVDetailRouteHelper.h"
#import <TTNavigationController.h>
#import "TTCustomAnimationDelegate.h"

@implementation TSVDetailRouteHelper

+ (void)registerCustomPushAnimationFromVCClass:(Class)fromVCClass
{
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:fromVCClass toVCClass:nil animationClass:[TTCustomAnimationPushAnimation class]];
}

+ (BOOL)openURLByPushViewController:(NSURL *)url
{
    return [self openURLByPushViewController:url userInfo:nil];
}

+ (BOOL)openURLByPushViewController:(NSURL *)url userInfo:(TTRouteUserInfo *)userInfo
{
  
    return [[TTRoute sharedRoute] openURLByPushViewController:url
                                                     userInfo:userInfo
                                                  pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
                                                      if ([nav isKindOfClass:[TTNavigationController class]] &&
                                                          [routeObj.instance isKindOfClass:[UIViewController class]]) {
                                                          [(TTNavigationController *)nav pushViewControllerByTransitioningAnimation:((UIViewController *)routeObj.instance) animated:YES];
                                                      }
                                                  }];
}

@end
