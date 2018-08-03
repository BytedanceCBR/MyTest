//
//  FRForumServer.h
//  Article
//
//  Created by 王霖 on 4/25/16.
//
//

#import <Foundation/Foundation.h>
#import <TTBaseLib/NSObject+TTAdditions.h>

@interface FRForumServer : NSObject<Singleton>

#pragma mark - Comment

/**
 *  头部用户删除自己帖子下面的评论
 *
 *  @param commentID 被删除评论ID
 *  @param threadID  评论所属的帖子ID
 *  @param finish    finish block
 */
- (void)authorDeleteComment:(int64_t)commentID groupID:(int64_t)groupID finish:(nullable void(^)(NSError * _Nullable error))finish;

/**
 *  头部用户删除自己评论下面的回复 （v2详情页也可以删回复）
 *
 *  @param replyID 被删除回复ID
 *  @param commentID 被删除回复所属的评论ID
 *  @param finish    finish block
 */
- (void)authorDeleteReply:(int64_t)replyID commentID:(int64_t)commentID finish:(nullable void(^)(NSError * _Nullable error))finish;

/**
 *  删除帖子
 *
 *  @param threadID 帖子ID
 *  @param finish   finish block
 */
- (void)deleteThreadWithThreadID:(int64_t)threadID finish:(nullable void (^)(NSError * _Nullable error, NSString * _Nullable tips))finish;

@end
