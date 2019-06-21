//
//  TTPostThreadTaskCenter.h
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import "TTPostTask.h"

/**
 作为一个TTPostTask的内存Cache，管理Task的存取
 建议所有TTPostTask的存取都走这个类
 */
@interface TTPostTaskCenter : NSObject

+ (instancetype)sharedInstance;

/**
 预期在主线程被调用

 @param taskID
 @param concernID
 */
- (void)asyncGetTaskWithID:(NSString *)taskID concernID:(NSString *)concernID completionBlock:(void(^)(TTPostTask *task))completionBlock;

/**
 预期在主线程被调用，获取内存中的task
 
 @param taskID
 @param concernID
 */
- (TTPostTask *)asyncGetMemoryTaskWithID:(NSString *)taskID concernID:(NSString *)concernID;

/**
 预期在主线程被调用

 @param task
 */
- (void)asyncSaveTask:(TTPostTask *)task;


/**
 预期在主线程被调用

 @param taskID 
 @param cid
 */
- (void)asyncRemoveTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid;

@end
