//
//  TTVPlayer+CacheProgress.h
//  Article
//
//  Created by panxiang on 2018/7/24.
//

#import "TTVPlayer.h"

#define TTVPlayerActionTypeRestoreCachedProgress @"TTVPlayerActionTypeRestoreCachedProgress"

@interface TTVProgressContext : NSObject

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSNumber *playbackTime;

- (instancetype)initWithKey:(NSString *)key playbackTime:(NSNumber *)time;

@end

@interface TTVPlayer (CacheProgress)

- (void)addTerminateNotification;
/**
 Cache current player progress. Must called before player stop or pause, after videoID was set up
 */
- (void)cacheProgress;

/**
 Restore cached progress. Called after player init, before play, after videoID was set up
 */
//- (void)restoreCachedProgressWithSource:(TTVPlayerSource)source;

/**
 Remove the progress cached before if less 5 sec left. Called when play finished, after videoID was set up
 */
- (void)removeProgressCacheIfNeeded;

- (TTVProgressContext *)cachedContextForKey:(NSString *)key;
@end
