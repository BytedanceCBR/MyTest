//GENERATED CODE , DON'T EDIT
#import "FHTopicListModel.h"
@implementation FHTopicListResponseModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHTopicListResponseDataListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"forumName": @"forum_name",
                           @"avatarUrl": @"avatar_url",
                           @"talkCountStr": @"talk_count_str",
                           @"forumId": @"forum_id",
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
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

