//
//  TTForumPostThreadTaskCenter.m
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import "TTForumPostThreadTaskCenter.h"
#import "TTPostVideoCacheHelper.h"
#import "TTBaseMacro.h"

@interface TTForumPostThreadTaskCenter ()

@property (nonatomic, strong) NSMapTable *taskMapTable;

@end

@implementation TTForumPostThreadTaskCenter

+ (instancetype)sharedInstance {
    static TTForumPostThreadTaskCenter *sharedInstance = nil;
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

- (void)asyncGetTaskWithID:(NSString *)taskID concernID:(NSString *)concernID completionBlock:(void(^)(TTForumPostThreadTask *task))completionBlock {
    if (isEmptyString(taskID) || isEmptyString(concernID)) {
        return;
    }
    id obj = [self.taskMapTable objectForKey:taskID];
    if (obj && [obj isKindOfClass:[TTForumPostThreadTask class]]) {
        TTForumPostThreadTask *task = (TTForumPostThreadTask *)obj;
        if ([task.concernID isEqualToString:concernID]) {
            if (completionBlock) {
                completionBlock(task);
            }
            return;
        }
    }
    [TTForumPostThreadTask fetchTaskFromDiskByTaskID:taskID concernID:concernID completion:^(TTForumPostThreadTask * _Nonnull fetchedTask) {
        [self.taskMapTable setObject:fetchedTask forKey:taskID];
        if (completionBlock) {
            completionBlock(fetchedTask);
        }
    }];
}

- (void)asyncSaveTask:(TTForumPostThreadTask *)task {
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
    if (obj && [obj isKindOfClass:[TTForumPostThreadTask class]]) {
        TTForumPostThreadTask *task = (TTForumPostThreadTask *)obj;
        if ([task.concernID isEqualToString:cid]) {
            [self.taskMapTable removeObjectForKey:taskID];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTForumPostThreadTask removeTaskFromDiskByTaskID:taskID concernID:cid];
    });
}

@end
