//
//  TTVideoCallbackTaskGlobalQueue.m
//  Article
//
//  Created by xiangwu on 2017/2/22.
//
//

#import "TTVideoCallbackTaskGlobalQueue.h"

@implementation TTVideoCallbackTask

@end

@interface TTVideoCallbackTaskGlobalQueue ()

{
    dispatch_queue_t _executeQueue;
}

@property (nonatomic, strong) NSMutableArray *taskQueue;

@end

@implementation TTVideoCallbackTaskGlobalQueue

+ (TTVideoCallbackTaskGlobalQueue *)sharedInstance {
    static dispatch_once_t onceToken;
    static TTVideoCallbackTaskGlobalQueue *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTVideoCallbackTaskGlobalQueue alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskQueue = [NSMutableArray array];
        _executeQueue = dispatch_queue_create("video_callback_task_global_queue_execute_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)enQueueCallbackTask:(TTVideoCallbackTask *)task {
    dispatch_async(_executeQueue, ^{
        [_taskQueue addObject:task];
    });
}

- (TTVideoCallbackTask *)popQueueFromHead {
    TTVideoCallbackTask *task = [self headTask];
    dispatch_sync(_executeQueue, ^{
        if (_taskQueue.count) {
            [_taskQueue removeObjectAtIndex:0];
        }
    });
    return task;
}

- (TTVideoCallbackTask *)popQueueFromTail {
    TTVideoCallbackTask *task = [self tailTask];
    dispatch_sync(_executeQueue, ^{
        if (_taskQueue.count) {
            [_taskQueue removeLastObject];
        }
    });
    return task;
}

- (void)clearQueue {
    dispatch_async(_executeQueue, ^{
        [_taskQueue removeAllObjects];
    });
}

- (TTVideoCallbackTask *)headTask {
    __block TTVideoCallbackTask *task = nil;
    dispatch_sync(_executeQueue, ^{
        task = [_taskQueue firstObject];
    });
    return task;
}

- (TTVideoCallbackTask *)tailTask {
    __block TTVideoCallbackTask *task = nil;
    dispatch_sync(_executeQueue, ^{
        task = [_taskQueue lastObject];
    });
    return task;
}

@end
