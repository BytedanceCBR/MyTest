//
//  TTVPlayerIdleController.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerIdleController.h"
#import <UIKit/UIKit.h>

static const NSTimeInterval kLockScreenTime = 60;
static const NSTimeInterval kUnLockScreenTime = 1;

@implementation TTVPlayerIdleController

+ (TTVPlayerIdleController *)sharedInstance {
    static TTVPlayerIdleController *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTVPlayerIdleController alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActiveNotification)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)lockScreen:(BOOL)lock later:(BOOL)later {
    @synchronized (self) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(lock) object:nil];
        if (lock) {
            if (later) {
                [self performSelector:@selector(lock) withObject:nil afterDelay:kLockScreenTime inModes:@[NSRunLoopCommonModes]];
            } else {
                [self lock];
            }
        } else {
            if (later) {
                [self performSelector:@selector(unLock) withObject:nil afterDelay:kUnLockScreenTime inModes:@[NSRunLoopCommonModes]];
            } else {
                [self unLock];
            }
        }
    }
}

- (BOOL)isLock
{
    return [UIApplication sharedApplication].idleTimerDisabled == NO;
}

- (void)lock {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)unLock {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)willResignActiveNotification
{
    [self lock];
}
@end
