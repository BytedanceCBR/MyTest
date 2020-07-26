//
//  FHIESGeckoManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/19.
//

#import "FHIESGeckoManager.h"
#import "IESGeckoKit.h"
#import "TTInstallIDManager.h"
#import "IESFalconManager.h"
#import "SSZipArchive.h"
#import "FHHouseBridgeManager.h"
#import "FHEnvContext.h"
#import "NSDictionary+TTAdditions.h"
#import "IESGeckoCacheManager.h"
#import "FHLynxManager.h"
#import "TTSettingsManager.h"

@implementation FHIESGeckoManager

+ (void)configGeckoInfo
{
    [IESGeckoKit setDeviceID:[[TTInstallIDManager sharedInstance] deviceID]];
    
    NSString *stringVersion = [FHEnvContext getToutiaoVersionCode];
    NSArray *geckoChannels = [FHIESGeckoManager fhGeckoChannels];
    NSMutableArray *localChannels = [NSMutableArray new];
    
    if ([geckoChannels isKindOfClass:[NSArray class]]) {
        [localChannels addObjectsFromArray:geckoChannels];
    }
    
    if (![localChannels containsObject:@"f_realtor_detail"]) {
        [localChannels addObject:@"f_realtor_detail"];
    }
    
    if (![localChannels containsObject:@"fe_app_c"]) {
        [localChannels addObject:@"fe_app_c"];
    }
    
    if (![localChannels containsObject:@"img"]) {
        [localChannels addObject:@"img"];
    }
    
    if (![localChannels containsObject:@"f_vr_source"]) {
        [localChannels addObject:@"f_vr_source"];
    }
    
    if ([[FHLynxManager sharedInstance] allLocalChannelsArray]) {
        [localChannels addObjectsFromArray:[[FHLynxManager sharedInstance] allLocalChannelsArray]];
    }
    
    if ([[FHLynxManager sharedInstance] allConfigChannelsArray]) {
        [localChannels addObjectsFromArray:[[FHLynxManager sharedInstance] allConfigChannelsArray]];
    }

    
    if ([localChannels isKindOfClass:[NSArray class]] && localChannels.count > 0) {
        [IESGeckoKit registerAccessKey:[FHIESGeckoManager getGeckoKey] appVersion:stringVersion channels:localChannels];
        [IESGeckoKit syncResourcesIfNeeded];// 同步资源文件
    }
}

+ (void)configIESWebFalcon
{
    if ([[[FHHouseBridgeManager sharedInstance] envContextBridge] isOpenWebOffline]) {
        IESFalconManager.interceptionWKHttpScheme = YES;
        IESFalconManager.interceptionEnable = YES;
        NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
        NSArray * domainVRPreload = [fhSettings tt_objectForKey:@"f_vr_preload_domain_list"];

        NSMutableString *pattern = [NSMutableString stringWithString:@"^(http|https)://.*.(pstatp.com/(toutiao)?|haoduofangs.com/f100/inner|99hdf.com/f100/inner|byteimg.com"] ;
        if ([domainVRPreload isKindOfClass:[NSArray class]]) {
            [domainVRPreload enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    [pattern appendFormat:@"|%@",obj];
                }
            }];
        }
        [pattern appendString:@")"];
        [IESFalconManager registerPattern:pattern forGeckoAccessKey:[FHIESGeckoManager getGeckoKey]];
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
        return  [IESGeckoCacheManager hasCacheForPath:nil accessKey:[FHIESGeckoManager getGeckoKey] channel:channel];
    }
    return NO;
}

+ (NSString *)getGeckoKey
{
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"]) {
        return @"adc27f2b35fb3337a4cb1ea86d05db7a";
    }else
    {
        return @"7838c7618ea608a0f8ad6b04255b97b9";
    }
}

@end
