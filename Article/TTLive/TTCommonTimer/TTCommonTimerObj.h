//
//  TTCommonTimerObj.h
//  Article
//
//  Created by xuzichao on 16/1/18.
//
//

#import <UIKit/UIKit.h>

@class TTCommonTimerObj;

@protocol TTCommonTimerObjDelegate <NSObject>
@optional
//停止，并判定是否满足最小值
- (void)ttTimer:(TTCommonTimerObj *)timer StopLessThanMinTime:(BOOL)isLess;

//达到最大值
- (void)ttTimerReachMaxTimeStop:(TTCommonTimerObj *)timer;

//每次计时的对应动作
- (void)ttTimer:(TTCommonTimerObj *)timer EachIntervalAction:(float)currentCountTime;

//计时中间值触发状态
- (void)ttTimer:(TTCommonTimerObj *)timer preinstallTime:(float)countTime;

@end

@interface TTCommonTimerObj: NSObject

@property (nonatomic,strong)  NSTimer *timer;
@property (nonatomic,assign,readonly)  float maxTime;
@property (nonatomic,weak) id<TTCommonTimerObjDelegate> delegate;

//设置一个预定值，触发一个事件
- (void)setPrepareTime:(float)time;

//最大计时,单位为秒,默认3600
- (void)maxTime:(float)time;

//最小计时,单位为秒，默认3
- (void)minTime:(float)time;

//开始
- (void)startTimer;

//停止并清理
- (void)clearTimer;

//计时间隔,默认1秒
- (void)timerInterval:(float)interval;

@end
