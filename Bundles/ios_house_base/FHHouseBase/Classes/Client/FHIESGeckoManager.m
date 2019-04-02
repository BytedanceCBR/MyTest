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

#if DEBUG
static NSString * const kFHIESGeckoKey = @"adc27f2b35fb3337a4cb1ea86d05db7a";
#else
static NSString * const kFHIESGeckoKey = @"7838c7618ea608a0f8ad6b04255b97b9";
#endif

@implementation FHIESGeckoManager

+ (void)configGeckoInfo
{
    [IESGeckoKit setDeviceID:[[TTInstallIDManager sharedInstance] deviceID]];
    [IESGeckoKit registerAccessKey:kFHIESGeckoKey appVersion:@"6.6.3" channels:@[@"fe_app_c"]];
    [IESGeckoKit syncResourcesIfNeeded];// 同步资源文件
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

@end
