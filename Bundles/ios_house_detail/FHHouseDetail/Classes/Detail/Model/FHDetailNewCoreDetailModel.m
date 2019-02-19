//GENERATED CODE , DON'T EDIT
#import "FHDetailNewCoreDetailModel.h"
@implementation FHDetailNewCoreDetailModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailNewCoreDetailDataDisclaimerModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"richText": @"rich_text",
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

@implementation FHDetailNewCoreDetailDataDisclaimerRichTextModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"highlightRange": @"highlight_range",
    @"linkUrl": @"link_url",
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

@implementation FHDetailNewCoreDetailDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"pricingPerSqm": @"pricing_per_sqm",
    @"powerWaterGasDesc": @"power_water_gas_desc",
    @"propertyType": @"property_type",
    @"propertyName": @"property_name",
    @"userStatus": @"user_status",
    @"saleAddress": @"sale_address",
    @"saleStatus": @"sale_status",
    @"developerName": @"developer_name",
    @"generalAddress": @"general_address",
    @"parkingNum": @"parking_num",
    @"openDate": @"open_date",
    @"plotRatio": @"plot_ratio",
    @"buildingDesc": @"building_desc",
    @"featureDesc": @"feature_desc",
    @"greenRatio": @"green_ratio",
    @"permitList": @"permit_list",
    @"circuitDesc": @"circuit_desc",
    @"propertyRight": @"property_right",
    @"buildingType": @"building_type",
    @"buildingCategory": @"building_category",
    @"deliveryDate": @"delivery_date",
    @"propertyPrice": @"property_price",
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

@implementation FHDetailNewCoreDetailDataUserStatusModel
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

@implementation FHDetailNewCoreDetailDataPermitListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"permitDate": @"permit_date",
    @"bindBuilding": @"bind_building",
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

