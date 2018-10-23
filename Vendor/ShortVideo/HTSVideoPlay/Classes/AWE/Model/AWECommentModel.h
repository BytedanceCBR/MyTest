//
//  AWECommentModel.h
//  LiveStreaming
//
//  Created by 01 on 16/7/11.
//  Copyright © 2016年 Bytedance. All rights reserved.
//
#import <Mantle/Mantle.h>

@interface AWECommentDiggStatus : MTLModel<MTLJSONSerializing>
@property (nonatomic, assign) BOOL userBury;
@property (nonatomic, strong) NSNumber *buryCount;
@property (nonatomic, strong) NSNumber *commentId;
@property (nonatomic, strong) NSNumber *diggCount;
@property (nonatomic, assign) BOOL stable;
@property (nonatomic, assign) BOOL userDigg;
@end

@interface ReplyCommentModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isPgcAuthor;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSNumber *userRelation;
@property (nonatomic, assign) BOOL userVerified;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userProfileImageUrl;
@end

@interface AWECommentModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, strong) ReplyCommentModel *replyToComment;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSNumber *replyCount;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL userVerified;
@property (nonatomic, assign) BOOL isBlocking;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *buryCount;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, copy) NSString *verifiedReason;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userProfileImageUrl;
@property (nonatomic, assign) BOOL userBury;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL isBlocked;
@property (nonatomic, strong) NSNumber *userRelation;
@property (nonatomic, copy) NSString *userAuthInfo;
@property (nonatomic, copy) NSString *userDecoration;
@property (nonatomic, strong) NSNumber *diggCount;
@property (nonatomic, strong) NSNumber *createTime;
@end

@interface AWECommentWrapper : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) AWECommentModel *comment;
@property (nonatomic, strong) NSNumber *cellType;
@end

@interface AWECommentResponseModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *totalNumber;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSArray<AWECommentWrapper *> *data;
@end
