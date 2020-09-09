//
//  FHNewHouseDetailSalesCollectionCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailSalesCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNewHouseDetailSalesCellModel : NSObject

@property (nonatomic, strong, nullable) NSArray<FHDetailNewDiscountInfoItemModel *> *discountInfo;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end

NS_ASSUME_NONNULL_END
