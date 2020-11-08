//
//  TTVPlayerCacheProgressController.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStateStore.h"
#import "TTVPlayerControllerProtocol.h"

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


@interface TTVPlayerCacheProgressController : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

/// 兼容feed内流播放进度缓存
@property (nonatomic, assign) NSInteger detailMaxCacheCount;
@property (nonatomic, strong) NSMutableArray *detailCacheQueue;

+ (TTVPlayerCacheProgressController *)sharedInstance;
- (void)cacheProgress:(CGFloat)progress currentTime:(CGFloat)currentTime VideoID:(NSString *)videoID isDetailFeed:(BOOL)isDetailFeed;
- (CGFloat)playTimeForVideoID:(NSString *)videoID;
- (void)removeCacheForVideoID:(NSString *)videoID;
- (CGFloat)progressForVideoID:(NSString *)videoID;

@end

