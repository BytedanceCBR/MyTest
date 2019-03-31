//
//  TTGetInstallIDTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTGetInstallIDTask.h"
#import "TTInstallIDManager.h"
#import "TTPlatformSwitcher.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTModuleBridge.h"
#import "TTPhoneConnectWatchManager.h"
#import "AccountKeyChainManager.h"
#import "TTFingerprintManager.h"

@implementation TTGetInstallIDTask

- (NSString *)taskIdentifier {
    return @"GetInstallID";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [[self class] setupInstallService];
    
    [[TTInstallIDManager sharedInstance] setDidRegisterBlock:^(NSString *deviceID, NSString *installID) {
        [[TTFingerprintManager sharedInstance] startFetchFingerprintIfNeeded];
    }];
}

+ (void)setupInstallService {
    [[TTInstallIDManager sharedInstance] setConfigParamsBlock:^(void) {
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:2];
        NSString *did = [[[[AccountKeyChainManager sharedManager] accountFromKeychain] stringValueForKey:@"device_id" defaultValue:nil] copy];
        [mDict setValue:did forKey:@"backup_device_id"];
        BOOL needEncrypt = [SSCommonLogic useEncrypt];
        if ([TTSandBoxHelper isInHouseApp]) {
            needEncrypt = NO;
        }
        [mDict setValue:@(needEncrypt) forKey:@"need_encrypt"];
        
        NSString *url = [[CommonURLSetting logBaseURL] stringByAppendingString:@"/service/2/device_register/"];
        [mDict setValue:url forKey:@"register_url_string"];
        
        return [mDict copy];
    }];
    
    [[TTInstallIDManager sharedInstance] startWithAppID:[TTSandBoxHelper ssAppID]
                                                channel:[TTSandBoxHelper getCurrentChannel]
                                            finishBlock:^(NSString *deviceID, NSString *installID) {
        // 更新installID
        if(!isEmptyString(installID)) {
            [ExploreExtenstionDataHelper saveSharedIID:installID];
            
            [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSGetInstallID" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
                return installID;
            }];
        }
        
        if (!isEmptyString(deviceID)) {
            [ExploreExtenstionDataHelper saveSharedDeviceID:deviceID];
            
            [self sendDeveiceIDToWatch:deviceID];
        }
    }];
}

+ (void)sendDeveiceIDToWatch:(NSString *)deviceID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:deviceID forKey:@"deviceID"];
    [[TTPhoneConnectWatchManager sharedInstance] sendUserInfo:dict];
}

@end
