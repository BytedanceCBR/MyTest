//
//  TTPostVideoCacheHelper.m
//  Article
//
//  Created by 王霖 on 16/10/25.
//
//

#import "TTPostVideoCacheHelper.h"
#import "NSDictionary+TTAdditions.h"
#import "TTBaseMacro.h"
#import "TTNetworkDefine.h"

static NSTimeInterval const kMaxCacheTimeInterval = 24*60*60;

static NSString * const kTTVideoCacheHelperVideoPathRetainCountMapKey = @"kTTVideoCacheHelperVideoPathMapKey";

NSString * const kTTVideoCacheHelperTitleKey = @"kTTVideoCacheHelperTitleKey";
NSString * const kTTVideoCacheHelperTitleRichSpanKey = @"kTTVideoCacheHelperTitleRichSpanKey";
NSString * const kTTVideoCacheHelperTitleInfoKey = @"kTTVideoCacheHelperTitleInfoKey";
static NSString * const kTTVideoCacheHelperVideosMapKey = @"kTTVideoCacheHelperVideosMapKey";
static NSString * const kTTVideoCacheHelperVideoGidKey = @"kTTVideoCacheHelperVideoGidKey";
static NSString * const kTTVideoCacheHelperVideoUrlKey = @"kTTVideoCacheHelperVideoUrlKey";
static NSString * const kTTVideoCacheHelperVideoTimeStampKey = @"kTTVideoCacheHelperVideoTimeStampKey";

@implementation TTPostVideoCacheHelper

+ (instancetype)sharedHelper {
    static TTPostVideoCacheHelper * sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[[self class] alloc] init];
        [sharedController cacheTitleInfo:nil];
    });
    return sharedController;
}

- (void)retainVideoAtPath:(nullable NSString *)videoPath {
    if (isEmptyString(videoPath)) {
        return;
    }
    NSDictionary *videoRetainCountArray = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTVideoCacheHelperVideoPathRetainCountMapKey];
    NSMutableDictionary *videoRetainCountMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:videoRetainCountArray];
    NSInteger retainCount = [videoRetainCountMutableDictionary tt_integerValueForKey:videoPath];
    retainCount = retainCount + 1;
    [videoRetainCountMutableDictionary setValue:@(retainCount) forKey:videoPath];
    [[NSUserDefaults standardUserDefaults] setValue:videoRetainCountMutableDictionary forKey:kTTVideoCacheHelperVideoPathRetainCountMapKey];
}

- (void)releaseVideoAtPath:(nullable NSString *)videoPath {
    [self releaseVideoAtPath:videoPath force:NO];
}

