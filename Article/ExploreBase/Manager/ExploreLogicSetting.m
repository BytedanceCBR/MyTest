//
//  ExploreLogicSetting.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-18.
//
//

#import "ExploreLogicSetting.h"

#import "TTArticleCategoryManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "SSSimpleCache.h"
#import <TTImage/TTWebImageManager.h>
#import "NSStringAdditions.h"
#import "SSTrashManager.h"

#import "ArticleModelUpdateHelper.h"
#import "TTDBCenter.h"
#import "TTStartupTasksTracker.h"
#import "IESVideoPlayer.h"
#import "AWEVideoConstants.h"
#import <BDTBasePlayer/TTVOwnPlayerCacheWrapper.h>

//#define kClearCacheTimeInterval     (7 * 24 * 60 * 60) // 7 days
// CoreData 自动清除时间设置为7day
#define kClearCoreDataCacheTimeInterval     (10 * 24 * 60 * 60) // 10 days //49x之后从7天改成10天 nick
#define kClearCacheTimeIntervalKey  @"kClearCacheTimeIntervalKey"


NSString *const kMainTabbarClickedNotificationUserInfoHasTipKey  = @"kMainTabbarClickedNotificationUserInfoHasTipKey";
NSString *const kMainTabbarClickedNotificationUserInfoShowFriendLabelKey  = @"kMainTabbarClickedNotificationUserInfoShowFriendLabelKey";
NSString *const kMainTabbarKeepClickedNotification      = @"kMainTabbarKeepClickedNotification";
NSString *const kMomentTabbarKeepClickedNotification    = @"kMomentTabbarKeepClickedNotification";
NSString *const kMineTabbarKeepClickedNotification      = @"kMineTabbarKeepClickedNotification";
NSString *const kVideoTabbarKeepClickedNotification   = @"kVideoTabbarKeepClickedNotification";
NSString *const kPhotoTabbarKeepClickedNotification      = @"kPhotoTabbarKeepClickedNotification";
NSString *const kWeitoutiaoTabbarClickedNotification     = @"kWeitoutiaoTabbarClickedNotification";
NSString *const kTSVTabbarContinuousClickNotification      = @"kTSVTabbarContinuousClickNotification";
NSString *const kHTSTabbarClickedNotification = @"kHTSTabbarClickedNotification";

NSString *const kCategoryManagementViewCategorySelectedNotification = @"kCategoryManagementViewCategorySelectedNotification";
NSString *const kCategoryManagerViewWillHideNotification = @"kCategoryManagerViewWillHideNotification";

NSString *const kChangeExploreTabBarBadgeNumberNotification         = @"kChangeExploreTabBarBadgeNumberNotification";
NSString *const kExploreTabBarItemIndentifierKey              = @"kExploreTabBarItemIndentifierKey";
NSString *const kExploreTabBarBadgeNumberKey            = @"kExploreTabBarBadgeNumberKey";
NSString *const kExploreTabBarDisplayRedPointKey        = @"kExploreTabBarDisplayRedPointKey";

NSString *const kExploreTabBarClickNotification = @"kExploreTabBarClickNotification";
NSString *const kExploreTopVCChangeNotification = @"kExploreTopVCChangeNotification";

NSString *const kExploreMixedListRefreshTypeNotification = @"kExploreMixedListRefreshTypeNotification";
//用户登录状态改变通知
NSString *const kFHLogInAccountStatusChangedNotification = @"kFHLogInAccountStatusChangedNotification";

BOOL isShareToPlatformEnterBackground = NO;

@implementation ExploreLogicSetting

+ (void)removeOrderedDatas:(NSArray *)array save:(BOOL)save
{
    NSMutableArray * mutArray = [NSMutableArray arrayWithCapacity:10];
    for (id obj in array) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            [mutArray addObject:obj];
        }
    }
    [ExploreOrderedData removeEntities:mutArray];
}

+ (void)clearFavoriteCoreData
{
    NSDictionary *query = @{@"listType" : @(ExploreOrderedDataListTypeFavorite)};
    NSArray<ExploreOrderedData *> *objs = [ExploreOrderedData objectsWithQuery:query];
    [ExploreOrderedData removeEntities:objs];
}

+ (void)clearReadHistoryCoreData
{
    NSDictionary *query = @{@"listType" : @(ExploreOrderedDataListTypeReadHistory)};
    NSArray<ExploreOrderedData *> *objs = [ExploreOrderedData objectsWithQuery:query];
    [ExploreOrderedData removeEntities:objs];
}

