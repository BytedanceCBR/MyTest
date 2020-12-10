//
//  FHNeighborhoodDetailHouseSaleSM.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleSM.h"
#import "FHHouseCardUtils.h"

@implementation FHNeighborhoodDetailHouseSaleSM

-(void)updateWithDataModel:(FHDetailSameNeighborhoodHouseResponseDataModel *)model {
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    for (id item in model.items) {
        id obj = [FHHouseCardUtils getEntityFromModel:item];
        if (obj) {
            [arrayM addObject:obj];
        }
    }
    self.items = arrayM.copy;
    self.moreTitle = [NSString stringWithFormat:@"查看在售%@套房源", model.total];
    self.model = model;
    
//    self.houseSaleCellModel = [[FHNeighborhoodDetailHouseSaleCellModel alloc] init];
//    self.houseSaleCellModel.neighborhoodSoldHouseData = model;
}

@end
