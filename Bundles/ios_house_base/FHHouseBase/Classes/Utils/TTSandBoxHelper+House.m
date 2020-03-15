//
//  TTSandBoxHelper+House.m
//  FHHouseBase
//
//  Created by 张静 on 2019/6/26.
//

#import "TTSandBoxHelper+House.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <objc/runtime.h>

@implementation TTSandBoxHelper (House)

+ (void)load
{
    Class class = [TTSandBoxHelper class];
    SEL originalSelector = @selector(isInHouseApp);
    SEL swizzledSelector = @selector(fh_isInHouseApp);
    [self exchangeClassMethod:class originalSelector:originalSelector swizzledSelector:swizzledSelector];
    SEL original1 = @selector(buildVerion);
    SEL swizzled1 = @selector(fhBuildVersion);
    [self exchangeClassMethod:class originalSelector:original1 swizzledSelector:swizzled1];
}


+ (void)exchangeClassMethod:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(object_getClass(class),
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (BOOL)fh_isInHouseApp
{
    // todo zjing test
    return YES;
    
    NSRange isRange = [[TTSandBoxHelper bundleIdentifier] rangeOfString:@"fp1" options:NSCaseInsensitiveSearch];
    if (isRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (NSString *)fhBuildVersion
{
    NSString * buildVersionRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
    NSString * buildVersionNew = [buildVersionRaw stringByReplacingOccurrencesOfString:@"." withString:@""];
    return buildVersionNew;
}



+ (BOOL)isAPPFirstLaunchForAd
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * currentStatus = [defaults objectForKey:@"isAPPFirstLaunchForAd_key"];
    return [currentStatus intValue] == 1 ? NO : YES;
    
}

+ (void)setAppFirstLaunchForAd
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"isAPPFirstLaunchForAd_key"];
    [defaults synchronize];
}


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

/**
 *  f100发布版本号，在info.plist基础上+600，为了兼容主端
 *
 *  @return 可能为nil
 */
+ (nullable NSString *)fhVersionCode
{
    /*
     * 因为feed流要求版本与头条一致，当前为0.x.x 待后面正式后要注意更改对应关系
     */
    NSString *curVersion = [TTSandBoxHelper versionName];
    NSArray<NSString *> *strArray = [curVersion componentsSeparatedByString:@"."];
    NSInteger version = 0;
    for (NSInteger i = 0; i < strArray.count; i += 1) {
        NSString *tmp = strArray[i];
        version = version * 10 + tmp.integerValue;
    }
    version += 600;
    NSMutableArray *newStrArray = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 2; i += 1) {
        NSInteger num = version % 10;
        version /= 10;
        NSString *tmp = [NSString stringWithFormat:@"%ld", num];
        [newStrArray addObject:tmp];
    }
    NSString *tmp = [NSString stringWithFormat:@"%ld",version];
    [newStrArray addObject:tmp];
    NSString *newVersion = [[newStrArray reverseObjectEnumerator].allObjects componentsJoinedByString:@"."];
    return newVersion;
}

@end