+ (void)clearPushHistoryCoreData
{
    NSDictionary *query = @{@"listType" : @(ExploreOrderedDataListTypePushHistory)};
    NSArray<ExploreOrderedData *> *objs = [ExploreOrderedData objectsWithQuery:query];
    [ExploreOrderedData removeEntities:objs];
}

+ (void)clearDBNewsLocalDataSave:(BOOL)save
{
//    NSError *error = nil;
    NSDictionary *query = @{@"listType" : @(ExploreOrderedDataListTypeCategory),
                            @"categoryID" : kTTNewsLocalCategoryID};
    
    // TODO: check
    NSArray<ExploreOrderedData *> *objs = [ExploreOrderedData objectsWithQuery:query];
    [ExploreOrderedData removeEntities:objs];
}

+ (float)urlCacheSize {
    NSUInteger result = 0;
    NSString *bundleID = [TTSandBoxHelper bundleIdentifier];
    NSString *webCache = [bundleID stringCachePath];
    NSString *cachePath = [webCache stringByAppendingPathComponent:@"TTURLCache"];
    
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:cachePath];
    
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        result += [attrs fileSize];
    }
    
    return result;
}

+ (void)addUpCacheSizeWithImage:(BOOL)imageSize http:(BOOL)httpSize coreData:(BOOL)coreDataSize wendaDraft:(BOOL)wendaDraft shortVideo:(BOOL)shortVideoSize completion:(void(^)(NSInteger))completionBlock
{
    
    __block CGFloat result = 0;
    
    //除了小视频以外的其他内容的总大小
    CGFloat otherCacheSize = [self cacheSizeWithImage:imageSize http:httpSize coreData:coreDataSize wendaDraft:wendaDraft];
    
    
    result += otherCacheSize;
    result += [[TTVOwnPlayerCacheWrapper sharedCache] getCacheSize];
    
    if (shortVideoSize) {
        id<IESVideoCacheProtocol> shortVideoCache = [IESVideoCache cacheWithType:IESVideoPlayerTypeSpecify];
        [shortVideoCache getCacheSizeWithCompletion:^(CGFloat shortVideoCacheSize) {
            result += shortVideoCacheSize;
            [[TTMonitor shareManager] trackService:@"huoshanCache" value:@(shortVideoCacheSize) extra:nil];
            
            if (completionBlock) {
                completionBlock(result);
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(result);
        }
    }
}

+ (float)cacheSizeWithImage:(BOOL)imageSize http:(BOOL)httpSize coreData:(BOOL)coreDataSize wendaDraft:(BOOL)wendaDraft
{
    CGFloat result = 0;
    
    CGFloat oneMB = 1024.f * 1024.f;
    
    float cacheSize = 0, sdCacheSize = 0, dbSize = 0, draftsSize = 0, urlCacheSize = 0, trashCacheSize = 0;
    
    if (imageSize) {
        cacheSize = [SSSimpleCache cacheSize];
        sdCacheSize = ([TTWebImageManager getSize] / oneMB);
        result += (cacheSize + sdCacheSize);
        
        [[TTMonitor shareManager] trackService:@"simpleCache" value:@(cacheSize) extra:nil];
        [[TTMonitor shareManager] trackService:@"sdCache" value:@(sdCacheSize) extra:nil];
    }
    
    dbSize = [ExploreOrderedData dbSize] / oneMB;
    if (coreDataSize) {
//        float coreDataSize = [[SSModelManager sharedManager] coreDataFileSize];
//        result += coreDataSize;
        result += dbSize;
    }
    
    if (wendaDraft) {
        result += draftsSize;
        
        [[TTMonitor shareManager] trackService:@"wendaDraft" value:@(draftsSize) extra:nil];
    }
    
    urlCacheSize = [self urlCacheSize] / oneMB;
    result += urlCacheSize;
    [[TTMonitor shareManager] trackService:@"urlCache" value:@(urlCacheSize) extra:nil];
    
    /// 计算Trash里面的
    trashCacheSize = [[SSTrashManager sharedManager] trashSize] / oneMB;
    result += trashCacheSize;
    
    [[TTMonitor shareManager] trackService:@"trashCache" value:@(trashCacheSize) extra:nil];
    
    return result;
}

+ (void)clearImage:(BOOL)clearImage httpCache:(BOOL)clearHTTPCache coreDataCache:(BOOL)clearCoreDataCache
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (clearImage) {
            [self clearImageCache];
        }
    });

    if (clearCoreDataCache) {
        [self clearCoreDataCache];
    }
}

