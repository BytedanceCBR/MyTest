//GENERATED CODE , DON'T EDIT
#import "FHUGCConfigModel.h"
@implementation FHUGCConfigModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCConfigDataPermissionModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCConfigDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"leadSuggest": @"lead_suggest",
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

@implementation FHUGCConfigDataLeadSuggestModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

