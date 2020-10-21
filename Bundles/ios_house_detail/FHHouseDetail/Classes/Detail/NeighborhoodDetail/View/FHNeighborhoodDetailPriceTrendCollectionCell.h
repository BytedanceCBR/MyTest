//
//  FHNeighborhoodDetailPriceTrendCollectionCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/15.
//

#import "FHDetailBaseCell.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailPriceTrendCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, copy) void (^addClickPriceTrendLogBlock)(void);

@end

@interface FHNeighborhoodDetailPriceTrendCellModel : NSObject<IGListDiffable>
@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
@end

NS_ASSUME_NONNULL_END
