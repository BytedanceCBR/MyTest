//
//  AWEVideoCommentModel.m
//  LiveStreaming
//
//  Created by 01 on 16/7/11.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWECommentModel.h"

@implementation AWECommentDiggStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"userBury" : @"user_bury",
             @"buryCount" : @"bury_count",
             @"commentId" : @"comment_id",
             @"diggCount" : @"digg_count",
             @"stable" : @"stable",
             @"userDigg" : @"user_digg"
            };
}

@end

@implementation ReplyCommentModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"isFollowed" : @"is_followed",
             @"isPgcAuthor" : @"is_pgc_author",
             @"userId" : @"user_id",
             @"text" : @"text",
             @"userRelation" : @"user_relation",
             @"userVerified" : @"user_verified",
             @"id" : @"id",
             @"isFollowing" : @"is_following",
             @"userName" : @"user_name",
             @"userProfileImageUrl" : @"user_profile_image_url",
            };
}

@end

@implementation AWECommentModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"isFollowed" : @"is_followed",
             @"replyToComment" : @"reply_to_comment",
             @"text" : @"text",
             @"replyCount" : @"reply_count",
             @"isFollowing" : @"is_following",
             @"userVerified" : @"user_verified",
             @"isBlocking" : @"is_blocking",
             @"userId" : @"user_id",
             @"buryCount" : @"bury_count",
             @"id" : @"id",
             @"verifiedReason" : @"verified_reason",
             @"platform" : @"platform",
             @"score" : @"score",
             @"userName" : @"user_name",
             @"userProfileImageUrl":@"user_profile_image_url",
             @"userBury" : @"user_bury",
             @"userDigg" : @"user_digg",
             @"isBlocked" : @"is_blocked",
             @"userRelation" : @"user_relation",
             @"userAuthInfo" : @"user_auth_info",
             @"userDecoration":@"user_decoration",
             @"diggCount" : @"digg_count",
             @"createTime" : @"create_time"
             };
}

+ (NSValueTransformer *)replyToCommentJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ReplyCommentModel.class];
}

@end

@implementation AWECommentWrapper

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"comment" : @"comment",
             @"cellType" : @"cell_type"
             };
}

+ (NSValueTransformer *)commentJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:AWECommentModel.class];
}

@end

@implementation AWECommentResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"totalNumber" : @"total_number",
             @"hasMore" : @"has_more",
             @"message" : @"message",
             @"data" : @"data"
             };
}

+ (NSValueTransformer *)dataJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:AWECommentWrapper.class];
}

@end
