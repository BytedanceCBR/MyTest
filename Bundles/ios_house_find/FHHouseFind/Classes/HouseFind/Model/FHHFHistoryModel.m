//GENERATED CODE , DON'T EDIT
#import "FHHFHistoryModel.h"
@implementation FHHFHistoryDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHFHistoryModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHFHistoryDataDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"openUrl": @"open_url",
    @"listText": @"list_text",
    @"historyId": @"history_id",
    @"desc" : @"description",
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

