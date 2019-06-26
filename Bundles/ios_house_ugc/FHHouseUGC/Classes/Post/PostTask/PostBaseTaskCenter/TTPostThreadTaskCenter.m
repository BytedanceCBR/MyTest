//
//  TTPostThreadTaskCenter.m
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import "TTPostThreadTaskCenter.h"
#import "TTPostThreadTask.h"

#import <TTBaseLib/TTBaseMacro.h>

@interface TTPostThreadTaskCenter ()

@property (nonatomic, strong) NSMapTable *taskMapTable;

@end

@implementation TTPostThreadTaskCenter

+ (instancetype)sharedInstance {
    static TTPostThreadTaskCenter *sharedInstance = nil;
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

- (void)asyncGetTaskWithID:(NSString *)taskID concernID:(NSString *)concernID completionBlock:(void(^)(TTPostThreadTask *task))completionBlock {
    if (isEmptyString(taskID) || isEmptyString(concernID)) {
        return;
    }
    id obj = [self.taskMapTable objectForKey:taskID];
    if (obj && [obj isKindOfClass:[TTPostThreadTask class]]) {
        TTPostThreadTask *task = (TTPostThreadTask *)obj;
        if ([task.concernID isEqualToString:concernID]) {
            if (completionBlock) {
                completionBlock(task);
            }
            return;
        }
    }
    [TTPostThreadTask fetchTaskFromDiskByTaskID:taskID concernID:concernID completion:^(TTPostTask * _Nonnull fetchedTask) {
        [self.taskMapTable setObject:fetchedTask forKey:taskID];
        if (completionBlock) {
            completionBlock((TTPostThreadTask *)fetchedTask);
        }
    }];
}

- (void)asyncSaveTask:(TTPostThreadTask *)task {
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
    if (obj && [obj isKindOfClass:[TTPostThreadTask class]]) {
        TTPostThreadTask *task = (TTPostThreadTask *)obj;
        if ([task.concernID isEqualToString:cid]) {
            [self.taskMapTable removeObjectForKey:taskID];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTPostThreadTask removeTaskFromDiskByTaskID:taskID concernID:cid];
    });
}

@end
