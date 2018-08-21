//
//  TTForumPostThreadTask.h
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import <Foundation/Foundation.h>
#import "FRUploadImageModel.h"
#import "TTForumUploadVideoModel.h"
#import "TTUGCDefine.h"
#import "Thread.h"
#import "ExploreOrderedData_Enums.h"
#import <TSVShortVideoPostTaskProtocol.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat TTForumPostVideoThreadTaskBeforeUploadImageProgress;
extern const CGFloat TTForumPostVideoThreadTaskBeforeUploadVideoProgress;
extern const CGFloat TTForumPostVideoThreadTaskBeforePostThreadProgress;

typedef void (^TTForumPostThreadTaskProgressBlock)(CGFloat progress);

typedef NS_ENUM(NSInteger, TTForumPostThreadTaskType) {
    TTForumPostThreadTaskTypeThread = 0, //发送普通的帖子
    TTForumPostThreadTaskTypeVideo = 1, //发送视频
};

typedef NS_ENUM(NSInteger, TTForumRepostThreadTaskType) {
    TTForumRepostThreadTaskType_Thread = 1, //转发的普通的帖子
    TTForumRepostThreadTaskType_Comment = 2, //转发并评论的数据
    TTForumRepostThreadTaskType_Reply = 3, //转发并回复的数据
};

typedef NS_ENUM(NSUInteger, TTForumPostThreadTaskErrorPosition) {
    TTForumPostThreadTaskErrorPositionNone = 0,
    TTForumPostThreadTaskErrorPositionImage = 1, //帖子图片(视频封面)没传成功
    TTForumPostThreadTaskErrorPositionPostThread = 2, //帖子(视频)发布接口没成功
    TTForumPostThreadTaskErrorPositionVideo = 3, //视频上传失败
    TTForumPostThreadTaskErrorPositionCancel = 4, //视频取消
};

@interface TTForumPostThreadTask : NSObject

@property(nonatomic, assign, readonly)TTForumPostThreadTaskType taskType;
@property(nonatomic, strong, readonly)NSString * taskID;
@property(nonatomic, assign)int64_t fakeThreadId;
@property(nonatomic, strong)NSString *title;
@property (nonatomic, copy) NSString *titleRichSpan;
@property(nonatomic, strong)NSString * content;
@property(nonatomic, copy) NSString *contentRichSpans; //JSON化的rich spans
@property(nonatomic, copy) NSString *mentionUser; // at 人
@property(nonatomic, copy) NSString *coverUrl; //避免server后续出现的缩略图不一致，客户端将最终显示使用的图片回传server
@property(nonatomic, copy) NSString *mentionConcern; // # 话题
@property(nonatomic, assign)int64_t create_time;
@property(nonatomic, strong)NSString * concernID;
@property(nonatomic, strong)NSString * categoryID;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *repostTitle;
@property(nonatomic, copy) NSString *repostSchema;

@property(nonatomic, assign)NSInteger forward;
@property(nonatomic, strong)NSArray<FRUploadImageModel *> * _Nullable images;
@property(nonatomic, assign)int source;

@property(nonatomic, assign)CGFloat longitude;
@property(nonatomic, assign)CGFloat latitude;
@property(nonatomic, strong)NSString * city;
@property(nonatomic, strong)NSString * detail_pos;
@property(nonatomic, assign)int locationType; //地址，发布器草稿使用
@property(nonatomic, strong)NSString *locationAddress;//地址，发布器草稿使用

@property(nonatomic, strong)NSString *phone;
@property(nonatomic, assign)FRFromWhereType fromWhere;
@property(nonatomic, assign)CGFloat score;
@property(nonatomic, assign)NSUInteger refer;
@property(nonatomic, assign)TTPostUGCEnterFrom postUGCEnterFrom;
@property(nonatomic, copy)NSDictionary * extraTrack;

@property(nonatomic, strong)TTForumUploadVideoModel *video;

@property(nonatomic, assign)BOOL isPosting;
@property(nonatomic, strong)NSError * _Nullable finishError;
@property(nonatomic, assign)TTForumPostThreadTaskErrorPosition errorPosition;
@property(nonatomic, assign)int retryCount;
@property(nonatomic, strong)NSDictionary * responseDict;

