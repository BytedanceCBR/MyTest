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
#import "TSVTabViewController.h"
#import "TTHTSTabViewController.h"
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
#import "AKActivityViewController.h"
#import "Bubble-Swift.h"
#import "FHHouseFindListViewController.h"

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
        if ([SSCommonLogic shouldUseOptimisedLaunch]) {
            homeVC = [[ArticleTabBarStyleNewsListViewController alloc] init];
        } else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"News" bundle:nil];
            homeVC = [sb instantiateInitialViewController];
        }
        return homeVC;
    } else if ([identifier isEqualToString:kTTTabVideoTabKey]) {
        UIViewController *videoVC;
        BOOL isTitanVideoBusiness = ttvs_isTitanVideoBusiness();
        if ([SSCommonLogic shouldUseOptimisedLaunch]) {
            if (isTitanVideoBusiness) {
                videoVC = [[TTVVideoTabViewController alloc] init];
            }
            else{
                videoVC = [[TTVideoTabViewController alloc] init];
            }
        } else {
            NSString *stroyBoradName = isTitanVideoBusiness? @"TTVTab":@"Video";
            UIStoryboard *sb = [UIStoryboard storyboardWithName:stroyBoradName bundle:nil];
            videoVC = [sb instantiateInitialViewController];
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
    else if ([identifier isEqualToString:kTTTabHTSTabKey]) {
        UIViewController *shortVideoTabVC = nil;
        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_tab_sub_category_enable" defaultValue:@0 freeze:YES] boolValue]) {
            shortVideoTabVC = [[TSVTabViewController alloc] init];
        } else {
            shortVideoTabVC = [[TTHTSTabViewController alloc] init];
        }
        return shortVideoTabVC;
    } else if ([identifier isEqualToString:kAKTabActivityTabKey]) {
        AKActivityViewController *vc = [[AKActivityViewController alloc] init];
        [vc preloadPage];
        return vc;
    } else if ([identifier isEqualToString:kFHouseFindTabKey]) {
        
        // add by zjing for test
        UIViewController *houseFindVC = nil;

        if (1) {
            houseFindVC = [[FHHouseFindListViewController alloc]init];

        }else {
           houseFindVC = [[HouseFindVC alloc] init];

        }
        return houseFindVC;

    } else if ([identifier isEqualToString:kFHouseMessageTabKey]) {
        ChatVC* vc = [[ChatVC alloc] init];
        return vc;
    } else if ([identifier isEqualToString:kFHouseMineTabKey]) {
        MineVC* vc = [[MineVC alloc] init];
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
    return @[kTTTabHomeTabKey,kTTTabVideoTabKey,kTTTabFollowTabKey,kTTTabMineTabKey,kTTTabWeitoutiaoTabKey,kTTTabHTSTabKey,kAKTabActivityTabKey];
}

+ (NSString *)priorMiddleTabIdentifier {
    //默认中间的tab是百万英雄活动页
//    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{@"middle_tab":@{@"tab_name":kTTTabActivityTabKey,@"url":@"sslocal://fantasy?enter_from=click_bottom"}} freeze:NO];
    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{} freeze:NO];
    
    NSDictionary *middleTabConfig = [tabListConfig tt_dictionaryValueForKey:@"middle_tab"];
    
    NSString *identifier = [middleTabConfig tt_stringValueForKey:@"tab_name"];
    
    return identifier;
}

+ (NSString *)priorMiddleTabSchema {
    //默认中间的tab是百万英雄活动页
    NSDictionary *tabListConfig = [[TTSettingsManager sharedManager] settingForKey:@"tt_tab_list_config" defaultValue:@{@"middle_tab":@{@"tab_name":kTTTabActivityTabKey,@"url":@"sslocal://fantasy?enter_from=click_bottom"}} freeze:NO];
    
    NSDictionary *middleTabConfig = [tabListConfig tt_dictionaryValueForKey:@"middle_tab"];
    
    NSString *schema = [middleTabConfig tt_stringValueForKey:@"url"];
    
    return schema;
}

+ (BOOL)hasPriorMiddleTab {
    
    NSString *identifier = [self priorMiddleTabIdentifier];
    
    BOOL isValid = [self isValidForMiddleTabIdenftifier:identifier];
    
    return isValid;
}

+ (BOOL)hasCustomMiddleButton {
    NSString *identifier = [self priorMiddleTabIdentifier];
    NSString *schema = [self priorMiddleTabSchema];
    return !isEmptyString(identifier) && !isEmptyString(schema) && [[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:schema]];
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
