//
//  FHConfigModel.m
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "FHConfigModel.h"

@implementation  FHConfigModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHConfigDataCityStatsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"mapOpenUrl": @"map_open_url",
                           @"cityDetailDesc": @"city_detail_desc",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"addedNumTodayUnit": @"added_num_today_unit",
                           @"addedNumTodayDesc": @"added_num_today_desc",
                           @"cityTitleDesc": @"city_title_desc",
                           @"cityPriceHint": @"city_price_hint",
                           @"pricingPerSqmDesc": @"pricing_per_sqm_desc",
                           @"cityName": @"city_name",
                           @"houseType": @"house_type",
                           @"addedNumToday": @"added_num_today",
                           @"monthUp": @"month_up",
                           @"pricingPerSqmUnit": @"pricing_per_sqm_unit",
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

@implementation  FHConfigDataHotCityListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cityId": @"city_id",
                           @"iconUrl": @"icon_url",
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


@implementation  FHConfigDataReviewInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isFLogin": @"is_f_login",
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


@implementation  FHConfigDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"houseTypeList": @"house_type_list",
                           @"opData2": @"op_data_2",
                           @"opData": @"op_data",
                           @"rentOpData": @"rent_op_data",
                           @"entryInfo": @"entry_info",
                           @"currentCityId": @"current_city_id",
                           @"mapSearch": @"map_search",
                           @"hotCityList": @"hot_city_list",
                           @"currentCityName": @"current_city_name",
                           @"cityList": @"city_list",
                           @"reviewInfo": @"review_info",
                           @"cityStats": @"city_stats",
                           @"userPhone": @"user_phone",
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


@implementation  FHConfigDataOpData2ItemsImageModel

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


@implementation  FHConfigDataRentOpDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"opStyle": @"op_style",
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


@implementation  FHConfigDataOpDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"opStyle": @"op_style",
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


@implementation  FHConfigDataOpDataItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"openUrl": @"open_url",
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


@implementation  FHConfigDataMapSearchModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"centerLatitude": @"center_latitude",
                           @"resizeLevel": @"resize_level",
                           @"centerLongitude": @"center_longitude",
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



@implementation  FHConfigDataRentOpDataItemsImageModel

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


@implementation  FHConfigDataRentOpDataItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"openUrl": @"open_url",
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


@implementation  FHConfigDataBannersImageModel

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


@implementation  FHConfigDataOpData2Model

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"opStyle": @"op_style",
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


@implementation  FHConfigDataCityListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cityId": @"city_id",
                           @"fullPinyin": @"full_pinyin",
                           @"simplePinyin": @"simple_pinyin",
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


@implementation  FHConfigDataBannersModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHConfigDataOpData2ItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"openUrl": @"open_url",
                           @"descriptionStr": @"description",
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


@implementation  FHConfigDataEntryInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"iconUrl": @"icon_url",
                           @"entryId": @"entry_id",
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


@implementation  FHConfigDataOpDataItemsImageModel

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

