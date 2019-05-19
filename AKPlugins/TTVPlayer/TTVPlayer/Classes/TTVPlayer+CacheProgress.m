//
//  TTVPlayer+CacheProgress.m
//  Article
//
//  Created by panxiang on 2018/7/24.
//

#import "TTVPlayer+CacheProgress.h"
#import "TTVPlayer+Engine.h"

#define kCacheThreshold 5


@implementation TTVProgressContext

- (instancetype)initWithKey:(NSString *)key playbackTime:(NSNumber *)time {
    if (self = [super init]) {
        _key = key;
        _playbackTime = time;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"key : %@, cache time : %@", _key, _playbackTime];
}

@end


static NSMutableArray<TTVProgressContext *> *_sharedContextQueue;

@implementation TTVPlayer (CacheProgress)

- (void)addTerminateNotification {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)cacheProgress {
    NSTimeInterval currentPlayTime = self.playbackTime.currentPlaybackTime;
    NSTimeInterval duration = self.playbackTime.duration;
    NSString *videoID = self.videoID;
    if (currentPlayTime <= 0 || duration <= 0 || isnan(currentPlayTime) || isnan(duration) || (duration - currentPlayTime) < kCacheThreshold) {
        [self removeProgressCacheIfNeeded];
        return;
    }
    
    TTVProgressContext *context = [[TTVProgressContext alloc] initWithKey:videoID playbackTime:@(currentPlayTime)];
    if (!_sharedContextQueue) {
        _sharedContextQueue = [NSMutableArray arrayWithCapacity:8];
        [_sharedContextQueue addObject:context];
    } else {
        BOOL updateExist = NO;
        for (TTVProgressContext *subContext in _sharedContextQueue) {
            if ([subContext.key isEqualToString:videoID]) {
                [_sharedContextQueue removeObject:subContext];
                [_sharedContextQueue addObject:context];
                updateExist = YES;
                break;
            }
        }
        if (!updateExist) {
            if (_sharedContextQueue.count == 8) {
                [_sharedContextQueue removeObjectAtIndex:0];
            }
            [_sharedContextQueue addObject:context];
        }
    }
}

- (void)removeProgressCacheIfNeeded {
    NSTimeInterval currentPlayTime = self.playbackTime.currentPlaybackTime;
    NSTimeInterval duration = self.playbackTime.duration;
    if (!isnan(currentPlayTime) && !isnan(duration) && (duration - currentPlayTime) < kCacheThreshold) {
        for (TTVProgressContext *subContext in _sharedContextQueue) {
            if ([subContext.key isEqualToString:self.videoID]) {
                [_sharedContextQueue removeObject:subContext];
                break;
            }
        }
    }
}

- (TTVProgressContext *)cachedContextForKey:(NSString *)key {
    if (isEmptyString(key)) {
        return nil;
    }
    for (TTVProgressContext *context in _sharedContextQueue) {
        if ([context.key isEqualToString:key]) {
            TTVProgressContext *poppedContext = context;
            return poppedContext;
        }
    }
    return nil;
}

- (void)applicationWillTerminate:(UIApplication *)application {
//    NSLog(@"%s", __FUNCTION__);
//    [self stop];
}


@end

