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

@implementation FHUGCModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCSearchDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"searchSocialGroups": @"search_social_groups",
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

@implementation FHUGCSearchModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

