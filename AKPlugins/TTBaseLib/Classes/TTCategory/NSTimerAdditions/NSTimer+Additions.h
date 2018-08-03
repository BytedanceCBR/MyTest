//
//  NSTimer+Additions.h
//  TTLive
//
//  Created by xuzichao on 16/3/31.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Additions)

/**
 *  NSTimer提供闭包方法
 *
 *  @param interval interval
 *  @param block block
 *  @param repeats repeats
 *
 *  @return NSTimer
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(void(^)())block
                                    repeats:(BOOL)repeats;

@end

@interface NSTimer (TTPauseable)

- (void)tt_pause;
- (void)tt_resume;

@end
