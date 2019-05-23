//
//  FHPushAuthorizeManager.m
//  FHCHousePush
//
//  Created by 张静 on 2019/5/22.
//

#import "FHPushAuthorizeManager.h"
#import "FHPushAuthorizeHelper.h"
#import "FHPushAuthorizeAlertView.h"
#import <FHHouseBase/FHUserTracker.h>

#define kPushShowArticleInterval (5) // 文章
#define kPushShowFollowInterval (5) // 关注
#define kPushShowMessageInterval (3) // 消息

@interface FHPushAuthorizeManager ()

@end

@implementation FHPushAuthorizeManager

+ (void)showArticleAlertIfNeeded:(NSDictionary *)params
{
    BOOL isArticleAlertEnabled = [self isArticleAlertEnabled];
    if (!isArticleAlertEnabled) {
        return;
    }
    FHPushAuthorizeAlertView *alert = [[FHPushAuthorizeAlertView alloc]initAuthorizeHintWithImageName:@"push_alert_price" title:@"房源一降价，立刻提醒我！" message:@"打开推送获取及时通知" confirmBtnTitle:@"打开通知" completed:^(FHAuthorizeHintCompleteType type) {
        NSMutableDictionary *paramDict = @{}.mutableCopy;
        if (type == FHAuthorizeHintCompleteTypeDone) {
            paramDict[@"click_type"] = @"confirm";
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }else {
            paramDict[@"click_type"] = @"cancel";
        }
        if (params.count > 0) {
            [paramDict addEntriesFromDictionary:paramDict];
        }
        [FHUserTracker writeEvent:@"article_tip_click" params:paramDict];
    }];
    [alert show];
    NSInteger lastTimeShowArticleAlert = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [FHPushAuthorizeHelper setLastTimeShowArticleAlert:lastTimeShowArticleAlert];
    
    [FHUserTracker writeEvent:@"article_tip_show" params:params];
}

+ (void)showFollowAlertIfNeeded:(NSDictionary *)params
{
    FHPushAuthorizeAlertView *alert = [[FHPushAuthorizeAlertView alloc]initAuthorizeHintWithImageName:@"push_alert_article" title:@"别错过楼市重要资讯！" message:@"打开推送即可获取最新消息" confirmBtnTitle:@"打开通知" completed:^(FHAuthorizeHintCompleteType type) {
        NSMutableDictionary *paramDict = @{}.mutableCopy;
        if (params.count > 0) {
            [paramDict addEntriesFromDictionary:params];
        }
        if (type == FHAuthorizeHintCompleteTypeDone) {
            paramDict[@"click_type"] = @"confirm";
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }else {
            paramDict[@"click_type"] = @"cancel";
        }

        [FHUserTracker writeEvent:@"tip_click" params:paramDict];
    }];
    [alert show];
    NSInteger lastTimeShowFollowAlert = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [FHPushAuthorizeHelper setLastTimeShowFollowAlert:lastTimeShowFollowAlert];
    
    [FHUserTracker writeEvent:@"tip_show" params:params];
}

+ (BOOL)isArticleAlertEnabled
{
    if ([self.class isAPNSEnabled]) {
        return NO;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - [FHPushAuthorizeHelper lastTimeShowArticleAlert];
    if (interval / (24 * 60 * 60) < kPushShowArticleInterval) {
        return NO;
    }
    return YES;
}

+ (BOOL)isFollowAlertEnabled
{
    if ([self isAPNSEnabled]) {
        return NO;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - [FHPushAuthorizeHelper lastTimeShowFollowAlert];
    if (interval / (24 * 60 * 60) < kPushShowFollowInterval) {
        return NO;
    }
    return YES;
}

+ (BOOL)isMessageTipEnabled
{
    if ([self isAPNSEnabled]) {
        return NO;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - [FHPushAuthorizeHelper lastTimeShowMessageTip];
    if (interval / (24 * 60 * 60) < kPushShowMessageInterval) {
        return NO;
    }
    return YES;
}

+ (BOOL)isAPNSEnabled
{
    BOOL enabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    return enabled;
}


@end
