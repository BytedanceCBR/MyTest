//
//  TTForumPostThreadTaskCenter.h
//  Article
//
//  Created by 徐霜晴 on 17/3/3.
//
//

#import <Foundation/Foundation.h>
#import "TTForumPostThreadTask.h"

@interface TTForumPostThreadTaskCenter : NSObject

+ (instancetype)sharedInstance;

/**
 预期在主线程被调用

 @param taskID <#taskID description#>
 @param concernID <#concernID description#>
 */
- (void)asyncGetTaskWithID:(NSString *)taskID concernID:(NSString *)concernID completionBlock:(void(^)(TTForumPostThreadTask *task))completionBlock;


/**
 预期在主线程被调用

 @param task <#task description#>
 */
- (void)asyncSaveTask:(TTForumPostThreadTask *)task;


/**
 预期在主线程被调用

 @param taskID 
 @param cid <#cid description#>
 */
- (void)asyncRemoveTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid;

@end
