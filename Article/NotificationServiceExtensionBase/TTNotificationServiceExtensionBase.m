//
//  NotificationServiceExtensionBase.m
//  Article
//
//  Created by 徐霜晴 on 16/8/30.
//
//

#import "TTNotificationServiceExtensionBase.h"
#import <BDUGPushSDK/BDUGPushExtension.h>

#define WeakSelf   __weak typeof(self) wself = self
#define StrongSelf __strong typeof(wself) self = wself

API_AVAILABLE(ios(10.0))
@interface TTNotificationServiceExtensionBase ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation TTNotificationServiceExtensionBase

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    //交给push sdk处理
    WeakSelf;
    [[BDUGPushExtension defaultManager] handleNotificationServiceRequest:request withAttachmentsComplete:^(UNMutableNotificationContent * _Nonnull notificationContent, NSError * _Nonnull error) {
        StrongSelf;
        self.bestAttemptContent = notificationContent;
        contentHandler(notificationContent ?: request.content);
    }];
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
