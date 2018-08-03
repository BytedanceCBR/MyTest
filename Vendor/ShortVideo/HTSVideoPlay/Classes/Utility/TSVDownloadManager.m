//
//  TSVDownloadManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/13.
//

#import "TSVDownloadManager.h"
#import "AWEVideoConstants.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "TTModuleBridge.h"
#import "TTSettingsManager.h"
#import "BTDNetworkUtilities.h"

@implementation TSVDownloadManager

+ (BOOL)shouldDownloadAppForGroupSource:(NSString *)groupSource
{
    if ([groupSource isEqualToString:HotsoonGroupSource] && ![AWEVideoPlayTransitionBridge canOpenHotsoon]) {
        return YES;
    } else if ([groupSource isEqualToString:AwemeGroupSource] && ![AWEVideoPlayTransitionBridge canOpenAweme]) {
        return YES;
    } else if ([groupSource isEqualToString:ToutiaoGroupSource]) {
        return NO;
    }
    return NO;
}

+ (void)downloadAppForGroupSource:(NSString *)groupSource
                          urlDict:(NSDictionary *)dict
{
    NSParameterAssert(groupSource);
    NSParameterAssert(dict);
    
    if (!groupSource || !dict) {
        return;
    }
    
    NSString *url = dict[groupSource];
    
    NSAssert(url, @"Download url must not be nil!");
    
    NSMutableDictionary *mutDict = [NSMutableDictionary new];
    [mutDict setValue:url forKey:@"download_track_url"];
    
    if ([groupSource isEqualToString:HotsoonGroupSource]) {
        [mutDict setValue:@"1086047750" forKey:@"app_appleid"];
    } else if ([groupSource isEqualToString:AwemeGroupSource]) {
        [mutDict setValue:@"1142110895" forKey:@"app_appleid"];
    } else {
        NSAssert([groupSource isEqualToString:ToutiaoGroupSource], @"Unknown Group Source");
        NSDictionary *configDict = [AWEVideoPlayTransitionBridge getConfigDictWithGroupSource:groupSource];
        [mutDict setValue:configDict[@"app_appleid"] forKey:@"app_appleid"];
    }
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"TSVDownloadAPP" object:nil withParams:[mutDict copy] complete:nil];
}

+ (void)openAppForGroupSource:(NSString *)groupSource
{
    if ([AWEVideoPlayTransitionBridge canOpenAppWithGroupSource:groupSource]) {
        [AWEVideoPlayTransitionBridge openAppWithGroupSource:groupSource];
    }
}

+ (void)preloadAppStoreForGroupSourceIfNeeded:(NSString *)groupSource
{
    if (![self isAppStorePreloadEnabled]) {
        return;
    }
    
    if (![self shouldDownloadAppForGroupSource:groupSource]) {
        return;
    }
    
    if (!groupSource) {
        return;
    }
    
    NSString *appleID;
    
    if ([groupSource isEqualToString:HotsoonGroupSource]) {
        appleID = @"1086047750";
    } else if ([groupSource isEqualToString:AwemeGroupSource]) {
        appleID = @"1142110895";
    } else {
        NSAssert([groupSource isEqualToString:ToutiaoGroupSource], @"Unknown Group Source");
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Class cls = NSClassFromString(@"TTAdAppDownloadManager");
    
    if (cls && [cls respondsToSelector:@selector(sharedManager)]) {
        id manager = [cls performSelector:@selector(sharedManager)];
        
        if ([manager respondsToSelector:@selector(preloadAppStoreAppleId:)]) {
            [manager performSelector:@selector(preloadAppStoreAppleId:) withObject:appleID];
        }
    }
#pragma clang diagnostic pop
}

+ (BOOL)isAppStorePreloadEnabled
{
    BOOL settingEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_appstore_preload_enable" defaultValue:@(0) freeze:NO] boolValue];
    
    return settingEnabled && BTDNetworkWifiConnected();
}

@end
