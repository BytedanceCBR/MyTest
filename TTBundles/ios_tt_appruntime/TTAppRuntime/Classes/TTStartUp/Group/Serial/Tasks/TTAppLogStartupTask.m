//
//  TTAppLogStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTAppLogStartupTask.h"
#import "TTTrackerWrapper.h"
#import "NewsBaseDelegate.h"
#import "TTTrackerSessionHandler.h"
#import <TTImpression/SSImpressionManager.h>
#import "ExploreExtenstionDataHelper.h"
#import "NewsBaseDelegate.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "TTAccountBusiness.h"
#import "SSImpressionManager.h"
#import "SSLogDataManager.h"
#import "TTModuleBridge.h"
#import "TTPlatformSwitcher.h"
#import "DebugUmengIndicator.h"
#import <TTTracker/TTTrackerCleaner.h>
#import "SSWebViewUtil.h"
#import "FHLocManager.h"
#import "FHEnvContext.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#import "SSCommonLogic.h"
#import "CommonURLSetting.h"
#import "TTLaunchDefine.h"
#import <BDABTestSDK/BDABTestManager.h>
#import <BDTracker/BDTrackerSDK.h>
#import <BDTracker/BDTrackerSDK+Debug.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import <BDTrackerProtocol/BDTrackerProtocol+ABTest.h>
#import <TTKitchen/TTKitchen.h>
#import <NSDictionary+BTDAdditions.h>
#import <TTSettingsManager.h>

#if __has_include(<TTTracker/TTTracker.h>)
#import <TTTracker/TTTracker.h>
#import <TTTracker/TTTrackerCleaner.h>
#endif

DEC_TASK("TTAppLogStartupTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+7);

@implementation TTAppLogStartupTask

- (NSString *)taskIdentifier {
    return @"AppLog";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] startTracker];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [[self class] startupTracker];
        [[SSImpressionManager shareInstance] setTodayExtensionBlock:^(void){
            //保存today extenstion的impression
            NSMutableDictionary * todayExtenstionImpressions = [ExploreExtenstionDataHelper fetchTodayExtenstionDict];
            if (todayExtenstionImpressions) {
                [todayExtenstionImpressions setValue:@"" forKey:@"session_id"];
            }
            
            [ExploreExtenstionDataHelper clearSavedTodayExtenstions];
            
            return [todayExtenstionImpressions copy];
        }];
    });
}

