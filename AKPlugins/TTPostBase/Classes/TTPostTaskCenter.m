//
//  TTPostThreadTaskCenter.m
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import "TTPostTaskCenter.h"

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

@interface TTPostTaskCenter ()

@property (nonatomic, strong) NSMapTable *taskMapTable;

@end

@implementation TTPostTaskCenter

+ (instancetype)sharedInstance {
    static TTPostTaskCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.taskMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return self;
}

- (void)asyncGetTaskWithID:(NSString *)taskID concernID:(NSString *)concernID completionBlock:(void(^)(TTPostTask *task))completionBlock {
    TTPostTask *resultTask = [self asyncGetMemoryTaskWithID:taskID concernID:concernID];
    if (resultTask) {
        if (completionBlock) {
            completionBlock(resultTask);
        }
    } else {
        [TTPostTask fetchTaskFromDiskByTaskID:taskID concernID:concernID completion:^(TTPostTask * _Nonnull fetchedTask) {
            [self.taskMapTable setObject:fetchedTask forKey:taskID];
            if (completionBlock) {
                completionBlock(fetchedTask);
            }
        }];
    }
}

- (TTPostTask *)asyncGetMemoryTaskWithID:(NSString *)taskID concernID:(NSString *)concernID {
    if (isEmptyString(taskID) || isEmptyString(concernID)) {
        return nil;
    }
    id obj = [self.taskMapTable objectForKey:taskID];
    if (obj && [obj isKindOfClass:[TTPostTask class]]) {
        TTPostTask *task = (TTPostTask *)obj;
        if ([task.concernID isEqualToString:concernID]) {
            
            return task;
        }
    }
    return nil;
}

- (void)asyncSaveTask:(TTPostTask *)task {
    if (!task) {
        return;
    }
    [self.taskMapTable setObject:task forKey:task.taskID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [task saveToDisk];
    });
}

- (void)asyncRemoveTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid {
    if (isEmptyString(taskID) || isEmptyString(cid)) {
        return;
    }
    id obj = [self.taskMapTable objectForKey:taskID];
    if (obj && [obj isKindOfClass:[TTPostTask class]]) {
        TTPostTask *task = (TTPostTask *)obj;
        if ([task.concernID isEqualToString:cid]) {
            [self.taskMapTable removeObjectForKey:taskID];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTPostTask removeTaskFromDiskByTaskID:taskID concernID:cid];
    });
}

@end
