//
//  TTGetInstallIDTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTGetInstallIDTask.h"
//#import "TTInstallIDManager.h"
#import "TTPlatformSwitcher.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTModuleBridge.h"
//#import "TTPhoneConnectWatchManager.h"
#import "AccountKeyChainManager.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "SSCommonLogic.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#import "CommonURLSetting.h"
#import <TTBaseLib/TTBaseMacro.h>
#import "TTLaunchDefine.h"
#import <BDInstall/BDInstall.h>
#import <BDInstall/BDInstallURLChina.h>
#import <BDInstall/BDInstallGlobalConfig.h>

DEC_TASK("TTGetInstallIDTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+7);

@implementation TTGetInstallIDTask

- (NSString *)taskIdentifier {
    return @"GetInstallID";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [[self class] setupInstallService];
    
//    [[TTInstallIDManager sharedInstance] observeDeviceDidRegistered:^(NSString * _Nonnull deviceID, NSString * _Nonnull installID) {
//        [[TTFingerprintManager sharedInstance] startFetchFingerprintIfNeeded];
//    }];
}

+ (void)setupInstallService {
    [BDInstallGlobalConfig sharedInstance].appID = [TTSandBoxHelper ssAppID];
    [BDInstallGlobalConfig sharedInstance].appName = [TTSandBoxHelper appName];
    [BDInstallGlobalConfig sharedInstance].channel = [TTSandBoxHelper getCurrentChannel];
    [BDInstallGlobalConfig sharedInstance].service = [TTGetInstallIDTask class];
    BOOL needEncrypt = [SSCommonLogic useEncrypt];
    if ([TTSandBoxHelper isInHouseApp]) {
        needEncrypt = NO;
    }
    [BDInstallGlobalConfig sharedInstance].encrypt = needEncrypt;
    [BDInstallGlobalConfig sharedInstance].autoActivated = YES;
    [[BDInstall sharedInstance] startRegisterDeviceWithSuccess:^(NSString * _Nonnull deviceID, NSString * _Nonnull installID) {
        // 更新installID
        if(!isEmptyString(installID)) {
            [ExploreExtenstionDataHelper saveSharedIID:installID];
            
            [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSGetInstallID" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
                return installID;
            }];
        }
        
        if (!isEmptyString(deviceID)) {
            [ExploreExtenstionDataHelper saveSharedDeviceID:deviceID];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"注册失败！");
    }];
    
//    [[TTInstallIDManager sharedInstance] setConfigParamsBlock:^(void) {
//        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:2];
//        NSString *did = [[[[AccountKeyChainManager sharedManager] accountFromKeychain] stringValueForKey:@"device_id" defaultValue:nil] copy];
//        [mDict setValue:did forKey:@"backup_device_id"];
//        BOOL needEncrypt = [SSCommonLogic useEncrypt];
////        if ([TTSandBoxHelper isInHouseApp]) {
////            needEncrypt = NO;
////        }
//        [mDict setValue:@(needEncrypt) forKey:@"need_encrypt"];
//
//        NSString *url = [[CommonURLSetting logBaseURL] stringByAppendingString:@"/service/2/device_register/"];
//        [mDict setValue:url forKey:@"register_url_string"];
//
//        return [mDict copy];
//    }];
    
//    [TTInstallIDManager sharedInstance].appID = [TTSandBoxHelper ssAppID];
//    [TTInstallIDManager sharedInstance].channel = [TTSandBoxHelper getCurrentChannel];
//    [TTInstallIDManager sharedInstance].appName = [TTSandBoxHelper appName];
//
//    [[TTInstallIDManager sharedInstance] startRegisterDeviceWithAutoActivated:YES success:^(NSString * _Nonnull deviceID, NSString * _Nonnull installID) {
//        // 更新installID
//        if(!isEmptyString(installID)) {
//            [ExploreExtenstionDataHelper saveSharedIID:installID];
//
//            [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSGetInstallID" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//                return installID;
//            }];
//        }
//
//        if (!isEmptyString(deviceID)) {
//            [ExploreExtenstionDataHelper saveSharedDeviceID:deviceID];
//
//            //            [self sendDeveiceIDToWatch:deviceID];
//        }
//    } failure:^(NSError * _Nonnull error) {
//
//    }];
}

#pragma mark - BDInstallURLConfigProtocol

+ (NSString *)registerDeviceBaseURL {
    return [CommonURLSetting registerDeviceBaseURLString];
}

+ (NSString *)activateDeviceBaseURL {
    return [CommonURLSetting activateDeviceBaseURLString];
}

//+ (void)sendDeveiceIDToWatch:(NSString *)deviceID {
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setValue:deviceID forKey:@"deviceID"];
//    [[TTPhoneConnectWatchManager sharedInstance] sendUserInfo:dict];
//}

@end
