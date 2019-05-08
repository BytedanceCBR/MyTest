//
//  TTVPlayerEventController.h
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerControllerProtocol.h"

@class TTVPlayerStateStore;
@class TTVPlayerModel;

@interface TTVPlayerEventController : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerModel *playerModel;
@property (nonatomic, strong, readonly) UIView *playerLayer;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) BOOL muted;
/// 播放时是否使用缓存&预加载
@property (nonatomic, assign) BOOL useCache;
/**
 请求播放地址url
 */
@property (nonatomic, copy,readonly) NSString *requestUrl;
- (void)readyToPlay;
- (void)releaseAysnc;
- (void)playVideo;
- (void)pauseVideo;
- (void)playVideoFromPayload:(NSDictionary *)payload;
- (void)pauseVideoFromPayload:(NSDictionary *)payload;
- (void)stopVideo;
- (void)seekVideoToProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised;
- (void)saveCacheProgress;
- (void)changeResolution:(TTVPlayerResolutionType)type;
@end
