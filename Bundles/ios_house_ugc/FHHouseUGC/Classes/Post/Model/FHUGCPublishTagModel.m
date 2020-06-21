//
//  FHUGCPublishTagModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/1/14.
//

#import "FHUGCPublishTagModel.h"

@implementation FHUGCPublishTagSocialModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"socialGroupId": @"social_group_id",
                           @"followerCount":@"follower_count",
                           @"followerDisplayCount":@"follower_display_count",
                           @"contentCount":@"content_count",
                           @"suggestReason":@"suggest_reason",
                           @"countText":@"count_text",
                           @"announcement":@"announcement",
                           @"announcementUrl":@"announcement_url",
                           @"avatar":@"avatar",
                           @"socialGroupName":@"social_group_name",
                           @"hasFollow":@"has_follow",
                           @"logPb":@"log_pb",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHUGCPublishTagModelData

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"recentlySocials":@"recently_socials"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHUGCPublishTagModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
