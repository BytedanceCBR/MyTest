//
//  TTBDTrackerStartupTask.m
//  TTAppRuntime
//
//  Created by 春晖 on 2019/12/15.
//

#import "TTBDTrackerStartupTask.h"
//#import <BDTracker/BDTrackerConfig.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import <TTArticleBase/SSCommonLogic.h>
#import <TTAccountSDK/TTAccount.h>
#import <TTAccountSDK/TTAccountUserEntity.h>
#import <TTImpression/SSImpressionManager.h>
#import <TTKitchen/TTKitchen.h>
#import <TTKitchenExtension/TTKitchenExtension.h>
#import "SSWebViewUtil.h"
//#import <BDTracker/BDTrackerSDK.h>
#import <TTImpression/SSImpressionManager.h>
#import <BDABTestSDK/BDABTestManager.h>
#import "TTLaunchDefine.h"

DEC_TASK("TTBDTrackerStartupTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+7);

static NSString * const kTTBDTrackerEnable = @"tt_bdtracker_config.enable";

TTRegisterKitchenFunction() {
    TTKitchenRegisterBlock(^{
        TTKConfigBOOL(kTTBDTrackerEnable, @"BDTracker双发控制开关", NO);
    });
}

@implementation TTBDTrackerStartupTask

- (NSString *)taskIdentifier {
    return @"TTBDTrackerStartupTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    
}
//
//
//    BDTrackerConfig *config = [BDTrackerConfig new];
//    config.appID = [TTSandBoxHelper ssAppID];
//    config.appName = [TTSandBoxHelper appName];
//    config.channel = [TTSandBoxHelper getCurrentChannel];
//    config.serviceVendor = kBDLogServiceVendorChina;
//
//    //是否加密
//    //in house 环境下也使用下发的加密开关
////    if([TTSandBoxHelper isInHouseApp]) {
////        config.needEncrypt = NO;
////    } else {
//        config.needEncrypt = [SSCommonLogic useEncrypt];
////    }
//    //用户id
//    config.userIDBlock = ^NSString * _Nullable{
//        return [TTAccount sharedAccount].user.userID.description;
//    };
////    //自定义event参数
////    config.customEventBlock = ^NSDictionary<NSString *,id> * _Nullable{
////        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
////        [eventDic setValue:[[SSImpressionManager shareInstance] ImpresssionWithBDFromType:[BDTrackerSDK fromType]] forKey:@"item_impression"];
////        [eventDic setValue:[[SSLogDataManager shareManager] needSendLogDatas] forKey:@"log_data"];
////
////        return [eventDic copy];
////    };
//
//    //自定义请求header参数
//    BOOL apmEnabled = [TTKitchen getBOOL:kTTKitchenAPMEnabledKey];
//
//    NSString *webUA = [SSWebViewUtil userAgentString:YES];
//    config.customRequestHeaderBlock = ^NSDictionary<NSString *,id> * _Nullable{
//        NSMutableDictionary *customHeader = [NSMutableDictionary dictionary];
//        [customHeader setValue:webUA forKey:@"web_ua"];
//        [customHeader setValue:@(apmEnabled) forKey:@"slardar_enable"];
//        [customHeader setValue:[TTAccount sharedAccount].isLogin ? @"1" : @"0" forKey:@"is_user_logged_in"];
//        return [customHeader copy];
//    };
//
//    [config setAbSDKVersionBlock:^NSString * _Nullable{
//        return [BDABTestManager queryExposureExperiments];
//    }];
//
//    [BDTrackerSDK setSDKEnable:[TTKitchen getBOOL:kTTBDTrackerEnable]];
//    if ([TTSandBoxHelper isInHouseApp]) {
//        [BDTrackerSDK setIsInHouseVersion:YES];
//    }
//
//    [BDTrackerSDK startWithConfig:config];
//}

@end
