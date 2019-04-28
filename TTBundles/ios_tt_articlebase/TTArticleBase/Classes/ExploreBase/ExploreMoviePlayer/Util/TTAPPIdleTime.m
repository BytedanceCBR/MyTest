//
//  TTAPPIdleTime.m
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

#import "TTAPPIdleTime.h"

#define kLockScreenTime 60 * 1


@implementation TTAPPIdleTime

- (void)lockScreen:(BOOL)lock later:(BOOL)later
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(lock) object:nil];
    if (lock) {
        if (later) {
            [self performSelector:@selector(lock) withObject:nil afterDelay:kLockScreenTime];
        }
        else
            {
            [self lock];
            }
    }
    else
        {
        [UIApplication sharedApplication].idleTimerDisabled = YES;  // 不允许自动锁屏
        }
}

- (void)lockScreen:(BOOL)lock
{
    [self lockScreen:lock later:NO];
}

- (void)lock
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}
@end
