//
//  FHNewHouseDetailSalesSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSalesSM.h"

@implementation FHNewHouseDetailSalesSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    FHNewHouseDetailSalesCellModel *salesCellModel = [[FHNewHouseDetailSalesCellModel alloc] init];
    //salesCellModel.contactViewModel = model.cont
    salesCellModel.discountInfo = model.data.discountInfo;
    self.salesCellModel = salesCellModel;
}

@end
