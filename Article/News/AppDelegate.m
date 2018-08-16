    //
//  AppDelegate.m
//  Article
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//3.x code


// 3.x code

#import "AppDelegate.h"
#define APPSEE_ENABLE 0

extern NSString * const SSCommonLogicSettingWebViewQueryStringEnableKey;
extern NSString * const SSCommonLogicSettingWebViewQueryStringListKey;

#if APPSEE_ENABLE
#import "Appsee/Appsee.h"
#endif

@implementation AppDelegate

- (NSString*)weixinAppID
{
//#if INHOUSE
//    return @"wx1186e32012d8a997";
//#else
//    return @"wx50d801314d9eb858";
//#endif
    
    // 爱看微信appid
    return @"wxc41809a35822b397";
}

- (NSString *)dingtalkAppID {
#if INHOUSE
    return @"dingoaqyfcq52rrbstfhui";
#else
    return @"dingoamfoom0wrwiyexx2z";
#endif
}

- (NSString *)umengTrackAppkey
{
    return @"347554830b8750e7c4451f61ed615cad";
}

#if APPSEE_ENABLE
static void *const kTTAppseeSampleContext = (void *)&kTTAppseeSampleContext;
extern NSString *const kTTAppseeEnableKey;

// Appsee只用于越狱渠道
- (void)handleAppseeSample
{
    
    if (![TTDeviceHelper isAppStoreChannel] && [[SSCommonLogic appseeSampleSetting] boolValue]) {
        [Appsee setOptOutStatus:NO];
    } else {
        [Appsee setOptOutStatus:YES];
    }
}

- (void)initAppsee
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kTTAppseeEnableKey : @(0)}];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:kTTAppseeEnableKey options:NSKeyValueObservingOptionInitial |NSKeyValueObservingOptionNew context:kTTAppseeSampleContext];
    
    [Appsee start:@"54d471f6bcae41e8b291a69ee4a61ebb"];
    [Appsee setDebugToNSLog:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == kTTAppseeSampleContext && [keyPath isEqualToString:kTTAppseeEnableKey]) {
        [self handleAppseeSample];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#endif

- (void)initWebViewCommonQueryStatus
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{SSCommonLogicSettingWebViewQueryStringEnableKey : @(1),SSCommonLogicSettingWebViewQueryStringListKey : @[@"snssdk.com", @"bytedance.com"]}];
}

- (void)dealloc
{
#if APPSEE_ENABLE
    [self removeObserver:[NSUserDefaults standardUserDefaults] forKeyPath:kTTAppseeEnableKey];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /// 注意，这里必须初始化这个Manager.勿删
    
    [self initWebViewCommonQueryStatus];

#if APPSEE_ENABLE
    //越狱渠道开启Appsee监控初始化
    if (![TTDeviceHelper isAppStoreChannel]) {
        [self initAppsee];
    }
#endif

    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
    
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    [super applicationWillEnterForeground:application];
}

@end
