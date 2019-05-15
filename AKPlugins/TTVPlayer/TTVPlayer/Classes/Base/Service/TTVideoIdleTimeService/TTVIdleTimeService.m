//
//  TTVIdleTimeService.m
//  Article
//
//  Created by liuty on 2017/3/2.
//
//

#import "TTVIdleTimeService.h"

#define kLockScreenTime 60 * 1

@implementation TTVIdleTimeService

#pragma mark -
#pragma mark public methods

+ (instancetype)sharedService {
    static dispatch_once_t onceToken;
    static TTVIdleTimeService *service = nil;
    dispatch_once(&onceToken, ^{
        service = [[TTVIdleTimeService alloc] init];
    });
    return service;
}

- (void)lockScreen:(BOOL)lock later:(BOOL)later {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_lock) object:nil];
    if (lock) {
        if (later) {
            [self performSelector:@selector(_lock) withObject:nil afterDelay:kLockScreenTime];
        } else {
            [self _lock];
        }
    } else {
        // 不允许自动锁屏
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)lockScreen:(BOOL)lock {
    [self lockScreen:lock later:NO];
}

#pragma mark -
#pragma mark private methods

- (void)_lock {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
