//
//  FHHouseRentModel.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/22.
//

#import "FHHouseRentModel.h"

@implementation  FHHouseRentDataItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"houseType": @"house_type",
                           @"imprId": @"impr_id",
                           @"houseImageTag": @"house_image_tag",
                           @"houseImage": @"house_image",
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


@implementation  FHHouseRentDataItemsHouseImageModel

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


@implementation  FHHouseRentDataItemsHouseImageTagModel

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


@implementation  FHHouseRentModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHHouseRentDataItemsTagsModel

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


@implementation  FHHouseRentDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"refreshTip": @"refresh_tip",
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


