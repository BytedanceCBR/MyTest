//
//  TTTelecomLogicSettings.m
//  Article
//
//  Created by Zuopeng Liu on 8/11/16.
//
//

#import "TTTelecomLogicSettings.h"
#import <TTTelecomManager.h>
#import <NSDictionary+TTAdditions.h>
#import <NetworkUtilities.h>
#import <TTNetworkHelper.h>
#import <TTReachability.h>
#import "TTTelecomLoggerImp.h"
#import "TTABAuthorizationManager.h"
#import "CommonURLSetting.h"



NSString * const TTNeedGettingPhoneKey    = @"TTNeedGettingPhoneKey";
NSString * const TTForceToGetPhoneKey     = @"TTForceToGetPhoneKey";
NSString * const TTGettingPhoneEnabledKey = @"TTGettingPhoneEnabledKey";

@implementation TTTelecomLogicSettings

+ (void)parseGettingPhoneConfigsFromSettings:(NSDictionary *)settings
{
    NSDictionary *referredSettings = settings;
    if (![referredSettings isKindOfClass:[NSDictionary class]]) {
        referredSettings = nil;
    }
    // 电信取号下发设置开关
    /** 取号延时 */
    NSInteger delayOfGettingPhone = [referredSettings tt_intValueForKey:@"get_mobile_delay"];
    [self.class setGettingPhoneDelay:delayOfGettingPhone];
    /** 开关服务端可控，YES 表示无论客户端是否授权，强制取号 */
    BOOL forceGettingPhoneEnabled = [referredSettings tt_boolValueForKey:@"get_mobile_directly"];
    [self.class setForceToGetPhoneEnabledForValue:forceGettingPhoneEnabled];
    
    // 电信取号新的配置
    NSDictionary *telecomSettings = [referredSettings tt_dictionaryValueForKey:@"tt_new_telecom_get_mobile_setting"];
    NSInteger ctrlAuthErrorAsCancel = YES; // 默认为YES
    if (telecomSettings) {
        /** 取号失败重试次数 */
        NSInteger maxRetryTimes = [telecomSettings tt_intValueForKey:@"max_retry_times"];
        [self.class setMaxRetryTimes:maxRetryTimes];
        
        ctrlAuthErrorAsCancel = [telecomSettings tt_intValueForKey:@"control_auth_error_as_cancellation"];
        
        /** 取号时蜂窝网络条件，默认0--表示可达可取号，2--表示2G就能取号，3--表示3G才能取号，4--表示4G才能取号 */
        s_cellularCondition = [telecomSettings tt_intValueForKey:@"cellular_condition"];
    }
    
    // 初始化电信取号设置
    [TTTelecomManager sharedManager].logDelegate = [TTTelecomLoggerImp new];
    [[TTTelecomManager sharedManager] setCarrierName:[TTNetworkHelper carrierName]];
    [[TTTelecomManager sharedManager] setNetworkReachabilityChangedNotification:kReachabilityChangedNotification];
    [TTTelecomManager sharedManager].networkConnectionFlagsHandler = ^TTTelecomNetworkConnectionFlags{
        TTTelecomNetworkConnectionFlags flags = TTTelecomNetworkConnectionFlagNone;
        if (TTNetwork2GConnected()) {
            flags |= TTTelecomNetworkConnectionFlag2G;
        }
        if (TTNetwork3GConnected()) {
            flags |= TTTelecomNetworkConnectionFlag3G;
        }
        if (TTNetwork4GConnected()) {
            flags |= TTTelecomNetworkConnectionFlag4G;
        }
        if (TTNetworkWifiConnected()) {
            flags |= TTTelecomNetworkConnectionFlagWIFI;
        }
        return flags;
    };
    [TTTelecomManager sharedManager].controlAuthErrorAsCancellation = ctrlAuthErrorAsCancel;
    [TTTelecomManager sharedManager].maxRetryTimes = [self.class maxRetryTimesWhenFailed];
    [TTTelecomManager setURLDomain:[CommonURLSetting baseURL]];
    [TTTelecomManager sharedManager].meetGettingPhoneConditionHandler = ^BOOL() {
        return [self.class newGettignPhoneEnabled] && [self.class meetCellularGetPhoneCondition];
    };
    [TTTelecomManager sharedManager].gettingPhoneCompletedHandler = ^(NSString *phoneString, NSError *error) {
        if (!error) {
            [self.class setGettingPhoneEnabled:NO];
            [self.class recordTimeIntervalWhenGettingPhoneSuccess];
        }
    };
    [TTTelecomManager setAsyncRegisterSDKBlock:^{
        [TTTelecomManager registerAppKey:kTTTelecomAppKey
                               appSecret:kTTTelecomAppSecret
                                 appName:@"Toutiao.ByteDance.com"];
    }];
    
    if (delayOfGettingPhone > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(5, delayOfGettingPhone) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TTTelecomManager fetchMobile];
        });
    }
}

