//
//  TTVPlayerInfoContext.m
//  TTVPlayer
//
//  Created by lisa on 2018/12/15.
//

#import "TTVPlayerEnvironmentContext.h"

@implementation TTVPlayerEnvironmentContext

// 单例
+ (instancetype _Nonnull)sharedInstance {
    static dispatch_once_t onceToken;
    static TTVPlayerEnvironmentContext *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTVPlayerEnvironmentContext alloc] init];
    });
    return instance;
}

+ (void)reset {
    [TTVPlayerEnvironmentContext sharedInstance].host = nil;
    [TTVPlayerEnvironmentContext sharedInstance].commonParameters = nil;
}

@end
