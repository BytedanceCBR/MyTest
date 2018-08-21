//
//  FRCommentRepost.h
//  FRCommentRepost
//
//  Created by 柴淞 on 9/7/17.
//
//

#import "ExploreOriginalData.h"
#import "FRActionDataService.h"
#import "FRApiModel.h"
#import "FRImageInfoModel.h"

@class DetailActionRequestManager;
@class Article;
@class Thread;
@class TTRichSpanText;
@class UGCRepostCommonModel;

/*

 FRCommentRepost 讲server下面两级model打平处理
 
 struct CommentBase {
 1: i64 id,                               # 评论ID
 2: string content,                       # 评论正文
 3: i16 status,                           # 评论状态
 4: i64 create_time,                      # 评论时间
 5: model.User user,                      # 评论用户信息
 6: model.ActionData action,              # 计数信息
 7: string content_rich_span,             # 富文本
 8: string detail_scheme,                 # 跳转详情
 9: optional Share share,                 # 分享信息
 10: i64 group_id,                        # 被评论的主体GroupID
 11: optional RepostParam repost_params,  # 服务端下发的转发发布参数
 }
 
 struct Comment {
 1: i64 id,                                   # 评论ID
 2: CommentBase comment_base,                 # 评论数据
 3: ugc_consts.CommentTypeCode comment_type,  # 评论类型
 4: i16 is_repost,                            # 是否是转发
 5: optional StreamUICtrl stream_ui,          # stream cell UI控制
 6: optional i32 show_origin,                 # 源内容是否展示
 7: optional string show_tips,                # 源内容展示文案
 8: optional ThreadBase origin_thread,        # 原帖子
 9: optional Group origin_group,              # 原文章
 }

 */



//server返回的id就是数据库的uniqueID，上一级ExploreOrderedData也是用这个
@interface FRCommentRepost : ExploreOriginalData

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *content; //后台content
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, strong) FRCommonUserStructModel *userModel;
@property (nonatomic, strong) FRShareInfoStructModel *shareInfoModel; //用于详情页分享
@property (nonatomic, strong) NSString *contentRichSpanJSONString; // content_rich_span 富文本部分
@property (nonatomic, strong) NSString *schema; // detail_schema cell跳转使用
@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) id<FRActionDataProtocol> actionDataModel;

/*
 message RepostParamStruct {
  required RepostTypeCode repost_type = 1;// 转发类型
  required int64 fw_id = 2;                            // 转发源内容ID
  required UGCTypeCode fw_id_type = 3;    // 转发源内容ID类型
  required int64 fw_user_id = 4;                       // 转发源内容UID
  required int64 opt_id = 5;                           // 转发父节点ID
  required UGCTypeCode opt_id_type = 6;   // 转发父节点ID类型
 }
 */
@property (nonatomic, strong) NSDictionary *repostParamsDict; // repost_params用于转发

@property (nonatomic, assign) FRCommentTypeCode commentType; // commentType 富文本部分
@property (nonatomic, assign) BOOL isRepost;

@property (nonatomic, assign) BOOL showOrigin; //show_origin 是否显示源内容
@property (nonatomic, strong) NSString *showTips; // show_tips showOrigin为NO时使用该字段，如果不存在则 @"原内容已删除"
@property (nonatomic, strong) NSDictionary *originCommonContent; // origin_common_content
@property (nonatomic, strong, readonly) Article *originGroup; // origin_group
@property (nonatomic, strong, readonly) Thread *originThread; // origin_thread
@property (nonatomic, retain) NSNumber *originGroupID;
@property (nonatomic, retain) NSNumber *originThreadID;
@property (nonatomic, strong, readonly) UGCRepostCommonModel *originRepostCommonModel; // origin_common_content
@property (nonatomic, strong) NSString *contentDecoration;
@property (nonatomic, strong) NSArray<NSDictionary *> *filterWords; //按道理应该放在orderedData里，但大多逻辑都写在具体业务中，此处外部手动赋值
/**
 *  Comment持有DetailActionRequestManager本身比较trick，但是由于DetailActionRequestManager非单例，并且
 *  DetailActionRequestManager的context不能变化，暂时由Comment持有
 */
@property (nonatomic, retain, readonly) DetailActionRequestManager *actionRequestManager;

- (TTRichSpanText *)getRichContent;

- (void)diggWithFinishBlock:(void (^)(NSError *))finishBlock;
- (void)cancelDiggWithFinishBlock:(void (^)(NSError *))finishBlock;
+ (void)setCommentRepostDeletedWithID:(NSString *)CommentRepostID;

+ (FRCommentRepost *)updateWithDictionary:(NSDictionary *)dictionary
                                commentId:(NSString *)commentID
                         parentPrimaryKey:(NSString *)parentPrimaryKey;

+ (FRCommentRepost *)objectForCommentId:(NSString *)commentID
                       parentPrimaryKey:(NSString *)parentPrimaryKey;

- (nullable NSArray<FRImageInfoModel *> *)getForwardedVideoU13CutImageModels;

@end
