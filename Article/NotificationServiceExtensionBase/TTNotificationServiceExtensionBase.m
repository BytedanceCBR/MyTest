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

    // iOS 10 Push锁屏统计相关，参照：
    // http://stackoverflow.com/questions/27933666/finding-out-if-the-device-is-locked-from-a-notification-widget
//    NSString *suiteName = @"group.todayExtenstionShareDefaults";
//    NSString *bundleInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
//    NSRange resRange = [bundleInfo rangeOfString:@"inHouse" options:NSCaseInsensitiveSearch];
//    if (resRange.location != NSNotFound) {
//        suiteName = @"group.com.ss.iphone.InHouse.article.News.ShareDefaults";;
//    }
    //
    NSString *suiteName = @"group.com.f100.client.extension.new";
    NSString *bundleInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSRange resRange = [bundleInfo rangeOfString:@"fp1" options:NSCaseInsensitiveSearch];
    if (resRange.location != NSNotFound) {
        suiteName = @"group.com.fp1.extension";;
    }
    NSURL *directoryURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:suiteName];
    NSString *checkfilePath = [directoryURL.path stringByAppendingPathComponent:@"security.dummy"];
    NSError *error = nil;
    NSData *data __unused = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:checkfilePath] options: NSDataReadingMappedIfSafe error:&error];
    
    BOOL locked = NO;
    if (error != nil && error.code == 257) {
        NSLog(@"**** the keychain appears to be locked, using the file method");
        locked = YES;
    }
    if (locked) {
        NSDictionary *pushUserInfo = request.content.userInfo;
        __block NSString *gidString = pushUserInfo[@"group_id"];
        if (gidString.length == 0) {
            NSURL* url = [NSURL URLWithString:pushUserInfo[@"o_url"]];
            NSArray *paramsList = [url.query componentsSeparatedByString:@"&"];
            [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
                NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
                if ([keyAndValue count] > 1) {
                    NSString *paramKey = [keyAndValue objectAtIndex:0];
                    NSString *paramValue = [keyAndValue objectAtIndex:1];
                    if ([paramValue rangeOfString:@"%"].length > 0) {
                        paramValue = [paramValue stringByRemovingPercentEncoding];
                    }
                    
                    if ([paramKey isEqualToString:@"groupid"] && paramValue) {
                        gidString = paramValue;
                        *stop = YES;
                    }
                }
            }];
        }
        if (gidString.length == 0) {
            gidString = @"00000000000000000000";
        }
        
        NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
        NSString *infoString = [sharedUserDefaults valueForKey:@"notificationInfo"];
        NSDate *now = [NSDate date];
        NSString *unixTimestamp = [NSString stringWithFormat:@"%ld", (long)[now timeIntervalSince1970]];
        if (infoString) {
            NSString *newString = [infoString stringByAppendingString:@","];
            newString = [newString stringByAppendingString:gidString];
            newString = [newString stringByAppendingString:@" "];
            newString = [newString stringByAppendingString:unixTimestamp];
            [sharedUserDefaults setObject:newString forKey:@"notificationInfo"];
        } else {
            NSString *infoString = [gidString stringByAppendingString:@" "];
            infoString = [infoString stringByAppendingString:unixTimestamp];
            [sharedUserDefaults setObject:infoString forKey:@"notificationInfo"];
        }
        [sharedUserDefaults synchronize];
    }
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
