//
//  TTVPlayerCacheProgressController+DetailFeed.m
//  BDTBasePlayer
//
//  Created by 刘华龙 on 2020/5/15.
//

#import "TTVPlayerCacheProgressController+DetailFeed.h"

@implementation TTVPlayerCacheProgressController (DetailFeed)

- (void)detailFeedCacheProgress:(CGFloat)progress currentTime:(CGFloat)currentTime VideoID:(NSString *)videoID {
    
    __block TTVPlayerCacheProgressObject *same = nil;
    [self.detailCacheQueue enumerateObjectsUsingBlock:^(TTVPlayerCacheProgressObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (videoID.length > 0 && [obj.videoID isEqualToString:videoID]) {
            same = obj;
            *stop = YES;
        }
    }];
    if (same) {
        [self.detailCacheQueue removeObject:same];
    }
    TTVPlayerCacheProgressObject *obj = [[TTVPlayerCacheProgressObject alloc] initWithVideoID:videoID progress:progress currentTime:currentTime];
    obj.stopEvent = self.playerStateStore.state.isInDetail ? @"detail_over" : @"list_over";
    [self.detailCacheQueue addObject:obj];
    if (self.detailCacheQueue.count > self.detailMaxCacheCount) {
        [self.detailCacheQueue removeObjectAtIndex:0];
    }
    
}

- (void)detailFeedRemoveCacheForVideoID:(NSString *)videoID
{
    __block TTVPlayerCacheProgressObject *same = nil;
    [self.detailCacheQueue enumerateObjectsUsingBlock:^(TTVPlayerCacheProgressObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.videoID isEqualToString:videoID]) {
            same = obj;
            *stop = YES;
        }
    }];
    if (same) {
        [self.detailCacheQueue removeObject:same];
    }
}

- (void)detailFeedRemoveCache {
    [self.detailCacheQueue removeAllObjects];
}

@end

