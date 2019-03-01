//
//  FHNewHouseItemModel.m
//  AFgzipRequestSerializer
//
//  Created by 张静 on 2018/11/21.
//

#import "FHNewHouseItemModel.h"

@implementation  FHNewHouseItemCoreInfoProperyTypeModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
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

@implementation  FHNewHouseItemCoreInfoSaleStatusModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
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


@implementation  FHNewHouseItemCoreInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"courtAddress": @"court_address",
                           @"saleStatus": @"sale_status",
                           @"properyType": @"propery_type",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"gaodeLng": @"gaode_lng",
                           @"gaodeLat": @"gaode_lat",
                           @"constructionOpendate": @"construction_opendate",
                           @"aliasName": @"alias_name",
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


@implementation  FHNewHouseItemModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"displayTitle": @"display_title",
                           @"displayDescription": @"display_description",
                           @"displayPricePerSqm": @"display_price_per_sqm",
                           @"imprId": @"impr_id",
                           @"searchId": @"search_id",
                           @"groupId": @"group_id",
                           @"houseId": @"id",
                           @"houseType": @"house_type",
                           @"coreInfo": @"core_info",
                           @"logPb": @"log_pb",
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

@implementation  FHNewHouseListDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"refreshTip": @"refresh_tip",
                           @"redirectTips": @"redirect_tips",
                           @"searchId": @"search_id",
                           @"mapFindHouseOpenUrl": @"map_find_house_open_url",
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

@implementation  FHNewHouseListResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end



