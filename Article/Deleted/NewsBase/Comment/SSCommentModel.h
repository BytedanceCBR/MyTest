//
//  SSCommentModel.h
//  Article
//
//  Created by Zhang Leonardo on 13-1-15.
//
//

#import <Foundation/Foundation.h>
#import "TTCommentModelProtocol.h"

@class TTGroupModel;
@class TTForumModel;
@class TTCommentReplyModel;

@interface SSCommentModel : NSObject <TTCommentModelProtocol>

@property(nonatomic, readonly, assign) BOOL isPGCAuthor;

@property(nonatomic, readonly, strong) NSNumber * commentID;
@property(nonatomic, readonly, strong) NSNumber * commentCreateTime;
@property(nonatomic, readonly, strong) NSNumber * userID;

@property(nonatomic, readonly, copy) NSString * userName;
@property(nonatomic, readonly, copy) NSString * commentContent;
@property(nonatomic, readonly, copy) NSString * fromSite;
@property(nonatomic, readonly, copy) NSString * userAvatarURL;
@property(nonatomic, readonly, copy) NSString * userProfileURL;
@property(nonatomic, readonly, copy) NSString * userPlatform;
@property(nonatomic, readonly, copy) NSString * itemTag;
@property(nonatomic, readonly, copy) NSString * userSignature;
@property(nonatomic, readonly, copy) NSString * accessoryInfo;
@property(nonatomic, readonly, copy) NSString * openURL;
@property(nonatomic, readonly, copy) NSString * mediaName;
@property(nonatomic, readonly, copy) NSString * mediaId;
@property(nonatomic, readonly, copy) NSString * userAuthInfo;

@property(nonatomic, readonly, copy) NSArray <TTCommentReplyModel *> *replyModelArr;
@property(nonatomic, readonly, copy) NSArray *authorBadgeList;

@property(nonatomic, readonly, strong) TTGroupModel *groupModel;
@property(nonatomic, readonly, strong) TTForumModel *forumModel;

@property(nonatomic, strong) NSNumber * digCount;
@property(nonatomic, strong) NSNumber * replyCount;
@property(nonatomic, strong) NSNumber * buryCount;

@property(nonatomic, assign) BOOL userDigged;
@property(nonatomic, assign) BOOL userBuried;
@property(nonatomic, assign) BOOL isBlocking;
@property(nonatomic, assign) BOOL isBlocked;

- (instancetype)initWithDictionary:(NSDictionary *)dict groupModel:(TTGroupModel *)groupModel NS_DESIGNATED_INITIALIZER;

@end
