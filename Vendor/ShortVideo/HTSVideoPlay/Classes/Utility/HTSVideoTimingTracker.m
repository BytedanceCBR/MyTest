//
//  HTSVideoTimingTracker.m
//  LiveStreaming
//
//  Created by SongLi.02 on 27/10/2016.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import "HTSVideoTimingTracker.h"
#import <UIKit/UIKit.h>

@interface HTSVideoTimingTracker ()
@property (nonatomic, strong) NSMutableDictionary<id, NSDate *> *timingDict;
@property (nonatomic, strong) NSMutableSet *ignoreBackgroundSet;
@property (nonatomic, strong) NSMutableDictionary<id, NSNumber *> *pausedDict;
@property (nonatomic, strong) NSMutableDictionary<id, NSDictionary *> *paramsDict;
@property (nonatomic, strong) NSMutableArray *observerArray;
@end

@implementation HTSVideoTimingTracker

- (BOOL)hasTimingForKey:(id<NSCopying>)key
{
    if (!key) {
        return NO;
    }
    return (self.timingDict[key] != nil) || (self.pausedDict[key] != nil);
}

- (BOOL)startTimingForKey:(id<NSCopying>)key ignoreBackgroundTime:(BOOL)ignore
{
    if (!key) {
        return NO;
    }
#ifdef TEST_MODE
    NSLog(@"%s %@", __func__, key);
#endif
    [self.timingDict setObject:[NSDate date] forKey:key];
    if (ignore) {
        [self.ignoreBackgroundSet addObject:key];
    }
    return YES;
}

- (BOOL)startTimingForKey:(id<NSCopying>)key ignoreBackgroundTime:(BOOL)ignore params:(NSDictionary *)params
{
    BOOL succeed = [self startTimingForKey:key ignoreBackgroundTime:ignore];
    if (succeed) {
        self.paramsDict[key] = params;
    }
    return succeed;
}

- (NSTimeInterval)pauseTimingForKey:(id<NSCopying>)key
{
    if (!key) {
        return NSNotFound;
    }
    NSDate *date = self.timingDict[key];
    if (!date) {
        return NSNotFound;
    }
    [self.timingDict removeObjectForKey:key];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date] * 1000; // 毫秒
    [self.pausedDict setObject:@(timeInterval) forKey:key];
#ifdef TEST_MODE
    NSLog(@"%s %@:%lf", __func__, key, timeInterval);
#endif
    return timeInterval;
}

- (BOOL)resumeTimingForKey:(id<NSCopying>)key
{
    if (!key) {
        return NO;
    }
#ifdef TEST_MODE
    NSLog(@"%s %@", __func__, key);
#endif
    NSTimeInterval timeInterval = [self.pausedDict[key] doubleValue] / 1000; // 秒
    if (timeInterval <= 0) {
        return NO;
    }
    [self.pausedDict removeObjectForKey:key];
    [self.timingDict setObject:[NSDate dateWithTimeIntervalSinceNow:-timeInterval] forKey:key];
    return YES;
}

- (NSTimeInterval)endTimingForKey:(id<NSCopying>)key
{
    if (!key) {
        return NSNotFound;
    }
    NSDate *date = self.timingDict[key];
    if (date) {
        [self.timingDict removeObjectForKey:key];
        [self.paramsDict removeObjectForKey:key];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date] * 1000; // 毫秒
#ifdef TEST_MODE
        NSLog(@"%s %@:%lf", __func__, key, timeInterval);
#endif
        return timeInterval;
    } else if (self.pausedDict[key]) {
        NSTimeInterval timeInterval = [self.pausedDict[key] doubleValue]; // 毫秒
        [self.pausedDict removeObjectForKey:key];
        [self.paramsDict removeObjectForKey:key];
#ifdef TEST_MODE
        NSLog(@"%s %@:%lf", __func__, key, timeInterval);
#endif
        return timeInterval;
    } else {
        [self.paramsDict removeObjectForKey:key];
#ifdef TEST_MODE
        NSLog(@"%s %@:NotFound", __func__, key);
#endif
        return NSNotFound;
    }
}

- (void)cancelTimingForKey:(id<NSCopying>)key
{
    if (!key) {
        return;
    }
    [self.timingDict removeObjectForKey:key];
    [self.pausedDict removeObjectForKey:key];
    [self.paramsDict removeObjectForKey:key];
}

- (void)pauseAllTiming
{
    [self.timingDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDate * _Nonnull obj, BOOL * _Nonnull stop) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:obj] * 1000; // 毫秒
        [self.pausedDict setObject:@(timeInterval) forKey:key];
    }];
    [self.timingDict removeAllObjects];
}

- (void)resumeAllTiming
{
    [self.pausedDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.timingDict setObject:[NSDate dateWithTimeIntervalSinceNow:-[obj doubleValue] / 1000] forKey:key];
    }];
    [self.pausedDict removeAllObjects];
}

- (NSDictionary<id<NSCopying>, NSNumber *> *)endAllTiming
{
    NSMutableDictionary<id<NSCopying>, NSNumber *> *dict = [NSMutableDictionary dictionary];
    [self.timingDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDate * _Nonnull obj, BOOL * _Nonnull stop) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:obj] * 1000; // 毫秒
        [dict setObject:@(timeInterval) forKey:key];
    }];
    [self.timingDict removeAllObjects];
    [dict addEntriesFromDictionary:self.pausedDict]; // 毫秒
    [self.pausedDict removeAllObjects];
    [self.paramsDict removeAllObjects];
#ifdef TEST_MODE
    NSLog(@"%s %@", __func__, dict);
#endif
    return dict.copy;
}

- (NSDictionary *)paramsForKey:(id<NSCopying>)key
{
    if (!key) {
        return nil;
    }
    return self.paramsDict[key];
}

- (NSDictionary<id<NSCopying>, NSDictionary *> *)allParams
{
    return self.paramsDict.copy;
}


#pragma mark - Private Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timingDict = [NSMutableDictionary dictionary];
        _pausedDict = [NSMutableDictionary dictionary];
        _observerArray = [NSMutableArray array];
        _ignoreBackgroundSet = [NSMutableSet set];
        _paramsDict = [NSMutableDictionary dictionary];
        
        __weak typeof(self) weakSelf = self;
        [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.ignoreBackgroundSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                [strongSelf pauseTimingForKey:obj];
            }];
        }]];
        [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.ignoreBackgroundSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                [strongSelf resumeTimingForKey:obj];
            }];
        }]];
    }
    return self;
}

- (void)dealloc
{
    for (id observer in self.observerArray) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

@end
