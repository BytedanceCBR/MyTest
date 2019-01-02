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
@end
