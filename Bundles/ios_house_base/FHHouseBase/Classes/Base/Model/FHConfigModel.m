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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
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
             @"logPb": @"log_pb",
             };
}

//+(NSDictionary *)modelContainerPropertyGenericClass
//{
//    return @{
//             @"options":[FHSearchFilterConfigOption class]
//             };
//}


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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return  @{
              @"cityId": @"city_id",
              @"iconUrl": @"icon_url",
              };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"isFLogin": @"is_f_login",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"backgroundColor": @"background_color",
             @"iconImage": @"icon_image",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"cityName": @"city_name",
             @"openUrl": @"open_url",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"isPriceValuationShowHouseTrend": @"is_price_valuation_show_house_trend",
             };
}

@end

@implementation FHConfigDataTabConfigModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHConfigDataUgcCategoryConfigModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"myJoinList": @"my_join_list",
                           @"nearbyList": @"nearby_list",
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

@implementation FHConfigCenterTabImageModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHConfigCenterTabModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"openUrl": @"open_url",
                           @"staticImage": @"static_image",
                           @"activationimage": @"activation_image",
                           @"logPb":@"log_pb",
                           @"tabId":@"tab_id"
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


@implementation FHRealtorEvaluatioinConfigModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"scoreTags": @"score_tags",
            @"goodTags": @"good_tags",
            @"badTags": @"bad_tags",
            @"goodPlaceholder": @"good_placeholder",
            @"badPlaceholder": @"bad_placeholder",
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

@implementation FHRealtorEvaluatioinTagModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation  FHConfigDataModel

+ (JSONKeyMapper*)keyMapper
{
//    NSDictionary *dict = @{
//                           @"houseTypeList": @"house_type_list",
//                           @"opData2": @"op_data_2",
//                           @"opData2list": @"op_data_2_list",
//                           @"opData": @"op_data",
//                           @"rentOpData": @"rent_op_data",
//                           @"mainPageBannerOpData": @"main_page_banner",
//                           @"houseOpData": @"house_op_data",
//                           @"entryInfo": @"entry_info",
//                           @"currentCityId": @"current_city_id",
//                           @"mapSearch": @"map_search",
//                           @"hotCityList": @"hot_city_list",
//                           @"currentCityName": @"current_city_name",
//                           @"cityList": @"city_list",
//                           @"reviewInfo": @"review_info",
//                           @"cityStats": @"city_stats",
//                           @"userPhone": @"user_phone",
//                           @"cityAvailability" : @"city_availability",
//                           @"citySwitch" : @"city_switch",
//                           @"searchTabNeighborhoodFilter": @"search_tab_neighborhood_filter",
//                           @"searchTabCourtFilter": @"search_tab_court_filter",
//                           @"neighborhoodFilter": @"neighborhood_filter",
//                           @"searchTabRentFilter": @"search_tab_rent_filter",
//                           @"courtFilterOrder": @"court_filter_order",
//                           @"searchTabFilter": @"search_tab_filter",
//                           @"rentFilterOrder": @"rent_filter_order",
//                           @"houseFilterOrder": @"house_filter_order",
//                           @"neighborhoodFilterOrder": @"neighborhood_filter_order",
//                           @"rentFilter": @"rent_filter",
//                           @"courtFilter": @"court_filter",
//                           @"diffCode": @"diff_code",
//                           @"saleHistoryFilter": @"sale_history_filter",
//                           @"rentBanner": @"rent_banner",
//                           @"entranceSwitch": @"entrance_switch",
//                           @"houseTypeDefault":@"house_type_default",
//                           @"jump2AdRecommend":@"jump_2_ad_recommend",
//                           @"ugcCitySwitch":@"ugc_city_switch",
//                           @"tabConfig": @"tab_config",
//                           @"ugcCategoryConfig": @"ugc_category_config",
//                           };
    NSDictionary *dict = [self modelCustomPropertyMapper];
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"houseTypeList": @"house_type_list",
             @"opData2": @"op_data_2",
             @"toolboxData":@"toolbox_data",
             @"mainPageTopOpData":@"main_page_top_op_data",
             @"opData2list": @"op_data_2_list",
             @"opData": @"op_data",
             @"houseOpData2": @"house_op_data_2",
             @"rentOpData": @"rent_op_data",
             @"mainPageBannerOpData": @"main_page_banner",
             @"houseListBanner": @"house_list_banner",
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
             @"rentBanner": @"rent_banner",
             @"entranceSwitch": @"entrance_switch",
             @"houseTypeDefault":@"house_type_default",
             @"jump2AdRecommend":@"jump_2_ad_recommend",
             @"ugcCitySwitch":@"ugc_city_switch",
             @"tabConfig": @"tab_config",
             @"opTab":@"op_tab",
             @"ugcCategoryConfig": @"ugc_category_config",
             @"realtorEvaluationConfig": @"realtor_evaluation",
             @"jumpPageOnStartup":@"jump_page_on_startup",
             @"tabWidget": @"tab_widget",
             @"channelType": @"channel_type",
             @"barConfig": @"bar_config"
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"opData2list":[FHConfigDataOpData2ListModel class],
             @"entryInfo":[FHConfigDataEntryInfoModel class],
             @"toolboxData":[FHConfigDataOpData2Model class],
             @"mainPageTopOpData":[FHConfigDataOpData2Model class],
             @"hotCityList":[FHConfigDataHotCityListModel class],
             @"cityList":[FHConfigDataCityListModel class],
             @"banners":[FHConfigDataBannersModel class],
             @"cityStats":[FHConfigDataCityStatsModel class],
             @"searchTabNeighborhoodFilter":[FHSearchFilterConfigItem class],
             @"rentFilterOrder":[FHSearchFilterConfigItem class],
             @"searchTabCourtFilter":[FHSearchFilterConfigItem class],
             @"neighborhoodFilter":[FHSearchFilterConfigItem class],
             @"searchTabRentFilter":[FHSearchFilterConfigItem class],
             @"filter":[FHSearchFilterConfigItem class],
             @"searchTabFilter":[FHSearchFilterConfigItem class],
             @"courtFilter":[FHSearchFilterConfigItem class],
             @"rentFilter":[FHSearchFilterConfigItem class],
             @"neighborhoodFilterOrder":[FHSearchFilterConfigItem class],
             @"saleHistoryFilter":[FHSearchFilterConfigItem class],
             @"courtFilterOrder":[FHSearchFilterConfigItem class],
             @"tabConfig":[FHConfigDataTabConfigModel class],             
             };
}


