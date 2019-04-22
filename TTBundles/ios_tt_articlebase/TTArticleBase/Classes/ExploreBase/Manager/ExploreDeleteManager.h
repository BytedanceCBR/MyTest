//
//  ExploreDeleteManager.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//  用于删除评论， 动态，动态的评论
//  TODO 将删除评论的代码迁移到 TTCommentDataManager

#import <Foundation/Foundation.h>



@interface ExploreDeleteManager : NSObject

+ (ExploreDeleteManager *)shareManager;
/**
 *  删除文章评论的方法
 *
 *  @param commentID 评论ID
 *  @param isAnswer  是否是问答
 */

- (void)deleteArticleCommentForCommentID:(NSString *)commentID isAnswer:(BOOL)isAnswer isNewComment:(BOOL)isNewComment;

/**
 删除评论的回复

 @param replyCommentID 二级评论ID
 @param hostCommentID 主体评论ID
 */
- (void)deleteReplyedComment:(NSString *)replyCommentID InHostComment:(NSString *)hostCommentID;

/**
 *  删除动态
 *
 *  @param momentID 删除指定ID的动态
 */
- (void)deleteMomentForMomentID:(NSString *)momentID;

/**
 *  删除动态评论
 *
 *  @param commentID 删除指定ID的动态评论
 */
- (void)deleteMomentCommentForCommentID:(NSString *)commentID;

@end
