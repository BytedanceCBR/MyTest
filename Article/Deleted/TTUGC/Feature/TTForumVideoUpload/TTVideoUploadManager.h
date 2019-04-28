//
//  TTVideoUploadManager.h
//  Article
//
//  Created by 徐霜晴 on 16/10/14.
//
//

#import <Foundation/Foundation.h>

@class TTVideoUploadOperation;

@interface TTVideoUploadManager : NSObject

- (instancetype)initWithMaxConcurrentOperationCount:(NSInteger)count;

- (NSArray<TTVideoUploadOperation *> *)videoUploadOperations;

- (void)addVideoUploadOperation:(TTVideoUploadOperation *)videoUploadOperation;

- (void)cancelVideoUploadOperationForTaskID:(NSString *)taskID;

- (void)cancelAllOperations;

@end
