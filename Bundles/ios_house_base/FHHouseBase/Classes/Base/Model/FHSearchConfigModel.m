//
//  FHSearchConfigModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/28.
//

#import "FHSearchConfigModel.h"


//for implementation
@implementation  FHSearchConfigRentFilterOrderOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"rankType": @"rank_type",
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigCourtFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigSearchTabFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigNeighborhoodFilterOrderOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"rankType": @"rank_type",
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigCourtFilterOrderModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigCourtFilterOrderOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigCourtFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigCourtFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSearchTabNeighborhoodFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSaleHistoryFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigNeighborhoodFilterOrderOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigNeighborhoodFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSearchTabCourtFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigHouseFilterOrderOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"rankType": @"rank_type",
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSearchTabNeighborhoodFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigCourtFilterOrderOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"rankType": @"rank_type",
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
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
                           @"saleHistoryFilter": @"sale_history_filter",
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


@implementation  FHSearchConfigSearchTabCourtFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSearchTabCourtFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigSearchTabRentFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigHouseFilterOrderOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigRentFilterOrderModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigRentFilterOrderOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigNeighborhoodFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigSaleHistoryFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSearchTabRentFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigHouseFilterOrderModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigSearchTabNeighborhoodFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigRentFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigRentFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigSearchTabFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigSearchTabRentFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigSaleHistoryFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigNeighborhoodFilterOrderModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigNeighborhoodFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigSearchTabFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
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


@implementation  FHSearchConfigFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigRentFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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



