//
//  TTASettingConfiguration.m
//  Article
//
//  Created by yin on 2018/1/23.
//

#import "TTASettingConfiguration.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTSettingsManager/TTSettingsManager+SaveSettings.h>
#import "NetworkUtilities.h"
#import <pthread/pthread.h>

BOOL ttas_isVideoScrollPlayEnable(void)
{
    return [[TTASettingConfiguration valueForSettingKey:@"tta_video_scroll_autoplay" defaultValue:@YES] boolValue];
}

BOOL ttas_isAutoPlayVideoPreloadEnable(void)
{
    return [[TTASettingConfiguration valueForSettingKey:@"tta_video_autoplay_preload_enable" defaultValue:@YES] boolValue]&& TTNetworkWifiConnected();
}

NSInteger ttas_autoPlayVideoPreloadResolution(void)
{
    return [[TTASettingConfiguration valueForSettingKey:@"tta_video_preload_resolution" defaultValue:@2] integerValue];
}

NSInteger ttas_isSplashSDKEnable(void)
{
    return [[TTASettingConfiguration valueForSettingKey:@"tta_splash_sdk_enable" defaultValue:@1] integerValue];
}

@implementation TTASettingConfiguration

static NSString* const kTTAdVideoScrollPlayEnableKey = @"kTTAdVideoScrollPlayEnableKey";

+ (void)setAdConfiguration:(NSDictionary *)dictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:dictionary forKey:kTTAdVideoScrollPlayEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSDictionary *)adConfiguration
{
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAdVideoScrollPlayEnableKey];
    if (!SSIsEmptyDictionary(dictionary)) {
        return dictionary;
    }
    return nil;
}

+ (id)valueForSettingKey:(NSString *)key defaultValue:(id)defaultValue
{
    NSDictionary *settingDict = [TTASettingConfiguration adConfiguration];
    if (SSIsEmptyDictionary(settingDict)) {
        return defaultValue;
    }
    id value = [settingDict valueForKey:key];
    if (value) {
        return value;
    }
    else if (defaultValue){
        return defaultValue;
    }
    else
        return nil;
}

@end
