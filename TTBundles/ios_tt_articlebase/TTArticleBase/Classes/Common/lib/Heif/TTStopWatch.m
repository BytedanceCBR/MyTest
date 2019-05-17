//
//  TTStopWatch.m
//  Article
//
//  Created by fengyadong on 2017/11/16.
//

#import <mach/mach_time.h>
#import "TTStopWatch.h"
#import <pthread.h>

@implementation TTStopWatch

static pthread_mutex_t stopWatchMutex = PTHREAD_MUTEX_INITIALIZER;

+ (NSMutableDictionary *)watches {
    static NSMutableDictionary *Watches = nil;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{
        Watches = @{}.mutableCopy;
    });
    return Watches;
}

+ (double)microsecondsFromMachTime:(uint64_t)time {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / 1e6;
}

+ (void)start:(NSString *)name {
    uint64_t begin = mach_absolute_time();
    pthread_mutex_lock(&stopWatchMutex);
    self.watches[name] = @(begin);
    pthread_mutex_unlock(&stopWatchMutex);
}

+ (NSTimeInterval)stop:(NSString *)name {
    uint64_t end = mach_absolute_time();
    pthread_mutex_lock(&stopWatchMutex);
    uint64_t begin = [self.watches[name] unsignedLongLongValue];
    NSTimeInterval interval = [self microsecondsFromMachTime:end - begin];
#ifdef DEBUG
    NSLog(@"========================Time taken for %@ %g ms",
              name, interval);
#endif
    [self.watches removeObjectForKey:name];
    pthread_mutex_unlock(&stopWatchMutex);
    return interval;
}

@end
