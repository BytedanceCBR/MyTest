//
//  FHIESGeckoManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/19.
//

#import "FHIESGeckoManager.h"
#import <IESGeckoKit.h>
#import <TTInstallIDManager.h>
#import <IESFalconManager.h>
#import "SSZipArchive.h"
#import "FHHouseBridgeManager.h"
#import <FHEnvContext.h>
#import <NSDictionary+TTAdditions.h>
#import "IESGeckoCacheManager.h"

@implementation FHIESGeckoManager

+ (void)configGeckoInfo
{
    [IESGeckoKit setDeviceID:[[TTInstallIDManager sharedInstance] deviceID]];

    NSString *stringVersion = [FHEnvContext getToutiaoVersionCode];
    NSArray *geckoChannels = [FHIESGeckoManager fhGeckoChannels];
    if ([geckoChannels isKindOfClass:[NSArray class]] && geckoChannels.count > 0) {
        [IESGeckoKit registerAccessKey:kFHIESGeckoKey appVersion:stringVersion channels:geckoChannels];
        [IESGeckoKit syncResourcesIfNeeded];// 同步资源文件
    }
}

+ (void)configIESWebFalcon
{
    if ([[[FHHouseBridgeManager sharedInstance] envContextBridge] isOpenWebOffline]) {
        IESFalconManager.interceptionWKHttpScheme = NO;
        IESFalconManager.interceptionEnable = YES;
        
        NSString *pattern = @"^(http|https)://.*.[pstatp.com]/toutiao/";
        [IESFalconManager registerPattern:pattern forGeckoAccessKey:kFHIESGeckoKey];
    }
}

+ (NSArray *)fhGeckoChannels
{
    NSDictionary *fhSettings = [self fhSettings];
    NSArray * f_gecko_channels = [fhSettings tt_arrayValueForKey:@"f_gecko_channels"];
    if ([f_gecko_channels isKindOfClass:[NSArray class]]) {
        return f_gecko_channels;
    }
    return @[];
}
+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

+ (BOOL)isHasCacheForChannel:(NSString *)channel
{
    if ([channel isKindOfClass:[NSString class]]) {
      return  [IESGeckoCacheManager hasCacheForPath:nil accessKey:kFHIESGeckoKey channel:channel];
    }
    return NO;
}

@end
