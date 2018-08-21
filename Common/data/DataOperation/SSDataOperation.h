//
//  SSDataOperation.h
//  Essay
//
//  Created by Dianwei on 12-7-10.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^shouldExecute)(id operationContext);
typedef void(^didFinished)(NSArray *newList, NSError *error,  id operationContext);

@protocol SSDataOperationDelegate;

@interface SSDataOperation : NSObject

- (void)execute:(id)operationContext;
- (void)cancel;
- (void)reuseOperation;
- (void)notifyWithData:(NSArray*)newlistData error:(NSError*)error userInfo:(NSDictionary*)userInfo;
- (void)executeNext:(id)operationContext;

@property(nonatomic, weak) id<SSDataOperationDelegate>opDelegate;
@property(nonatomic, assign)BOOL hasFinished;
@property(nonatomic, copy)shouldExecute shouldExecuteBlock;
@property(nonatomic, copy)didFinished didFinishedBlock;
@property(nonatomic, weak)SSDataOperation *nextOperation;
@property(nonatomic, readonly)BOOL cancelled;

@end

@protocol SSDataOperationDelegate <NSObject>

@optional

- (void)dataOperation:(SSDataOperation *)op increaseData:(NSArray *)increaseData error:(NSError *)error userInfo:(NSDictionary *)userInfo;
- (void)dataOperationStartExecute:(SSDataOperation *)op;
- (void)dataOperationInterruptExecute:(SSDataOperation *)op;
@end
