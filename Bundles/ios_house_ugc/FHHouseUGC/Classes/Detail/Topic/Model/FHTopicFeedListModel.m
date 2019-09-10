//GENERATED CODE , DON'T EDIT
#import "FHTopicFeedListModel.h"
@implementation FHTopicFeedListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
    @"apiBaseInfo": @"api_base_info",
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

@implementation FHTopicFeedListDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHTopicFeedListApiBaseInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"appExtraParams": @"app_extra_params",
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

