//
//  TTMonitor+Timing.h
//  LiveStreaming
//
//  Created by SongLi.02 on 9/4/16.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import <TTMonitor/TTMonitor.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTMonitor (Timing)

/**
 *  开始计时，如果key与已存在的key冲突则覆盖已存在的key
 */
+ (void)startTimingForKey:(nonnull id<NSCopying>)key;

/**
 *  结束计时，并将duration上报monitor。成功则返回YES，未找到key则返回NO
 */
+ (BOOL)endTimingForKey:(nonnull id<NSCopying>)key serviceName:(nonnull NSString *)serviceName;

/**
 *  取消计时
 */
+ (void)cancelTimingForKey:(nonnull id<NSCopying>)key;

+ (NSTimeInterval)timeIntervalForKey:(nonnull id<NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
