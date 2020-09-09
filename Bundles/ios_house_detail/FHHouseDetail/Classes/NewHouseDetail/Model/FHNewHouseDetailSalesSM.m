//
//  FHNewHouseDetailSalesSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSalesSM.h"

@implementation FHNewHouseDetailSalesSM

- (void)updateDetailModel:(FHDetailNewModel *)model contactViewModel:(nonnull FHHouseDetailContactViewModel *)contactViewModel{
    
    FHNewHouseDetailSalesCellModel *salesCellModel = [[FHNewHouseDetailSalesCellModel alloc] init];
    salesCellModel.contactViewModel = contactViewModel;
    salesCellModel.discountInfo = model.data.discountInfo;
    self.salesCellModel = salesCellModel;
}

@end
