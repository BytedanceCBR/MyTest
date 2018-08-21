//
//  TTBDSDKOpenURLTask.m
//  Article
//
//  Created by zuopengliu on 27/9/2017.
//

#import "TTBDSDKOpenURLTask.h"
#import <Bytedancebase/BDSDKApi.h>
#import <Bytedancebase/BDPlatformSDKApi.h>
#import "TTPlatformOAuthSDKManager.h"
#import "TTPushMsgAuthLoginManager.h"



@implementation TTBDSDKOpenURLTask

- (NSString *)taskIdentifier
{
    return @"BytedanceSDKOpenURL";
}

- (BOOL)isResident
{
    return YES;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canhandleHuoShanBDSDK = [TTAccountAuthHuoShan handleOpenURL:url];
    if (canhandleHuoShanBDSDK) return YES;
    
    BOOL canhandleDouYinBDSDK = [TTAccountAuthDouYin handleOpenURL:url];
    if (canhandleDouYinBDSDK) return YES;
    
    BOOL canHandleBDPlatformSDK = [TTPlatformOAuthSDKManager handleOpenURL:url];
    if (canHandleBDPlatformSDK) return YES;
    
    // User Promotion Request from BytedanceApps Platform
    if ([TTPushMsgAuthLoginManager handleOpenURL:url]) {
        return YES;
    }
    
    return NO;
}

@end
