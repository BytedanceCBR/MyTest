//
//  FHInterception.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/24.
//

#import "FHInterception.h"
#import "HMDTTMonitor.h"

#define InterceptionManagerContinue @"interception_manager_continue"
#define InterceptionManagerComplete @"interception_manager_complete"

@interface FHInterception ()

@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , copy) Condition condition;
@property(nonatomic , copy) Complete complete;
@property(nonatomic , copy) Operation operation;
@property(nonatomic , copy) Task task;
@property(nonatomic , assign) CGFloat interceptTime;
@property(nonatomic , assign) BOOL success;
@property(nonatomic , strong) FHInterceptionConfig *config;
@property(nonatomic , assign) BOOL isRunning;

@end

@implementation FHInterception

- (instancetype)init {
    self = [super init];
    if (self) {
        self.interceptTime = 0;
        self.success = YES;
        self.isRunning = NO;
        self.config = [[FHInterceptionConfig alloc] init];
    }
    return self;
}

- (TTHttpTask *)addParamInterceptionWithConfig:(FHInterceptionConfig *)config
                                     Condition:(Condition)condition
                                     operation:(Operation)operation
                                      complete:(Complete)complete
                                          task:(Task)task {
    if(config){
        self.config = config;
    }
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
        self.isRunning = NO;
        return task();
    }else{
        //参数有问题
        self.isRunning = YES;
        
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

- (void)cancel {
    if(self.isRunning){
        [self stopTimer];
        self.isRunning = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.complete(self.success,nil);
        });
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
        _timer = [NSTimer timerWithTimeInterval:self.config.compareTime target:self selector:@selector(compareParamCondition) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)compareParamCondition {
    self.interceptTime = self.interceptTime + self.config.compareTime;
    if(self.interceptTime > self.config.maxInterceptTime){
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
            if(self.config.isContinue){
                httpTask = self.task();
            }
            //上报错误参数日志
            [[HMDTTMonitor defaultManager] hmdTrackService:InterceptionManagerContinue metric:nil category:self.config.category extra:@{
            }];
        }
        self.isRunning = NO;
        self.complete(self.success,httpTask);
        
        //每次结束的时候上报结果
        NSMutableDictionary *reportDic = [NSMutableDictionary dictionary];
        if(self.config.category.count > 0){
            [reportDic addEntriesFromDictionary:self.config.category];
        }
        reportDic[@"check_gap"] = @(self.config.compareTime);
        reportDic[@"time_out"] = @(self.config.maxInterceptTime);
        reportDic[@"intercept_time"] = @(self.interceptTime);
        reportDic[@"success"] = @(self.success);
        [[HMDTTMonitor defaultManager] hmdTrackService:InterceptionManagerComplete metric:nil category:reportDic extra:@{
        }];
    });
}

@end
