//
//  TTStartupAKLaunchTask.m
//  Article
//
//  Created by 冯靖君 on 2018/3/25.
//

#import "TTStartupAKLaunchTask.h"
#import "AKRedPacketManager.h"
#import "AKHelper.h"
#import <SecGuard/SGMSafeGuardManager.h>
#import <TTRoute.h>

@interface TTStartupAKLaunchTask ()<SGMSafeGuardDelegate>
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

    SGMSafeGuardConfig *config = [SGMSafeGuardConfig configWithPlatform:SGMSafeGuardPlatformHotSoon
                                                                  appID:@"1370"
                                                               hostType:SGMSafeGuardHostTypeDomestic
                                                              secretKey:[self secretKey]];
    [[SGMSafeGuardManager sharedManager] sgm_startWithConfig:config delegate:self];
    // 安全组@liuzhanluan and @libo 说用火山的appid和spname
//    IESSafeGuardConfig *config = [IESSafeGuardConfig configWithPlatform:IESSafeGuardPlatformCommon
//                                                                  appID:@"1370"
//                                                                 spname:@"hotsoon"
//                                                              secretKey:[self secretKey]];
////    [IESSafeGuardManager startWithConfig:config delegate:self.class];
//
//    IESDeviceFingerprintPlatform internalPlatform = (IESDeviceFingerprintPlatform)(config.platform);
//    [IESDeviceFingerprintManager registerPlatform:internalPlatform];
//    [IESDeviceFingerprintManager registerDelegate:self.class];
//
//    [IESSafeGuardManager scheduleSafeGuard];
//    [IESSafeGuardManager startForScene:@"launch"];
    [[SGMSafeGuardManager sharedManager] sgm_scheduleSafeGuard];

}

- (NSString *)secretKey
{
    return @"a3668f0afac72ca3f6c1697d29e0e1bb1fef4ab0285319b95ac39fa42c38d05f";
}

- (void)stop
{
//    [IESDeviceFingerprintManager stop];
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

- (nullable CLLocation *)sgm_currentLocation {
    return nil;
}

- (nonnull NSString *)sgm_customDeviceID {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (nonnull NSString *)sgm_installChannel {
    return [TTSandBoxHelper getCurrentChannel];
}

- (nonnull NSString *)sgm_installID {
    return [[TTInstallIDManager sharedInstance] installID];
}

- (nonnull NSString *)sgm_sessionID {
    return [[TTAccount sharedAccount] sessionKey];
}

    @end
