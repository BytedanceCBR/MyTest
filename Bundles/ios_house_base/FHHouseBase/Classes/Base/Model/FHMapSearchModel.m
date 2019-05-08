//
//  FHMapSearchModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchModel.h"

@implementation  FHMapSearchDataListLogPbModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"imprId": @"impr_id",
                           @"groupId": @"group_id",
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


@implementation  FHMapSearchDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"mapFindHouseOpenUrl": @"map_find_house_open_url",
                           @"searchId": @"search_id",
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


@implementation  FHMapSearchModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHMapSearchDataListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"centerLatitude": @"center_latitude",
                           @"centerLongitude": @"center_longitude",
                           @"pricePerSqm": @"price_per_sqm",
                           @"onSaleCount": @"on_sale_count",
                           @"houseListOpenUrl": @"house_list_open_url",
                           @"mapFindHouseOpenUrl": @"map_find_house_open_url",
                           @"nid":@"id",
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

