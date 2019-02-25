//GENERATED CODE , DON'T EDIT
#import "FHDetailRelatedNeighborhoodResponseModel.h"
@implementation FHDetailRelatedNeighborhoodResponseModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailRelatedNeighborhoodResponseDataItemsImagesModel
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

@implementation FHDetailRelatedNeighborhoodResponseDataModel
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

@implementation FHDetailRelatedNeighborhoodResponseDataItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"displaySubtitle": @"display_subtitle",
    @"gaodeLat": @"gaode_lat",
    @"displayPrice": @"display_price",
    @"displayTitle": @"display_title",
    @"displayDescription": @"display_description",
    @"gaodeLng": @"gaode_lng",
    @"displayPricePerSqm": @"display_price_per_sqm",
    @"imprId": @"impr_id",
    @"displayBuiltYear": @"display_built_year",
    @"houseType": @"house_type",
    @"displayStatsInfo": @"display_stats_info",
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

@implementation FHDetailRelatedNeighborhoodResponseDataItemsBaseInfoMapModel
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

