//
//  FHDetailOldModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import "FHDetailOldModel.h"
@implementation FHDetailOldDataHousePricingRankModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"buySuggestion": @"buy_suggestion",
                           @"analyseDetail": @"analyse_detail",
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

@implementation FHDetailOldDataCoreInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataUserStatusModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"pricingSubStauts": @"pricing_sub_stauts",
                           @"houseSubStatus": @"house_sub_status",
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

@implementation FHDetailOldDataContactModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"businessLicense": @"business_license",
                           @"realtorName": @"realtor_name",
                           @"homePage": @"home_page",
                           @"realtorId": @"realtor_id",
                           @"agencyId": @"agency_id",
                           @"agencyName": @"agency_name",
                           @"avatarUrl": @"avatar_url",
                           @"showRealtorinfo": @"show_realtorinfo",
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

@implementation FHDetailOldDataNeighborhoodInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"areaId": @"area_id",
                           @"groupId": @"group_id",
                           @"cityId": @"city_id",
                           @"areaName": @"area_name",
                           @"pricingPerSqmV": @"pricing_per_sqm_v",
                           @"districtId": @"district_id",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"gaodeLat": @"gaode_lat",
                           @"imprId": @"impr_id",
                           @"districtName": @"district_name",
                           @"monthUp": @"month_up",
                           @"gaodeLng": @"gaode_lng",
                           @"searchId": @"search_id",
                           @"gaodeImageUrl": @"gaode_image_url",
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

@implementation FHDetailOldDataHousePriceRangeModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"curPrice": @"cur_price",
                           @"priceMin": @"price_min",
                           @"priceMax": @"price_max",
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

@implementation FHDetailOldDataPriceTrendValuesModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"timeStr": @"time_str",
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

@implementation FHDetailOldDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"priceTrend": @"price_trend",
                           @"userStatus": @"user_status",
                           @"baseInfo": @"base_info",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"logPb": @"log_pb",
                           @"houseImage": @"house_image",
                           @"shareInfo": @"share_info",
                           @"priceChangeHistory": @"price_change_history",
                           @"pricingPerSqmV": @"pricing_per_sqm_v",
                           @"housePriceRange": @"house_price_range",
                           @"imprId": @"impr_id",
                           @"housePricingRank": @"house_pricing_rank",
                           @"abtestVersions": @"abtest_versions",
                           @"houseOverreview": @"house_overreview",
                           @"uploadAt": @"upload_at",
                           @"coreInfo": @"core_info",
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

@implementation FHDetailOldDataHousePricingRankBuySuggestionModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailOldDataPriceTrendModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataBaseInfoModel
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

@implementation FHDetailOldDataHouseOverreviewListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataHouseOverreviewModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"reportUrl": @"report_url",
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

@implementation FHDetailOldModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

// MARK 自定义类型

