//
//  TTHTSVideoConfiguration.m
//  LiveStreaming
//
//  Created by SongLi.02 on 15/05/2017.
//  Copyright © 2017 Bytedance. All rights reserved.
//

#import "TTHTSVideoConfiguration.h"
#import <IESVideoPlayer/IESVideoPlayer.h>
#import "TTDeviceHelper.h"
#import "TTSandBoxHelper.h"
#import "TTInstallIDManager.h"
#import "TTAccountManager.h"
#import "TTNetworkHelper.h"
#import "TTExtensions.h"
#import "SSLogDataManager.h"
#import "TTVVideoURLSettingUtility.h"
#import "TTVPlayerSettingUtility.h"
#import "AWEVideoDiskCacheConfiguration.h"
#import "TTSettingsManager.h"

@implementation TTHTSVideoConfiguration

+ (void)setup
{
    [IESVideoPlayerConfig setUserKey:[self shortVideoUserKey] secretKey:[self shortVideoSecretKey]];
    
    [IESVideoPlayerConfig setCommonParamBlock:^NSDictionary * {
        /**
         *  根据头条视频标准上报通用参数
         *  「 @高洪磊 ：os_version  aid  device_id  user_id  web_id  cx (WIFI等网络类型)  device_platform version_code update_version_code 」
         */
        NSMutableDictionary *commonParams = [NSMutableDictionary dictionary];
        [commonParams setValue:@([TTDeviceHelper OSVersionNumber]) forKey:@"os_version"];
        [commonParams setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
        [commonParams setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        [commonParams setValue:[TTAccountManager userID] forKey:@"user_id"];
        [commonParams setValue:[TTNetworkHelper connectMethodName] forKey:@"cx"];
        [commonParams setValue:[TTDeviceHelper platformName] forKey:@"device_platform"];
        [commonParams setValue:[TTSandBoxHelper versionName] forKey:@"version_code"];
        [commonParams setValue:[TTExtensions buildVersion] forKey:@"update_version_code"];
        return [commonParams copy];
    }];
    
    [IESVideoPlayerConfig setDomainConfigBlock:^NSString *(NSString *url) {
        return [TTVVideoURLSettingUtility toutiaoPlayApi];
    }];
    
    [IESVideoPlayerConfig setApplogCallBlock:^(NSDictionary *dict) {
        [[SSLogDataManager shareManager] appendLogData:dict];
    }];
    
    [IESVideoPlayerConfig setCacheKeyParserBlock:^NSString *(NSString *url) {
        return [url MD5HashString];
    }];
    
    NSInteger limitCache = 100;
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_disk_cache_optimize" defaultValue:@1 freeze:YES] boolValue]) {
        float fressDisk = [TTDeviceHelper getFreeDiskSpace]/(1024 *1024);
        if (fressDisk < 500) {
            limitCache = 50;
        }
    }
    // 缓存的整体最大大小 MB
    [IESVideoPlayerConfig setCacheSizeLimit:limitCache];
    
    // 自动清理缓存的时间间隔 sec
    [AWEVideoDiskCacheConfiguration sharedInstance].autoTrimInterval = 10 * 60;
}

+ (NSString *)shortVideoUserKey
{
    return @"tt_shortvideo";
}

+ (NSString *)shortVideoSecretKey
{
    return @"1fd5db12db3d3992d4400e1559f720d4";
}

@end