+ (void)startTracker {
    /**
     增加服务端实验用于控制是否使用BDTracker，默认情况下使用TTTracker
     实验地址：https://data.bytedance.net/libra/flight/539777/edit
     */
    BOOL useBDTracker = NO;
    NSDictionary *settings = [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    if (settings && [settings isKindOfClass:[NSDictionary class]]) {
        useBDTracker = [settings btd_boolValueForKey:@"f_bdtracker_enabled"];
    }
    
    if (useBDTracker) {
        [BDTrackerProtocol setBDTrackerEnabled];
        [self setupBDTracker];
    } else {
        [BDTrackerProtocol setTTTrackerEnabled];
        [self setupTTTracker];
    }
}

+ (void)setupBDTracker {
    // 下面这些设置要在初始化SDK之前
    [BDTrackerSDK setSDKEnable:YES];
    BDTrackerConfig *config = [BDTrackerConfig new];
    config.appID = [TTSandBoxHelper ssAppID];
    config.appName = [TTSandBoxHelper appName];
    config.channel = [TTSandBoxHelper getCurrentChannel];
    //是否加密
    config.needEncrypt = [SSCommonLogic useEncrypt];
    if ([TTSandBoxHelper isInHouseApp]) {
        if ([BDTrackerSDK respondsToSelector:@selector(setIsInHouseVersion:)]) {
            [BDTrackerSDK setIsInHouseVersion:YES];
        }
        config.needEncrypt = NO;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AppLogClearDidInhouse"]) {
            [BDTrackerSDK clearDidAndIid];
        }
    }
    
    [config setAbSDKVersionBlock:^NSString * _Nullable {
        return [BDABTestManager queryExposureExperiments];
    }];
    
    //用户id
    config.userIDBlock = ^NSString * _Nullable{
        return [TTAccount sharedAccount].userIdString;
    };
    @weakify(self);
    config.URLBlock = ^NSString * _Nullable(BDTrackerURLType type) {
        //return @"http://log.snssdk.com/service/2/app_log/";
        @strongify(self);
        switch (type) {
            case BDTrackerURLTypeConfig:
                return [self configURL];
            case BDTrackerURLTypeBatchReport:
                return [self batchReportURL];
            case BDTrackerURLTypeBatchReportBackup:
                return [self batchReportBackupURL];
            case BDTrackerURLTypeImmediateReport:
                return [self immediateReportURL];
            case BDTrackerURLTypeImmediateReportBackup:
                return [self immediateReportBackupURL];
            case BDTrackerURLTypeRegister:
                return [self registerDeviceURL];
            case BDTrackerURLTypeActivate:
                return [self activateDeviceURL];
            case BDTrackerURLTypeTest:
                return [self testURL];
            default:
                break;
        }
        return nil;
    };
    //自定义请求header参数
    NSString *webUA = [SSWebViewUtil userAgentString:YES];
    config.customRequestHeaderBlock = ^NSDictionary<NSString *,id> * _Nullable{
        NSMutableDictionary *customHeader = [NSMutableDictionary dictionary];
        if ([SSCommonLogic isUAEnable]) {
            [customHeader setValue:[self userAgentString] forKey:@"web_ua"];
        }
        NSString* currentCityName = [FHLocManager sharedInstance].currentReGeocode.city;
        NSString* provinceName = [FHLocManager sharedInstance].currentReGeocode.administrativeArea;
        customHeader[@"city_name"] = currentCityName;
        customHeader[@"province_name"] = provinceName;
        customHeader[@"house_city"] =  [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        customHeader[@"update_version_code"] = [TTSandBoxHelper buildVerion];
        return [customHeader copy];
    };
    [BDTrackerSDK startWithConfig:config];
}

+ (void)setupTTTracker {
    [[TTTracker sharedInstance] setConfigParamsBlock:^(void) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:[TTAccountManager userID] forKey:@"user_id"];
        //in house 环境下也使用下发的加密开关
//        if([TTSandBoxHelper isInHouseApp]) {
//            [params setValue:@(NO) forKey:@"need_encrypt"];
//        } else {
            [params setValue:@([SSCommonLogic useEncrypt]) forKey:@"need_encrypt"];
//        }

        return [params copy];
    }];
    
    [[TTTracker sharedInstance] setCustomEventBlock:^(void) {
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setValue:[[SSImpressionManager shareInstance] ImpressionsfromType:[TTTrackerCleaner sharedCleaner].fromType] forKey:@"item_impression"];
        [eventDic setValue:[[SSLogDataManager shareManager] needSendLogDatas] forKey:@"log_data"];
        [eventDic setValue:@"event_type" forKey:@"house_app2c_v2"];
        return [eventDic copy];
    }];

    [[TTTracker sharedInstance] setTransferBlock:^NSString * _Nonnull(TTTrackerURLType type) {
        if (type == TTTrackerURLTypeBatchReport) {
            return  [CommonURLSetting appLogURLString];
        }else if (type == TTTrackerURLTypeImmediateReport){
            return [CommonURLSetting rtAppLogURLString];
        }else if (type == TTTrackerURLTypeConfig){
            return [CommonURLSetting trackLogConfigURLString];
        }
        return nil;
    }];
    
    [[self class] updateCustomerHeader];

    [TTTracker startWithAppID:[TTSandBoxHelper ssAppID] channel:[TTSandBoxHelper getCurrentChannel] appName:[TTSandBoxHelper appName]];

    if ([TTSandBoxHelper isInHouseApp]) {
        [[TTTracker sharedInstance] setIsInHouseVersion:YES];
        [self enableUmengLabelDisplay];
    }
}

