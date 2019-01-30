//
//  TTiOS10NotificationCheckTask.m
//  Article
//
//  Created by chenren on 04/05/2017.
//
//

#import "TTiOS10NotificationCheckTask.h"
#import "TTTrackerWrapper.h"

@implementation TTiOS10NotificationCheckTask

- (void)setupLockedFile
{
    NSString *suiteName = [self suiteName];
    NSURL *directoryURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:suiteName];
    NSString *lockfilePath = [directoryURL.path stringByAppendingPathComponent:@"security.dummy"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:lockfilePath error:&error];
    [[NSFileManager defaultManager] createFileAtPath:lockfilePath
                                            contents:[@"iOS10NotificationCheck" dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:@{NSFileProtectionKey: NSFileProtectionComplete}];
}

- (BOOL)isResident
{
    return YES;
}

- (NSString *)taskIdentifier
{
    return @"iOS10NotificationCheck";
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // iOS 10 Push统计相关
    [self setupLockedFile];
    [self checkPushNotifications];
}

- (void)checkPushNotifications
{
    NSString *suiteName = [self suiteName];
    NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    NSString *info = [sharedUserDefaults valueForKey:@"notificationInfo"];
    if (info) {
        [TTTrackerWrapper event:@"apn" label:@"iOS10_locked_push" value:info extValue:nil extValue2:nil dict:nil];
        [sharedUserDefaults removeObjectForKey:@"notificationInfo"];
        [sharedUserDefaults synchronize];
    }
}

- (NSString *)suiteName
{
//    NSString *suiteName = @"group.todayExtenstionShareDefaults";
//    NSString *bundleInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
//    NSRange resRange = [bundleInfo rangeOfString:@"inHouse" options:NSCaseInsensitiveSearch];
//    if (resRange.location != NSNotFound) {
//        suiteName = @"group.com.ss.iphone.InHouse.article.News.ShareDefaults";;
//    }

    NSString *suiteName = @"group.com.f100.client.extension";
    return suiteName;
}

@end
