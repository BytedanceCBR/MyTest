//
//  TTForumPostThreadOperation.h
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import <Foundation/Foundation.h>
#import "TTForumPostThreadTask.h"

typedef NS_ENUM(NSUInteger, TTForumPostThreadOperationState) {
    TTForumPostThreadOperationStateUnknown,
    TTForumPostThreadOperationStatePending,
    TTForumPostThreadOperationStateResumed,
    TTForumPostThreadOperationStateCancelled,
    TTForumPostThreadOperationStateFailed,
    TTForumPostThreadOperationStateSuccessed,
    TTForumPostThreadOperationStateRemoved,
};

typedef NS_ENUM(NSUInteger, TTForumPostThreadOperationCancelHint) {
    TTForumPostThreadOperationCancelHintUnknown = 0,
    TTForumPostThreadOperationCancelHintCancel = 1,
    TTForumPostThreadOperationCancelHintRemove = 2,
};

typedef void(^TTForumPostThreadOperationStateUpdatedBlock)(TTForumPostThreadTask *task, TTForumPostThreadOperationState lastState, TTForumPostThreadOperationState currentState);
typedef void(^TTForumPostThreadOperationSuccessBlock)(TTForumPostThreadTask *task, NSDictionary *resultModelDict);
typedef void(^TTForumPostThreadOperationCancelledBlock)(TTForumPostThreadTask *task, TTForumPostThreadOperationCancelHint cancelHint);
typedef void(^TTForumPostThreadOperationFailureBlock)(TTForumPostThreadTask *task, NSError *error);


@protocol TTForumPostThreadOperationProtocol <NSObject>

@property (nonatomic, copy) NSString *taskID;
@property (nonatomic, copy) NSString *concernID;
@property (nonatomic, assign) TTForumPostThreadTaskType taskType;
@property (nonatomic, assign, readonly) BOOL cancellable;

- (instancetype)initWithPostThreadTaskID:(NSString *)taskID
                               concernID:(NSString *)concernID
                           suggestedTask:(TTForumPostThreadTask *)suggestedTask
                       stateUpdatedBlock:(TTForumPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                            successBlock:(TTForumPostThreadOperationSuccessBlock)successBlock
                          cancelledBlock:(TTForumPostThreadOperationCancelledBlock)cancelledBlock
                            failureBlock:(TTForumPostThreadOperationFailureBlock)failureBlock;

- (void)cancelWithHint:(TTForumPostThreadOperationCancelHint)cancelHint;

@end


@interface TTForumPostThreadOperation : NSOperation<TTForumPostThreadOperationProtocol>

+ (NSOperation<TTForumPostThreadOperationProtocol> *)operationWithPostThreadTaskID:(NSString *)taskID
                                                                         concernID:(NSString *)concernID
                                                                          taskType:(TTForumPostThreadTaskType)taskType
                                                                     suggestedTask:(TTForumPostThreadTask *)suggestedTask
                                                                 stateUpdatedBlock:(TTForumPostThreadOperationStateUpdatedBlock)stateUpdatedBlock
                                                                      successBlock:(TTForumPostThreadOperationSuccessBlock)successBlock
                                                                    cancelledBlock:(TTForumPostThreadOperationCancelledBlock)cancelledBlock
                                                                      failureBlock:(TTForumPostThreadOperationFailureBlock)failureBlock;

@end
