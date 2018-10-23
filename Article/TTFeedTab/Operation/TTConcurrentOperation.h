//
//  TTConcurrentOperation.h
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import <Foundation/Foundation.h>

//状态枚举
typedef NS_ENUM(NSInteger, ConcurrentOperationState) {
    ConcurrentOperationReadyState = 1,
    ConcurrentOperationExecutingState,
    ConcurrentOperationFinishedState
};

@interface TTConcurrentOperation : NSOperation

@property (nonatomic, assign) ConcurrentOperationState state;

- (void)asyncOperation;
- (void)didFinishCurrentOperation;

@end
