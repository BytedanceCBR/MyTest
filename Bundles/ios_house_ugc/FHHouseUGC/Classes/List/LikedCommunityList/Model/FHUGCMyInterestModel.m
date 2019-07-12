//GENERATED CODE , DON'T EDIT
#import "FHUGCMyInterestModel.h"
@implementation FHUGCMyInterestDataRecommendSocialGroupsThreadInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCMyInterestModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCMyInterestDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"recommendSocialGroups": @"recommend_social_groups",
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

@implementation FHUGCMyInterestDataRecommendSocialGroupsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"socialGroup": @"social_group",
    @"threadInfo": @"thread_info",
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

@implementation FHUGCMyInterestDataRecommendSocialGroupsThreadInfoImagesModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
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

@implementation FHUGCMyInterestDataRecommendSocialGroupsSocialGroupModel
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