- (void)releaseVideoAtPath:(nullable NSString *)videoPath force:(BOOL)force {
    if (isEmptyString(videoPath)) {
        return;
    }
    NSDictionary *videoRetainCountArray = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTVideoCacheHelperVideoPathRetainCountMapKey];
    NSMutableDictionary *videoRetainCountMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:videoRetainCountArray];
    
    if (force) {
        [videoRetainCountMutableDictionary removeObjectForKey:videoPath];
        NSError *error = nil;
        NSString *url = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), videoPath];
        __unused BOOL succeed = [[NSFileManager defaultManager] removeItemAtPath:url error:&error];
        LOGD(@"删除视频 %@ %@ error: %@", succeed ? @"成功" : @"失败", videoPath, error);
    }else {
        NSInteger retainCount = [videoRetainCountMutableDictionary tt_integerValueForKey:videoPath];
        retainCount = retainCount - 1;
        if (retainCount <= 0) {
            [videoRetainCountMutableDictionary removeObjectForKey:videoPath];
            NSError *error = nil;
            NSString *url = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), videoPath];
            __unused BOOL succeed = [[NSFileManager defaultManager] removeItemAtPath:url error:&error];
            LOGD(@"删除视频 %@ %@ error: %@", succeed ? @"成功" : @"失败", videoPath, error);
        }
        else {
            [videoRetainCountMutableDictionary setValue:@(retainCount) forKey:videoPath];
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:videoRetainCountMutableDictionary forKey:kTTVideoCacheHelperVideoPathRetainCountMapKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addVideoCacheWith:(nullable NSString *)gid url:(nullable NSString *)url {
    NSArray <NSDictionary *> * videosCacheMap = [[NSUserDefaults standardUserDefaults] objectForKey:kTTVideoCacheHelperVideosMapKey];
    NSMutableArray <NSDictionary *> * mutableVideosCacheMap =[NSMutableArray array];
    if ([videosCacheMap isKindOfClass:[NSArray class]] && videosCacheMap.count > 0) {
        [mutableVideosCacheMap addObjectsFromArray:videosCacheMap];
    }
    NSMutableDictionary * map = [NSMutableDictionary dictionary];
    [map setValue:gid forKey:kTTVideoCacheHelperVideoGidKey];
    [map setValue:url forKey:kTTVideoCacheHelperVideoUrlKey];
    [map setValue:[NSDate date] forKey:kTTVideoCacheHelperVideoTimeStampKey];
    [mutableVideosCacheMap addObject:map];
    [[NSUserDefaults standardUserDefaults] setObject:mutableVideosCacheMap forKey:kTTVideoCacheHelperVideosMapKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteVideoCacheIfNeed {
    // 清理发送成功的视频
    NSArray <NSDictionary *> * videosCacheMap = [[NSUserDefaults standardUserDefaults] objectForKey:kTTVideoCacheHelperVideosMapKey];
    if ([videosCacheMap isKindOfClass:[NSArray class]] && videosCacheMap.count > 0) {
        NSMutableArray <NSDictionary *> * videosCacheMutableMap = videosCacheMap.mutableCopy;
        NSMutableArray <NSDictionary *> * needDeleteVideosCache = [NSMutableArray array];
        
        [videosCacheMap enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                //去掉24h清理缓存的策略
//                NSDate * date = [obj objectForKey:kTTVideoCacheHelperVideoTimeStampKey];
//
//                NSDate * nowDate = [NSDate date];
//                NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate:date];

//                if (timeInterval >= kMaxCacheTimeInterval) {
//                    [needDeleteVideosCache addObject:obj];
//                }
            }else {
                [needDeleteVideosCache addObject:obj];
            }
        }];
        [needDeleteVideosCache enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString * url = [obj tt_stringValueForKey:kTTVideoCacheHelperVideoUrlKey];
                [self releaseVideoAtPath:url];
                [videosCacheMutableMap removeObject:obj];
            }else {
                [videosCacheMutableMap removeObject:obj];
            }
        }];
        
        if (videosCacheMutableMap.count > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:videosCacheMutableMap forKey:kTTVideoCacheHelperVideosMapKey];
        }else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTVideoCacheHelperVideosMapKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 清理没有使用的视频
    NSDictionary * videoRetainCountMap = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTVideoCacheHelperVideoPathRetainCountMapKey];
    NSSet * allVideoPaths = [NSSet setWithArray:videoRetainCountMap.allKeys];
    
    NSString * homeDirectory = NSHomeDirectory();
    NSString * videocachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/TTMicroHeadlineVideo/"];
    NSArray <NSString *> * allVideos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videocachesDirectory error:nil];
    [allVideos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = [videocachesDirectory stringByAppendingString:obj];
        if (homeDirectory.length < obj.length) {
            obj = [obj substringFromIndex:homeDirectory.length];
        }
        if (![allVideoPaths containsObject:obj]) {
            [[NSFileManager defaultManager] removeItemAtPath:[homeDirectory stringByAppendingString:obj] error:nil];
        }
    }];
}

//- (NSString *)titleOfCached {
//    NSString * title = [[NSUserDefaults standardUserDefaults] objectForKey:kTTVideoCacheHelperTitleKey];
//    if (isEmptyString(title)) {
//        return nil;
//    }else {
//        return title;
//    }
//}
//
//- (void)cacheTitle:(nullable NSString *)title {
//    if (isEmptyString(title)) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTVideoCacheHelperTitleKey];
//    }else {
//        [[NSUserDefaults standardUserDefaults] setObject:title forKey:kTTVideoCacheHelperTitleKey];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

- (void)cacheTitleInfo:(NSDictionary *)titleInfo{
    if (SSIsEmptyDictionary(titleInfo)) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTVideoCacheHelperTitleInfoKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:titleInfo forKey:kTTVideoCacheHelperTitleInfoKey];
    }
}

- (NSDictionary *)getTitleInfo{
    NSDictionary *titleInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kTTVideoCacheHelperTitleInfoKey];
    if (SSIsEmptyDictionary(titleInfo)) {
        return nil;
    }
    return titleInfo;
}

@end
