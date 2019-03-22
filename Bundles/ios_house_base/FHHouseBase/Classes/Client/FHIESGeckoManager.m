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

#if DEBUG
static NSString * const kFHIESGeckoKey = @"adc27f2b35fb3337a4cb1ea86d05db7a";
//static NSString * const kFHIESGeckoKey = @"7838c7618ea608a0f8ad6b04255b97b9";
#else
static NSString * const kFHIESGeckoKey = @"adc27f2b35fb3337a4cb1ea86d05db7a";
//static NSString * const kFHIESGeckoKey = @"7838c7618ea608a0f8ad6b04255b97b9";
#endif

@implementation FHIESGeckoManager

+ (void)configGeckoInfo
{
    [IESGeckoKit setDeviceID:[[TTInstallIDManager sharedInstance] deviceID]];
    [IESGeckoKit registerAccessKey:kFHIESGeckoKey appVersion:@"6.6.1" channels:@[@"fe_app_c"]];
    [IESGeckoKit syncResourcesIfNeeded];// 同步资源文件
}

+ (void)configIESWebFalcon
{
    IESFalconManager.interceptionEnable = YES;
    
    /*
    NSString *searchPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:@"falcon_dyfe" ofType:@"zip"] toDestin ation:searchPath];
    [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:@"wallet" ofType:@"zip"] toDestination:searchPath];
    */
    
    NSString *pattern = @"^(http|https)://.*.[bytecdn.cn|snssdk.com|pstatp.com]/toutiao/";
    //[IESFalconManager registerPattern:pattern forSearchPath:searchPath];
    [IESFalconManager registerPattern:pattern forGeckoAccessKey:kFHIESGeckoKey];
//    [IESFalconManager registerPattern:@"https://webcast.amemv.com/falcon/" forGeckoAccessKey:@"2d15e0aa4fe4a5c91eb47210a6ddf467"];
}

@end
