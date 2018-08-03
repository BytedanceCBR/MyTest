//
//  TTAccountSessionTask.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/9/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import <TTHttpTask.h>
#import "TTAccountSessionTask.h"
#import "TTAccountSessionTaskProtocol.h"



@interface TTAccountSessionTask ()

@property (nonatomic, strong) TTHttpTask *task;

@end

@implementation TTAccountSessionTask

- (instancetype)initWithSessionTask:(TTHttpTask *)task
{
    
    if ((self = [super init])) {
        //- On iOS 7, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `__NSCFURLSessionTask`.
        //- On iOS 8, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `NSURLSessionTask`.
        
        // NSAssert([task isKindOfClass:NSURLSessionTask.class], @"Must be NSURLSessionTask!");
        self.task = task;
    }
    return self;
}

- (void)cancel
{
    [self.task cancel];
}

- (void)suspend
{
    [self.task suspend];
}

- (void)resume
{
    [self.task resume];
}

- (void)setPriority:(float)priority
{
    // since ios 8
    if ([self.task respondsToSelector:@selector(setPriority:)]) {
        [self.task setPriority:priority];
    }
}

- (TTASessionTaskState)state
{
    TTASessionTaskState state = TTASessionTaskStateRunning;
    
    switch (self.task.state) {
        case TTHttpTaskStateSuspended:
            state = TTASessionTaskStateSuspended;
            break;
        case TTHttpTaskStateCanceling:
            state = TTASessionTaskStateCanceling;
            break;
        case TTHttpTaskStateCompleted:
            state = TTASessionTaskStateCompleted;
            
        default:
            break;
    }
    return state;
}

@end
