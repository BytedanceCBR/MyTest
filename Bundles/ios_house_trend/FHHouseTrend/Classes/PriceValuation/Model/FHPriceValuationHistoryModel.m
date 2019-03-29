//GENERATED CODE , DON'T EDIT
#import "FHPriceValuationHistoryModel.h"
@implementation FHPriceValuationHistoryDataHistoryHouseListHouseInfoImageInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
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

@implementation FHPriceValuationHistoryDataHistoryHouseListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"houseInfo": @"house_info",
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

@implementation FHPriceValuationHistoryDataHistoryHouseListHouseInfoImageInfoIconModel
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

@implementation FHPriceValuationHistoryModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHPriceValuationHistoryDataHistoryHouseListHouseInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"estimatePriceInt": @"estimate_price_int",
    @"stateDescStr": @"state_desc_str",
    @"stateInt": @"state_int",
    @"imageInfo": @"image_info",
    @"rateStr": @"rate_str",
    @"neiborhoodNameStr": @"neiborhood_name_str",
    @"houseInfoStr": @"house_info_str",
    @"averagePriceStr": @"average_price_str",
    @"houseInfoDict": @"house_info_dict",
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

@implementation FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"decorationType": @"decoration_type",
    @"totalFloor": @"total_floor",
    @"facingType": @"facing_type",
    @"buildingType": @"building_type",
    @"floorPlanBath": @"floor_plan_bath",
    @"floorPlanHall": @"floor_plan_hall",
    @"builtYear": @"built_year",
    @"estimateId": @"estimate_id",
    @"floorPlanRoom": @"floor_plan_room",
    @"neighborhoodId": @"neighborhood_id",
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

@implementation FHPriceValuationHistoryDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"historyHouseList": @"history_house_list",
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

