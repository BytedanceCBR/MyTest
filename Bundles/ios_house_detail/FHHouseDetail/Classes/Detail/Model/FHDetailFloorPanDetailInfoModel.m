//GENERATED CODE , DON'T EDIT
#import "FHDetailFloorPanDetailInfoModel.h"
@implementation FHDetailFloorPanDetailInfoDataImagesModel
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

@implementation FHDetailFloorPanDetailInfoDataContactModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"noticeDesc": @"notice_desc",
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

@implementation FHDetailFloorPanDetailInfoDataUserStatusModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"courtOpenSubStatus": @"court_open_sub_status",
    @"pricingSubStatus": @"pricing_sub_status",
    @"courtSubStatus": @"court_sub_status",
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

@implementation FHDetailFloorPanDetailInfoDataRecommendModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"roomCount": @"room_count",
    @"saleStatus": @"sale_status",
    @"pricingPerSqm": @"pricing_per_sqm",
    @"imprId": @"impr_id",
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

@implementation FHDetailFloorPanDetailInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailFloorPanDetailInfoDataBaseInfoModel
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

@implementation FHDetailFloorPanDetailInfoDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"userStatus": @"user_status",
    @"areaId": @"area_id",
    @"baseInfo": @"base_info",
    @"logPb": @"log_pb",
    @"saleStatus": @"sale_status",
    @"areaName": @"area_name",
    @"districtId": @"district_id",
    @"pricingPerSqm": @"pricing_per_sqm",
    @"districtName": @"district_name",
    @"courtId": @"court_id",
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

@implementation FHDetailFloorPanDetailInfoDataRecommendImagesModel
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

