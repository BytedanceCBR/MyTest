//GENERATED CODE , DON'T EDIT
#import "FHUGCScialGroupModel.h"
@implementation FHUGCScialGroupModel
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
    @"socialGroupName": @"social_group_name",
    @"hasFollow": @"has_follow",
    @"operation": @"operation",
    @"logPb":@"log_pb",
    @"announcementUrl":@"announcement_url",
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
