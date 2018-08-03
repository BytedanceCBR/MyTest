//
//  TTUGCPostCenterProtocol.h
//  Pods
//
//  Created by xushuangqing on 23/11/2017.
//


#ifndef TTUGCPostCenterProtocol_h
#define TTUGCPostCenterProtocol_h

#import <Foundation/Foundation.h>
#import <TTServiceCenter.h>
#import <TTRecordedVideo.h>

//通知
extern NSString * const TTPostTaskBeginNotification;            //进入发布队列
extern NSString * const TTPostTaskResumeNotification;           //开始上传
extern NSString * const TTPostTaskdProgressUpdateNotification;  //进度修正
extern NSString * const TTPostTaskFailNotification;             //发布失败
extern NSString * const TTPostTaskSuccessNotification;          //发布成功
extern NSString * const TTPostTaskDeletedNotification;          //任务删除

extern NSString * const TTPostTaskNotificationUserInfoKeyFakeID;      //TTPostTaskDeletedNotification中userInfo中的key
extern NSString * const TTPostTaskNotificationUserInfoKeyConcernID;   //TTPostTaskDeletedNotification中userInfo中的key
extern NSString * const TTPostTaskNotificationUserInfoKeyChallengeGroupID;  //TTPostTaskDeletedNotification中userInfo中的key

extern NSString * const TTUGCPostCenterClassName;

@protocol TTUGCPostCenterProtocol<TTService>

/**
 首次发送一个小视频

 @param video 从发布器传出的TTRecordVideo对象
 @param concernID
 @param categoryID
 @param extraTrack
 */
- (void)protocol_postShortVideo:(TTRecordedVideo *)video concernID:(NSString *)concernID categoryID:(NSString *)categoryID extraTrack:(NSDictionary *)extraTrack;


/**
 从活动页首次发送一个小视频

 @param video 从发布器传出的TTRecordVideo对象
 @param concernID
 @param categoryID
 @param extraTrack
 */
- (void)protocol_postShortVideoFromConcernHomepage:(TTRecordedVideo *)video concernID:(NSString *)concernID categoryID:(NSString *)categoryID extraTrack:(NSDictionary *)extraTrack;

/**
 获取存在硬盘中的任务草稿，注意该方法比较耗时

 @param concernID 关心id
 @return 硬盘中的若干个任务草稿
 */
- (NSArray *)protocol_fetchDiscTaskForConcernID:(nonnull NSString *)concernID;

/**
 异步获取存在硬盘中的任务草稿

 @param concernID 关心id
 @param completion 完成回调
 */
- (void)protocol_asyncFetchDiscTaskForConcernID:(nonnull NSString *)concernID completion:(void (^)(NSArray *tasks))completion;

/**
 对某一个task进行重试

 @param fakeID task发送期间的fakeID
 @param concernID task所在的关心id
 */
- (void)protocol_resentShortVideoForFakeID:(int64_t)fakeID concernID:(nonnull NSString *)concernID;

/**
 取消某一个task，并删除草稿

 @param fakeID task发送期间的fakeID
 @param concernID task所在的关心id
 */
- (void)protocol_removeShortVideoTaskForFakeID:(int64_t)fakeID concernID:(nonnull NSString *)concernID;

@end


#endif /* TTUGCPostCenterProtocol_h */
