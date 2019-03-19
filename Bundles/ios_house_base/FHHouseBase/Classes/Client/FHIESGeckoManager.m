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

static NSString * const kFHIESGeckoKey = @"adc27f2b35fb3337a4cb1ea86d05db7a";

@implementation FHIESGeckoManager

+ (void)configGeckoInfo
{
    [IESGeckoKit setDeviceID:[[TTInstallIDManager sharedInstance] deviceID]];
    [IESGeckoKit registerAccessKey:kFHIESGeckoKey appVersion:@"1.0.1" channels:@[@"test_ios"]];
    [IESGeckoKit syncResourcesIfNeeded];// 同步资源文件
}

+ (void)configIESWebFalcon
{
    IESFalconManager.interceptionEnable = YES;
    
    /*
    NSString *searchPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:@"falcon_dyfe" ofType:@"zip"] toDestination:searchPath];
    [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:@"wallet" ofType:@"zip"] toDestination:searchPath];
    */
    
    NSString *pattern = @"^(http|https)://.*.[bytecdn.cn|snssdk.com|tiktok.com]/falcon/";
    //[IESFalconManager registerPattern:pattern forSearchPath:searchPath];
    [IESFalconManager registerPattern:pattern forGeckoAccessKey:kFHIESGeckoKey];
//    [IESFalconManager registerPattern:@"https://webcast.amemv.com/falcon/" forGeckoAccessKey:@"2d15e0aa4fe4a5c91eb47210a6ddf467"];
}

@end
