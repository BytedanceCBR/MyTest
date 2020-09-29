//
//  FHNewHouseDetailBuildingsSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailBuildingsSM.h"

@implementation FHNewHouseDetailBuildingsSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    FHNewHouseDetailBuildingModel * building = [[FHNewHouseDetailBuildingModel alloc] init];
    building.buildingInfo = model.data.buildingInfo;
    self.buildingCellModel = building;
    self.items = [NSArray arrayWithObject:building];
}

@end
