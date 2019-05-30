//
//  TTPostTask.h
//  Pods
//
//  Created by xushuangqing on 23/02/2018.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTPostTaskType) {
    TTPostTaskTypeThread = 0, //发送普通的帖子
    TTPostTaskTypeVideo = 1, //发送视频
};

typedef NS_ENUM(NSUInteger, TTPostTaskStatus) {
    TTPostTaskStatusPosting = 0,
    TTPostTaskStatusFailed = 1,
    TTPostTaskStatusSucceed = 2,
};

typedef void (^TTPostTaskProgressBlock)(CGFloat progress);

@interface TTPostTask : NSObject<NSCoding>

@property(nonatomic, assign)TTPostTaskType taskType;

@property(nonatomic, copy) NSString *taskID;
@property(nonatomic, copy) NSString *concernID;
@property(nonatomic, copy) NSString *userID;

@property(nonatomic, assign)int64_t fakeThreadId;

- (instancetype)initWithTaskType:(TTPostTaskType)taskType;

+ (NSString *)taskIDFromFakeThreadID:(int64_t)fakeThreadId;

/**
 *  把任务持久化到磁盘
 *
 *  @return 是否成功持久化
 */
- (BOOL)saveToDisk;

/**
 *  把任务从磁盘从删除
 *
 *  @return 若存在并且删除成功返回YES，都这返回NO
 */
- (BOOL)removeFromDisk;

/**
*  持久化任务
*
*  @param task 需持久化任务
*
*  @return 是否成功持久化
*/
+ (BOOL)persistentToDiskWithTask:(TTPostTask *)task;

/**
 *  从持久化中获取指定的任务
 *
 *  @param taskID task ID
 *  @param cid    concern ID
 *
 *  @return task id和forum id所指定的task。持久化中不存在返回nil
 */
+ (TTPostTask *)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid;
+ (void)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid completion:(void(^)(TTPostTask *task))completion;

/**
 *  从持久化中获取指定concernID的任务
 *
 *  @param cid    concern ID
 *
 *  @return concernID所指定的所有task。持久化中不存在返回nil
 */
+ (NSArray <TTPostTask *> *)fetchTasksFromDiskForConcernID:(NSString *)concernID;

/**
 *  从持久化中移除指定的任务
 *
 *  @param taskID task ID
 *  @param cid    concern ID
 *
 *  @return 任务存在并且成功移除返回YES，否则返回NO
 */
+ (BOOL)removeTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid;

/**
 *  移除持久化中所有的任务
 */
+ (void)removeAllDiskTask;


@end

@interface TTPostTask(UI)

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *titleRichSpan;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *contentRichSpans;

@property (nonatomic, assign, readonly) TTPostTaskStatus status;
@property (nonatomic, assign) BOOL isPosting;
@property (nonatomic, assign, readonly) CGFloat uploadProgress;

@property (nonatomic, copy, readonly) NSDictionary *extraTrack;

@property (nonatomic, strong, readonly) UIImage *coverImage;
@property (nonatomic, strong) NSError *finishError;

@property (nonatomic, assign, readonly) NSInteger repostType;
@property (nonatomic, assign, readonly) BOOL shouldShowRedPacket;

@end

