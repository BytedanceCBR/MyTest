//
//  TTRefreshView+HomePage.m
//  Article
//
//  Created by 张元科 on 2018/11/21.
//

#import "TTRefreshView+HomePage.h"
#import "TTArticleTabBarController.h"
#import "TTTabbar.h"
#import "TTBadgeNumberView.h"
#import "TTSegmentedControl.h"
#import "TTExploreMainViewController.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTRefreshView.h"
#import "TTNavigationController.h"

NSString * const kHomePagePullDownNotification  = @"kHomePagePullDownNotification";

@interface UIViewController (HomePageVC)

+ (BOOL)isCurrentShownMainHomeVC;

@end

@implementation TTRefreshView (HomePage)

+ (void)load
{
    Method doHandlerMethod = class_getInstanceMethod(self, @selector(doHandler));
    Method doHandlerMainPageMethod = class_getInstanceMethod(self, @selector(doHandler_mainPage));
    if (doHandlerMethod && doHandlerMainPageMethod) {
        method_exchangeImplementations(doHandlerMethod, doHandlerMainPageMethod);
    }
}

- (void)doHandler_mainPage {
    BOOL isHomePageVC = [UIViewController isCurrentShownMainHomeVC];
    if (isHomePageVC && ([self direction] == PULL_DIRECTION_DOWN)) {
        // 首页下拉刷新
        NSDictionary *userInfo =  [NSDictionary dictionaryWithObject:@(YES) forKey:@"needPullDownData"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomePagePullDownNotification object:nil userInfo:userInfo];
    }
    
    [self doHandler_mainPage];
}

@end


@implementation UIViewController (HomePageVC)

+ (BOOL)isCurrentShownMainHomeVC {
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    if ([mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        TTArticleTabBarController *tabbarVC = (TTArticleTabBarController *)mainWindow.rootViewController;
        if (tabbarVC.selectedIndex == 0) {
            if ([tabbarVC.selectedViewController isKindOfClass:[TTNavigationController class]]) {
                TTNavigationController *navVC = (TTNavigationController *)tabbarVC.selectedViewController;
                UIViewController *vc = navVC.viewControllers.lastObject;
                if ([vc isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
