//
//  FHBuildingDetailModel.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailModel.h"

@implementation FHBuildingDetailRelatedFloorpanModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
                           @"id": @"id",
                           @"title": @"title",
                           @"facingDirection": @"facing_direction",
                           @"pricing": @"pricing",
                           @"squaremeter": @"squaremeter",
                           @"images": @"images",
                           @"tags": @"tags",
                           @"logPb": @"log_pb",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBuildingDetailRelatedFloorpanListModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
                           @"title": @"title",
                           @"list": @"list",
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
                           @"pointX": @"point_x",
                           @"pointY": @"point_y",
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
                           @"highlightedRealtor": @"highlighted_realtor",
                           @"buildingImage": @"building_image",
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

@implementation FHBuildingIndexModel

+ (instancetype)indexModelWithSaleStatus:(NSInteger)saleStatus withBuildingIndex:(NSInteger)buildingIndex {
    FHBuildingIndexModel *indexModel = [[FHBuildingIndexModel alloc] init];
    indexModel.saleStatus = saleStatus;
    indexModel.buildingIndex = buildingIndex;
    return indexModel;
}

- (BOOL)isEqual:(FHBuildingIndexModel *)object {
    return (self.buildingIndex == object.buildingIndex) && (self.saleStatus == object.saleStatus);
}

@end

@implementation FHBuildingSaleStatusModel



@end

@implementation FHBuildingLocationModel


@end