-(instancetype)initShadowWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSArray *keys = @[
                      @"op_data_2",
                      @"op_data_2_list",
                      @"toolbox_data",
                      @"main_page_top_op_data",
                      @"op_data",
                      @"rent_op_data",
                      @"main_page_banner",
                      @"house_op_data",
                      @"hot_city_list",
                      @"city_list",
                      @"review_info",
                      @"banners",
                      @"search_tab_neighborhood_filter",
                      @"rent_filter_order",
                      @"search_tab_court_filter",
                      @"neighborhood_filter",
                      @"search_tab_rent_filter",
                      @"filter",
                      @"search_tab_filter",
                      @"court_filter",
                      @"house_filter_order",
                      @"rent_filter",
                      @"neighborhood_filter_order",
                      @"court_filter_order",
                      @"sale_history_filter",
                      @"rent_banner"
                      ];
    for (NSString *key in keys) {
        [mdict removeObjectForKey:key];
    }
    self = [super initWithDictionary:mdict error:error];
    if(self){
        self.originDict = dict;
    }
    return self;
}

#define DICT_PROP_GET(className , propertyName , key) \
-(className *)propertyName {\
    if(!_##propertyName && _originDict){ \
        NSDictionary *data =_originDict[key]; \
        _##propertyName = [[className alloc]initWithDictionary:data error:nil]; \
    }\
    return _##propertyName;\
}

#define ARRAY_PROP_GET(className , propertyName , key) \
-(NSArray< className > *)propertyName { \
    if(!_##propertyName && _originDict){ \
        NSArray *jsons = _originDict[key]; \        
        if([jsons isKindOfClass:[NSArray class]]){ \
            NSMutableArray *list = [NSMutableArray new]; \
            for (NSDictionary *json in jsons) { \
                className *model = [[className alloc] initWithDictionary:json error:nil]; \
                if(model){ \
                    [list addObject:model]; \
                } \
            }\
            _##propertyName = list; \
        }\
    }\
    return _##propertyName; \
}


DICT_PROP_GET(FHConfigDataOpData2Model,opData2,@"op_data_2")
ARRAY_PROP_GET(FHConfigDataOpData2ListModel,opData2list,@"op_data_2_list")
DICT_PROP_GET(FHConfigDataOpData2Model,toolboxData,@"toolbox_data")
DICT_PROP_GET(FHConfigDataOpData2Model,mainPageTopOpData,@"main_page_top_op_data")
DICT_PROP_GET(FHConfigDataOpDataModel,opData,@"op_data")
DICT_PROP_GET(FHConfigDataOpDataModel,houseOpData2,@"house_op_data_2")
DICT_PROP_GET(FHConfigDataRentOpDataModel,rentOpData,@"rent_op_data")
DICT_PROP_GET(FHConfigDataMainPageBannerOpDataModel ,mainPageBannerOpData,@"main_page_banner")
DICT_PROP_GET(FHConfigDataMainPageBannerOpDataModel ,houseListBanner,@"house_list_banner")
DICT_PROP_GET(FHConfigDataOpData2Model ,houseOpData,@"house_op_data")
ARRAY_PROP_GET(FHConfigDataHotCityListModel, hotCityList,@"hot_city_list");
ARRAY_PROP_GET(FHConfigDataCityListModel ,cityList,@"city_list")
DICT_PROP_GET(FHConfigDataReviewInfoModel ,reviewInfo,@"review_info")
ARRAY_PROP_GET(FHConfigDataBannersModel , banners , @"banners")
ARRAY_PROP_GET(FHSearchFilterConfigItem,searchTabNeighborhoodFilter,@"search_tab_neighborhood_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,rentFilterOrder,@"rent_filter_order")
ARRAY_PROP_GET(FHSearchFilterConfigItem,searchTabCourtFilter,@"search_tab_court_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,neighborhoodFilter,@"neighborhood_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,searchTabRentFilter,@"search_tab_rent_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,filter,@"filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,searchTabFilter,@"search_tab_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,courtFilter,@"court_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,houseFilterOrder,@"house_filter_order")
ARRAY_PROP_GET(FHSearchFilterConfigItem,rentFilter,@"rent_filter")
ARRAY_PROP_GET(FHSearchFilterConfigItem,neighborhoodFilterOrder,@"neighborhood_filter_order")
ARRAY_PROP_GET(FHSearchFilterConfigItem,courtFilterOrder,@"court_filter_order")
ARRAY_PROP_GET(FHSearchFilterConfigItem,saleHistoryFilter,@"sale_history_filter")
DICT_PROP_GET(FHConfigDataRentBannerModel,rentBanner,@"rent_banner")


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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return  @{
              @"urlList": @"url_list",
              };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"opStyle": @"op_style",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"items":[FHConfigDataRentOpDataItemsModel class]
             };
}


