//
//  NSTimer+TTNoRetainRef.m
//  TTAccountLogin
//
//  Created by liuzuopeng on 09/06/2017.
//  Copyright © 2017 Nice2Me. All rights reserved.
//

#import "NSTimer+TTNoRetainRef.h"
#import <objc/runtime.h>



typedef void (^TTNoRetainRefNSTimerFiredBlock)(NSTimer *timer);

#pragma mark - TTNSTimerHoldObject

@interface TTNSTimerHoldObject : NSObject

@property (nonatomic, assign) BOOL repeated;

@property (nonatomic, assign) SEL selector;
@property (nonatomic,   weak) id target;

@property (nonatomic,   copy) TTNoRetainRefNSTimerFiredBlock block;

@end

@implementation TTNSTimerHoldObject

- (instancetype)init
{
    if ((self = [super init])) {
        _repeated = NO;
    }
    return self;
}

@end



#pragma mark - NSTimer (TTNoRetainRef)

@implementation NSTimer (TTNoRetainRef)

- (void)_setNSTimerHoldObject:(TTNSTimerHoldObject *)timerHoldObject
{
    objc_setAssociatedObject(self, @selector(_NSTimerHoldObject), timerHoldObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTNSTimerHoldObject *)_NSTimerHoldObject
{
    return objc_getAssociatedObject(self, _cmd);
}

+ (instancetype)ttNRF_timerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)yesOrNo
{
    TTNoRetainRefNSTimer *unRefTimer = [TTNoRetainRefNSTimer new];
    
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.target = aTarget;
    timerHoldObject.selector = aSelector;
    timerHoldObject.repeated = yesOrNo;
    
    id timer = [self.class timerWithTimeInterval:ti
                                          target:self
                                        selector:@selector(fireTimer:)
                                        userInfo:userInfo
                                         repeats:yesOrNo];
    
    if ([timer respondsToSelector:@selector(_setNSTimerHoldObject:)]) {
        [timer _setNSTimerHoldObject:timerHoldObject];
    }
    
    return timer;
}

+ (instancetype)ttNRF_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                              target:(id)aTarget
                                            selector:(SEL)aSelector
                                            userInfo:(nullable id)userInfo
                                             repeats:(BOOL)yesOrNo
{
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.target = aTarget;
    timerHoldObject.selector = aSelector;
    timerHoldObject.repeated = yesOrNo;
    
    id timer = [self.class scheduledTimerWithTimeInterval:ti
                                                   target:self
                                                 selector:@selector(fireTimer:)
                                                 userInfo:userInfo
                                                  repeats:yesOrNo];
    
    if ([timer respondsToSelector:@selector(_setNSTimerHoldObject:)]) {
        [timer _setNSTimerHoldObject:timerHoldObject];
    }
    
    return timer;
    
}

+ (instancetype)ttNRF_timerWithTimeInterval:(NSTimeInterval)ti
                                    repeats:(BOOL)yesOrNo
                                      block:(void (^)(NSTimer *timer))block
{
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.block = [block copy];
    timerHoldObject.repeated = yesOrNo;
    
    id timer = [self.class timerWithTimeInterval:ti
                                          target:self
                                        selector:@selector(fireTimer:)
                                        userInfo:nil
                                         repeats:yesOrNo];
    
    if ([timer respondsToSelector:@selector(_setNSTimerHoldObject:)]) {
        [timer _setNSTimerHoldObject:timerHoldObject];
    }
    
    return timer;
}

+ (instancetype)ttNRF_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                             repeats:(BOOL)yesOrNo
                                               block:(void (^)(NSTimer *timer))block
{
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.block = [block copy];
    timerHoldObject.repeated = yesOrNo;
    
    id timer = [self.class scheduledTimerWithTimeInterval:ti
                                                   target:self
                                                 selector:@selector(fireTimer:)
                                                 userInfo:nil
                                                  repeats:yesOrNo];
    
    if ([timer respondsToSelector:@selector(_setNSTimerHoldObject:)]) {
        [timer _setNSTimerHoldObject:timerHoldObject];
    }
    
    return timer;
}

