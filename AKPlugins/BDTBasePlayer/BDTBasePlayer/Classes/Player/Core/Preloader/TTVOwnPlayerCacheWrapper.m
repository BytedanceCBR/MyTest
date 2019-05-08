//
//  TTVOwnPlayerCacheWrapper.m
//  BDTBasePlayer
//
//  Created by peiyun on 2017/12/24.
//

#import "TTVOwnPlayerCacheWrapper.h"
#import "TTVOwnPlayerPreloaderWrapper.h"

@interface TTVOwnPlayerCacheWrapper ()

@end

@implementation TTVOwnPlayerCacheWrapper

+ (instancetype)sharedCache
{
    static TTVOwnPlayerCacheWrapper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTVOwnPlayerCacheWrapper alloc] init];
    });
    return instance;
}

- (void)setCacheSizeLimit:(NSUInteger)maxSizeInMB
{
    [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader setMaxCacheSize:maxSizeInMB * 1024 * 1024];
}

- (BOOL)hasCacheForVideoID:(NSString *)videoID
{
    HandleType handler = [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader getHandle:videoID resolution:TTVOwnPlayerPreloaderDefaultResolution];
    return handler != 0;
}

- (void)clearCacheForVideoID:(NSString *)videoID
{
    HandleType handler = [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader getHandle:videoID resolution:TTVOwnPlayerPreloaderDefaultResolution];
    [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader removeTask:handler];
}

- (void)clearAllCache
{
    [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader removeAllTask];
}

- (CGFloat)getCacheSize
{
    long long currentCacheSize = [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader getTotalCacheSize];
    return currentCacheSize / 1024.0 / 1024.0;
}

@end
