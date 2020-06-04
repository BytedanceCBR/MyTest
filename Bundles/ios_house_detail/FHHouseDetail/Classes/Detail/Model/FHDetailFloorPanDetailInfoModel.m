//GENERATED CODE , DON'T EDIT
#import "FHDetailFloorPanDetailInfoModel.h"

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

@implementation FHDetailFloorPanDetailInfoDataRecommendModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"roomCount": @"room_count",
    @"saleStatus": @"sale_status",
    @"pricingPerSqm": @"pricing_per_sqm",
    @"imprId": @"impr_id",
    @"saleStatus": @"sale_status",
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

@implementation FHFloorPanDetailInfoModelBaseExtraModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFloorPanDetailInfoModelPriceConsultModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFloorPanDetailInfoModelBaseExtraAddressGaodeImgModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"latRatio": @"lat_ratio",
    @"lngRatio": @"lng_ratio",
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

@implementation FHFloorPanDetailInfoModelBaseExtraAddressModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"gaodeLat": @"gaode_lat",
    @"gaodeImg": @"gaode_img",
    @"gaodeImgUrl": @"gaode_img_url",
    @"gaodeLng": @"gaode_lng",
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

@implementation FHFloorPanDetailInfoModelBaseExtraCourtModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailFloorPanDetailInfoDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"areaId": @"area_id",
    @"baseInfo": @"base_info",
    @"logPb": @"log_pb",
    @"facingDirection": @"facing_direction",
    @"saleStatus": @"sale_status",
    @"areaName": @"area_name",
    @"districtId": @"district_id",
    @"pricingPerSqm": @"pricing_per_sqm",
    @"districtName": @"district_name",
    @"courtId": @"court_id",
    @"userStatus": @"user_status",
    @"highlightedRealtor": @"highlighted_realtor",
    @"chooseAgencyList": @"choose_agency_list",
    @"saleStatus": @"sale_status",
    @"highlightedRealtorAssociateInfo":@"highlighted_realtor_associate_info",
    @"displayPrice": @"display_price",
    @"imageDictList": @"house_image_dict_list",
    @"imageAssociateInfo" : @"image_associate_info",
    @"discountInfo": @"discount_info",
    @"priceConsult": @"price_consult",
    @"baseExtra": @"base_extra"
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

