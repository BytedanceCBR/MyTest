//
//  HTSVideoTimingTracker.h
//  LiveStreaming
//
//  Created by SongLi.02 on 27/10/2016.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTSVideoTimingTracker : NSObject
    
/**
 *  是否正在/暂停计时
 */
- (BOOL)hasTimingForKey:(id<NSCopying>)key;

/**
 *  开始计时，如果与该key已暂停则恢复计时，如果key与已存在的key冲突则覆盖已存在的key
 */
- (BOOL)startTimingForKey:(id<NSCopying>)key ignoreBackgroundTime:(BOOL)ignore;

/**
 *  开始计时，如果与该key已暂停则恢复计时，如果key与已存在的key冲突则覆盖已存在的key
 */
- (BOOL)startTimingForKey:(id<NSCopying>)key ignoreBackgroundTime:(BOOL)ignore params:(NSDictionary *)params;

/**
 *  暂停计时
 */
- (NSTimeInterval)pauseTimingForKey:(id<NSCopying>)key;

/**
 *  恢复计时
 */
- (BOOL)resumeTimingForKey:(id<NSCopying>)key;

/**
 *  结束计时，返回duration毫秒
 */
- (NSTimeInterval)endTimingForKey:(id<NSCopying>)key;

/**
 *  取消计时
 */
- (void)cancelTimingForKey:(id<NSCopying>)key;

/**
 *  全部暂停
 */
- (void)pauseAllTiming;

/**
 *  全部恢复
 */
- (void)resumeAllTiming;

/**
 *  结束所有计时并返回结果
 */
- (NSDictionary<id<NSCopying>, NSNumber *> *)endAllTiming;

/**
 *  取参数
 */
- (NSDictionary *)paramsForKey:(id<NSCopying>)key;

/**
 *  取参数
 */
- (NSDictionary<id<NSCopying>, NSDictionary *> *)allParams;

@end

NS_ASSUME_NONNULL_END
