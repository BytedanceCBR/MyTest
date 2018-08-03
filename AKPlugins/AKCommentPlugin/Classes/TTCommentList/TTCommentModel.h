//
//  TTCommentModel.h
//  Article
//
//  Created by 冯靖君 on 16/3/30.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TTCommentModelProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface TTCommentModel : JSONModel<TTCommentModelProtocol>

@property(nonatomic, readonly, assign) BOOL userVerified;
@property(nonatomic, readonly, assign) BOOL isPGCAuthor;

@property(nonatomic, readonly, strong) NSNumber * commentID;
@property(nonatomic, readonly, strong) NSNumber * commentCreateTime;
@property(nonatomic, readonly, strong) NSNumber * userID;

@property(nonatomic, readonly, copy) NSString * userName;
@property(nonatomic, readonly, copy) NSString * commentContent;
@property(nonatomic, readonly, copy) NSString * commentContentRichSpanJSONString;
@property(nonatomic, readonly, copy) NSString * fromSite;
@property(nonatomic, readonly, copy) NSString * userAvatarURL;
@property(nonatomic, readonly, copy) NSString * userProfileURL;
@property(nonatomic, readonly, copy) NSString * userPlatform;
@property(nonatomic, readonly, copy) NSString * userDecorator;
@property(nonatomic, readonly, copy) NSString * itemTag;
@property(nonatomic, readonly, copy) NSString * userSignature;
@property(nonatomic, readonly, copy) NSString * accessoryInfo;
@property(nonatomic, readonly, copy) NSString * openURL;
@property(nonatomic, readonly, copy) NSString * mediaName;
@property(nonatomic, readonly, copy) NSString * mediaId;
@property(nonatomic, readonly, copy) NSString * verifiedInfo;
@property(nonatomic, readonly, copy) NSString<Optional> * userAuthInfo;

@property(nonatomic, readonly, copy) NSArray<TTCommentReplyModel *> *replyModelArr;
@property(nonatomic, readonly, copy) NSArray *authorBadgeList;

@property(nonatomic, readonly, strong) TTGroupModel *groupModel;

@property(nonatomic, strong) NSNumber<Optional> * digCount;
@property(nonatomic, strong) NSNumber<Optional> * replyCount;
@property(nonatomic, strong) NSNumber<Optional> * buryCount;

@property(nonatomic, assign) BOOL userDigged;
@property(nonatomic, assign) BOOL userBuried;
@property(nonatomic, assign) BOOL isBlocking;
@property(nonatomic, assign) BOOL isBlocked;

@property(nonatomic, strong, readwrite) TTQutoedCommentModel<Optional> *quotedComment;
/**
 *  5.5添加：评论列表通知cell的控制字段，非服务器传回，客户端业务逻辑确定
 *
 */
@property(nonatomic, readonly, assign) BOOL shouldShowDelete;    //该条评论是否可删除，默认NO

@property(nonatomic, copy) NSDictionary<Optional> *trackerDic ; //统计字段

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dict groupModel:(nullable TTGroupModel *)groupModel NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithCommentRepostDictionary:(nullable NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
