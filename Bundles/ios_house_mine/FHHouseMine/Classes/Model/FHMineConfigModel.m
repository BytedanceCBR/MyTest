//GENERATED CODE , DON'T EDIT
#import "FHMineConfigModel.h"
@implementation FHMineConfigDataIconOpDataMyIconModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"opStyle": @"op_style",
    @"iconRowNum": @"icon_row_num",
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

@implementation FHMineConfigDataIconOpDataMyIconItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"openUrl": @"open_url",
    @"textColor": @"text_color",
    @"addDescription": @"add_description",
    @"tagImage": @"tag_image",
    @"backgroundColor": @"background_color",
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

@implementation FHMineConfigDataIconOpDataMyIconItemsImageModel
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

@implementation FHMineConfigDataIconOpDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"myIconId": @"my_icon_id",
    @"myIcon": @"my_icon",
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

@implementation FHMineConfigModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHMineConfigDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"iconOpData": @"icon_op_data",
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

