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
                           @"openUrl": @"open_url",
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

@implementation FHConfigDataAvailabilityModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
                           @"iconImage": @"icon_image",
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

@implementation FHConfigDataCitySwitchModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cityName": @"city_name",
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

@implementation FHConfigDataEntranceSwitchModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isPriceValuationShowHouseTrend": @"is_price_valuation_show_house_trend",
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
                           @"houseOpData": @"house_op_data",
                           @"entryInfo": @"entry_info",
                           @"currentCityId": @"current_city_id",
                           @"mapSearch": @"map_search",
                           @"hotCityList": @"hot_city_list",
                           @"currentCityName": @"current_city_name",
                           @"cityList": @"city_list",
                           @"reviewInfo": @"review_info",
                           @"cityStats": @"city_stats",
                           @"userPhone": @"user_phone",
                           @"cityAvailability" : @"city_availability",
                           @"citySwitch" : @"city_switch",
                           @"searchTabNeighborhoodFilter": @"search_tab_neighborhood_filter",
                           @"searchTabCourtFilter": @"search_tab_court_filter",
                           @"neighborhoodFilter": @"neighborhood_filter",
                           @"searchTabRentFilter": @"search_tab_rent_filter",
                           @"courtFilterOrder": @"court_filter_order",
                           @"searchTabFilter": @"search_tab_filter",
                           @"rentFilterOrder": @"rent_filter_order",
                           @"houseFilterOrder": @"house_filter_order",
                           @"neighborhoodFilterOrder": @"neighborhood_filter_order",
                           @"rentFilter": @"rent_filter",
                           @"courtFilter": @"court_filter",
                           @"diffCode": @"diff_code",
                           @"saleHistoryFilter": @"sale_history_filter",
                           @"entranceSwitch": @"entrance_switch",
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

@implementation  FHConfigDataHouseOpDataModel

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

@implementation  FHConfigDataHouseOpDataItemsModel

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enable = true; // 默认是开通的
    }
    return self;
}

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


