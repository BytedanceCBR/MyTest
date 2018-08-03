//
//  NSTimer+NoRetain.h
//  Article
//
//  Created by 王霖 on 16/10/9.
//
//

#import <Foundation/Foundation.h>

@interface NSTimer (NoRetain)

+ (NSTimer *)scheduledNoRetainTimerWithTimeInterval:(NSTimeInterval)ti
                                             target:(id)aTarget
                                           selector:(SEL)aSelector
                                           userInfo:(id)userInfo
                                            repeats:(BOOL)yesOrNo;

+ (instancetype)tt_timerWithTimeInterval:(NSTimeInterval)ti
                                 repeats:(BOOL)yesOrNo
                                   block:(void (^)(NSTimer *timer))block;

+ (NSTimer *)tt_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                 repeats:(BOOL)yesOrNo
                                   block:(void (^)(NSTimer *timer))block;

@end
