//
//  TSVUserModel.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/9/25.
//

#import "TSVUserModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTBaseMacro.h"

@implementation TSVUserModel

+ (JSONKeyMapper *)keyMapper
{
    TSVUserModel *model = nil;
    NSDictionary *dict = @{
                           @keypath(model, avatarURL): @"info.avatar_url",
                            @keypath(model, name): @"info.name",
                            @keypath(model, schema): @"info.schema",
                            @keypath(model, userAuthInfo): @"info.user_auth_info",
                            @keypath(model, userID): @"info.user_id",
                            @keypath(model, verifiedContent): @"info.verified_content",
                            @keypath(model, desc): @"info.desc",
                            @keypath(model, userDecoration): @"info.user_decoration",
                            @keypath(model, isFollowed): @"relation.is_followed",
                            @keypath(model, isFollowing): @"relation.is_following",
                            @keypath(model, isFriend): @"relation.is_friend" ,
                            @keypath(model, followingsCount): @"relation_count.followings_count",
                            @keypath(model, followersCount): @"relation_count.followers_count",
                            };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    TSVUserModel *model = nil;
    NSArray *optionalArray = @[
                               @keypath(model, isFollowing),
                                @keypath(model, isFollowed),
                                @keypath(model, isFriend),
                                @keypath(model, followingsCount),
                                @keypath(model, followersCount),
                                ];
    return [optionalArray containsObject:propertyName];
}

@end
