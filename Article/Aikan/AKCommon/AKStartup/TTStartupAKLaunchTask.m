//
//  TTStartupAKLaunchTask.m
//  Article
//
//  Created by 冯靖君 on 2018/3/25.
//

#import "TTStartupAKLaunchTask.h"
#import "AKRedPacketManager.h"
#import "AKHelper.h"
#import <IESSafeGuardManager.h>
#import <IESDeviceFingerprintManager.h>
#import <TTRoute.h>

@interface TTStartupAKLaunchTask () <IESDeviceFingerprintDelegate>
@end

@implementation TTStartupAKLaunchTask

- (NSString *)taskIdentifier
{
    return @"ak_common_launch";
}

- (BOOL)isResident
{
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    // 初始化设置并启动设备指纹sdk
    [self registerSafeGuardService];
    
    // 注册路由action
    [self registerRouteActions];
    
//    // 尝试获取新人红包
//    [[AKRedPacketManager sharedManager] applyNewbeeRedPacketIgnoreLocalFlag:NO];
}

- (void)registerRouteActions
{
    // 切换tab
    [TTRoute registerAction:^(NSDictionary *params) {
        NSString *tabIdentifier = [params tt_stringValueForKey:@"id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:({
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:tabIdentifier forKey:@"tag"];
            [userInfo copy];
        })];
    } withIdentifier:@"change_tab"];
    
    // 弹新人红包
    [TTRoute registerAction:^(NSDictionary *params) {
        [[AKRedPacketManager sharedManager] applyNewbeeRedPacketIgnoreLocalFlag:YES];
    } withIdentifier:@"apply_newbee_rp"];
}

- (void)registerSafeGuardService
{
    // 安全组@liuzhanluan and @libo 说用火山的appid和spname
    IESSafeGuardConfig *config = [IESSafeGuardConfig configWithPlatform:IESSafeGuardPlatformCommon
                                                                  appID:@"1112"
                                                                 spname:@"hotsoon"
                                                              secretKey:[self secretKey]];
//    [IESSafeGuardManager startWithConfig:config delegate:self.class];
    
    IESDeviceFingerprintPlatform internalPlatform = (IESDeviceFingerprintPlatform)(config.platform);
    [IESDeviceFingerprintManager registerPlatform:internalPlatform];
    [IESDeviceFingerprintManager registerDelegate:self.class];
    
    [IESSafeGuardManager scheduleSafeGuard];
    [IESSafeGuardManager startForScene:@"launch"];
}

- (NSString *)secretKey
{
    return @"2a35c29661d45a80fdf0e73ba5015be19f919081b023e952c7928006fa7a11b3";
}

- (void)stop
{
    [IESDeviceFingerprintManager stop];
}

#pragma mark - IESDeviceFingerprintDelegate

+ (NSString *)customDeviceID
{
    return [[TTInstallIDManager sharedInstance] deviceID];
}

+ (NSString *)installID
{
    return [[TTInstallIDManager sharedInstance] installID];
}

+ (NSString *)sessionID
{
    return [[TTAccount sharedAccount] sessionKey];
}

+ (NSString *)installChannel
{
    return [TTSandBoxHelper getCurrentChannel];
}

+ (CLLocation *)currentLocation;
{
    return nil;
}

@end
