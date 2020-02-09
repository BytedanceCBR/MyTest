//
//  TTTabBarProvider.m
//  Article
//
//  Created by fengyadong on 2017/12/15.
//

#import "TTTabBarProvider.h"
#import "TTArticleTabBarController.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTVVideoTabViewController.h"
#import "TTVideoTabViewController.h"
//#import "TTWeitoutiaoViewController.h"
//#import "TTSFActivityMainViewController.h"
//#import "TTFollowWebViewController.h"
#import "TTProfileViewController.h"
#import "TTSettingsManager.h"
//#import "TTUGCPermissionService.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTTabbar.h"
//#import "SSCommonLogic+TTSFActivityStatus.h"
#import "TTNavigationController.h"
#import "TTVSettingsConfiguration.h"
#import "TTTabbar.h"
#import "TTVSettingsConfiguration.h"
#import "TTSegmentedControl.h"
//#import "TTSFActivityManager.h"
//#import "TTSFResourcesManager.h"
#import "FHMessageViewController.h"
#import "FHMineViewController.h"
#import <FHHouseFind/FHHouseFindViewController.h>
#import <BDABTestSDK/BDABTestManager.h>
#import "SSCommonLogic.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <FHHouseUGC/FHCommunityViewController.h>
#import "FHHomeViewController.h"
#import "FHHomeMainViewController.h"
#import "FHConfigModel.h"
#import "FHEnvContext.h"
#import "FHHouseESituationViewController.h"

NSString *kTTMiddleTabDidChangeNotification = @"kTTMiddleTabDidChangeNotification";

static NSString *lastTabIdentifier;

@implementation TTTabBarProvider

+ (void)initialize {
    if (self == [TTTabBarProvider class]) {
        lastTabIdentifier = [self priorMiddleTabIdentifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMiddleTabIdentifierDidReceiveNote:) name:TTSettingsManagerDidUpdateNotification object:nil];
    }
}

+ (void)updateMiddleTabIdentifierDidReceiveNote:(NSNotification *)notification {
    NSString *curIndetifier = [self priorMiddleTabIdentifier];
    if (![curIndetifier isEqualToString:lastTabIdentifier]) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:lastTabIdentifier forKey:@"last"];
        [userInfo setValue:curIndetifier forKey:@"current"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTMiddleTabDidChangeNotification object:nil userInfo:[userInfo copy]];
        lastTabIdentifier = curIndetifier;
    }
}

+ (UINavigationController *)naviVCForIdentifier:(NSString *)identifier {
    UIViewController *rootVC = [self rootVCForIdentifier:identifier];
    UINavigationController *naviVC = [self naviWithRootVC:rootVC];
    
    return naviVC;
}

+ (UIViewController *)rootVCForIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:kTTTabHomeTabKey]) {
        UIViewController *homeVC;
//        homeVC = [[FHHomeViewController alloc] init];
        homeVC = [[FHHomeMainViewController alloc] init];
//        homeVC = [[ArticleTabBarStyleNewsListViewController alloc] init];
        return homeVC;
    } else if ([identifier isEqualToString:kTTTabVideoTabKey]) {
        UIViewController *videoVC;
        BOOL isTitanVideoBusiness = ttvs_isTitanVideoBusiness();
        if (isTitanVideoBusiness) {
            videoVC = [[TTVVideoTabViewController alloc] init];
        }
        else{
            videoVC = [[TTVideoTabViewController alloc] init];
        }
        return videoVC;
    }
//    else if ([identifier isEqualToString:kTTTabFollowTabKey]) {
//        return [[TTFollowWebViewController alloc] init];
//    }
    else if ([identifier isEqualToString:kTTTabMineTabKey]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        TTProfileViewController *profileVC = [sb instantiateInitialViewController];
        return profileVC;
    }
//    else if ([identifier isEqualToString:kTTTabWeitoutiaoTabKey]) {
//        return [[TTWeitoutiaoViewController alloc] init];
//    }
//    else if ([identifier isEqualToString:kTTTabHTSTabKey]) {
//        UIViewController *shortVideoTabVC = [[TTHTSTabViewController alloc] init];
//        return shortVideoTabVC;
//    }
//    else if ([identifier isEqualToString:kAKTabActivityTabKey]) {
//        AKActivityViewController *vc = [[AKActivityViewController alloc] init];
//        [vc preloadPage];
//        return vc;
//    }
    else if ([identifier isEqualToString:kFHouseFindTabKey]) {

//        UIViewController *houseFindVC = nil;
//        if ([SSCommonLogic findTabShowHouse] == 1) {
//            houseFindVC = [[FHHouseFindListViewController alloc]init];
//
//        }else {
//            houseFindVC = [[FHHouseFindViewController alloc] init];
//        }
        FHCommunityViewController *communityVC = [[FHCommunityViewController alloc] init];
        
        return communityVC;

    } else if ([identifier isEqualToString:kFHouseMessageTabKey]) {
        FHMessageViewController* vc = [[FHMessageViewController alloc] init];
        return vc;
    } else if ([identifier isEqualToString:kFHouseMineTabKey]) {
        FHMineViewController* vc = [[FHMineViewController alloc] init];
//        MineVC* vc = [[MineVC alloc] init];
        return vc;
    } else if ([identifier isEqualToString:kFHouseHouseEpidemicSituationTabKey]) {
        FHHouseESituationViewController* vc = [[FHHouseESituationViewController alloc] init];
        //        MineVC* vc = [[MineVC alloc] init];
        return vc;
    }
    
    return nil;
}

