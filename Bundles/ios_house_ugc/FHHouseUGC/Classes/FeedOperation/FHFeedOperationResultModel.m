//GENERATED CODE , DON'T EDIT
#import "FHFeedOperationResultModel.h"
@implementation FHFeedOperationResultModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedOperationResultDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"stickStyle": @"stick_style",
    @"isStick": @"is_stick",
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

