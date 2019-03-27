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

@implementation FHIESGeckoManager

+ (void)configGeckoInfo
{
    [IESGeckoKit setDeviceID:[[TTInstallIDManager sharedInstance] deviceID]];

    NSString *stringVersion = [FHEnvContext getToutiaoVersionCode];
    
    [IESGeckoKit registerAccessKey:kFHIESGeckoKey appVersion:stringVersion channels:@[@"fe_app_c",@"test_ios"]];
    [IESGeckoKit syncResourcesIfNeeded];// 同步资源文件
}

+ (void)configIESWebFalcon
{
    if ([[[FHHouseBridgeManager sharedInstance] envContextBridge] isOpenWebOffline]) {
        IESFalconManager.interceptionWKHttpScheme = YES;
        IESFalconManager.interceptionEnable = YES;
        
        NSString *pattern = @"^(http|https)://.*.[pstatp.com]/toutiao/";
        [IESFalconManager registerPattern:pattern forGeckoAccessKey:kFHIESGeckoKey];
    }
}

@end
