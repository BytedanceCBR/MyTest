//
//  TTVPlaybackTime.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TTVPlayerTimeAdaptor <NSObject>

@property (nonatomic, readonly) NSTimeInterval currentPlaybackTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval playableDuration;
@property (nonatomic, readonly) NSTimeInterval durationWatched;

@end


/**
 内核跟 playtime 相关的model
 */
@interface TTVPlaybackTime : NSObject<NSCopying>

- (instancetype)initWithTTVPlayerTimeAdaptor:(NSObject<TTVPlayerTimeAdaptor> *)adaptor;

@property (nonatomic, assign, readonly) NSTimeInterval      currentPlaybackTime;// 当前播放时间
@property (nonatomic, assign, readonly) NSTimeInterval      duration;        // 视频时长
@property (nonatomic, assign, readonly) NSTimeInterval      durationWatched; // 观看时长
@property (nonatomic, assign, readonly) NSTimeInterval      playableDuration;// 可播放时长
@property (nonatomic, assign, readonly) CGFloat             progress;        // 当前的播放进度 [0, 1]，计算得出
@property (nonatomic, assign, readonly) CGFloat             cachedProgress;  // 缓存进度[0,1] 由上面的属性计算得出

@end

NS_ASSUME_NONNULL_END
