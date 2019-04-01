//GENERATED CODE , DON'T EDIT
#import "FHCityMarketDetailResponseModel.h"
@implementation FHCityMarketDetailResponseDataSummaryItemListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"showArrow": @"show_arrow",
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

@implementation FHCityMarketDetailResponseDataHotListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"itemType": @"item_type",
    @"moreBtnText": @"more_btn_text",
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

@implementation FHCityMarketDetailResponseDataMarketTrendListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"updateTime": @"update_time",
    @"dataSource": @"data_source",
    @"districtMarketInfoList": @"district_market_info_list",
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

@implementation FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTimeLineModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"timeStamp": @"time_stamp",
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

@implementation FHCityMarketDetailResponseDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"pricePerSqmUnit": @"price_per_sqm_unit",
    @"dataSource": @"data_source",
    @"bottomOpenUrl": @"bottom_open_url",
    @"specialOldHouseList": @"special_old_house_list",
    @"marketTrendList": @"market_trend_list",
    @"summaryItemList": @"summary_item_list",
    @"pricePerSqm": @"price_per_sqm",
    @"hotList": @"hot_list",
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

@implementation FHCityMarketDetailResponseModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"locationName": @"location_name",
    @"timeLine": @"time_line",
    @"trendLines": @"trend_lines",
    @"dottedLineColor": @"dotted_line_color",
    @"locationId": @"location_id",
    @"locationType": @"location_type",
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

@implementation FHCityMarketDetailResponseDataHotListItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"averagePrice": @"average_price",
    @"neighborhoodName": @"neighborhood_name",
    @"openUrl": @"open_url",
    @"houseCount": @"house_count",
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

@implementation FHCityMarketDetailResponseDataSpecialOldHouseListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"moreBtnText": @"more_btn_text",
    @"openUrl": @"open_url",
    @"rankOpenUrl": @"rank_open_url",
    @"questionText": @"question_text",
    @"answerText": @"answer_text",
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

@implementation FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"shortDesc": @"short_desc",
    @"valueUnit": @"value_unit",
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

