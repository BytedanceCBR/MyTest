//
//  TTCommentDataManager.h
//  Article
//
//  Created by 冯靖君 on 16/4/7.
//
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager/TTNetworkDefine.h>
#import "TTCommentDefines.h"

@class TTGroupModel;
@class SSUserModel;
@class TTCommentDetailModel;

#define kDeleteMomentNotificationKey      @"kDeleteMomentNotificationKey"
#define kDeleteCommentNotificationKey     @"kDeleteCommentNotificationKey"
#define kTTDeleteZZCommentNotification    @"kTTDeleteZZCommentNotification" //删除了推荐给粉丝的评论
#define kPostMessageFinishedNotification  @"kPostMessageFinishedNotification"
#define kCommentRepostSuccessNotification @"kCommentRepostSuccessNotification"
#define kCommentRepostFwID                @"kCommentRepostFwID"
#define kCommentRepostOptID               @"kCommentRepostOptID"


typedef void (^TTCommentDiggListFinishBlock)(NSMutableOrderedSet <SSUserModel *> * _Nullable diggUsers, NSInteger diggCount, NSError * _Nullable error);


@interface TTCommentDataManager : NSObject

+ (instancetype)sharedManager;

/**
 *  详情页老UI获取评论，区分“热度”和“时间”tab, 增加topCommentID和zzids参数
 *
 *  @param article       所属文章
 *  @param loadMode      refresh还是loadMore
 *  @param category      指定tab
 *  @param offset        loadMore的offset
 *  @param loadMoreCount 一次loadMore加载的评论条数
 *  @param topCommentID  置顶评论id，从article获取
 *  @param zzids         转载推荐评论id拼接字符串
 *  @param finishBlock   VM层传入的接口回调
 */
- (void)startFetchCommentsWithGroupModel:(TTGroupModel *)groupModel
                             forLoadMode:(TTCommentLoadMode)loadMode
                          loadMoreOffset:(NSNumber *)offset
                           loadMoreCount:(NSNumber *)loadMoreCount
                                   msgID:(NSString *)msgID
                                 options:(TTCommentLoadOptions)options
                             finishBlock:(TTCommentLoadFinishBlock)finishBlock;

// NOTICE service_id 的含义参考
// https://wiki.bytedance.net/pages/viewpage.action?pageId=149704582
- (void)startFetchCommentsWithGroupModel:(TTGroupModel *)groupModel
                               serviceID:(NSString *)serviceID
                             forLoadMode:(TTCommentLoadMode)loadMode
                          loadMoreOffset:(NSNumber *)offset
                           loadMoreCount:(NSNumber *)loadMoreCount
                                   msgID:(NSString *)msgID
                                 options:(TTCommentLoadOptions)options
                             finishBlock:(TTCommentLoadFinishBlock)finishBlock;

- (void)startFetchCommentsWithGroupID:(NSString *)groupID
                               itemID:(NSString *)itemID
                              forumID:(NSString *)forumID
                            aggreType:(NSInteger)aggreType
                       loadMoreOffset:(NSInteger)offset
                        loadMoreCount:(NSInteger)loadMoreCount
                                msgID:(NSString *)msgID
                              options:(TTCommentLoadOptions)options
                          finishBlock:(TTCommentLoadFinishBlock)finishBlock;


/**
 * 获取评论详情
 * @param commentID 评论ID
 * @param finishBlock 回调方法
 */
- (void)fetchCommentDetailWithCommentID:(NSString *)commentID
                            finishBlock:(void (^)(TTCommentDetailModel *model, NSError *error))finishBlock;

/**
 * 获取评论回复列表
 * TODO IDL Model
 * @param commentID 评论ID
 * @param loadMoreOffset 偏移量
 * @param loadMoreCount 加载条数
 * @param msgID 消息ID，如果是消息跳转，则置顶高亮
 * @param isRepost 标识当前是转发详情页
 * @param finishBlock 回调方法
 */
- (void)fetchCommentReplyListWithCommentID:(NSString *)commentID
                            loadMoreOffset:(NSInteger)loadMoreOffset
                             loadMoreCount:(NSInteger)loadMoreCount
                                     msgID:(NSString *)msgID
                                  isRepost:(BOOL)isRepost
                               finishBlock:(void(^)(id jsonObj, NSError *error))finishBlock;

