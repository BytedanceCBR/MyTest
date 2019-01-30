//
//  TTSandBoxHelper.m
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import "TTSandBoxHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation TTSandBoxHelper
@end

@implementation TTSandBoxHelper (TTPlist)

+ (NSString*)appDisplayName {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    return appName;
}

+ (NSString*)versionName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)bundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)buildVerion{
//    NSString* buildVersionRaw = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    NSString * buildVersionRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
    NSString * buildVersionNew = [buildVersionRaw stringByReplacingOccurrencesOfString:@"." withString:@""];
    //除非误操作info.plist文件，否则版本一直会有
    if (!buildVersionNew) {
        buildVersionNew = @"65100";
    }
    return buildVersionNew;
}

+ (NSString*)appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"];
}

+ (BOOL)isInHouseApp {
    NSRange isRange = [[self bundleIdentifier] rangeOfString:@"inHouse" options:NSCaseInsensitiveSearch];
    if (isRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (NSString*)ssAppID {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSAppID"];
}

+ (NSString *)ssAppMID {
    NSString * mid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSMID"];
    if (!mid) {
        NSLog(@"*** NO SSMID set in plist");
    }
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSMID"];
}

+ (NSString *)ssAppScheme {
    NSString * mid = [self ssAppMID];
    if (mid) {
        return [NSString stringWithFormat:@"snssdk%@://", mid];
    }
    NSLog(@"*** CAN NOT generate AppScheme");
    return nil;
}

+ (NSString *)appOwnURL {
    NSArray *urlTypes = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleURLTypes"];
    NSDictionary *urlDic = [[urlTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"CFBundleURLName=%@",@"own"]] firstObject];
    NSString *url = [[urlDic valueForKey:@"CFBundleURLSchemes"] firstObject];
    return url;
}

+ (NSString *)getCurrentChannel {
    static NSString *channelName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channelName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
    });
    return channelName;
}

+ (BOOL)isAppStoreChannel {
    if([[self getCurrentChannel] isEqualToString:@"App Store"])
        return YES;
    
    return NO;
}

@end

@implementation TTSandBoxHelper (TTUserDefault)

//+ (NSString *)deviceID {
//    NSString * dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSSCommonSavedDeviceIDKey"];
//    if (!dID || dID.length == 0) {
//        //ugly code 兼容升级版本的临时策略
//        dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kDeviceIDStorageKey"];
//    }
//    return dID;
//}
//
//+ (void)saveDeviceID:(NSString *)deviceID {
//    [[NSUserDefaults standardUserDefaults] setValue:deviceID forKey:@"kSSCommonSavedDeviceIDKey"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+ (void)saveInstallID:(NSString *)installID {
//    [[NSUserDefaults standardUserDefaults] setValue:installID forKey:@"kSSCommonSavedIIDKey"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+ (NSString *)installID {
//    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kSSCommonSavedIIDKey"];
//}

+ (BOOL)isAPPFirstLaunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSNumber * currentStatus = [defaults objectForKey:[NSString stringWithFormat:@"APP_LAUNCHED%@", key]];
    return [currentStatus intValue] == 1 ? NO : YES;
}

+ (void)setAppFirstLaunch {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"APP_LAUNCHED%@", key]];
    [defaults synchronize];
}

+ (NSInteger)appLaunchedTimes {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * currentStatus = [defaults objectForKey:[self _AppLaunchedTimesKey]];
    return [currentStatus integerValue];
}

+ (void)setAppDidLaunchThisTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self _AppLaunchedTimesKey];
    NSInteger launchedTime = [[defaults valueForKey:key] integerValue];
    [defaults setValue:@(launchedTime + 1) forKey:key];
    [defaults synchronize];
}

+ (void)resetAppLaunchedTimes {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(0) forKey:[self _AppLaunchedTimesKey]];
    [defaults synchronize];
}

+ (NSString *)_AppLaunchedTimesKey {
    return [NSString stringWithFormat:@"APP_LAUNCHED_Times%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

@end

@implementation TTSandBoxHelper (TTFileSystem)

- (NSString *)sandBoxCachePath {
    NSString* cachePath = nil;
    if (!cachePath) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachePath = [dirs objectAtIndex:0];
    }
    return cachePath;
}

- (NSString *)sandBoxDocumentsPath {
    static NSString* documentsPath = nil;
    if (!documentsPath) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [dirs objectAtIndex:0];
    }
    return documentsPath;
}

+ (BOOL)disableBackupForPath:(NSString*)path {
    NSURL *URL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    return error == nil;
}

@end

@implementation TTSandBoxHelper (TTAssetCount)

+ (void)saveAssetCount {
    [self _getAssetCountIfAutorizedCompleted:^(BOOL succeed, NSInteger count) {
        if (succeed) {
            [[NSUserDefaults standardUserDefaults] setValue:@(count) forKey:@"NSUserDefaultsKeyAssetCount"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUserDefaultsKeyAssetCount"];
        }
    }];
}

+ (BOOL)hasValidAssetCountSavedLastTime {
    id countObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultsKeyAssetCount"];
    if (countObj) {
        return YES;
    }
    return NO;
}

+ (NSInteger)assetCountSavedLastTime {
    NSInteger assetCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"NSUserDefaultsKeyAssetCount"];
    return assetCount;
}

+ (void)_getAssetCountIfAutorizedCompleted:(void(^)(BOOL succeed, NSInteger count))completed {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetsLibrary *assetsLibrary = [self _defaultAssetsLibrary];
            __block NSInteger count = 0;
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    count += [group numberOfAssets];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completed(YES, count);
                    });
                }
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completed(NO, 0);
                });
            }];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(NO, 0);
        });
    }
}

+ (ALAssetsLibrary *)_defaultAssetsLibrary {
    static ALAssetsLibrary *library;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

@end

