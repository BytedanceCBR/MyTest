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
#import "TTInstallIDManager.h"
#import <TTAccountBusiness.h>
#import "SSImpressionManager.h"
#import "SSLogDataManager.h"
#import "TTModuleBridge.h"
#import "TTPlatformSwitcher.h"
#import "DebugUmengIndicator.h"
#import <TTTracker/TTTrackerCleaner.h>
#import "SSWebViewUtil.h"
//#import "Bubble-Swift.h"
#import "FHLocManager.h"
#import "FHEnvContext.h"
@implementation TTAppLogStartupTask

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSSendTrack" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSString *event = params[@"event"];
        NSString *label = params[@"label"];
        NSString *value = params[@"value"];
        NSString *extValue = params[@"extra"];
        NSDictionary *attributes = params[@"attributes"];
        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
        [extraDic setValue:extValue forKey:@"ext_value"];
        [extraDic addEntriesFromDictionary:attributes];
        wrapperTrackEventWithCustomKeys(event, label, value, nil, extraDic);
        return nil;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"HTSV3SendTrack" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSString *event = params[@"event"];
        NSDictionary *paramsDict = params[@"params"];
        [TTTrackerWrapper eventV3:event params:paramsDict];
        return nil;
    }];
}

- (NSString *)taskIdentifier {
    return @"AppLog";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] startupTracker];
    [[SSImpressionManager shareInstance] setTodayExtensionBlock:^(void){
        //保存today extenstion的impression
        NSMutableDictionary * todayExtenstionImpressions = [ExploreExtenstionDataHelper fetchTodayExtenstionDict];
        if (todayExtenstionImpressions) {
            [todayExtenstionImpressions setValue:@"" forKey:@"session_id"];
        }
        
        [ExploreExtenstionDataHelper clearSavedTodayExtenstions];
        
        return [todayExtenstionImpressions copy];
    }];
}

+ (void)startupTracker {
    [[TTTracker sharedInstance] setConfigParamsBlock:^(void) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:[TTAccountManager userID] forKey:@"user_id"];
        if([TTSandBoxHelper isInHouseApp]) {
            [params setValue:@(NO) forKey:@"need_encrypt"];
        } else {
            [params setValue:@([SSCommonLogic useEncrypt]) forKey:@"need_encrypt"];
        }
        
        return [params copy];
    }];
    
    [[TTTracker sharedInstance] setCustomEventBlock:^(void) {
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setValue:[[SSImpressionManager shareInstance] ImpressionsfromType:[TTTrackerCleaner sharedCleaner].fromType] forKey:@"item_impression"];
        [eventDic setValue:[[SSLogDataManager shareManager] needSendLogDatas] forKey:@"log_data"];
        [eventDic setValue:@"event_type" forKey:@"house_app2c_v2"];
        return [eventDic copy];
    }];

    [[self class] updateCustomerHeader];

    [TTTracker startWithAppID:[TTSandBoxHelper ssAppID] channel:[TTSandBoxHelper getCurrentChannel]];

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
        NSString* provinceName = [FHLocManager sharedInstance].currentReGeocode.province;
        customHeader[@"city_name"] = currentCityName;
        customHeader[@"province_name"] = provinceName;
        customHeader[@"house_city"] =  [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
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


@end