+ (void)clearCache
{
    [self clearImage:YES httpCache:YES coreDataCache:YES];
}


+ (void)clearTempVideoAudioFileCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory= NSTemporaryDirectory();
    NSString *tempVideosGroupPath = [NSString stringWithFormat:@"%@TempVideos/",documentsDirectory];
    NSString *tempAudiosGroupPath = [NSString stringWithFormat:@"%@TempAudios/",documentsDirectory];
    // 判断文件夹是否存在
    if ([fileManager fileExistsAtPath:tempVideosGroupPath]) {
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempVideosGroupPath error:nil];
        for (NSString *fileName in contents) {
            [fileManager removeItemAtPath:[tempVideosGroupPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
    
    if ([fileManager fileExistsAtPath:tempAudiosGroupPath]) {
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempAudiosGroupPath error:nil];
        for (NSString *fileName in contents) {
            [fileManager removeItemAtPath:[tempAudiosGroupPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

+ (float)cacheSizeWithTempVideoAudioFile
{
    
    CGFloat result = 0;
    CGFloat oneMB = 1024.f * 1024.f;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory= NSTemporaryDirectory();
    NSString *tempVideosGroupPath = [NSString stringWithFormat:@"%@TempVideos/",documentsDirectory];
    NSString *tempAudiosGroupPath = [NSString stringWithFormat:@"%@TempAudios/",documentsDirectory];
    
    // 判断文件夹是否存在
    if ([fileManager fileExistsAtPath:tempVideosGroupPath]) {
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempVideosGroupPath error:nil];
        for (NSString *fileName in contents) {
            NSString *filePath = [tempVideosGroupPath stringByAppendingPathComponent:fileName];
            result += [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
        }
    }
    
    if ([fileManager fileExistsAtPath:tempAudiosGroupPath]) {
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempAudiosGroupPath error:nil];
        for (NSString *fileName in contents) {
            NSString *filePath = [tempVideosGroupPath stringByAppendingPathComponent:fileName];
            result += [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
        }
    }
    
    [[TTMonitor shareManager] trackService:@"tempAudioVideo" value:@(result / oneMB) extra:nil];
    
    return result / oneMB;
}

+ (void)clearCoreDataCache
{
    [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:@"ClearCache" params:nil];
    
    //[SSModelManager clearCoreData];
    
    [TTDBCenter deleteDBFile:[ExploreOrderedData dbName]];
    
    // 清理广告过期管理数据
    [ArticleModelUpdateHelper deleteADExpirePlist];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreClearedCoreDataCacheNotification
                                                        object:self
                                                      userInfo:nil];
}

+ (void)clearImageCache
{
    [[SSSimpleCache sharedCache] clearCache];
    [TTWebImageManager clearDisk];
}

+ (void)tryClearCoreDataCache
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSNumber *last = [[NSUserDefaults standardUserDefaults] objectForKey:kClearCacheTimeIntervalKey];
    BOOL needClean = NO;
    if ([SSCommonLogic needCleanCoreData]) {
        needClean = YES;
        [SSCommonLogic setNeedCleanCoreData:NO];
    }
    if(!last) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:now] forKey:kClearCacheTimeIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        last = @(now);
    }
    if(needClean || (now - [last doubleValue] >= kClearCoreDataCacheTimeInterval)) {
        [self clearCoreDataCache];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:now] forKey:kClearCacheTimeIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)isUpgradeUser
{
//    //debug
//    return NO;
//    //end
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"exploreIsUpgradeUserKey"] boolValue];
}

+ (void)setIsUpgradeUser:(BOOL)upgrade
{
    [[NSUserDefaults standardUserDefaults] setObject:@(upgrade) forKey:@"exploreIsUpgradeUserKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNeedCleanOldCache {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSNumber *last = [[NSUserDefaults standardUserDefaults] objectForKey:kClearCacheTimeIntervalKey];
    
    BOOL needClean = NO;
    if ([SSCommonLogic needCleanCoreData]) {
        needClean = YES;
    }
    
    if(!last) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:now] forKey:kClearCacheTimeIntervalKey];
        last = @(now);
    }
    if(needClean || (now - [last doubleValue] >= kClearCoreDataCacheTimeInterval)){
        return YES;
    }
    return NO;
}


@end
