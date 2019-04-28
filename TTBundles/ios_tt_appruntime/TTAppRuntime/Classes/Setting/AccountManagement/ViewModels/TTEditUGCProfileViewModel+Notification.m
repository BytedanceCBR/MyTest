//
//  TTEditUGCProfileViewModel+Notification.m
//  Article
//
//  Created by liuzuopeng on 8/25/16.
//
//

#import "TTEditUGCProfileViewModel+Notification.h"



@implementation TTEditUGCProfileViewModel (Notification)

- (void)registerNotifications
{
    [super registerNotifications];
}

- (void)unregisterNotifications
{
    [super unregisterNotifications];
}


- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    [self reloadViewModel];
}

@end