// 下面几个 contructXX 里面的重复代码抽出来了
+ (TTNavigationController *)naviWithRootVC:(UIViewController *)rootViewController {
    TTNavigationController *navi =
    [[TTNavigationController alloc] initWithRootViewController:rootViewController];
    navi.ttNavBarStyle = @"White";
    navi.ttDefaultNavBarStyle = @"White";
    return navi;
}

+ (NSArray<NSString *> *)allSupportedTags {
    return @[kTTTabHomeTabKey,kTTTabVideoTabKey,kTTTabFollowTabKey,kTTTabMineTabKey,kTTTabWeitoutiaoTabKey,kTTTabHTSTabKey];//,kAKTabActivityTabKey];
}

+ (NSString *)priorMiddleTabIdentifier {
    
    //默认中间的tab是百万英雄活动页
//    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{@"middle_tab":@{@"tab_name":kTTTabActivityTabKey,@"url":@"sslocal://fantasy?enter_from=click_bottom"}} freeze:NO];
//    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{} freeze:NO];
//
//    NSDictionary *middleTabConfig = [tabListConfig tt_dictionaryValueForKey:@"middle_tab"];
//
//    NSString *identifier = [middleTabConfig tt_stringValueForKey:@"tab_name"];
    FHConfigCenterTabModel *centerTabConfig = [[FHEnvContext sharedInstance] getConfigFromCache].opTab;
    NSString *identifier = centerTabConfig.enable?kFHouseHouseEpidemicSituationTabKey:@"";
    
    return identifier;
}

+ (NSString *)priorMiddleTabSchema {
    //默认中间的tab是百万英雄活动页
//    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{@"middle_tab":@{@"tab_name":kTTTabActivityTabKey,@"url":@"sslocal://fantasy?enter_from=click_bottom"}} freeze:NO];
//
//    NSDictionary *middleTabConfig = [tabListConfig tt_dictionaryValueForKey:@"middle_tab"];
    FHConfigCenterTabModel *centerTabConfig = [[FHEnvContext sharedInstance] getConfigFromCache].opTab;
    
    NSString *schema = centerTabConfig.openUrl;
    
    return schema;
}

+ (BOOL)hasPriorMiddleTab {
    
    NSString *identifier = [self priorMiddleTabIdentifier];
    
    BOOL isValid = [self isValidForMiddleTabIdenftifier:identifier];
    
    return isValid;
}

+ (BOOL)hasCustomMiddleButton {
    
//    NSString *identifier = [self priorMiddleTabIdentifier];
//    NSString *schema = [self priorMiddleTabSchema];
//    return !isEmptyString(identifier) && !isEmptyString(schema) && [[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:schema]];
    FHConfigCenterTabModel *centerTabConfig = [[FHEnvContext sharedInstance] getConfigFromCache].opTab;

    return centerTabConfig.enable;
}

+ (NSArray<NSString *> *)confTabList {
//#warning TTSF_TEST_MODE
//#ifdef DEBUG
//    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{@"normal_tabs":@[kTTTabWeitoutiaoTabKey,kTTTabMineTabKey]} freeze:NO];
//#else
    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{} freeze:NO];
//#endif

    return [tabListConfig tt_arrayValueForKey:@"normal_tabs"];
}

+ (BOOL)isPublishButtonOnTabBar {
    //pm@李想说发布器入口全量切到topbar的右侧
    return NO;
//    return [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCEntrancePosition] == TTPostUGCEntrancePositionTabbar && ![self hasPriorMiddleTab];
}

+ (BOOL)isPublishButtonOnTopBar {
    return NO;
}

+ (BOOL)isMineTabOnTabBar {
    return [[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:kTTTabMineTabKey];
}

+ (BOOL)isHTSTabOnTabBar {
    return [[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:kTTTabHTSTabKey];
}

+ (BOOL)isFollowTabOnTabBar {
    return [[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:kTTTabFollowTabKey];
}

+ (BOOL)isWeitoutiaoOnTabBar {
    return [[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:kTTTabWeitoutiaoTabKey];
}

+ (NSString *)currentSelectedTabTag {
    NSString *tag;
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    if (!mainWindow || ![mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        return @"unknown";
    }
    TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
    
    NSUInteger index = tabBarController.selectedIndex;
    
    TTTabbar *tabBar = ((TTTabbar *)tabBarController.tabBar);
    
    if (index >= tabBar.tabItems.count) {
        return @"unknown";
    }
    
    tag = [tabBar.tabItems objectAtIndex:index].identifier;
    
    return tag;
}

+ (BOOL)isValidForMiddleTabIdenftifier:(NSString *)identifier {
    return YES;
}

@end
