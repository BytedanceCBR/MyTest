//
//  ArticleMomentCommentManager.h
//  Article
//
//  Created by Dianwei on 14-5-23.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMomentDefine.h"

#import "TTCommentDetailReplyCommentModel.h"
#import "TTCommentDetailCellLayout.h"

@class ArticleMomentCommentModel;
@interface ArticleMomentCommentManager : NSObject
@property(nonatomic, retain)NSString *momentID;
@property(nonatomic, assign, readonly,getter = isLoading)BOOL loading;

/**
 
 看起来我必须写点注释了...fuck
 
 等评论和动态拆开后..我一定回来改... @zengruihuan

 @param momentID       评论或者动态ID ...fuck
 @param isNewComment   是否处于新版UI   如果NO, 评论or动态 请求统一接口, YES, 请求不同接口
 @param isFromeComment 是否从 文章评论区进入..

 @return
 */
- (id)initWithMomentID:(NSString*)momentID isNewComment:(BOOL)isNewComment isFromeComment:(BOOL)isFromeComment;

/**
 Manager内部维护下次请求的offset
 */

- (void)startLoadMoreCommentWithCount:(int) count width:(CGFloat)width finishBlock:(void(^)(NSArray *comments, NSArray *hotComments,BOOL hasMore, int totalCount, NSError *error))finishBlock;
- (NSArray*)comments;

// 热门评论
- (NSArray *)hotComments;

- (NSArray *)commentLayouts;

- (NSArray *)hotCommentLayouts;

- (void)refreshLayoutsWithWidth:(CGFloat)width;

- (ArticleMomentCommentModel *)commentModelForID:(NSString *)cID;

/**
 同时也会在列表的相应动态中插入comment
 */
- (void)insertComment:(TTCommentDetailReplyCommentModel *)comment;

- (void)insertCommentLayout:(TTCommentDetailCellLayout *)layout;

/**
 删除动态评论
 */
- (void)deleteComment:(TTCommentDetailReplyCommentModel *)comment;

- (void)deleteCommentLayout:(TTCommentDetailCellLayout *)layout;


/**
 回复动态或动态的评论
 如果是评论动态的评论，需要给commentID和commentUserID
 回复内容自动插入comments中
 */


+ (void)startPostCommentForComment:(NSString*)momentID
                         CommentID:(NSString*)commentID
                     commentUserID:(NSString*)commentUserID
                           content:(NSString*)content
                            source:(ArticleMomentSourceType)source
                         isForward:(BOOL)isForward
                   withFinishBlock:(void(^)(ArticleMomentCommentModel *model, NSError *error))finishBlock;

/**
 动态评论点赞
 */
+ (void)startDiggCommentWithCommentID:(NSString *)commentID
                      withFinishBlock:(void(^)(NSError *error))finishBlock;

- (void)fetchCommentDetailListWithCommentID:(NSString *)commentID count:(int)count width:(CGFloat)width finishBlock:(void(^)(NSArray *result, NSArray *hotComments, BOOL hasMore, NSInteger totalCount, NSError *error))finishBlock;

- (void)handleReplyCommentDigWithCommentID:(NSString *)commentID replayID:(NSString *)replayID userDigg:(BOOL)userDigg finishBlock:(void(^)(NSError *error))finishBlock;
@end
