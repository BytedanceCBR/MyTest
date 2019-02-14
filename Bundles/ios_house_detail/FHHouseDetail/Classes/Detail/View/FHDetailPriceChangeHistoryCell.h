//
//  FHDetailPriceChangeHistoryCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailPriceChangeHistoryCell : FHDetailBaseCell

@end

@interface  FHDetailPriceChangeHistoryModel: FHDetailBaseModel

@property (nonatomic, strong , nullable) FHPriceChangeHistoryPriceChangeHistoryModel *priceChangeHistory;

@end

NS_ASSUME_NONNULL_END
