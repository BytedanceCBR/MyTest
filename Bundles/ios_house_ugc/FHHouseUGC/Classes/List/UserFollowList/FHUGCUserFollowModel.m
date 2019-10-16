//GENERATED CODE , DON'T EDIT
#import "FHUGCUserFollowModel.h"
@implementation FHUGCUserFollowDataAdminListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"userName": @"user_name",
    @"avatarUrl": @"avatar_url",
    @"userId": @"user_id",
    @"homepageAuth": @"homepage_auth",
    @"followTime": @"follow_time",
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

@implementation FHUGCUserFollowModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCUserFollowDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
    @"adminList": @"admin_list",
    @"followList": @"follow_list",
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

@implementation FHUGCUserFollowDataFollowListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"userName": @"user_name",
    @"avatarUrl": @"avatar_url",
    @"userId": @"user_id",
    @"homepageAuth": @"homepage_auth",
    @"followTime": @"follow_time",
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

