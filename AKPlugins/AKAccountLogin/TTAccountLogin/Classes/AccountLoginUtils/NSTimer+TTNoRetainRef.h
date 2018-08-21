//
//  NSTimer+TTNoRetainRef.h
//  TTAccountLogin
//
//  Created by liuzuopeng on 09/06/2017.
//  Copyright © 2017 Nice2Me. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

#pragma mark - NSTimer (TTNoRetainRef)

/**
 *  Usage:
 *
 *  @property (nonatomic, weak/strong) NSTimer *timer;
 *
 *  timer = [NSTimer ttNRF_timerWithTimeInterval:***
 *                                        target:self
 *                                      selector:***
 *                                          ******
 *                                                  ];
 *
 *  - (void)dealloc {
 *      [self.timer invalidate];
 *      self.timer = nil;
 *  }
 */
@interface NSTimer (TTNoRetainRef)

+ (instancetype)ttNRF_timerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)yesOrNo;

+ (instancetype)ttNRF_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                              target:(id)aTarget
                                            selector:(SEL)aSelector
                                            userInfo:(nullable id)userInfo
                                             repeats:(BOOL)yesOrNo;

+ (instancetype)ttNRF_timerWithTimeInterval:(NSTimeInterval)ti
                                    repeats:(BOOL)yesOrNo
                                      block:(void (^)(NSTimer *timer))block;

+ (instancetype)ttNRF_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                             repeats:(BOOL)yesOrNo
                                               block:(void (^)(NSTimer *timer))block;

/** 计时时可使用 */
@property (nonatomic, assign) NSTimeInterval tt_countdownTime;

@end



#pragma mark - TTNoRetainRefNSTimer

/**
 *  Usage:
 *
 *  @property (nonatomic, weak/strong) NSTimer *timer;
 *
 *  timer = [TTNoRetainRefNSTimer timerWithTimeInterval:***
 *                                               target:self
 *                                             selector:***
 *                                                  ******
 *                                                          ];
 *
 *  - (void)dealloc {
 *      [self.timer invalidate];
 *      self.timer = nil;
 *  }
 */

@interface TTNoRetainRefNSTimer : NSObject

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                            target:(id)aTarget
                          selector:(SEL)aSelector
                          userInfo:(nullable id)userInfo
                           repeats:(BOOL)yesOrNo;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)yesOrNo;

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                           repeats:(BOOL)yesOrNo
                             block:(void (^)(NSTimer *timer))block;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                    repeats:(BOOL)yesOrNo
                                      block:(void (^)(NSTimer *timer))block;


@property (nonatomic, weak) NSTimer *timer;

@end

NS_ASSUME_NONNULL_END
