//
//  FHInterceptionManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/20.
//

#import "FHInterceptionManager.h"

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
        self.maxInterceptTime = 5;
        self.compareTime = 1;
        self.interceptTime = 0;
        self.success = YES;
    }
    return self;
}

- (TTHttpTask *)addParamInterception:(CGFloat)interval condition:(Condition)condition operation:(Operation)operation complete:(Complete)complete task:(Task)task {
    self.maxInterceptTime = interval;
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
            
            NSLog(@"______开始");
            sleep(5);
            NSLog(@"______结束");
            BOOL success = NO;
            
            __block TTHttpTask *httpTask = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.isContinue){
                    httpTask = task();
                }
                complete(success,httpTask);
            });
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
    self.interceptTime ++;
    
    BOOL success = NO;
    
    __block TTHttpTask *httpTask = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.isContinue){
            httpTask = self.task();
        }
        self.complete(success,httpTask);
    });
}

@end
