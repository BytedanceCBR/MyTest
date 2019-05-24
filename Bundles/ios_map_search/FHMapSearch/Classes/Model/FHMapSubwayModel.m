//GENERATED CODE , DON'T EDIT
#import "FHMapSubwayModel.h"
@implementation FHMapSubwayModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHMapSubwayDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHMapSubwayDataOptionModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isEmpty": @"is_empty",
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

@implementation FHMapSubwayDataOptionOptionsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isEmpty": @"is_empty",
    @"isNoLimit": @"is_no_limit",
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

