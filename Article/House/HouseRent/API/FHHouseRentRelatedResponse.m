//
//  FHHouseRentRelatedResponse.m
//  Article
//
//  Created by leo on 2018/11/22.
//

#import "FHHouseRentRelatedResponse.h"
//for implementation
@implementation  FHHouseRentRelatedResponseDataItemsHouseImageTagModel

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


@implementation  FHHouseRentRelatedResponseDataItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"houseType": @"house_type",
                           @"imprId": @"impr_id",
                           @"searchId": @"search_id",
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


@implementation  FHHouseRentRelatedResponseDataItemsHouseImageModel

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


@implementation  FHHouseRentRelatedResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHHouseRentRelatedResponseDataItemsTagsModel

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


@implementation  FHHouseRentRelatedResponseDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
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
