//
//  UIViewController+TTMovieUtil.m
//  Article
//
//  Created by songxiangwu on 2016/10/31.
//
//

#import "UIViewController+TTMovieUtil.h"

NSString *ttv_getFormattedTimeStrOfPlay(NSTimeInterval playTimeInterval)
{
    int hour = (int)playTimeInterval / 3600;
    int minute = ((int)playTimeInterval / 60) % 60;
    int second = (int)playTimeInterval % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02i:%02i", minute, second];
    if (hour > 0) {
        timeStr = [NSString stringWithFormat:@"%02i:%02i:%02i", hour, minute, second];
    }
    return timeStr;
}

@implementation UIViewController (TTMovieUtil)

+ (UIViewController *)ttmu_currentViewController {
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [UIViewController ttmu_findBestViewController:viewController];
}

+ (UIViewController *)ttmu_findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [UIViewController ttmu_findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController ttmu_findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController ttmu_findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController ttmu_findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

@end
