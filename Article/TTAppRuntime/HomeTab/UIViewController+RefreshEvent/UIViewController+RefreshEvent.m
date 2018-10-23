//
//  UIViewController+RefreshEvent.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/30.
//
//

#import "UIViewController+RefreshEvent.h"
#import "TTArticleTabBarController.h"
#import "TTTabbar.h"
#import "TTBadgeNumberView.h"
#import "TTSegmentedControl.h"
#import "TTCategory.h"
#import "TTNavigationController.h"

@implementation UIViewController (RefreshEvent)

- (NSString *)modifyEventLabelForRefreshEvent:(NSString *)label
                                categoryModel:(TTCategory *)model{
    NSMutableString *muLabel = [NSMutableString stringWithString:label];
    //这种判断事件的只针对存在频道ID的情况下进行
    if(!isEmptyString(model.categoryID)){
        if(![model.categoryID isEqualToString:kTTMainCategoryID]){
            [muLabel appendFormat:@"_%@",model.categoryID];
        }
    }
    return [muLabel copy];
}

//针对当前频道的统计事件，需要考虑tabbar上是否有提示的情况
- (BOOL)isTabbarHasTip{
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    if ([mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        TTArticleTabBarController *tabbarVC = (TTArticleTabBarController *)mainWindow.rootViewController;
        if([tabbarVC.tabBar isKindOfClass:[TTTabbar class]]){
            TTTabbar *tabbar = (TTTabbar *)tabbarVC.tabBar;
            if(tabbarVC.selectedIndex < tabbar.tabItems.count){
                TTBadgeNumberView *badgeView = [tabbar.tabItems[tabbarVC.selectedIndex] ttBadgeView];
                if(badgeView.hidden){
                    return NO;
                }
                else{
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
