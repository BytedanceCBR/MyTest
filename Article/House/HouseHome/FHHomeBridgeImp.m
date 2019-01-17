//
//  FHHomeBridgeImp.m
//  Article
//
//  Created by 谢飞 on 2018/12/11.
//

#import "FHHomeBridgeImp.h"
#import "TTArticleCategoryManager.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import "TTLocationManager.h"
#import "CommonURLSetting.h"
#import "Bubble-Swift.h"
#import "TTTabBarManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import "TTTabBarProvider.h"

@implementation FHHomeBridgeImp

- (NSString *)feedStartCategoryName
{
    NSString * categoryStartName = [SSCommonLogic feedStartCategory];
    return categoryStartName;
}

- (NSString *)baseUrl
{
    return [CommonURLSetting baseURL];
}

- (NSString *)currentSelectCategoryName
{
    NSString * currentCategoryName = [TTArticleCategoryManager currentSelectedCategoryID];
    return currentCategoryName;
}

- (void)isShowTabbarScrollToTop:(BOOL)scrollToTop
{
    TTTabBarItem * currentTabbar = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kTTTabHomeTabKey];
    
    if (scrollToTop)
    {
        [currentTabbar setTitle:@"回到顶部"];
        [currentTabbar setNormalImage:[UIImage imageNamed:@"tab-home"] highlightedImage:[UIImage imageNamed:@"ic-tab-return-normal"] loadingImage:[UIImage imageNamed:@"tab-home_press"]];
    }else {
        [currentTabbar setTitle:@"首页"];
        [currentTabbar setNormalImage:[UIImage imageNamed:@"tab-home"] highlightedImage:[UIImage imageNamed:@"tab-home_press"] loadingImage:[UIImage imageNamed:@"tab-home_press"]];
    }
}

- (void)setUpLocationInfo:(NSDictionary *)dict
{
    [[TTLocationManager sharedManager] setUpAmapInfo:dict];
}

- (void)jumpCountryList:(UIViewController *)viewController
{
    NSURL *url = [[NSURL alloc] initWithString:@"sslocal://city_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:NULL];
}

- (void)jumpToTabbarFirst
{
    
    [[TTCategoryBadgeNumberManager sharedManager] updateNotifyBadgeNumberOfCategoryID:@"f_house_news" withShow:NO];
    [[EnvContext shared].client.messageManager startSyncCategoryBadge];
    
    NSString *firstTabItemIdentifier = [[TTTabBarManager sharedTTTabBarManager].tabItems firstObject].identifier;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:({
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:firstTabItemIdentifier forKey:@"tag"];
        [userInfo copy];
    })];
}

- (BOOL)isCurrentTabFirst
{
    if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
        return YES;
    }
    return NO;
}
@end
