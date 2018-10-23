//
//  TTVideoUploadManager.m
//  Article
//
//  Created by 徐霜晴 on 16/10/14.
//
//

#import "TTVideoUploadManager.h"
#import "TTVideoUploadOperation.h"

static const NSInteger kDefaultConcurrentOperationCount = 1;

@interface TTVideoUploadManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation TTVideoUploadManager

- (instancetype)init {
    return [self initWithMaxConcurrentOperationCount:kDefaultConcurrentOperationCount];
}

- (instancetype)initWithMaxConcurrentOperationCount:(NSInteger)count {
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:count];
    }
    return self;
}

- (NSArray<TTVideoUploadOperation *> *)videoUploadOperations {
    return [[self.operationQueue operations] copy];
}

- (void)addVideoUploadOperation:(TTVideoUploadOperation *)videoUploadOperation {
    
    if (isEmptyString(videoUploadOperation.taskID)) {
        LOGW(@"videoUploadOperation添加失败 添加的videoUploadOperation无有效taskID");
        return;
    }
    
    __block BOOL hasSameUploadOperation = NO;
    [[self.operationQueue operations] enumerateObjectsUsingBlock:^(TTVideoUploadOperation * _Nonnull operation, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([operation.taskID isEqualToString:videoUploadOperation.taskID]) {
            hasSameUploadOperation = YES;
            *stop = YES;
        }
    }];
    
    if (!hasSameUploadOperation) {
        [self.operationQueue addOperation:videoUploadOperation];
    }
    else {
        LOGW(@"videoUploadOperation添加失败 队列中已有同样taskID的videoUploadOperation");
    }
}

- (void)cancelVideoUploadOperationForTaskID:(NSString *)taskID {
    [[self.operationQueue operations] enumerateObjectsUsingBlock:^(TTVideoUploadOperation * _Nonnull operation, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([operation.taskID isEqualToString:taskID]) {
            [operation cancel];
        }
    }];
}

- (void)cancelAllOperations {
    [self.operationQueue cancelAllOperations];
}

@end
