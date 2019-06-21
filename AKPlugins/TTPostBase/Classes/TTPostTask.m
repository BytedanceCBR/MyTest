//
//  TTPostTask.m
//  Pods
//
//  Created by xushuangqing on 23/02/2018.
//

#import "TTPostTask.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAccount.h"
#import "TTAccountManager.h"

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

@interface TTPostTask()

@end

@implementation TTPostTask

#define kTTPostThreadTask @"TTPostThreadTask"

- (instancetype)initWithTaskType:(TTPostTaskType)taskType {
    self = [super init];
    if (self) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        int64_t intNow = (int64_t)(now * 1000);
        self.taskID = [NSString stringWithFormat:@"%@%lli", kTTPostThreadTask, intNow];
        self.fakeThreadId = intNow;
        self.taskType = taskType;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.taskType = [aDecoder decodeIntegerForKey:@"taskType"];
        self.taskID = [aDecoder decodeObjectForKey:@"taskID"];
        self.concernID = [aDecoder decodeObjectForKey:@"concernID"];
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
        self.fakeThreadId = [aDecoder decodeInt64ForKey:@"fakeThreadId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_taskType forKey:@"taskType"];
    [aCoder encodeObject:_taskID forKey:@"taskID"];
    [aCoder encodeObject:_concernID forKey:@"concernID"];
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeInt64:_fakeThreadId forKey:@"fakeThreadId"];
}

+ (NSString *)taskIDFromFakeThreadID:(int64_t)fakeThreadId {
    return [NSString stringWithFormat:@"%@%lli", kTTPostThreadTask, fakeThreadId];
}

- (BOOL)saveToDisk {
    return [[self class] persistentToDiskWithTask:self];
}

- (BOOL)removeFromDisk {
    return [[self class] removeTaskFromDiskByTaskID:self.taskID concernID:self.concernID];
}

+ (BOOL)persistentToDiskWithTask:(TTPostTask *)task {
    if (isEmptyString(task.taskID) || isEmptyString(task.concernID)) {
        return NO;
    }
    if (isEmptyString(task.userID)) {
        return NO;
    }
    @synchronized(self) {
        BOOL result = NO;
        @try {
            NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * dictionaryPath = [[docsPath stringByAppendingPathComponent:kTTPostThreadTask] stringByAppendingPathComponent:task.userID];
            BOOL isDirectory = NO;
            NSError * createDireError = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath isDirectory:&isDirectory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:&createDireError];
            }
            
            dictionaryPath = [dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", task.concernID]];
            isDirectory = NO;
            createDireError = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath isDirectory:&isDirectory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:&createDireError];
            }
            
            NSString *filename = [dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", task.taskID]];
            
            result = [NSKeyedArchiver archiveRootObject:task toFile:filename];
            
        }
        @catch (NSException *exception) {
            result = NO;
        }
        @finally {
            
        }
        return result;
    }
}

+ (void)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid completion:(void(^)(TTPostTask *task))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTPostTask *task = [self fetchTaskFromDiskByTaskID:taskID concernID:cid];
#if DEBUG
        //task.debug_currentMethod = [TTUGCBacktraceLogger ttugc_backtraceOfCurrentThread];
#endif
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(task);
            });
        }
    });
}

+ (TTPostTask *)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid {
    if (isEmptyString(taskID) || isEmptyString(cid)) {
        return nil;
    }
    
    NSString * userID = [[TTAccount sharedAccount] userIdString];
    
    if (isEmptyString(userID)) {
        return nil;
    }
    @synchronized(self) {
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [[[docsPath stringByAppendingPathComponent:kTTPostThreadTask] stringByAppendingPathComponent:userID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", cid]];
        NSString *filename = [dictionaryPath stringByAppendingPathComponent:taskID];
        id cached = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if (cached && [cached isKindOfClass:[self class]]) {
#if DEBUG || INHOUSE
            //((TTPostThreadTask *)cached).debug_currentMethod = @"";
#endif
            return cached;
        }
        return nil;
    }
}

+ (NSArray <TTPostTask *> *)fetchTasksFromDiskForConcernID:(NSString *)concernID {
    if (isEmptyString(concernID)) {
        return nil;
    }
    
    NSString * userID = [[TTAccount sharedAccount] userIdString];
    
    if (isEmptyString(userID)) {
        return nil;
    }
    @synchronized (self) {
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [[[docsPath stringByAppendingPathComponent:kTTPostThreadTask] stringByAppendingPathComponent:userID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", concernID]];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:dictionaryPath isDirectory:nil]) {
            return nil;
        }
        NSDirectoryEnumerator* en = [fm enumeratorAtPath:dictionaryPath];
        NSString* file = nil;
        NSMutableArray <TTPostTask *> *tasks = [[NSMutableArray alloc] init];
        while (file = [en nextObject]) {
            NSString *filename = [dictionaryPath stringByAppendingPathComponent:file];
            id cached = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
            if (cached && [cached isKindOfClass:[self class]]) {
#if DEBUG || INHOUSE
                //((TTPostThreadTask *)cached).debug_currentMethod = @"";
#endif
                [tasks addObject:cached];
            }
        }
        return tasks;
    }
}

+ (BOOL)removeTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid {
    if (isEmptyString(taskID) || isEmptyString(cid)) {
        return NO;
    }
    
    NSString * userID = [[TTAccount sharedAccount] userIdString];
    
    if (isEmptyString(userID)) {
        return nil;
    }
    @synchronized(self) {
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [[[docsPath stringByAppendingPathComponent:kTTPostThreadTask] stringByAppendingPathComponent:userID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", cid]];
        NSString *filename = [dictionaryPath stringByAppendingPathComponent:taskID];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:nil]) {
            return [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
        }
        return NO;
    }
}

+ (void)removeAllDiskTask {
    @synchronized(self) {
        @try {
            NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kTTPostThreadTask];
            NSFileManager* fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:dictionaryPath isDirectory:nil]) {
                return;
            }
            NSDirectoryEnumerator* en = [fm enumeratorAtPath:dictionaryPath];
            NSError* err = nil;
            BOOL res;
            
            NSString* file;
            while (file = [en nextObject]) {
                res = [fm removeItemAtPath:[dictionaryPath stringByAppendingPathComponent:file] error:&err];
                if (!res && err) {
                    NSLog(@"oops: %@", err);
                }
            }
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}

@end

@implementation TTPostTask(UI)

- (NSString *)title {
    return nil;
}

- (NSString *)titleRichSpan {
    return nil;
}

- (NSString *)content {
    return nil;
}

- (NSString *)contentRichSpans {
    return nil;
}

- (TTPostTaskStatus)status {
    return 0;
}

- (BOOL)isPosting {
    return NO;
}

- (void)setIsPosting:(BOOL)isPosting {
    
}

- (CGFloat)uploadProgress {
    return 0;
}

- (NSDictionary *)extraTrack {
    return nil;
}

- (UIImage *)coverImage {
    return nil;
}

- (NSError *)finishError {
    return nil;
}

- (void)setFinishError:(NSError *)finishError {
    
}

- (NSInteger)repostType {
    return 0;
}

- (BOOL)shouldShowRedPacket {
    return NO;
}

@end
