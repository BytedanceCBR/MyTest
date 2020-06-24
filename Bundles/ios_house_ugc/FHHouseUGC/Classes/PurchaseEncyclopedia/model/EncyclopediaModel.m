//
//  EncyclopediaModel.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/15.
//

#import "EncyclopediaModel.h"

@implementation EncyclopediaItemFilterWordModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"isSelected": @"is_selected"
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

@implementation EncyclopediaItemMediaModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"avatarUrl": @"avatar_url",
        @"mediaId": @"media_id"
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

@implementation EncyclopediaItemModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"mediaName": @"media_name",
        @"banComment": @"ban_comment",
        @"articleType": @"article_type",
        @"hasM3u8Video": @"has_m3u8_video",
        @"hasMp4Video": @"has_mp4_video",
        @"articleSubType": @"article_sub_type",
        @"buryCount": @"bury_count",
        @"hasVideo": @"has_video",
        @"commentCount": @"comment_count",
        @"articleUrl": @"article_url",
        @"publishTime": @"publish_time",
        @"hasImage": @"has_image",
        @"tagId": @"tag_id",
        @"displayUrl": @"display_url",
        @"itemId": @"item_id",
        @"repinCount": @"repin_count",
        @"diggCount": @"digg_count",
        @"mediaInfo": @"media_info",
        @"filterWords": @"filter_words",
        @"groupId": @"group_id",
        @"logPb": @"log_pb",
        @"imprId": @"impr_id",
        @"searchId": @"search_id",
        @"imageList": @"image_list",
        
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


@implementation EncyclopediaDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"imprId": @"impr_id",
        @"logPb": @"log_pb",
        @"searchId": @"search_id",
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

@implementation EncyclopediaModel

@end

@implementation EncyclopediaConfigDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"items": @"data",
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
