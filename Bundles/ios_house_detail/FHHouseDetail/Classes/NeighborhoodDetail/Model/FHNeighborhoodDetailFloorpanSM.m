//
//  FHNeighborhoodDetailFloorpanSM.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/14.
//

#import "FHNeighborhoodDetailFloorpanSM.h"

@implementation FHNeighborhoodDetailFloorpanSM


-(void)updateWithDataModel:(FHDetailNeighborhoodSaleHouseInfoListModel *)model{
    self.floorpanCellModel = [[FHNeighborhoodDetailFloorpanCellModel alloc] init];
    self.floorpanCellModel.saleHouseInfoModel = model;
}

@end
