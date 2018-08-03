//
//  AKTaskSettingHelper.m
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import "AKRedPacketManager.h"
#import "AKTaskSettingDefine.h"
#import "AKTaskSettingHelper.h"
#import "AKActivityTabManager.h"
#import <TTSettingsManager.h>
@implementation AKTaskSettingHelper

static AKTaskSettingHelper *shareInstance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AKTaskSettingHelper alloc] init];
    });
    return shareInstance;
}

- (BOOL)isEnableShowCoinTip
{
    BOOL enable = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKeySettingShowConinTip]) {
        enable = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeySettingShowConinTip];
    }
    return enable && self.akBenefitEnable;
}

- (void)setShowCoinTip:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kUserDefaultKeySettingShowConinTip];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isEnableShowTaskEntrance
{
    BOOL enable = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKeySettingShowEntrance]) {
        enable = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultKeySettingShowEntrance];
    }
    return enable && self.akBenefitEnable;
}

- (BOOL)akBenefitEnable
{
    NSDictionary *setting = [[TTSettingsManager sharedManager] settingForKey:@"tt_aikan_benefit_setting" defaultValue:@{} freeze:YES];
    BOOL enable = [setting tt_boolValueForKey:@"enable"];
    return enable;
}

- (BOOL)appIsReviewing
{
    NSDictionary *setting = [[TTSettingsManager sharedManager] settingForKey:@"tt_aikan_benefit_setting" defaultValue:@{} freeze:NO];
    BOOL enable = [setting tt_boolValueForKey:@"review_flag"];
    if (![setting objectForKey:@"review_flag"]) {
        enable = YES;
    }
    return enable;
}

- (void)updateBenefitValue
{
      [[AKRedPacketManager sharedManager] applyNewbeeRedPacketIgnoreLocalFlag:NO];
//    [[AKActivityTabManager sharedManager] updateActivityTabHiddenState:![AKTaskSettingHelper shareInstance].isEnableShowTaskEntrance];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kAKBenefitSettingValueUpdateNotification object:self];
}

- (void)setShowTaskEntrance:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kUserDefaultKeySettingShowEntrance];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isEnableWith:(NSString *)key
{
    if ([key isEqualToString:kIdentifierFunctionShowCoinTip]) {
        return [self isEnableShowCoinTip];
    }
    if ([key isEqualToString:kIdentifierFunctionShowEntrance]) {
        return [self isEnableShowTaskEntrance];
    }
    return NO;
}

- (void)setEnable:(BOOL)enable key:(NSString *)key
{
    if ([key isEqualToString:kIdentifierFunctionShowCoinTip]) {
        [self setShowCoinTip:enable];
    }
    if ([key isEqualToString:kIdentifierFunctionShowEntrance]) {
        [self setShowTaskEntrance:enable];
    }
}

@end
