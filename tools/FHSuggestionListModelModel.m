//GENERATED CODE , DON'T EDIT
#import "FHSuggestionListModelModel.h"
@implementation FHSuggestionListModelDataItemsBaseInfoMapModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"pricingPerSqm": @"pricing_per_sqm",
    @"builtYear": @"built_year",
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

@implementation FHSuggestionListModelDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
    @"searchHistoryOpenUrl": @"search_history_open_url",
    @"refreshTip": @"refresh_tip",
    @"searchId": @"search_id",
    @"houseListOpenUrl": @"house_list_open_url",
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

@implementation FHSuggestionListModelDataItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"pricePerSqmUnit": @"price_per_sqm_unit",
    @"baseInfo": @"base_info",
    @"displaySubtitle": @"display_subtitle",
    @"neighborhoodInfo": @"neighborhood_info",
    @"gaodeLat": @"gaode_lat",
    @"displayPrice": @"display_price",
    @"houseVideo": @"house_video",
    @"displayTitle": @"display_title",
    @"displayDescription": @"display_description",
    @"displayStatsInfo": @"display_stats_info",
    @"cardType": @"card_type",
    @"displayPricePerSqm": @"display_price_per_sqm",
    @"imprId": @"impr_id",
    @"cellStyle": @"cell_style",
    @"displayBuiltYear": @"display_built_year",
    @"houseType": @"house_type",
    @"gaodeLng": @"gaode_lng",
    @"pricePerSqmNum": @"price_per_sqm_num",
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

@implementation FHSuggestionListModelModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSuggestionListModelDataItemsImagesModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"imageType": @"image_type",
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

@implementation FHSuggestionListModelDataItemsNeighborhoodInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"areaId": @"area_id",
    @"groupId": @"group_id",
    @"cityId": @"city_id",
    @"neighborhoodImages": @"neighborhood_images",
    @"pricingPerSqmV": @"pricing_per_sqm_v",
    @"districtId": @"district_id",
    @"gaodeImageUrl": @"gaode_image_url",
    @"pricingPerSqm": @"pricing_per_sqm",
    @"gaodeLat": @"gaode_lat",
    @"imprId": @"impr_id",
    @"locationFullName": @"location_full_name",
    @"districtName": @"district_name",
    @"monthUp": @"month_up",
    @"gaodeLng": @"gaode_lng",
    @"searchId": @"search_id",
    @"areaName": @"area_name",
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

@implementation FHSuggestionListModelDataItemsBaseInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isSingle": @"is_single",
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

@implementation FHSuggestionListModelDataItemsHouseVideoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasVideo": @"has_video",
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

