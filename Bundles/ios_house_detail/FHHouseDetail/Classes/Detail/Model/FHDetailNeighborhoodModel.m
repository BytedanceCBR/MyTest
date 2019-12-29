//
//  FHDetailNeighborhoodModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import "FHDetailNeighborhoodModel.h"
@implementation FHDetailNeighborhoodDataCoreInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailNeighborhoodModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailNeighborhoodDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"priceTrend": @"price_trend",
                           @"logPb": @"log_pb",
                           @"statsInfo": @"stats_info",
                           @"baseInfo": @"base_info",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"shareInfo": @"share_info",
                           @"totalSales": @"total_sales",
                           @"totalSalesCount": @"total_sales_count",
                           @"neighbordhoodStatus": @"neighbordhood_status",
                           @"imprId": @"impr_id",
                           @"abtestVersions": @"abtest_versions",
                           @"neighborhoodImage": @"neighborhood_image",
                           @"coreInfo": @"core_info",
                           @"neighborhoodVideo": @"neighborhood_video",
                           @"evaluationInfo": @"evaluation_info",
                           @"chooseAgencyList": @"choose_agency_list",
                           @"ugcSocialGroup":@"ugc_social_group",
                           @"recommendedRealtors": @"recommended_realtors",
                           @"recommendedRealtorsTitle": @"recommended_realtors_title",
                           @"highlightedRealtor": @"highlighted_realtor",
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

//@implementation FHDetailNeighborhoodDataBaseInfoModel
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"isSingle": @"is_single",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//@end

@implementation FHDetailNeighborhoodDataStatsInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"openUrl": @"open_url",
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

@implementation FHDetailNeighborhoodDataTotalSalesModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"userStatus": @"user_status",
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

@implementation FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"scoreLevel": @"score_level",
                           @"scoreName": @"score_name",
                           @"scoreValue": @"score_value",
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
@implementation FHDetailNeighborhoodNeighborhoodInfoSchoolInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"schoolType": @"school_type",
                           @"schoolId": @"school_id",
                           @"schoolName": @"school_name",
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

@implementation FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"totalScore": @"total_score",
                           @"detailUrl": @"detail_url",
                           @"subScores": @"sub_scores",
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

@implementation FHDetailNeighborhoodDataNeighborhoodInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"areaId": @"area_id",
                           @"groupId": @"group_id",
                           @"cityId": @"city_id",
                           @"areaName": @"area_name",
                           @"pricingPerSqmV": @"pricing_per_sqm_v",
                           @"districtId": @"district_id",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"gaodeLat": @"gaode_lat",
                           @"imprId": @"impr_id",
                           @"locationFullName": @"location_full_name",
                           @"districtName": @"district_name",
                           @"monthUp": @"month_up",
                           @"gaodeLng": @"gaode_lng",
                           @"houseVideo": @"house_video",
                           @"searchId": @"search_id",
                           @"gaodeImageUrl": @"gaode_image_url",
                           @"gaodeImage": @"gaode_image",
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

@implementation FHVideoHouseVideoVideoInfosModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"vHeight": @"v_height",
                           @"imageHeight": @"image_height",
                           @"vWidth": @"v_width",
                           @"imageWidth": @"image_width",
                           @"coverImageUrl": @"cover_image_url",
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

@implementation FHVideoHouseVideoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"videoInfos": @"video_infos",
                           @"infoSubTitle": @"info_sub_title",
                           @"infoTitle": @"info_title",
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

@implementation FHDetailNeighborhoodDataTotalSalesListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"agencyName": @"agency_name",
                           @"dataSource": @"data_source",
                           @"dealDate": @"deal_date",
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

@implementation FHDetailNeighborhoodDataNeighbordhoodStatusModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"neighborhoodSubStatus": @"neighborhood_sub_status",
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


