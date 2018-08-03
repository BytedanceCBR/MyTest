//
//  AWEUserModel.m
//  Aweme
//
//  Created by Quan Quan on 16/8/10.
//  Copyright © 2016年 Bytedance. All rights reserved.
//
#import "AWEUserModel.h"

@implementation AWEUserModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"userId"     : @"user_id",
             @"mediaId"    : @"media_id",
             @"name"       : @"name",
             @"type"       : @"type",
             @"createTime"  : @"create_time",
             @"screenName"  : @"screen_name",
             @"lastUpdate"  : @"last_update",
             @"avatarUrl"   : @"avatar_url",
             @"isFollowed"  : @"is_followed",
             @"isFollowing" : @"is_following",
             @"userVerified": @"user_verified"
             };
}

@end
