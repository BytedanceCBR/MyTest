//
//  FHPushAuthorizeHelper.m
//  FHCHousePush
//
//  Created by 张静 on 2019/5/22.
//

#import "FHPushAuthorizeHelper.h"

static NSString * const kFHPushArticleAlertKey = @"kFHPushArticleAlertKey";
static NSString * const kFHPushFollowAlertKey = @"kFHPushFollowAlertKey";
static NSString * const kFHPushMessageTipKey = @"kFHPushMessageTipKey";

@implementation FHPushAuthorizeHelper

+ (void)setLastTimeShowArticleAlert:(NSInteger)lastTimeShowArticleAlert
{
    [[NSUserDefaults standardUserDefaults]setInteger:lastTimeShowArticleAlert forKey:kFHPushArticleAlertKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)lastTimeShowArticleAlert
{
    return [[NSUserDefaults standardUserDefaults]integerForKey:kFHPushArticleAlertKey];
}

+ (void)setLastTimeShowFollowAlert:(NSInteger)lastTimeShowFollowAlert
{
    [[NSUserDefaults standardUserDefaults]setInteger:lastTimeShowFollowAlert forKey:kFHPushFollowAlertKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)lastTimeShowFollowAlert
{
    return [[NSUserDefaults standardUserDefaults]integerForKey:kFHPushFollowAlertKey];
}

+ (void)setLastTimeShowMessageTip:(NSInteger)lastTimeShowMessageTip
{
    [[NSUserDefaults standardUserDefaults]setInteger:lastTimeShowMessageTip forKey:kFHPushMessageTipKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)lastTimeShowMessageTip
{
    return [[NSUserDefaults standardUserDefaults]integerForKey:kFHPushMessageTipKey];
}

@end
