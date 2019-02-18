//
//  FHDetailPriceTrendCellModel.h
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHDetailPriceTrendCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmV;
@end

NS_ASSUME_NONNULL_END
