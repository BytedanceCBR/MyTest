//
//  TTVOwnPlayerCacheWrapper.h
//  BDTBasePlayer
//
//  Created by peiyun on 2017/12/24.
//

#import <Foundation/Foundation.h>

@interface TTVOwnPlayerCacheWrapper : NSObject

+ (instancetype)sharedCache;

- (void)setCacheSizeLimit:(NSUInteger)maxSizeInMB;
- (BOOL)hasCacheForVideoID:(NSString *)videoID;
- (void)clearCacheForVideoID:(NSString *)videoID;
- (void)clearAllCache;
- (CGFloat)getCacheSize;

@end
