//
//  TTCommonTimerObj.m
//  Article
//
//  Created by xuzichao on 16/1/18.
//
//

#import "TTCommonTimerObj.h"
#import "NSStringAdditions.h"

@interface TTCommonTimerObj()

@property (nonatomic,assign)  float preinstallTime;
@property (nonatomic,assign)  float maxTime;
@property (nonatomic,assign)  float minTime;
@property (nonatomic,assign)  float currentCountTime;
@property (nonatomic,assign)  float interval;

@end

@implementation TTCommonTimerObj

- (instancetype)init
{
    self = [super init];
    if (self) {
        //计时
        self.currentCountTime = 0;
        self.maxTime = 3600;
        self.minTime = 3;
        self.interval = 1;
    }
    
    return self;
}

- (void)dealloc
{
    [self clearTimer];
}

//设置一个预定值，触发一个事件
- (void)setPrepareTime:(float)time;
{
    if (time < self.maxTime && time > self.minTime) {
        self.preinstallTime = time;
    }
}

//最大计时
- (void)maxTime:(float)time
{
    if (time > 0 && time < self.maxTime) {
        self.maxTime = time;
    }
}

//最小计时
- (void)minTime:(float)time
{
    if (time > 0 && time < self.minTime) {
        self.minTime = time;
    }
}

//计时间隔
- (void)timerInterval:(float)interval
{
    if (interval > 0) {
        self.interval = interval;
    }
}


- (void)startTimer
{
    [self.timer invalidate];
    
    self.timer = [NSTimer timerWithTimeInterval:self.interval target:self selector:@selector(timerEachAction:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer  forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
    
    
}


- (void)clearTimer
{
    //计时停止的回调
    if (self.timer.valid) {
        
        if ([self.delegate respondsToSelector:@selector(ttTimer:StopLessThanMinTime:)]) {
            if (self.currentCountTime < self.minTime) {
                
                [self.delegate ttTimer:(TTCommonTimerObj *)self StopLessThanMinTime:YES];
            }
            else {
                
                [self.delegate ttTimer:(TTCommonTimerObj *)self StopLessThanMinTime:NO];
            }
        }
        
        //清理
        [self.timer invalidate];
        self.timer = nil;
        self.currentCountTime = 0;
    }
    
}

- (void)timerEachAction:(NSTimer *)timer
{
    self.currentCountTime = self.currentCountTime + self.interval;
    
    //达到预定值
    if (self.currentCountTime == self.preinstallTime) {
        if ([self.delegate respondsToSelector:@selector(ttTimer:preinstallTime:)]) {
            [self.delegate ttTimer:(TTCommonTimerObj *)self preinstallTime:self.preinstallTime];
        }
    }
    
    //达到最大时间回调
    if (self.currentCountTime > self.maxTime) {
        
        if ([self.delegate respondsToSelector:@selector(ttTimerReachMaxTimeStop:)]) {
            [self.delegate ttTimerReachMaxTimeStop:(TTCommonTimerObj *)self];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(ttTimer:EachIntervalAction:)]) {
            [self.delegate ttTimer:(TTCommonTimerObj *)self EachIntervalAction:self.currentCountTime];
        }
    }
    
}




@end