+ (void)fireTimer:(NSTimer *)timer
{
    TTNSTimerHoldObject *selfHoldObject = [timer _NSTimerHoldObject];
    if (selfHoldObject) {
        if (selfHoldObject.block) {
            selfHoldObject.block(timer);
        } else if (selfHoldObject.target && selfHoldObject.selector) {
            NSMethodSignature *mSignature = [selfHoldObject.target methodSignatureForSelector:selfHoldObject.selector];
            if (!mSignature) {
                NSLog(@"Class: %@, SEL: %@, call failure (target doesn't own selector)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                return;
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([mSignature numberOfArguments] == 3) {
                [selfHoldObject.target performSelector:selfHoldObject.selector withObject:timer];
            } else {
                [selfHoldObject.target performSelector:selfHoldObject.selector];
            }
#pragma clang diagnostic pop
        }
    }
}

- (void)setTt_countdownTime:(NSTimeInterval)tt_countdownTime
{
    objc_setAssociatedObject(self, @selector(tt_countdownTime), @(tt_countdownTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)tt_countdownTime
{
    NSNumber *timeNumber = objc_getAssociatedObject(self, _cmd);
    if ([timeNumber respondsToSelector:@selector(doubleValue)]) {
        return [timeNumber doubleValue];
    } else if ([timeNumber respondsToSelector:@selector(floatValue)]) {
        return [timeNumber floatValue];
    }
    return 0;
}

@end



#pragma mark - TTNoRetainRefNSTimer

@interface TTNoRetainRefNSTimer ()

@property (nonatomic, strong) TTNSTimerHoldObject *timerHoldObject;

@end

@implementation TTNoRetainRefNSTimer

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                            target:(id)aTarget
                          selector:(SEL)aSelector
                          userInfo:(id)userInfo
                           repeats:(BOOL)yesOrNo
{
    TTNoRetainRefNSTimer *unRefTimer = [TTNoRetainRefNSTimer new];
    
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.target = aTarget;
    timerHoldObject.selector = aSelector;
    timerHoldObject.repeated = yesOrNo;
    
    unRefTimer.timerHoldObject = timerHoldObject;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:unRefTimer
                                           selector:@selector(fireTimer:)
                                           userInfo:userInfo
                                            repeats:yesOrNo];
    
    unRefTimer.timer = timer;
    
    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)yesOrNo
{
    TTNoRetainRefNSTimer *unRefTimer = [TTNoRetainRefNSTimer new];
    
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.target = aTarget;
    timerHoldObject.selector = aSelector;
    timerHoldObject.repeated = yesOrNo;
    
    unRefTimer.timerHoldObject = timerHoldObject;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                      target:unRefTimer
                                                    selector:@selector(fireTimer:)
                                                    userInfo:userInfo
                                                     repeats:yesOrNo];
    
    unRefTimer.timer = timer;
    
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                           repeats:(BOOL)yesOrNo
                             block:(void (^)(NSTimer *timer))block
{
    TTNoRetainRefNSTimer *unRefTimer = [TTNoRetainRefNSTimer new];
    
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.block = [block copy];
    timerHoldObject.repeated = yesOrNo;
    
    unRefTimer.timerHoldObject = timerHoldObject;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:unRefTimer
                                           selector:@selector(fireTimer:)
                                           userInfo:nil
                                            repeats:yesOrNo];
    
    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                    repeats:(BOOL)yesOrNo
                                      block:(void (^)(NSTimer *timer))block
{
    TTNoRetainRefNSTimer *unRefTimer = [TTNoRetainRefNSTimer new];
    
    TTNSTimerHoldObject *timerHoldObject = [TTNSTimerHoldObject new];
    timerHoldObject.block = [block copy];
    timerHoldObject.repeated = yesOrNo;
    
    unRefTimer.timerHoldObject = timerHoldObject;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                      target:unRefTimer
                                                    selector:@selector(fireTimer:)
                                                    userInfo:nil
                                                     repeats:yesOrNo];
    
    return timer;
}

- (void)fireTimer:(NSTimer *)timer
{
    if (timer != _timer) {
        return;
    }
    
    if (self.timerHoldObject.block) {
        self.timerHoldObject.block(timer);
    } else if (self.timerHoldObject.target && self.timerHoldObject.selector) {
        NSMethodSignature *mSignature = [self.timerHoldObject.target methodSignatureForSelector:self.timerHoldObject.selector];
        if (!mSignature) {
            NSLog(@"Class: %@, SEL: %@, call failure (target doesn't own selector)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            return;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([mSignature numberOfArguments] == 3) {
            [self.timerHoldObject.target performSelector:self.timerHoldObject.selector withObject:timer];
        } else {
            [self.timerHoldObject.target performSelector:self.timerHoldObject.selector];
        }
#pragma clang diagnostic pop
    }
}

@end
