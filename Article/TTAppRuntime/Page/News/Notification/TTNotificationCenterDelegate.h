//
//  TTNotificationCenterDelegate.h
//  Article
//
//  Created by 徐霜晴 on 16/8/25.
//
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface TTNotificationCenterDelegate : NSObject<UNUserNotificationCenterDelegate>

+ (instancetype)sharedNotificationCenterDelegate;
- (void)registerNotificationCenter;

- (void)applicationDidComeToForeground;

// 使用 iOS 10 新增的 UNNotification API 实现清红点但不清系统通知列表
// 1. 参考 https://stackoverflow.com/questions/41210373/ios-10-2-usernotifications-problems-on-simple-alert-and-badge/42102863#42102863
// 2. 参考网易新闻的用法
- (void)sendClearBadgeNotification API_AVAILABLE(ios(10.0));

@end