@property(nonatomic, assign)CGFloat uploadProgress;
@property(nonatomic, copy)TTForumPostThreadTaskProgressBlock progressBlock;
@property(nonatomic, assign)TTRequestRedPacketType requestRedPacketType;

//接口转发相关字段
@property (nonatomic, assign) TTThreadRepostType repostType; //转发类型
@property (nonatomic, copy) NSString *fw_id;
@property (nonatomic, assign) FRUGCTypeCode fw_id_type;
@property (nonatomic, copy) NSString *opt_id;
@property (nonatomic, assign) FRUGCTypeCode opt_id_type;
@property (nonatomic, copy) NSString *fw_user_id;
@property (nonatomic, assign) BOOL repostToComment; // 是否转发并评论
@property (nonatomic, assign) TTForumRepostThreadTaskType repostTaskType;

@property(nonatomic, assign, readonly)TTForumPostThreadTaskStatus status;

@property(nonatomic, copy) NSString* debug_currentMethod; //当前调用的方法。追查使用

@property (nonatomic, copy) NSString *challengeGroupID; //被挑战视频的groupID
@property (nonatomic, copy) NSDictionary *pkStatus;
// 在初始化时确定Task的类型，默认为发普通帖子
- (instancetype)initWithTaskType:(TTForumPostThreadTaskType)taskType;


//****耗时方法
- (void)addTaskImages:(nullable NSArray<TTForumPostImageCacheTask*> *)taskImages thumbImages:(nullable NSArray<UIImage*> *)thumbImages;

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
 *  压缩视频封面图
 */
- (void)compressVideoCoverImage;

/**
 *  任务中是否有还没有上传的图片
 *
 *  @return 是否有还未上传的图片
 */
- (BOOL)needUploadImg;

/**
 *  视频封面是否还未上传
 *
 *  @return 视频封面是否还未上传
 */
- (BOOL)needUploadVideoCover;

/**
 *  视频是否还未上传
 *
 *  @return 视频是否还未上传
 */
- (BOOL)needUploadVideo;

/**
 *  返回需要上传的图片
 *
 *  @return 需要上传的图片
 */
- (NSArray<FRUploadImageModel *> *)needUploadImgModels;

/**
 *  由task构造fake thread的dictionary
 *
 *  @param task 发送任务
 *
 *  @return fake thread dictionary
 */
+ (NSDictionary *)fakeThreadDictionary:(TTForumPostThreadTask *)task;

/**
 *  持久化任务
 *
 *  @param task 需持久化任务
 *
 *  @return 是否成功持久化
 */
+ (BOOL)persistentToDiskWithTask:(TTForumPostThreadTask *)task;

/**
 *  从持久化中获取指定的任务
 *
 *  @param taskID task ID
 *  @param cid    concern ID
 *
 *  @return task id和forum id所指定的task。持久化中不存在返回nil
 */
+ (TTForumPostThreadTask *)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid;
+ (void)fetchTaskFromDiskByTaskID:(NSString *)taskID concernID:(NSString *)cid completion:(void(^)(TTForumPostThreadTask *task))completion;

/**
 *  从持久化中获取指定concernID的任务
 *
 *  @param cid    concern ID
 *
 *  @return concernID所指定的所有task。持久化中不存在返回nil
 */
+ (nullable NSArray <TTForumPostThreadTask *> *)fetchTasksFromDiskForConcernID:(nonnull NSString *)concernID;

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


+ (NSString *)taskInDiskPosition;
+ (NSString *)taskIDFromFakeThreadID:(int64_t)fakeThreadId;

+ (TTRepostOperationItemType) repostOperationItemTypeFromOptType:(FRUGCTypeCode)optIdType;

- (NSDictionary *)extraTrackForVideo;
- (NSDictionary *)extraTrackForVideoPublishDone;

@end


@interface TTForumPostThreadTask (ShortVideoProtocol)<TSVShortVideoPostTaskProtocol>

@end


NS_ASSUME_NONNULL_END
