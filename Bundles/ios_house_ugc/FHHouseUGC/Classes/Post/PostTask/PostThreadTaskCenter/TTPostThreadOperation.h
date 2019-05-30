//
//  TTPostThreadOperation.h
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import <Foundation/Foundation.h>
#import "TTPostThreadTask.h"

typedef NS_ENUM(NSUInteger, TTPostThreadOperationState) {
    TTPostThreadOperationStateUnknown,
    TTPostThreadOperationStatePending,
    TTPostThreadOperationStateResumed,
    TTPostThreadOperationStateCancelled,
    TTPostThreadOperationStateFailed,
    TTPostThreadOperationStateSuccessed,
    TTPostThreadOperationStateRemoved,
};

typedef NS_ENUM(NSUInteger, TTPostThreadOperationCancelHint) {
    TTPostThreadOperationCancelHintUnknown = 0,
    TTPostThreadOperationCancelHintCancel = 1,
    TTPostThreadOperationCancelHintRemove = 2,
};

typedef void(^TTPostThreadOperationStateUpdatedBlock)(TTPostThreadTask *task, TTPostThreadOperationState lastState, TTPostThreadOperationState currentState);
typedef void(^TTPostThreadOperationSuccessBlock)(TTPostThreadTask *task, NSDictionary *resultModelDict);
typedef void(^TTPostThreadOperationCancelledBlock)(TTPostThreadTask *task, TTPostThreadOperationCancelHint cancelHint);
typedef void(^TTPostThreadOperationFailureBlock)(TTPostThreadTask *task, NSError *error);


@interface TTPostThreadOperation : NSOperation

+ (TTPostThreadOperation *)operationWithPostThreadTaskID:(NSString *)taskID
                                                    concernID:(NSString *)concernID
                                                suggestedTask:(TTPostThreadTask *)suggestedTask
                                            stateUpdatedBlock:(TTPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                                                 successBlock:(TTPostThreadOperationSuccessBlock)successBlock
                                               cancelledBlock:(TTPostThreadOperationCancelledBlock)cancelledBlock
                                                 failureBlock:(TTPostThreadOperationFailureBlock)failureBlock;

@property (nonatomic, copy) NSString *taskID;
@property (nonatomic, copy) NSString *concernID;
@property (nonatomic, assign, readonly) BOOL cancellable;

- (instancetype)initWithPostThreadTaskID:(NSString *)taskID
                               concernID:(NSString *)concernID
                           suggestedTask:(TTPostThreadTask *)suggestedTask
                       stateUpdatedBlock:(TTPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                            successBlock:(TTPostThreadOperationSuccessBlock)successBlock
                          cancelledBlock:(TTPostThreadOperationCancelledBlock)cancelledBlock
                            failureBlock:(TTPostThreadOperationFailureBlock)failureBlock;

- (void)cancelWithHint:(TTPostThreadOperationCancelHint)cancelHint;

@end
