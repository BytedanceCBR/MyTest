
//
//  FHHouseNeighborModel.m
//  FHHouseBase
//
//  Created by 张静 on 2018/12/13.
//

#import "FHHouseNeighborModel.h"


//for implementation
@implementation  FHHouseNeighborDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"refreshTip": @"refresh_tip",
                           @"redirectTips": @"redirect_tips",
                           @"searchId": @"search_id",
                           @"houseListOpenUrl": @"house_list_open_url",
                           @"searchHistoryOpenUrl": @"search_history_open_url",
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

@implementation FHHouseNeighborItemHouseVideo

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasVideo": @"has_video"
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


@implementation  FHHouseNeighborDataItemsModel

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
                           @"houseVideo": @"house_video",
                           @"displayStatsInfo": @"display_stats_info",
                           @"baseInfoMap": @"base_info_map",
                           @"searchId": @"search_id",
                           @"dealStatus": @"deal_status",
                           @"dealOpenUrl": @"deal_open_url",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"baseInfo": @"base_info",
                           @"pricePerSqmNum": @"price_per_sqm_num",
                           @"pricePerSqmUnit": @"price_per_sqm_unit",
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


@implementation  FHHouseNeighborModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHHouseNeighborDataItemsBaseInfoMapModel

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

@implementation FHHouseNeighborDataItemsModel (RecommendReason)

-(BOOL)showRecommendReason
{
    return NO;
}

@end
