//
//  FHNeighborhoodDetailHouseSaleSM.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleSM.h"

@implementation FHNeighborhoodDetailHouseSaleSM

-(void)updateWithDataModel:(FHDetailSameNeighborhoodHouseResponseDataModel *)model {
    self.houseSaleCellModel = [[FHNeighborhoodDetailHouseSaleCellModel alloc] init];
    self.houseSaleCellModel.neighborhoodSoldHouseData = model;
}

@end
