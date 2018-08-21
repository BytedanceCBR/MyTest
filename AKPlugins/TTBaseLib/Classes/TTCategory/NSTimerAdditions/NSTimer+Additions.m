//
//  NSTimer+Additions.m
//  TTLive
//
//  Created by xuzichao on 16/3/31.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import "NSTimer+Additions.h"
@import ObjectiveC;

@implementation NSTimer (Additions)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(void(^)())block
                                    repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)blockInvoke:(NSTimer *)timer{
    void(^block)() = timer.userInfo;
    if (block) {
        block();
    }
}


@end

@implementation NSTimer (TTPauseable)

- (void)tt_pause {
    if (self.ttPausedDate || self.ttNextFireDate) {
        return;
    }
    
    self.ttPausedDate = [NSDate date];
    self.ttNextFireDate = [self fireDate];
    
    [self setFireDate:[NSDate distantFuture]];
}

- (void)tt_resume {
    if (!self.ttPausedDate || !self.ttNextFireDate) {
        return;
    }
    
    float pauseTime = -1 * [self.ttPausedDate timeIntervalSinceNow];
    [self setFireDate:[self.ttNextFireDate initWithTimeInterval:pauseTime sinceDate:self.ttNextFireDate]];
    
    self.ttPausedDate = nil;
    self.ttNextFireDate = nil;
}

- (NSDate *)ttPausedDate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTtPausedDate:(NSDate *)pausedDate {
    objc_setAssociatedObject(self, @selector(ttPausedDate), pausedDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)ttNextFireDate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTtNextFireDate:(NSDate *)nextFireDate {
    objc_setAssociatedObject(self, @selector(ttNextFireDate), nextFireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
