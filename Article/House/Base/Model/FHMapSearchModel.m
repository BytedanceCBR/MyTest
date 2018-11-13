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
                           @"pricePerSqm": @"price_per_sqm",
                           @"centerLongitude": @"center_longitude",
                           @"onSaleCount": @"on_sale_count",
                           @"centerLatitude": @"center_latitude",
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

