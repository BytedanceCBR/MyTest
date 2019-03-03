//GENERATED CODE , DON'T EDIT
#import "FHDetailRelatedHouseResponseModel.h"
@implementation FHDetailRelatedHouseResponseModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailRelatedHouseResponseDataItemsTagsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"backgroundColor": @"background_color",
    @"textColor": @"text_color",
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

@implementation FHDetailRelatedHouseResponseDataItemsBaseInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailRelatedHouseResponseDataItemsCoreInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailRelatedHouseResponseDataItemsBaseInfoMapModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"pricingPerSqm": @"pricing_per_sqm",
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

@implementation FHDetailRelatedHouseResponseDataItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"baseInfo": @"base_info",
    @"displaySubtitle": @"display_subtitle",
    @"displayPrice": @"display_price",
    @"displayBuiltYear": @"display_built_year",
    @"displayTitle": @"display_title",
    @"displayDescription": @"display_description",
    @"coreInfo": @"core_info",
    @"displayPricePerSqm": @"display_price_per_sqm",
    @"uploadAt": @"upload_at",
    @"imprId": @"impr_id",
    @"cellStyle": @"cell_style",
    @"houseImage": @"house_image",
    @"houseType": @"house_type",
    @"displaySameNeighborhoodTitle": @"display_same_neighborhood_title",
    @"baseInfoMap": @"base_info_map",
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

@implementation FHDetailRelatedHouseResponseDataItemsHouseImageModel
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

@implementation FHDetailRelatedHouseResponseDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
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

