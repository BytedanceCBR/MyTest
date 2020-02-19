//GENERATED CODE , DON'T EDIT
#import "FHUGCScialGroupModel.h"
@implementation FHUGCScialGroupModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCScialGroupDataChatStatusModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"conversationId": @"conversation_id",
    @"conversationStatus": @"user_status",
    @"maxConversationCount": @"user_limit",
    @"currentConversationCount": @"user_count",
    @"conversationShortId": @"conversation_short_id",
    @"idempotentId": @"idempotent_id"
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
@implementation FHUGCScialGroupDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"contentCount": @"content_count",
    @"suggestReason": @"suggest_reason",
    @"followerCount": @"follower_count",
    @"socialGroupId": @"social_group_id",
    @"countText": @"count_text",
    @"contentText": @"content_text",
    @"socialGroupName": @"social_group_name",
    @"hasFollow": @"has_follow",
    @"operation": @"operation",
    @"logPb":@"log_pb",
    @"announcementUrl":@"announcement_url",
    @"userAuth": @"user_auth",
    @"chatStatus": @"chat_status",
    @"shareInfo":@"share_info",
    @"tabInfo": @"tab_info",
    @"showStatus": @"show_status",
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

@implementation FHUGCSocialGroupOperationModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"imageUrl": @"image_url",
                           @"imageWidth": @"image_width",
                           @"imageHeight": @"image_height",
                           @"linkUrl": @"link_url",
                           @"hasOperation": @"has_operation",
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

@implementation FHUGCScialGroupDataTabInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabName": @"tab_name",
                           @"showName": @"show_name",
                           @"isDefault": @"is_default",
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
