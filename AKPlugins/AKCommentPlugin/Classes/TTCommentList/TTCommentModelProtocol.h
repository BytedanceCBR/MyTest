//
//  TTCommentModelProtocol.h
//  Article
//
//  Created by 延晋 张 on 16/5/25.
//
//

typedef NS_ENUM(NSInteger, TTCommentUserRelationType) {
    TTCommentUserRelationTypeNone = 0,           //没关系
    TTCommentUserRelationTypeFollow ,            //已关注(你关注了他)
    TTCommentUserRelationTypeFriend,             //好友(互相关注)
};

#import <Foundation/Foundation.h>
#import "TTQutoedCommentModel.h"

@class TTGroupModel;
@class TTCommentReplyModel;

@protocol TTCommentModelProtocol <NSObject, NSCopying>

@required

@property (nonatomic, readonly, assign) BOOL isPGCAuthor;//5.1添加：该条评论是否是本文作者

@property (nonatomic, readonly, strong) NSNumber *commentID;
@property (nonatomic, readonly, strong) NSNumber *commentCreateTime;
@property (nonatomic, readonly, strong) NSNumber *userID;

@property (nonatomic, readonly, copy) NSString *userName;
@property (nonatomic, readonly, copy) NSString *commentContent;
@property (nonatomic, readonly, copy) NSString *commentContentRichSpanJSONString;
@property (nonatomic, readonly, copy) NSString *fromSite;
@property (nonatomic, readonly, copy) NSString *userAvatarURL;
@property (nonatomic, readonly, copy) NSString *userProfileURL;
@property (nonatomic, readonly, copy) NSString *userPlatform;
@property (nonatomic, readonly, copy) NSString *itemTag;//may nil
@property (nonatomic, readonly, copy) NSString *userSignature;// may nil
@property (nonatomic, readonly, copy) NSString *accessoryInfo;// may nil 评论额外信息（如机型），server传回
@property (nonatomic, readonly, copy) NSString *userAuthInfo; // 头条认证展现
@property (nonatomic, readonly, copy) NSString *openURL;
@property (nonatomic, readonly, copy) NSString *mediaName;
@property (nonatomic, readonly, copy) NSString *mediaId;

@property (nonatomic, readonly, copy) NSArray <TTCommentReplyModel *> *replyModelArr;
@property (nonatomic, readonly, copy) NSArray *authorBadgeList;//added 5.2.1: 用户badge信息

@property (nonatomic, readonly, strong) TTGroupModel *groupModel;

@property (nonatomic, strong) NSNumber *digCount;
@property (nonatomic, strong) NSNumber *replyCount;
@property (nonatomic, strong) NSNumber *buryCount;

@property (nonatomic, assign) BOOL userDigged;
@property (nonatomic, assign) BOOL userBuried;
@property (nonatomic, assign) BOOL isBlocking;
@property (nonatomic, assign) BOOL isBlocked;

- (instancetype)initWithDictionary:(NSDictionary *)dict groupModel:(TTGroupModel *)groupModel;

- (BOOL)isAvailable;
- (BOOL)hasReply;

@optional //只在TTCommentModel中使用
@property (nonatomic, strong) TTQutoedCommentModel *quotedComment; //引用的评论
@property (nonatomic, readonly, copy) NSString *verifiedInfo;
@property (nonatomic, strong) NSNumber *userRelation; //好友关系
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) BOOL isUnFold; //全部展开 显示原文...... 应该放在layout里的...
@property (nonatomic, assign) BOOL isStick; //是否为置顶
@property (nonatomic, copy) NSDictionary *trackerDic ; //统计字段
/// 用户关系 例如 好友 已关注  nil代表没有关系
/// @return 用户关系
- (NSString *)userRelationStr;

/// 用户信息 格式:头条号,认证信息 例如 头条号作者,好多房开发工程师
/// @return 用户信息
- (NSString *)userInfoStr;

- (NSString *)userDecoration;

@end
