//
//  TTPostThreadTask.h
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTPostThreadDefine.h"

#import <Foundation/Foundation.h>
#import <ios_house_im/FRUploadImageModel.h>
#import <TTPostBase/TTPostTask.h>
#import <TTUGCFoundation/FRApiModel.h>
#import <TTUGCFoundation/TTUGCDefine.h>
#import "TTRepostDefine.h"
#import "TTUGCImageCompressManager.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat TTForumPostVideoThreadTaskBeforeUploadImageProgress;
extern const CGFloat TTForumPostVideoThreadTaskBeforeUploadVideoProgress;
extern const CGFloat TTForumPostVideoThreadTaskBeforePostThreadProgress;

typedef NS_ENUM(NSInteger, TTForumRepostThreadTaskType) {
    TTForumRepostThreadTaskType_Thread = 1,  //转发的普通的帖子
    TTForumRepostThreadTaskType_Comment = 2, //转发并评论的数据
    TTForumRepostThreadTaskType_Reply = 3,   //转发并回复的数据
};

typedef NS_ENUM(NSUInteger, TTPostThreadTaskErrorPosition) {
    TTPostThreadTaskErrorPositionNone = 0,
    TTPostThreadTaskErrorPositionImage = 1,      //帖子图片(视频封面)没传成功
    TTPostThreadTaskErrorPositionPostThread = 2, //帖子(视频)发布接口没成功
    TTPostThreadTaskErrorPositionVideo = 3,      //视频上传失败
    TTPostThreadTaskErrorPositionCancel = 4,     //视频取消
};

@interface TTPostThreadTask : TTPostTask

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) NSString *titleRichSpan;
@property(nonatomic, strong)NSString * content;
@property(nonatomic, copy) NSString *contentRichSpans; //JSON化的rich spans
@property(nonatomic, copy) NSString *mentionUser; // at 人
@property(nonatomic, copy) NSString *coverUrl; //避免server后续出现的缩略图不一致，客户端将最终显示使用的图片回传server
@property(nonatomic, copy) NSString *mentionConcern; // # 话题
@property (nonatomic, copy) NSString *forumNames; // 自建的话题
@property(nonatomic, assign)int64_t create_time;
@property(nonatomic, strong)NSString * categoryID;
@property(nonatomic, copy) NSString *repostTitle;
@property(nonatomic, copy) NSString *repostSchema;
@property (nonatomic,strong) NSString *fw_native_schema;
@property (nonatomic,strong) NSString *fw_share_url;
@property(nonatomic, copy) NSString *communityID;
@property(nonatomic, copy) NSString *businessPayload;
@property(nonatomic, assign)NSInteger forward;
@property(nonatomic, strong)NSArray<FRUploadImageModel *> * _Nullable images;
@property(nonatomic, assign)int source;

@property(nonatomic, assign)CGFloat longitude;
@property(nonatomic, assign)CGFloat latitude;
@property(nonatomic, strong)NSString * city;
@property(nonatomic, strong)NSString * detail_pos;
@property(nonatomic, assign)int locationType; //地址，发布器草稿使用
@property(nonatomic, strong)NSString *locationAddress;//地址，发布器草稿使用
@property (nonatomic, assign) NSRange selectedRange; // 草稿光标位置

@property(nonatomic, strong)NSString *phone;
@property(nonatomic, assign)FRFromWhereType fromWhere;
@property(nonatomic, assign)CGFloat score;
@property(nonatomic, assign)NSUInteger refer;
@property(nonatomic, assign)TTPostUGCEnterFrom postUGCEnterFrom;
@property(nonatomic, assign)int64_t insertMixCardID;//专题中带插入的card的id
@property(nonatomic, copy) NSString *relatedForumSubjectID;
@property(nonatomic, copy)NSDictionary * extraTrack;

@property(nonatomic, assign)BOOL isPosting;
@property(nonatomic, strong)NSError * _Nullable finishError;
@property(nonatomic, assign)TTPostThreadTaskErrorPosition errorPosition;
@property(nonatomic, assign)int retryCount;
@property(nonatomic, strong)NSDictionary * responseDict;

@property(nonatomic, assign)CGFloat uploadProgress;
@property(nonatomic, copy)TTPostTaskProgressBlock progressBlock;

@property(nonatomic, copy) NSString *postID;
@property(nonatomic, assign) BOOL syncToRocket;

@property(nonatomic, copy) NSString *promotionID;

//接口转发相关字段
@property (nonatomic, assign) TTThreadRepostType repostType; //转发类型
@property (nonatomic, copy) NSString *fw_id;
@property (nonatomic, assign) FRUGCTypeCode fw_id_type;
@property (nonatomic, copy) NSString *opt_id;
@property (nonatomic, assign) FRUGCTypeCode opt_id_type;
@property (nonatomic, copy) NSString *fw_user_id;
@property (nonatomic, assign) BOOL repostToComment; // 是否转发并评论
@property (nonatomic, assign) TTForumRepostThreadTaskType repostTaskType;

@property (nonatomic, assign, readonly) TTPostTaskStatus status;

@property (nonatomic, copy) NSString *debug_currentMethod; //当前调用的方法。追查使用

// sdk 分享相关参数
@property (nonatomic, copy) NSString *sdkParams;

@property (nonatomic, copy)     NSString       *social_group_id;
@property (nonatomic, copy)     NSString       *social_group_name;
@property (nonatomic, assign)   BOOL       hasSocialGroup;  // 是否是外部传入小区
@property (nonatomic, assign)  NSInteger  bindType;

// 在初始化时确定Task的类型，默认为发普通帖子
- (instancetype)initWithTaskType:(TTPostTaskType)taskType;


//****耗时方法
- (void)addTaskImages:(nullable NSArray<TTUGCImageCompressTask *> *)taskImages thumbImages:(nullable NSArray<UIImage *> *)thumbImages;

/**
 *  任务中是否有还没有上传的图片
 *
 *  @return 是否有还未上传的图片
 */
- (BOOL)needUploadImg;

/**
 *  返回需要上传的图片
 *
 *  @return 需要上传的图片
 */
- (NSArray<FRUploadImageModel *> *)needUploadImgModels;

+ (NSString *)taskInDiskPosition;

+ (TTRepostOperationItemType) repostOperationItemTypeFromOptType:(FRUGCTypeCode)optIdType;

@end


@interface TTPostThreadTask (UI)

@end


NS_ASSUME_NONNULL_END

