//
//  TTConcurrentOperation.m
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTConcurrentOperation.h"

@implementation TTConcurrentOperation

- (BOOL)isReady {
    BOOL isReady = YES;
    if (SSIsEmptyArray(self.dependencies)) {
        isReady = self.state == ConcurrentOperationReadyState;
    } else {
        for (NSOperation *operation in self.dependencies) {
            if (!operation.isFinished) {
                isReady = NO;
                break;
            }
        }
    }
    return isReady;
}
- (BOOL)isExecuting{
    return self.state == ConcurrentOperationExecutingState;
}
- (BOOL)isFinished{
    return self.state == ConcurrentOperationFinishedState;
}

- (instancetype)init {
    if (self = [super init]) {
        self.state = ConcurrentOperationReadyState;
    }
    return self;
}

- (void)start {
    if ([self isCancelled]){
        [self willChangeValueForKey:@"isFinished"];
        self.state = ConcurrentOperationFinishedState;
        [self didChangeValueForKey:@"isFinished"];
        return;
    } else {
        [self willChangeValueForKey:@"isExecuting"];
        self.state = ConcurrentOperationExecutingState;
        [self asyncOperation];
        [self didChangeValueForKey:@"isExecuting"];
        
    }
}

- (void)asyncOperation {
}

- (void)didFinishCurrentOperation {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = nil;
    }
    self.state = ConcurrentOperationFinishedState;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

@end
