//
//  TTVPlaybackTimePrivate.h
//  Pods
//
//  Created by panxiang on 2019/2/18.
//

/**
 内核跟 playtime 相关的model
 */
@interface TTVPlaybackTime()

/** 播放时长相关的状态 */
@property (nonatomic) NSTimeInterval currentPlaybackTime;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval durationWatched;
@property (nonatomic) NSTimeInterval playableDuration;
@property (nonatomic) CGFloat        progress; // 播放进度 [0, 1]
@property (nonatomic) CGFloat        cachedProgress; // 缓存进度[0,1] 由上面的属性计算得出

@end


