//
//  ExploreMomentDefine_Enums.h
//  Pods
//
//  Created by SongChai on 2018/2/8.
//

#ifndef ExploreMomentDefine_Enums_h
#define ExploreMomentDefine_Enums_hs

//删除动态, 发送方保证在主线程发送
// userInfo: {@"id":momentID}
#define kDeleteMomentNotificationKey    @"kDeleteMomentNotificationKey"

//删除动态对应评论的通知
#define kDeleteCommentNotificationKey   @"kDeleteCommentNotificationKey"

/**
 *  删除动态详情页的评论的notification
 *
 *  userInfo: {@"cid":commentID, @"mid":momentID}
 */
#define kDeleteMomentCommentNotificationKey @"kDeleteMomentCommentNotificationKey"

// 以下notifications不在main thread发送；接收方需要自己把UI相关操作加入到主线程中
// userinfo: {@"item" : momentItem}
#define kPostMomentItemDoneNotification @"kPostMomentItemDoneNotification"

// userinfo: {@"forum_id" : forumID, @"item" : forumItem}
#define kPostForumItemDoneNotification @"kPostForumItemDoneNotification"

// userinfo: {@"item" : momentItem}
#define kForwardMomentItemDoneNotification @"kForwardMomentItemDoneNotification"

// userInfo: {@"user_id" : userID}
// 拉黑通知名
#define kTTJSOrRNBlockOrUnBlockUserNotificationName @"kTTJSOrRNBlockOrUnBlockUserNotificationName"

// userInfo: {@"user_id" : userID}
// 举报通知名
#define kTTJSOrRNReportUserNotificationName @"kTTJSOrRNReportUserNotificationName"

#define kDetailDeleteUGCMovieNotification @"kDetailDeleteUGCMovieNotification"

typedef enum : NSUInteger {
    PostMomentSourceFromMoment = 1,
    PostMomentSourceFromForum = 2,
} PostMomentSourceType;

/**
 *  请求来源类型
 */
typedef NS_ENUM(NSUInteger, ArticleMomentSourceType)
{
    /**
     *  未指定类型
     */
    ArticleMomentSourceTypeNotAssign = 0,
    /**
     *  讨论区请求
     */
    ArticleMomentSourceTypeForum = 3,
    /**
     *  动态列表请求
     */
    ArticleMomentSourceTypeMoment = 4,
    /**
     *  文章详情页评论请求
     */
    ArticleMomentSourceTypeArticleDetail = 5,
    /**
     *  个人主页
     */
    ArticleMomentSourceTypeProfile = 6,
    /**
     *  消息
     */
    ArticleMomentSourceTypeMessage = 7,
    /**
     *  动态详情页请求
     */
    ArticleMomentSourceTypeMomentDetail = 8,
    
    /**
     *  Feed流
     */
    ArticleMomentSourceTypeFeed = 9,
    
    /**
     *  表示是帖子的动态详情页
     */
    ArticleMomentSourceTypeThread = 10
};

#endif
