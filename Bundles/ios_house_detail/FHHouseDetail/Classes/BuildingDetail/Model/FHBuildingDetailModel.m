//
//  FHBuildingDetailModel.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailModel.h"

@implementation FHBuildingDetailRelatedFloorpanListModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
                           @"buildingID": @"id",
                           @"name": @"name",
                           @"saleStatus": @"sale_status",
                           @"baseInfo": @"base_info",
                           @"relatedFloorplanList": @"related_floorplan",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBuildingDetailDataItemModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
                           @"buildingID": @"id",
                           @"name": @"name",
                           @"saleStatus": @"sale_status",
                           @"baseInfo": @"base_info",
                           @"relatedFloorplanList": @"related_floorplan",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBuildingDetailDataModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
                           @"buildingList": @"building_list",
                           @"associateInfo": @"associate_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBuildingDetailModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
