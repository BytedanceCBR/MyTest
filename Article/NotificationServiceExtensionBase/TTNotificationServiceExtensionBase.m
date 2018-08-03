//
//  NotificationServiceExtensionBase.m
//  Article
//
//  Created by 徐霜晴 on 16/8/30.
//
//

#import "TTNotificationServiceExtensionBase.h"

#define WeakSelf   __weak typeof(self) wself = self
#define StrongSelf __strong typeof(wself) self = wself

@interface TTNotificationServiceExtensionBase ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation TTNotificationServiceExtensionBase

- (void)downloadAttatchmentWithURL:(NSURL *)url
                        completion:(void (^)(NSURL *localURL))completion {
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url
                                                                             completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                                 if (location) {
                                                                                     NSURL *cacheDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]];
                                                                                     NSURL *attatchmentsDir = [cacheDirectoryPath URLByAppendingPathComponent:@"attatchments"];
                                                                                     NSError * createDireError = nil;
                                                                                     BOOL isDirectory = NO;
                                                                                     if (![[NSFileManager defaultManager] fileExistsAtPath:[attatchmentsDir path] isDirectory:&isDirectory]) {
                                                                                         [[NSFileManager defaultManager] createDirectoryAtPath:[attatchmentsDir path] withIntermediateDirectories:YES attributes:nil error:&createDireError];
                                                                                     }
                                                                                     
                                                                                     NSString *uuid = [[NSUUID UUID] UUIDString];
                                                                                     NSString *fileName = [uuid stringByAppendingString:[response suggestedFilename]];
                                                                                     
                                                                                     NSURL *cacheURL = [attatchmentsDir URLByAppendingPathComponent:fileName];
                                                                                     NSError *moveItemError = nil;
                                                                                     BOOL moveSucceed = [[NSFileManager defaultManager] moveItemAtURL:location toURL:cacheURL error:&moveItemError];
                                                                                     if (completion) {
                                                                                         completion(moveSucceed ? cacheURL : nil);
                                                                                     }
                                                                                 }
                                                                                 else {
                                                                                     if (completion) {
                                                                                         completion(nil);
                                                                                     }
                                                                                 }
                                                                             }];
    [downloadTask resume];
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // iOS 10 Push锁屏统计相关，参照：
    // http://stackoverflow.com/questions/27933666/finding-out-if-the-device-is-locked-from-a-notification-widget
    NSString *suiteName = @"group.todayExtenstionShareDefaults";
    NSString *bundleInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSRange resRange = [bundleInfo rangeOfString:@"inHouse" options:NSCaseInsensitiveSearch];
    if (resRange.location != NSNotFound) {
        suiteName = @"group.com.ss.iphone.InHouse.article.News.ShareDefaults";;
    }
    
    NSURL *directoryURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:suiteName];
    NSString *checkfilePath = [directoryURL.path stringByAppendingPathComponent:@"security.dummy"];
    NSError *error = nil;
    NSData *data __unused = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:checkfilePath] options: NSDataReadingMappedIfSafe error:&error];
    
    BOOL locked = NO;
    if (error != nil && error.code == 257) {
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
    
    // 使用new_alert的内容覆盖推送标题和内容
    NSDictionary *userInfo = request.content.userInfo;
    NSDictionary *newAlert = userInfo[@"new_alert"];
    if (newAlert && [newAlert isKindOfClass:[NSDictionary class]]) {
        NSString *title = newAlert[@"title"];
        NSString *content = newAlert[@"content"];
        if (title && [title isKindOfClass:[NSString class]] && title.length > 0) {
            self.bestAttemptContent.title = title;
        }
        if (content && [content isKindOfClass:[NSString class]] && content.length > 0) {
            self.bestAttemptContent.body = content;
        }
    }
    
    // 添加附件
    NSString *attachmentLink = userInfo[@"attachment"];
    if (attachmentLink && [attachmentLink isKindOfClass:[NSString class]] && attachmentLink.length > 0) {
        NSURL *attachmentURL = [NSURL URLWithString:attachmentLink];
        if (attachmentURL) {
            WeakSelf;
            [self downloadAttatchmentWithURL:attachmentURL
                                  completion:^(NSURL *localURL) {
                                      StrongSelf;
                                      if (localURL) {
                                          NSError *error = nil;
                                          UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"identifier"
                                                                                                                                URL:localURL
                                                                                                                            options:nil
                                                                                                                              error:&error];
                                          if (attachment) {
                                              self.bestAttemptContent.attachments = @[attachment];
                                          }
                                      }
                                      contentHandler(self.bestAttemptContent);
                                  }];
        }
        else {
            contentHandler(self.bestAttemptContent);
        }
    }
    else {
        contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
