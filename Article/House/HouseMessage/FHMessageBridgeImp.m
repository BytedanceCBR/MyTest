//
//  FHMessageBridgeImp.m
//  NewsLite
//
//  Created by 谢思铭 on 2019/2/17.
//

#import "FHMessageBridgeImp.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import "FHEnvContext.h"
#import "FHMessageManager.h"

@implementation FHMessageBridgeImp

- (NSInteger)getMessageTabBarBadgeNumber {
    TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
    return tabBarItem.ttBadgeView.badgeNumber;
}

- (void)clearMessageTabBarBadgeNumber {
    TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
    tabBarItem.ttBadgeView.badgeNumber = TTBadgeNumberHidden;
}

- (void)reduceMessageTabBarBadgeNumber:(NSInteger)number {
    [[FHEnvContext sharedInstance].messageManager reduceSystemMessageTabBarBadgeNumber:number];
//    TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
//    TTBadgeNumberView *badgeView = tabBarItem.ttBadgeView;
//    NSInteger msgCount = number;
//    NSInteger tabMsgCount = badgeView.badgeNumber;
//    tabMsgCount -= msgCount;
//    tabMsgCount = tabMsgCount >= 0 ? tabMsgCount : 0;
//    badgeView.badgeNumber = tabMsgCount;
}

- (void)setMessageTabBadgeNumber:(NSInteger)number {
    TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
    if(number > 0){
        tabBarItem.ttBadgeView.badgeNumber = number;
    }else{
        tabBarItem.ttBadgeView.badgeNumber = TTBadgeNumberHidden;
    }
}

@end
