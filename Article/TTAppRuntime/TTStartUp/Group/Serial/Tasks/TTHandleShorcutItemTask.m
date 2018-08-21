//
//  TTHandleShorcutItemTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTHandleShorcutItemTask.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTSettingMineTabEntry.h"
#import "TTSettingMineTabManager.h"

@implementation TTHandleShorcutItemTask

- (NSString *)taskIdentifier {
    return @"HanleShorcutItem";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
#ifdef __IPHONE_9_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        BOOL fromShortcut = ([launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey] != nil);
#pragma clang diagnostic pop
        if (fromShortcut) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            [[self class] handleShortcutItem:[launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey]];
#pragma clang diagnostic pop
        }
    }
#endif
}

#pragma mark - UIApplicationShortcutItem
#ifdef __IPHONE_9_0
//通过shortcutItem标签打开app后的处理
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
+ (void)handleShortcutItem:(UIApplicationShortcutItem *)item {
#pragma clang diagnostic pop
    //item的title作为url的host尝试打开
    NSURL *shortcutUrl = nil;
    if ([item.type isEqualToString:@"search"]) {
        shortcutUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://%@?", item.type]];
        wrapperTrackEvent(@"search_tab", @"enter_force_touch");
    } else if ([item.type isEqualToString:@"activity"]) {
        shortcutUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://target?action=change_tab&id=tab_ak_activity"]];
        wrapperTrackEvent(@"activity_tab", @"enter_force_touch");
    }
    
    if ([[TTRoute sharedRoute] canOpenURL:shortcutUrl]) {
        [[TTRoute sharedRoute] openURLByPushViewController:shortcutUrl];
    }
}
#endif

#ifdef __IPHONE_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
#pragma clang diagnostic pop
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [[self class] handleShortcutItem:shortcutItem];
    }
}
#endif

@end

