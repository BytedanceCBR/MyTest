//
//  TTVPlayerCacheProgressController+DetailFeed.h
//  BDTBasePlayer
//
//  Created by 刘华龙 on 2020/5/15.
//

#import "TTVPlayerCacheProgressController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerCacheProgressController (DetailFeed)

- (void)detailFeedCacheProgress:(CGFloat)progress currentTime:(CGFloat)currentTime VideoID:(NSString *)videoID;
- (void)detailFeedRemoveCacheForVideoID:(NSString *)videoID;
- (void)detailFeedRemoveCache;

@end

NS_ASSUME_NONNULL_END

