//
//  FHDetailPriceTrendCellModel.h
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailPriceTrendModel;
@interface FHDetailPriceTrendCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;

@end

NS_ASSUME_NONNULL_END
