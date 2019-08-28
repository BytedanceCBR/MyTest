//GENERATED CODE , DON'T EDIT
#import "FHTopicListModel.h"

@implementation FHTopicListResponseModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"errNo": @"err_no",
                           @"errTips": @"err_tips",
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

@implementation FHTopicListResponseDataSuggestModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHTopicListResponseDataSuggestHighlightModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"forumName": @"forum_name",
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

@implementation FHTopicListResponseDataSuggestForumModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"forumName": @"forum_name",
                           @"concernId": @"concern_id",
                           @"forumId": @"forum_id",
                           @"avatarUrl": @"avatar_url",
                           @"talkCountStr": @"talk_count_str",
                           @"talkCount": @"talk_count",
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

@implementation FHTopicListResponseDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"accurateMatch": @"accurate_match",
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

