//
//  TTMonitor+Timing.m
//  LiveStreaming
//
//  Created by SongLi.02 on 9/4/16.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import "TTMonitor+Timing.h"

static NSMutableDictionary *timingDict;

@implementation TTMonitor (Timing)

+ (void)startTimingForKey:(id<NSCopying>)key
{
    if (key) {
        NSNumber *startTime = @(CACurrentMediaTime()*1000.0);
        [[self timingDict] setObject:startTime forKey:key];
    }
}

+ (BOOL)endTimingForKey:(id<NSCopying>)key serviceName:(NSString *)serviceName
{
    NSNumber *startTime = [self timingDict][key];
    if (!startTime) {
        return NO;
    }
    double endTime = CACurrentMediaTime()*1000.0;
    
    [[self timingDict] removeObjectForKey:key];
    NSTimeInterval timeInterval = endTime - [startTime doubleValue];
    [[TTMonitor shareManager] trackService:serviceName value:@(timeInterval) extra:nil];
    return YES;
}

+ (void)cancelTimingForKey:(nonnull id<NSCopying>)key
{
    if (key) {
       [[self timingDict] removeObjectForKey:key];
    }
}

+ (NSTimeInterval)timeIntervalForKey:(nonnull id<NSCopying>)key
{
    NSNumber *startTime = [self timingDict][key];
    if (!startTime) {
        return 0;
    }
    double endTime = CACurrentMediaTime()*1000.0;
    NSTimeInterval timeInterval = endTime - [startTime doubleValue];
    return timeInterval;
}

#pragma mark - Private Methods

+ (NSMutableDictionary *)timingDict
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timingDict = [NSMutableDictionary dictionary];
    });
    return timingDict;
}

@end
