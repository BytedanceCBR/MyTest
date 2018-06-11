//
//  TTAppLogStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTAppLogStartupTask.h"
#import "BDStartUpManager.h"

#if BD_TTTracker
#import "TTTracker.h"
//#import <TTTracker/TTTracker.h>
#endif

@implementation TTAppLogStartupTask

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
#if BD_TTTracker
    [[TTTracker sharedInstance] setConfigParamsBlock:^(void) {
      //   外部使用方配置是否加密等参数
        return @{};
    }];

    [[TTTracker sharedInstance] setCustomEventBlock:^(void) {
        // 使用方自定义Event参数
        return @{};
    }];

    [[TTTracker sharedInstance] setCustomHeaderBlock:^(void) {
        // 使用方自定义Header参数
        return @{};
    }];
    // TTTrackerConfig *config = [[TTTrackerConfig alloc] init];
    // config.serviceVendor = kInstallServiceVendorChina;
    // [TTTracker setupConfig:config];
    
    NSString *appID = [BDStartUpManager sharedInstance].appID;
    NSString *channel = [BDStartUpManager sharedInstance].channel;
    NSString *appName = [BDStartUpManager sharedInstance].appName;
    NSAssert(appID.length, @"appID不能为空！");
    NSAssert(channel.length, @"channel不能为空！");
    NSAssert(appName.length, @"appName不能为空！");

    [TTTracker startWithAppID:appID channel:channel appName:appName];
#endif
}

@end

