//
//  ExploreMomentDefine.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-21.
//
//

#import <Foundation/Foundation.h>

#import "SSTTTAttributedLabel.h"

#ifndef Article_ExploreMomentDefine_h
#define Article_ExploreMomentDefine_h

//删除动态, 发送方保证在主线程发送
// userInfo: {@"id":momentID}
#define kDeleteMomentNotificationKey @"kDeleteMomentNotificationKey"

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
     *  动态区请求
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
    ArticleMomentSourceTypeMessage = 7
};

static inline CGSize sizeOfString (NSString *str, CGFloat fontSize, CGFloat fixedWidth)
{
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:getDefaultParagraphStyle()};
    CGSize size = [SSTTTAttributedLabel sizeThatFitsString:str withConstraints:CGSizeMake(fixedWidth, CGFLOAT_MAX) attributes:attributes limitedToNumberOfLines:10];
    
    return size;
}

static inline CGFloat heightOfString (NSString *str, CGFloat fontSize, CGFloat fixedWidth)
{
    return sizeOfString(str, fontSize, fixedWidth).height;
}

#endif
