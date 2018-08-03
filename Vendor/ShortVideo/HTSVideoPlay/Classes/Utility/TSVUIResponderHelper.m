//
//  TSVUIResponderHelper.m
//  AFgzipRequestSerializer
//
//  Created by 王双华 on 2017/11/10.
//

#import "TSVUIResponderHelper.h"

@implementation TSVUIResponderHelper

+ (UIViewController *)topmostViewController
{
    return [self topmostVCForVC:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topmostVCForVC:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self topmostVCForVC:((UITabBarController *)vc).selectedViewController];
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self topmostVCForVC:((UINavigationController *)vc).visibleViewController];
    } else if (vc.presentedViewController) {
        return [self topmostVCForVC:vc.presentedViewController];
    } else {
        return vc;
    }
}

@end