+(void)updateCustomerHeader {
    [[TTTracker sharedInstance] setCustomHeaderBlock:^(void) {
        NSMutableDictionary *customHeader = [NSMutableDictionary dictionary];
        if ([SSCommonLogic isUAEnable]) {
            [customHeader setValue:[self userAgentString] forKey:@"web_ua"];
        }
        //        NSString* currentCityName = [[EnvContext shared].client currentCityName];
        //        NSString* provinceName = [[EnvContext shared].client currentProvince];
        NSString* currentCityName = [FHLocManager sharedInstance].currentReGeocode.city;
        NSString* provinceName = [FHLocManager sharedInstance].currentReGeocode.administrativeArea;
        customHeader[@"city_name"] = currentCityName;
        customHeader[@"province_name"] = provinceName;
        customHeader[@"house_city"] =  [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        customHeader[@"update_version_code"] = [TTSandBoxHelper buildVerion];
        return [customHeader copy];
    }];
}

+ (void)enableUmengLabelDisplay {
    [[TTTracker sharedInstance] registerWithServiceID:@"bytedance.toutiao.umemgdisplay" willCacheOneLogBlock:^(NSDictionary * _Nonnull hookedLog) {
        NSMutableString *mStr = [NSMutableString string];
        if([hookedLog objectForKey:@"tag"] && [hookedLog objectForKey:@"label"])
        {
            [mStr appendFormat:@"%@ %@", [hookedLog objectForKey:@"tag"], [hookedLog objectForKey:@"label"]];
            if([hookedLog objectForKey:@"value"])
            {
                [mStr appendFormat:@" %@", [hookedLog objectForKey:@"value"]];
            }
            
            if([hookedLog objectForKey:@"ext_value"])
            {
                [mStr appendFormat:@" %@", [hookedLog objectForKey:@"ext_value"]];
            }
            
            [[DebugUmengIndicator sharedIndicator] addDisplayString:mStr];
        }
        
        if([hookedLog tt_stringValueForKey:@"event"])
        {
            [[DebugUmengIndicator sharedIndicator] addDisplayString:[hookedLog tt_stringValueForKey:@"event"]];
        }
    }];
}


+ (NSString *)userAgentString
{
    __block NSString* webUA = nil;
    if ([NSThread isMainThread]) {
        webUA = [SSWebViewUtil userAgentString:NO];
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            webUA = [SSWebViewUtil userAgentString:NO];
        });
    }
    if (!isEmptyString(webUA)) {
        return  webUA;
    }
    return nil;
}

#pragma mark - BDTrackerURLConfigProtocol

+ (nonnull NSString *)activateDeviceURL {
    // 激活
    return [CommonURLSetting activateDeviceBaseURLString];
}

+ (nullable NSString *)batchReportBackupURL {
    return @"https://applog.snssdk.com/service/2/app_log/";
}

+ (nonnull NSString *)batchReportURL {
    // 批量上报
    return  [CommonURLSetting appLogURLString];
}

+ (nonnull NSString *)configURL {
    return [CommonURLSetting trackLogConfigURLString];
}

+ (nullable NSString *)immediateReportBackupURL {
    return @"https://rtlog.snssdk.com/service/2/app_log/";
}

+ (nullable NSString *)immediateReportURL {
    // 实时上报
    return [CommonURLSetting rtAppLogURLString];
}

+ (nonnull NSString *)registerDeviceURL {
    // 注册
    return [CommonURLSetting registerDeviceBaseURLString];
}

+ (nullable NSString *)testURL {
    return @"https://log.snssdk.com/service/2/app_log_test/";
}

@end
