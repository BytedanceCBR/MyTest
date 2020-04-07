//
//  FHDetailSalesCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailNewDiscountInfoItemModel;

@interface FHDetailSalesCell : FHDetailBaseCell

@end

@interface FHDetailSalesCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailNewDiscountInfoItemModel *> *discountInfo;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@end

NS_ASSUME_NONNULL_END
