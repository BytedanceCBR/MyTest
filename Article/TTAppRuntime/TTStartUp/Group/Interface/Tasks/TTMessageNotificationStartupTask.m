//
//  TTMessageNotificationStartupTask.m
//  Article
//
//  Created by 邱鑫玥 on 2017/5/3.
//
//

#import "TTMessageNotificationStartupTask.h"
#import "TTMessageNotificationManager.h"
#import "ArticleMessageManager.h"

@implementation TTMessageNotificationStartupTask

- (NSString *)taskIdentifier {
    return @"MessageNotification";
}

#pragma mark - UIApplicationDelegate Method
- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    //新消息通知定时轮询未读消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TTMessageNotificationManager sharedManager] startPeriodicalFetchUnreadMessageNumberWithChannel:nil];
        [ArticleMessageManager startPeriodicalGetFollowNumber];
    });
}

@end