#pragma mark - get phone forcely

+ (BOOL)forceToGetPhoneEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:TTForceToGetPhoneKey];
}

+ (void)setForceToGetPhoneEnabledForValue:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:TTForceToGetPhoneKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSInteger s_cellularCondition = 0;
/** 蜂窝网络取号条件 */
+ (BOOL)meetCellularGetPhoneCondition
{
    if (s_cellularCondition < 0) return YES;
    if (s_cellularCondition == 3) {
        return (TTNetwork3GConnected() || TTNetwork4GConnected());
    } else if (s_cellularCondition == 4) {
        return (TTNetwork4GConnected());
    }
    return (TTNetwork2GConnected() || TTNetwork3GConnected() || TTNetwork4GConnected());
}

#pragma mark - get phone delay

/**
 * 控制服务端返回的延时，是否需要获取电信手机号
 */
+ (void)setGettingPhoneDelay:(NSTimeInterval)delay
{
    if (delay > 0) {
        [self setNeedGettingPhone:YES];
    } else {
        [self setNeedGettingPhone:NO];
    }
}

+ (void)setNeedGettingPhone:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:TTNeedGettingPhoneKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)needGettingPhone
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:TTNeedGettingPhoneKey];
}

/**
 *  1. 前期是只有授权才会电信取号
 *  2. forceToGetPhoneEnabled开关是服务端可控，该开关打开无论是否授权都会读取开启电信取号
 *  3. TTGettingPhoneEnabledKey控制每次启动仅能取号一次
 */
+ (BOOL)gettingPhoneEnabled
{
    BOOL enableGettingPhone = [[NSUserDefaults standardUserDefaults] boolForKey:TTGettingPhoneEnabledKey];
    return (([TTABAuthorizationManager hasBeenAuthorized] || [self.class forceToGetPhoneEnabled]) &&
            [self.class needGettingPhone] && enableGettingPhone);
}

/**
 *  取号条件
 *
 *  1. get_mobile_delay > 0
 *  2. 时间间隔 > x天, 服务端控制
 *  3. get_mobile_directly
 */
+ (BOOL)newGettignPhoneEnabled
{
    return (/* [self.class meetTimeLimitRequirement] && */ [self.class needGettingPhone]) || ([self.class forceToGetPhoneEnabled]);
}

/**
 *  三方讨论，要求每次启动仅仅能访问一次，每次启动后清空
 */
+ (void)setGettingPhoneEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:TTGettingPhoneEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString * const TTGettignPhoneMinIntervalDaysKey = @"TTGettignPhoneMinIntervalDaysKey";

+ (void)setMinIntervalDays:(NSInteger)days
{
    [[NSUserDefaults standardUserDefaults] setInteger:days forKey:TTGettignPhoneMinIntervalDaysKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)minIntervalDays
{
    return MAX(1, [[NSUserDefaults standardUserDefaults] integerForKey:TTGettignPhoneMinIntervalDaysKey]);
}

#pragma mark - retry

static NSString * const TTGettingPhoneMaxRetryTimesKey = @"TTGettingPhoneMaxRetryTimesKey";

+ (void)setMaxRetryTimes:(NSInteger)MaxRetryTimes
{
    [[NSUserDefaults standardUserDefaults] setInteger:MaxRetryTimes forKey:TTGettingPhoneMaxRetryTimesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)maxRetryTimesWhenFailed
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:TTGettingPhoneMaxRetryTimesKey];
}

#pragma mark - 记录上次取号成功的时间

static NSString * const TTGettingPhoneSuccessTimeIntervalKey = @"TTGettingPhoneSuccessTimeIntervalKey";

+ (void)recordTimeIntervalWhenGettingPhoneSuccess
{
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setInteger:currentTimeInterval forKey:TTGettingPhoneSuccessTimeIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)meetTimeLimitRequirement
{
    NSInteger minIntervalDays = [self.class minIntervalDays];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastSuccessTimeInterval = [[NSUserDefaults standardUserDefaults] integerForKey:TTGettingPhoneSuccessTimeIntervalKey];
    if ((currentTimeInterval - lastSuccessTimeInterval) / (24 * 60 * 60) >= minIntervalDays) {
        return YES;
    }
    return NO;
}

@end
