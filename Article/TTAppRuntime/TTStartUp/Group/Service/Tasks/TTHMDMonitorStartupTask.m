//
//  TTHMDMonitorStartupTask.m
//  Article
//
//  Created by 谷春晖 on 2018/10/11.
//

#import "TTHMDMonitorStartupTask.h"
#import <Heimdallr/Heimdallr.h>
#import <Heimdallr/HMDInjectedInfo.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTTracker/TTTrackerSessionHandler.h>
#import <TTAccountUserEntity.h>
#import <TTAccount.h>
#import <HMDTTMonitorManager.h>

@implementation TTHMDMonitorStartupTask


- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super shouldExecuteForApplication:application options:launchOptions];
    [[self class] setupAPMModule];
    return YES;
}

//- (void)modSetUp:(BHContext *)context
//{
//    BOOL apmEnable = [[[TTSettingsManager sharedManager] settingForKey:@"learning_apm_enable" defaultValue:@0 freeze:YES] boolValue];
//    if (apmEnable) {
//        [self setupAPMModule];xx
//    }
//}

+ (void)setupAPMModule
{
    TTAccountUserEntity *user = [[TTAccount sharedAccount] user];
    HMDInjectedInfo *injectedInfo = [HMDInjectedInfo defaultInfo];
    injectedInfo.appID = [TTSandBoxHelper ssAppID];
    injectedInfo.appName = [TTSandBoxHelper appName];
    injectedInfo.channel = [TTSandBoxHelper getCurrentChannel];
    injectedInfo.deviceID = [TTInstallIDManager sharedInstance].deviceID;
    injectedInfo.installID = [TTInstallIDManager sharedInstance].installID;
    injectedInfo.userID = [user.userID description];
    injectedInfo.userName = user.name;
    injectedInfo.commonParams = [TTNetworkManager shareInstance].commonParams;
    injectedInfo.sessionID = [TTTrackerSessionHandler sharedHandler].sessionID;
    
//    [[HMDTTMonitorManager shared] setupWithInjectedInfo:[HMDInjectedInfo defaultInfo]];
    [[Heimdallr shared] setupWithInjectedInfo:[HMDInjectedInfo defaultInfo]];
}

@end
