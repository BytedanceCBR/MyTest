//GENERATED CODE , DON'T EDIT
#import "FHUGCModel.h"
@implementation FHUGCDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"userFollowSocialGroups": @"user_follow_social_groups",
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

@implementation FHUGCDataUserFollowSocialGroupsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"socialGroupId": @"social_group_id",
    @"contentCount": @"content_count",
    @"followCount": @"follow_count",
    @"forumId": @"forum_id",
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

@implementation FHUGCModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCDataUserFollowSocialGroupsAvatarModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"imageType": @"image_type",
    @"urlList": @"url_list",
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

