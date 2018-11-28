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
#import "UIAlertView+FHAlertView.h"


@interface PreFcAction : NSObject<UIAlertViewDelegate>
{
    dispatch_semaphore_t _sema;
}
+(instancetype)shareInstance;
-(void)setSema:(dispatch_semaphore_t)sema;
@end

@implementation PreFcAction

+ (instancetype)shareInstance {
    static PreFcAction* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PreFcAction alloc] init];
    });
    return instance;

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *urlStr = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@", @"1434642658"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    dispatch_semaphore_signal(_sema);
}

- (void)setSema:(dispatch_semaphore_t)sema {
    _sema = sema;
}

@end

void fhPreFcActionAlert(forceCrashMask mask)
{
    if (mask & forceCrashMaskRebuild) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        if ([NSThread isMainThread]) {
            PreFcAction* action = [PreFcAction shareInstance];
            [action setSema:sema];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到您当前安装的软件为非官方版本，为保证正常安全浏览请前往App Store下载安装官方版本" delegate:action cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                PreFcAction* action = [PreFcAction shareInstance];
                [action setSema:sema];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到您当前安装的软件为非官方版本，为保证正常安全浏览请前往App Store下载安装官方版本" delegate:action cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [alert show];
            });
        }
        dispatch_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

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
}

- (void)registerSafeGuardService
{

    SGMSafeGuardConfig *config = [SGMSafeGuardConfig configWithPlatform:SGMSafeGuardPlatformAweme
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
    [[SGMSafeGuardManager sharedManager] setPreFcActionPtr:fhPreFcActionAlert];
}

- (NSString *)secretKey
{
    return @"2a35c29661d45a80fdf0e73ba5015be19f919081b023e952c7928006fa7a11b3";
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
