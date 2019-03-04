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

@interface TTVPlayerCacheProgressController : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
+ (TTVPlayerCacheProgressController *)sharedInstance;
- (void)cacheProgress:(CGFloat)progress currentTime:(CGFloat)currentTime VideoID:(NSString *)videoID;
- (CGFloat)playTimeForVideoID:(NSString *)videoID;
- (void)removeCacheForVideoID:(NSString *)videoID;
- (CGFloat)progressForVideoID:(NSString *)videoID;

@end
