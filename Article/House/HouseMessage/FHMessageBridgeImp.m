//
//  FHMessageBridgeImp.m
//  NewsLite
//
//  Created by 谢思铭 on 2019/2/17.
//

#import "FHMessageBridgeImp.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"

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
    TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
    TTBadgeNumberView *badgeView = tabBarItem.ttBadgeView;
    NSInteger msgCount = number;
    NSInteger tabMsgCount = badgeView.badgeNumber;
    tabMsgCount -= msgCount;
    tabMsgCount = tabMsgCount >= 0 ? tabMsgCount : 0;
    badgeView.badgeNumber = tabMsgCount;
}



@end