@end

@implementation FHConfigDataMainPageBannerOpDataModel

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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
              @"opStyle": @"op_style",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"items":[FHConfigDataRentOpDataItemsModel class]
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"opStyle": @"op_style",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"items":[FHConfigDataHouseOpDataItemsModel class]
             };
}


@end


@implementation  FHConfigDataOpDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"opStyle": @"op_style",
                           @"iconRowNum":@"icon_row_num"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"opStyle": @"op_style",
             @"iconRowNum":@"icon_row_num"
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"items":[FHConfigDataOpDataItemsModel class]
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"logPb": @"log_pb",
             @"openUrl": @"open_url",
             @"backgroundColor": @"background_color",
             @"textColor": @"text_color",
             @"desc":@"description",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"image":[FHConfigDataOpDataItemsImageModel class]
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"centerLatitude": @"center_latitude",
             @"resizeLevel": @"resize_level",
             @"centerLongitude": @"center_longitude",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"urlList": @"url_list",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"logPb": @"log_pb",
             @"openUrl": @"open_url",
             @"descriptionStr": @"description",
             @"backgroundColor": @"background_color",
             @"textColor": @"text_color",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass

{
    return @{
             @"image":[FHConfigDataRentOpDataItemsImageModel class]
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"logPb": @"log_pb",
             @"openUrl": @"open_url",
             @"descriptionStr": @"description",
             @"backgroundColor": @"background_color",
             @"textColor": @"text_color",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass

{
    return @{
             @"image":[FHConfigDataRentOpDataItemsImageModel class]
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"urlList": @"url_list",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"opStyle": @"op_style",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass

{
    return @{
             @"items":[FHConfigDataOpData2ItemsModel class]
             };
}


@end

@implementation  FHConfigDataOpData2ListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"opDataList": @"op_data_list",
                           @"opData2Type": @"op_data_2_type",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"opDataList": @"op_data_list",
             @"opData2Type": @"op_data_2_type",
             };
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


#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"cityId": @"city_id",
             @"fullPinyin": @"full_pinyin",
             @"simplePinyin": @"simple_pinyin",
             };
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
                           @"addDescription":@"add_description",
                           @"tagImage":@"tag_image",
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"logPb": @"log_pb",
             @"openUrl": @"open_url",
             @"descriptionStr": @"description",
             @"backgroundColor": @"background_color",
             @"addDescription":@"add_description",
             @"tagImage":@"tag_image",
             @"textColor": @"text_color",
             };
}


+(NSDictionary *)modelContainerPropertyGenericClass

{
    return @{
             @"image":[FHConfigDataOpData2ItemsImageModel class],
             @"tagImage":[FHConfigDataOpData2ItemsImageModel class]
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"iconUrl": @"icon_url",
             @"entryId": @"entry_id",
             };
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"urlList": @"url_list",
             };
}

@end


@implementation FHConfigDataRentBannerModel
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"opStyle": @"op_style",
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass

{
    return @{
             @"items":[FHConfigDataRentBannerItemsModel class]
             };
}


@end

@implementation FHConfigDataRentBannerItemsImageModel
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"urlList": @"url_list",
             };
}

@end


@implementation FHConfigDataRentBannerItemsModel
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

#pragma mark - yymodel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"logPb": @"log_pb",
             @"openUrl": @"open_url",
             @"backgroundColor": @"background_color",
             @"textColor": @"text_color",
             };
}


+(NSDictionary *)modelContainerPropertyGenericClass

{
    return @{
             @"image":[FHConfigDataRentBannerItemsImageModel class]
             };
}


@end

@implementation FHConfigDataTabWidgetModel
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

@implementation FHConfigDataTabWidgetImageModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"imageType": @"image_type",
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

