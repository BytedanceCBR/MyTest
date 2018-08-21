//
//  TTVideoCallbackTaskGlobalQueue.h
//  Article
//
//  Created by xiangwu on 2017/2/22.
//
//

#import <Foundation/Foundation.h>

@interface TTVideoCallbackTask : NSObject

@property (nonatomic, copy) dispatch_block_t callback;

@end

@interface TTVideoCallbackTaskGlobalQueue : NSObject

+ (TTVideoCallbackTaskGlobalQueue *)sharedInstance;
- (void)enQueueCallbackTask:(TTVideoCallbackTask *)task;
- (TTVideoCallbackTask *)popQueueFromHead;
- (TTVideoCallbackTask *)popQueueFromTail;
- (void)clearQueue;
- (TTVideoCallbackTask *)headTask;
- (TTVideoCallbackTask *)tailTask;

@end
