//
//  HTSVideoPlayUserModel.m
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/19.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "HTSVideoPlayUserModel.h"


@implementation HTSVideoPlayURLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"urlList"     : @"url_list",
             @"uri"         : @"uri"};
}

@end


@implementation HTSVideoPlayUserStatsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"userID"        : @"id",
             @"itemCount"     : @"item_count",
             @"recordCount"   : @"record_count",
             @"followingCount": @"following_count",
             @"followerCount" : @"follower_count",
             @"diamondCount"  : @"diamond_consumed_count",
             @"dailyFanTicketCount"   : @"daily_fan_ticket_count",
             @"dailyIncome"   : @"daily_income"
             };
}

@end


@implementation HTSVideoPlayUserModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"userID"             : @"id",
             @"shortID"            : @"short_id",
             @"nickName"           : @"nickname",
             @"signature"          : @"signature",
             @"level"              : @"level",
             @"birthdayVaild"      : @"birthday_valid",
             @"birthday"           : @"birthday",
             @"birthdayDescription": @"birthday_description",
             @"constellation"      : @"constellation",
             @"city"               : @"city",
             @"avatarThumb"        : @"avatar_thumb",
             @"avatarMedium"       : @"avatar_medium",
             @"avatarLarge"        : @"avatar_large",
             @"followStatus"       : @"follow_status",
             @"blockStatus"        : @"block_status",
             @"stats"              : @"stats",
             @"topFans"            : @"top_fans",
             @"ticketCount"        : @"fan_ticket_count",
             @"sinaVerifiedReason" : @"verified_reason",
             @"sinaVerified"       : @"verified",
             @"topVipNo"           : @"top_vip_no",
             @"canOthersDownloadVideo" : @"allow_others_download_video",
             };
}

+ (NSValueTransformer *)followStatusJSONTransformer
{
    NSDictionary *transformDictionary = @{[NSNull null] : @(HTSVideoPlayFollowStatusUnDefined),
                                          @(0) : @(HTSVideoPlayFollowStatusUnFollow),
                                          @(1) : @(HTSVideoPlayFollowStatusFollowed),
                                          @(2) : @(HTSVideoPlayFollowStatusFollowingFollowed )};
    
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:transformDictionary
                                                            defaultValue:@(HTSVideoPlayFollowStatusUnDefined)
                                                     reverseDefaultValue:@"undefined"];
}

+ (NSValueTransformer *)statsJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[HTSVideoPlayUserStatsModel class]];
}

+ (NSValueTransformer *)avatarThumbJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[HTSVideoPlayURLModel class]];
}

+ (NSValueTransformer *)avatarMediumJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[HTSVideoPlayURLModel class]];
}

+ (NSValueTransformer *)avatarLargeJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[HTSVideoPlayURLModel class]];
}

+ (NSValueTransformer *)topFansJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[HTSVideoPlayUserModel class]];
}

- (BOOL)isEqual:(id)object
{
    if (!object || [object isEqual:[NSNull null]]) {
        return NO;
    }
    HTSVideoPlayUserModel *obj = object;
    return [obj.userID isEqualToNumber:self.userID];
}

@end
