//
//  FHNeighborhoodDetailSurroundingNeighborCollectionCell.h
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/11.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSurroundingNeighborCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^houseShowBlock)(NSUInteger index);

@property (nonatomic, copy) void (^selectIndexBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
