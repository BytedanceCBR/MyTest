//GENERATED CODE , DON'T EDIT
#import "FHUGCVoteResponseModel.h"
@implementation FHUGCVoteResponseModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCVoteResponseDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"optionIds": @"option_ids",
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

