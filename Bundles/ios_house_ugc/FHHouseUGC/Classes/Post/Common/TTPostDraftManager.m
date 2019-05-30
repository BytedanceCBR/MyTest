//
//  TTPostDraftManager.m
//  TTPostThread
//
//  Created by SongChai on 2018/7/31.
//

#import "TTPostDraftManager.h"
#import <YYCache/YYDiskCache.h>
#import <TTBaseLib/TTBaseMacro.h>

@interface TTPostDraftManager ()

@end

@implementation TTPostDraftManager {
    YYDiskCache *_diskCache;
}
//
//+ (void)registerDiskBehavior {
//    TTRegisterDiskBehaviorMethod
//    [[BDDiskBehaviorManager defaultManager] registerBehavior:[TTPostDraftManager sharedInstance]];
//}

static TTPostDraftManager *sharedInstance = nil;

+ (TTPostDraftManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedInstance = [TTPostDraftManager new];
        [sharedInstance setUP];
    });
    return sharedInstance;
}

- (void)setUP {
    NSString *appSupportFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [appSupportFolder stringByAppendingPathComponent:@"TTUGC/TTPostDraft"];
    _diskCache = [[YYDiskCache alloc] initWithPath:path];
    _diskCache.ageLimit = 30 * 24 * 60 * 60;
    _diskCache.countLimit = 30;
}

- (void)saveRepostDraftWithFwID:(NSString *)fwID optID:(NSString *)optID draft:(NSDictionary *)dict {
    if (isEmptyString(fwID) && isEmptyString(optID)) {
        return;
    }
    
    [_diskCache setObject:dict forKey:[NSString stringWithFormat:@"%@-%@", fwID, optID]];
}

- (NSDictionary *)repostDraftWithFwID:(NSString *)fwID optID:(NSString *)optID {
    if (isEmptyString(fwID) && isEmptyString(optID)) {
        return nil;
    }
    
    return (NSDictionary *)[_diskCache objectForKey:[NSString stringWithFormat:@"%@-%@", fwID, optID]];
}

- (void)clearRepostDraftWithFwID:(NSString *)fwID optID:(NSString *)optID {
    if (isEmptyString(fwID) && isEmptyString(optID)) {
        return;
    }
    
    [_diskCache removeObjectForKey:[NSString stringWithFormat:@"%@-%@", fwID, optID]];
}

- (void)clearAllDraft {
    [_diskCache removeAllObjects];
}


#pragma mark - BDDiskBehavior

- (void)tt_calculateSizeWithCompletion:(BDDiskCalculateSizeBlock)completionBlock diskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager {
    //读取磁盘的大小，并且返回
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [_diskCache path];
        NSInteger fileCount = 0, fileSize = 0;
        if ([fileManager fileExistsAtPath:cachePath]) {
            NSArray<NSString *> *subpathsArray = [fileManager subpathsAtPath:cachePath];
            fileCount += [subpathsArray count];
            for (NSString *fileName in subpathsArray) {
                if ([fileName isKindOfClass:[NSString class]]) {
                    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
                    if ([fileManager fileExistsAtPath:filePath]) {
                        fileSize += [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
                    }
                }
            }
        }
        
        if (completionBlock) {
            completionBlock(fileCount,fileSize);
        }
        
    });
}

- (void)tt_clearDiskWithCompletion:(BDDiskClearCompletionBlock)completion diskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager {
    [_diskCache removeAllObjectsWithBlock:^{
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)tt_autoClearDiskWithCompletion:(BDDiskClearCompletionBlock)completion diskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager {
    [_diskCache trimToCount:5 withBlock:^{
        if (completion) {
            completion(nil);
        }
    }];
}

- (NSArray<NSURL *> *)tt_URLsOnDiskOfDiskBehaviorManager:(BDDiskBehaviorManager *)diskBehaviorManager {
    NSString *cachePath = [_diskCache path];
    NSURL *cacheURL = [NSURL URLWithString:cachePath];
    if (cacheURL) {
        return @[cacheURL];
    }
    return nil;
}

@end