/**
 * 评论发布
 * @param groupID 所属文章或帖子的 ID
 * @param aggrType 表示采用GroupId(AggrType:0 或 1) 或者 ItemId(AggrType:2) 作为获取唯一标示
 * @param itemTag 区分是不是广告，可能已经弃用
 * @param content 评论内容
 * @param replyToCommentID 评论详情页回复并转发时，所属评论 ID
 * @param context 统计用字段
 * @return 返回评论是否发送，用户未登录情况下并不会发送，不确定是否发送成功
 */
- (BOOL)postCommentWithGroupID:(NSString *)groupID
                      aggrType:(NSInteger)aggrType
                       itemTag:(NSString *)itemTag
                       content:(NSString *)content
              replyToCommentID:(NSString *)replyToCommentID
                       context:(id)context;

- (BOOL)postCommentWithGroupID:(NSString *)groupID
                     serviceID:(NSString *)serviceID
                      aggrType:(NSInteger)aggrType
                       itemTag:(NSString *)itemTag
                       content:(NSString *)content
               contentRichSpan:(NSString *)contentRichSpan
                   mentionUser:(NSString *)mentionUser
              replyToCommentID:(NSString *)replyToCommentID
                       replyID:(NSString *)replyID
                      isRepost:(BOOL)isRepost
                 repostContent:(NSString *)repostContent
         repostContentRichSpan:(NSString *)repostContentRichSpan
                    repostFwID:(NSString *)repostFwID
           commentTimeInterval:(NSString *)interval
                    staytimeMs:(NSNumber *)staytimeMs
                       readPct:(NSNumber *)readPct
                       context:(id)context
                      callback:(TTNetworkJSONFinishBlock)callback;

/**
 * 提交评论回复
 * @param commentID 评论ID
 * @param replyCommentID 如果是对回复的回复，则目标评论回复 ID
 * @param replyUserID 如果是对回复的回复，则目标评论回复用户 ID
 * @param richSpanText 回复内容 rich_span_text
 */
- (void)postCommentReplyWithCommentID:(NSString *)commentID
                       replyCommentID:(NSString *)replyCommentID
                          replyUserID:(NSString *)replyUserID
                              content:(NSString *)content
                      contentRichSpan:(NSString *)contentRichSpan
                         mentionUsers:(NSString *)mentionUsers
                          finishBlock:(void (^)(id jsonObj, NSError *error))finishBlock;


/**
 * 删除评论
 * @param commentID 评论ID
 * @param finishBlock 回调方法
 */
- (void)deleteCommentWithCommentID:(NSString *)commentID finishBlock:(void (^)(NSError *error))finishBlock;

/**
 * 删除评论回复
 * @param commentReplyID 评论回复ID
 * @param commentID 回复所属评论ID
 * @param finishBlock 回调方法
 */
- (void)deleteCommentReplyWithCommentReplyID:(NSString *)commentReplyID commentID:(NSString *)commentID finishBlock:(void (^)(NSError *error))finishBlock;

/**
 * 作者删除其他人的评论
 * @param commentID 评论ID
 * @param groupID 帖子或文章ID
 * @param finishBlock 回调方法
 */
- (void)deleteCommentByAuthorWithCommentID:(NSString *)commentID groupID:(NSString *)groupID finishBlock:(void (^)(NSError *error))finishBlock;

/**
 * 作者删除其他人的评论回复
 * @param commentReplyID 评论回复ID
 * @param commentID 回复所属评论ID
 * @param finishBlock 回调方法
 */
- (void)deleteCommentReplyByAuthorWithCommentReplyID:(NSString *)commentReplyID commentID:(NSString *)commentID finishBlock:(void (^)(NSError *error))finishBlock;

/**
 * 加载评论点赞列表
 * @param commentID 评论ID
 * @param finishBlock 回调方法
 */
- (void)fetchCommentDiggListWithCommentID:(NSString *)commentID finishBlock:(TTCommentDiggListFinishBlock)finishBlock;

/**
 * 点赞评论回复
 * @param commentReplyID 评论回复ID
 * @param commentID 回复所属评论ID
 * @param isDigg 是否点赞还是取消点赞
 */
- (void)diggCommentReplyWithCommentReplyID:(NSString *)commentReplyID commentID:(NSString *)commentID isDigg:(BOOL)isDigg;

@end

