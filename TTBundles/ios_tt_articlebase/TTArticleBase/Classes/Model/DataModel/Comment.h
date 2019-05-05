//
//  Comment.h
//  Article
//
//  Created by 王双华 on 16/11/10.
//
//

#import "ExploreOriginalData.h"

@class ArticleMomentModel;
@class DetailActionRequestManager;

@interface Comment : ExploreOriginalData
/**
 *  评论内容 对应服务端字段comment
 */
@property (nullable, nonatomic, retain) NSDictionary *commentDict;
/**
 *  评论内容补充内容 对应服务端字段comment_extra
 */
@property (nullable, nonatomic, retain) NSDictionary *commentExtra;
/**
 *  评论的文章的标题
 */
@property (nullable, nonatomic, retain) NSString     *title;
/**
 *  关键词
 */
@property (nullable, nonatomic, retain) NSArray      *filterWords;
/**
 *  aggr_type 透传给服务端，统计用
 */
@property (nullable, nonatomic, retain) NSNumber *aggrType;
/**
 *  评论的文章的group_id
 */
@property (nullable, nonatomic, copy) NSString  *groupID;
/**
 评论文章的item_id
 */
@property (nullable, nonatomic, copy) NSString  *itemID;
/**
 *  是否显示播放按钮，有视频就显示
 */
@property (nonatomic, retain, nullable) NSNumber       *hasVideo;
/**
 *  文章来源
 */
@property (nullable, nonatomic, retain) NSString     *source;
/**
 *  u11标识符
 */
@property (nullable, nonatomic, retain) NSNumber     *cellLayoutStyle;
/**
 *  dislike的选项
 */
@property (nullable, nonatomic, retain) NSArray      *actionList;


/**
 文章作者信息
 */
@property (nullable, nonatomic, copy) NSDictionary *articleUserInfo;

/**
 转发信息
 **/
@property (nullable, nonatomic, copy) NSDictionary *forwardInfo;

/**
 *  Comment持有DetailActionRequestManager本身比较track，但是由于DetailActionRequestManager非单例，并且
 *  DetailActionRequestManager的context不能变化，暂时由Comment持有
 */
@property (nullable, nonatomic, retain, readonly) DetailActionRequestManager * actionRequestManager;

/**
 文章的作者ID
 */
- (nullable NSString *)articleUserID;


/**
 文章作者名字
 */
- (nullable NSString *)articleUserName;


/**
 文章作者头像
 */
- (nullable NSString *)articleUserAvatar;


/**
 文章作者认证
 */
- (BOOL)articleUserVerified;

/**
 *  评论用户的id
 */
- (nullable NSString *)userID;
/**
 *  评论内容
 */
- (nonnull NSString *)commentContent;
/**
 *  评论用户头条展现信息
 */
- (nullable NSString *)userAuthInfo;


/**
 佩饰
 */
- (nullable NSString *)userDecoration;

/**
 *  评论用户认证信息
 */
- (nullable NSString *)userVerifiedContent;
/**
 *  顶的数量
 */
- (int)diggCount;
/**
 *  是否已顶
 */
- (BOOL)userDigg;
/**
 *  评论数
 */
- (int)commentCount;
/**
 *  评论用户头像
 */
- (nullable NSString *)userAvatarURL;
/**
 *  用户名
 */
- (nullable NSString *)userName;
/**
 *  评论id
 */
- (nullable NSString *)commentID;


/**
 *  评论显示最大行数
 */
- (NSUInteger)maxLineNumber;
/**
 *  点击评论用户头像跳转url
 */
- (nullable NSString *)sourceOpenURL;
/**
 *  文章缩略图url
 */
- (nullable NSString *)articleImageUrl;
/**
 *  评论跳转url
 */
- (nullable NSString *)commentOpenURL;
///**
// *  动态id
// */
//- (nullable NSString *)dongtaiID;
///**
// *  推荐原因类型
// */
//- (nullable NSNumber *)recommendReasonType;
/**
 *  推荐理由type
 */
- (nullable NSNumber *)recommendReasonType;
/**
 *  点击文章跳转url
 */
- (nullable NSString *)articleOpenURL;
/**
 *  是否已关注
 */
- (BOOL)isFollowed;
/**
 *  是否已经被对方关注
 */
- (BOOL)userIsFollowed;

- (void)setIsFollowed:(BOOL)followed;

- (void)updateDictWithUserDigg:(BOOL)userDigg;

- (void)updateDictWithDiggCount:(nullable NSNumber *)diggCount;

@end

