//
//  FHNewHouseDetailSalesSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"
#import "FHNewHouseDetailSalesCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailSalesSM : FHNewHouseDetailSectionModel

@property (nonatomic, strong) FHNewHouseDetailSalesCellModel *salesCellModel;

- (void)updateDetailModel:(FHDetailNewModel *)model contactViewModel:(FHHouseDetailContactViewModel *)contactViewModel;

@end

NS_ASSUME_NONNULL_END
