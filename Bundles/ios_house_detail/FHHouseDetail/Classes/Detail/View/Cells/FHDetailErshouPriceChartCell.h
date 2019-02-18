//
//  FHDetailErshouPriceChartCell.h
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailOldDataPriceTrendModel;

@interface FHDetailErshouPriceChartCell : FHDetailBaseCell

@end

@interface FHDetailErshouPriceTrendModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataPriceTrendModel *> *priceTrend;


@end
NS_ASSUME_NONNULL_END
