//GENERATED CODE , DON'T EDIT
#import "FHSystemMsgModel.h"
@implementation FHSystemMsgDataItemsImagesModel
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

@implementation FHSystemMsgDataItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"moreDetail": @"more_detail",
    @"logPb": @"log_pb",
    @"openUrl": @"open_url",
    @"dateStr": @"date_str",
    @"buttonName": @"button_name",
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

@implementation FHSystemMsgModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSystemMsgDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
    @"minCursor": @"min_cursor",
    @"searchId": @"search_id",
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

