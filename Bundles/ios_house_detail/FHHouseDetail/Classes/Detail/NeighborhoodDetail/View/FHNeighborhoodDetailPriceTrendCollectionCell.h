//
//  FHNeighborhoodDetailPriceTrendCollectionCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/15.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailPriceTrendCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^addClickPriceTrendLogBlock)(void);

@end

@interface FHNeighborhoodDetailPriceTrendCellModel : NSObject
@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
@end

NS_ASSUME_NONNULL_END
