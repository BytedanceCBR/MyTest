//
//  TTCommentDetailReplyCommentModel.m
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import "TTCommentDetailReplyCommentModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTUGCFoundation/FRApiModel.h>



@implementation TTCommentDetailReplyCommentModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        self.user = [[SSUserModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"user"]];
        self.qutoedCommentModel = [[TTQutoedCommentModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"reply_to_comment"]];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.commentID isEqualToString:[object commentID]];
}

- (NSUInteger)hash
{
    return [self.commentID hash];
}

- (NSString *)userRelationDescription {
    NSString *result = nil;
    if (self.user.isFollowing && self.user.isFollowed) {
        result = @"(互相关注)";
    }
    if (self.user.isFollowing && !self.user.isFollowed) {
        result = @"(已关注)";
    }
    return result;
}

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *keyMapperDic = @{
        @"id": @"commentID",
        @"digg_count": @"diggCount",
        @"content": @"content",
        @"content_rich_span": @"contentRichSpanJSONString",
        @"create_time": @"createTime",
        @"user_digg": @"userDigg",
        @"is_pgc_author": @"isPGCAuthor",
        @"is_owner": @"isOwner",
        @"reply_to_comment": @"qutoedCommentModel" // TODO 可能是错误的设置
    };
    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"isOwner"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isPgcAuthor"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"diggCount"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"userDigg"]) {
        return YES;
    }
    return NO;
}

+ (TTCommentDetailReplyCommentModel *)createReplyCommentModelWithCommentRepostAndReplyDitionary:(NSDictionary *)commentRepostAndReplyDic{

    if (SSIsEmptyDictionary(commentRepostAndReplyDic) || isEmptyString([commentRepostAndReplyDic tt_stringValueForKey:@"reply_id"]) || SSIsEmptyDictionary([commentRepostAndReplyDic tt_dictionaryValueForKey:@"raw_data"])) {
        return nil;
    }

    NSString *commentRepostReplyID = [commentRepostAndReplyDic tt_stringValueForKey:@"reply_id"];

    NSMutableDictionary *commentRepostRawData =  [[commentRepostAndReplyDic tt_dictionaryValueForKey:@"raw_data"] mutableCopy];
    NSDictionary *commentRepostOriginThreadDic = [commentRepostRawData tt_dictionaryValueForKey:@"origin_thread"];
    NSDictionary *commentRepostOriginGroupDic = [commentRepostRawData tt_dictionaryValueForKey:@"origin_group"];
    NSDictionary *commentRepostBase = [commentRepostRawData tt_dictionaryValueForKey:@"comment_base"];
    if (SSIsEmptyDictionary(commentRepostBase)) {
        return nil;
    }

    NSTimeInterval commentRepostCreateTime = [commentRepostBase tt_doubleValueForKey:@"create_time"];
    NSString *commentRepostContent = [commentRepostBase tt_stringValueForKey:@"content"];
    NSString *commentRepostContentRichSpan = [commentRepostBase tt_stringValueForKey:@"content_rich_span"];

    NSDictionary *commentRepostUserDic  = [commentRepostBase tt_dictionaryValueForKey:@"user"];
    FRCommonUserStructModel *commentRepostUserModel = [[FRCommonUserStructModel alloc] initWithDictionary:commentRepostUserDic error:nil];

    NSDictionary *commentRepostActionDataDic = [commentRepostBase tt_dictionaryValueForKey:@"action"];
    FRActionDataStructModel *actionModel = [[FRActionDataStructModel alloc] initWithDictionary:commentRepostActionDataDic error:nil];


    TTCommentDetailReplyCommentModel *replyModel = [[TTCommentDetailReplyCommentModel alloc] init];
    replyModel.commentID = commentRepostReplyID;
    if (!SSIsEmptyDictionary(commentRepostOriginThreadDic)) {
        replyModel.groupID = [commentRepostOriginThreadDic tt_stringValueForKey:@"thread_id"];
    }
    else if (!SSIsEmptyDictionary(commentRepostOriginGroupDic)) {
        replyModel.groupID =  [commentRepostOriginThreadDic tt_stringValueForKey:@"group_id"];
    }
    replyModel.content = commentRepostContent;
    replyModel.contentRichSpanJSONString = commentRepostContentRichSpan;
    replyModel.createTime = commentRepostCreateTime;
    replyModel.user = [self userModelWithUserCommonStructModel:commentRepostUserModel];
    replyModel.diggCount = actionModel.digg_count.integerValue;
    replyModel.userDigg = actionModel.user_digg.boolValue;

    return replyModel;

}

+ (SSUserModel *)userModelWithUserCommonStructModel:(FRCommonUserStructModel *)commonUserModel {

    if (!commonUserModel || isEmptyString(commonUserModel.info.user_id)) {
        return nil;
    }

    SSUserModel *userModel = [[SSUserModel alloc] init];

    userModel.ID = commonUserModel.info.user_id;
    userModel.name = commonUserModel.info.name;
    userModel.avatarURLString = commonUserModel.info.avatar_url;
    userModel.userDescription = commonUserModel.info.description;
    userModel.userAuthInfo = commonUserModel.info.user_auth_info;
    userModel.followerCount = commonUserModel.relation_count.followers_count.longLongValue;
    userModel.followingCount = commonUserModel.relation_count.followings_count.longLongValue;
    userModel.verifiedReason = commonUserModel.info.verified_content;
    userModel.media_id = commonUserModel.info.media_id;
    userModel.isBlocked = commonUserModel.block.is_blocked.boolValue;
    userModel.isBlocking = commonUserModel.block.is_blocking.boolValue;
    userModel.isFollowed = commonUserModel.relation.is_followed.boolValue;
    userModel.isFollowing = commonUserModel.relation.is_following.boolValue;
    userModel.isFriend = commonUserModel.relation.is_friend.boolValue;
    userModel.role = SSUserRoleTypeOfNormal;
    return userModel;

}

@end
