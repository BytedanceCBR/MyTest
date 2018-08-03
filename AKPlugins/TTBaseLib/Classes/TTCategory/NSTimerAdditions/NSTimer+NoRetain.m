//
//  NSTimer+NoRetain.m
//  Article
//
//  Created by 王霖 on 16/10/9.
//
//

#import "NSTimer+NoRetain.h"

@interface _TTTimerTarget : NSObject
@property (nonatomic, weak) id wTarget;
@end

@implementation _TTTimerTarget

- (instancetype)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        self.wTarget = target;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.wTarget;
}

@end

@implementation NSTimer (NoRetain)

+ (NSTimer *)scheduledNoRetainTimerWithTimeInterval:(NSTimeInterval)ti
                                             target:(id)aTarget
                                           selector:(SEL)aSelector
                                           userInfo:(id)userInfo
                                            repeats:(BOOL)yesOrNo
{
    _TTTimerTarget * timerTarget = [[_TTTimerTarget alloc] initWithTarget:aTarget];
    return [self scheduledTimerWithTimeInterval:ti target:timerTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (instancetype)tt_timerWithTimeInterval:(NSTimeInterval)ti
                                 repeats:(BOOL)yesOrNo
                                   block:(void (^)(NSTimer *timer))block
{
    NSParameterAssert(block != nil);
    return [self.class timerWithTimeInterval:ti
                                      target:self
                                    selector:@selector(tt_blockInvoke:)
                                    userInfo:[block copy]
                                     repeats:yesOrNo];
}

+ (NSTimer *)tt_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                       repeats:(BOOL)yesOrNo
                                         block:(void (^)(NSTimer *timer))block
{
    NSParameterAssert(block != nil);
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(tt_blockInvoke:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)tt_blockInvoke:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    
    if (block) {
        block(timer);
    }
}

@end
