//
//  FHDetailPriceRankCell.h
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailPriceRankCell : FHDetailBaseCell

@end

@interface FHDetailPriceRankModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailOldDataHousePricingRankModel *priceRank;

@end


NS_ASSUME_NONNULL_END
