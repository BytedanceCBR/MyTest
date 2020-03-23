//
//  FHInterceptionManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/20.
//

#import "FHInterceptionManager.h"
#import "HMDTTMonitor.h"

#define InterceptionManagerContinue @"InterceptionManagerContinue"

@interface FHInterceptionManager ()

@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , copy) Condition condition;
@property(nonatomic , copy) Complete complete;
@property(nonatomic , copy) Operation operation;
@property(nonatomic , copy) Task task;
@property(nonatomic , assign) CGFloat interceptTime;
@property(nonatomic , assign) BOOL success;

@end

@implementation FHInterceptionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isContinue = NO;
        self.maxInterceptTime = 5.0f;
        self.compareTime = 1.0f;
        self.interceptTime = 0;
        self.success = YES;
        self.category = @{};
    }
    return self;
}

- (TTHttpTask *)addParamInterceptionWithCondition:(Condition)condition operation:(Operation)operation complete:(Complete)complete task:(Task)task {
    self.condition = condition;
    self.complete = complete;
    self.operation = operation;
    self.task = task;
    
    BOOL paramCurrent = YES;
    if(self.condition){
        paramCurrent = self.condition();
    }
    
    if(paramCurrent){
        //参数没有问题
        return task();
    }else{
        //参数有问题
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //执行解决方案
            if(self.operation){
                self.operation();
            }
            
            self.interceptTime = 0;
            [self startTimer];
        });

        return nil;
    }
}

- (void)startTimer {
    if (_timer) {
        [self stopTimer];
    }
    [self.timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:self.compareTime target:self selector:@selector(compareParamCondition) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)compareParamCondition {
    self.interceptTime = self.interceptTime + self.compareTime;
    if(self.interceptTime > self.maxInterceptTime){
        //超时
        [self quitLoop];
        return;
    }
    
    if(self.condition){
        self.success = self.condition();
        if(self.success){
            [self quitLoop];
            return;
        }
    }else{
        [self quitLoop];
    }
}

- (void)quitLoop {
    [self stopTimer];
    __block TTHttpTask *httpTask = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.success){
            httpTask = self.task();
        }else{
            if(self.isContinue){
                httpTask = self.task();
            }
            //上报错误参数日志
            [[HMDTTMonitor defaultManager] hmdTrackService:InterceptionManagerContinue metric:nil category:self.category extra:@{
            }];
        }
        self.complete(self.success,httpTask);
    });
}

@end
