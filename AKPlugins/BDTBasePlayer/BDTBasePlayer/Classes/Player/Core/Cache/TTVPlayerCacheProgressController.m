//
//  TTVPlayerCacheProgressController.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerCacheProgressController.h"
#import "KVOController.h"
#import "TTTRacker.h"

@interface TTVPlayerCacheProgressObject : NSObject

@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, assign) CGFloat progress;
/**
 记录当前播放的时间
 */
@property (nonatomic, assign) CGFloat currentTime;
@property (nonatomic, copy) NSString *stopEvent;

- (instancetype)initWithVideoID:(NSString *)videoID progress:(CGFloat)progress currentTime:(CGFloat)currentTime;

@end

@implementation TTVPlayerCacheProgressObject

- (instancetype)initWithVideoID:(NSString *)videoID progress:(CGFloat)progress currentTime:(CGFloat)currentTime {
    self = [super init];
    if (self) {
        _videoID = [videoID copy];
        _progress = progress;
        _currentTime = currentTime;
    }
    return self;
}

@end

@interface TTVPlayerCacheProgressController ()

@property (nonatomic, assign) NSInteger maxCacheCount;
@property (nonatomic, strong) NSMutableArray *cacheQueue;

@end

@implementation TTVPlayerCacheProgressController

- (void)dealloc
{
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
    }
}

+ (TTVPlayerCacheProgressController *)sharedInstance {
    static TTVPlayerCacheProgressController *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTVPlayerCacheProgressController alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxCacheCount = 2;
        _cacheQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    if (action.actionType == TTVPlayerEventTypeShowVideoFirstFrame) {
        TTVPlayerCacheProgressObject *cache = [self objectWithVideoID:self.playerStateStore.state.playerModel.videoID];
        [self sendContinuePlayTrack:cache.stopEvent];
    }
}

- (void)sendContinuePlayTrack:(NSString *)stopEvent
{
    NSString *label = @"list_continue";
    if (self.playerStateStore.state.isInDetail) {
        label = @"detail_continue";
    }
    ttTrackEvent(stopEvent, label);
}

- (void)removeCacheForVideoID:(NSString *)videoID
{
    __block TTVPlayerCacheProgressObject *same = nil;
    [_cacheQueue enumerateObjectsUsingBlock:^(TTVPlayerCacheProgressObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.videoID isEqualToString:videoID]) {
            same = obj;
            *stop = YES;
        }
    }];
    if (same) {
        [_cacheQueue removeObject:same];
    }
}

- (void)cacheProgress:(CGFloat)progress currentTime:(CGFloat)currentTime VideoID:(NSString *)videoID {
    if (progress <= 0 || progress >= 100) {
        return;
    }
    __block TTVPlayerCacheProgressObject *same = nil;
    [_cacheQueue enumerateObjectsUsingBlock:^(TTVPlayerCacheProgressObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (videoID.length > 0 && [obj.videoID isEqualToString:videoID]) {
            same = obj;
            *stop = YES;
        }
    }];
    if (same) {
        [_cacheQueue removeObject:same];
    }
    TTVPlayerCacheProgressObject *obj = [[TTVPlayerCacheProgressObject alloc] initWithVideoID:videoID progress:progress currentTime:currentTime];
    obj.stopEvent = self.playerStateStore.state.isInDetail ? @"detail_over" : @"list_over";
    [_cacheQueue addObject:obj];
    if (_cacheQueue.count > _maxCacheCount) {
        [_cacheQueue removeObjectAtIndex:0];
    }
}

- (TTVPlayerCacheProgressObject *)objectWithVideoID:(NSString *)videoID {
    for (TTVPlayerCacheProgressObject *obj in _cacheQueue) {
        if ([obj.videoID isEqualToString:videoID]) {
            return obj;
            break;
        }
    }
    return nil;
}

- (TTVPlayerCacheProgressObject *)progressObjectForVideoID:(NSString *)videoID {
    for (TTVPlayerCacheProgressObject *obj in _cacheQueue) {
        if ([obj.videoID isEqualToString:videoID]) {
            return obj;
            break;
        }
    }
    return nil;
}

- (CGFloat)playTimeForVideoID:(NSString *)videoID{
    return [self progressObjectForVideoID:videoID].currentTime;
}

- (CGFloat)progressForVideoID:(NSString *)videoID {
    return [self progressObjectForVideoID:videoID].progress;
}

@end
