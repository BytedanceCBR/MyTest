//
//  FHNeighborhoodDetailHouseSaleCollectionCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHDetailBaseCell.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHouseSaleCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^didSelectItem)(NSInteger index);
@property (nonatomic, copy) void (^willShowItem)(NSInteger index);

@end

@interface FHNeighborhoodDetailHouseSaleItemCollectionCell : FHDetailBaseCollectionCell

@end
@interface FHNeighborhoodDetailHouseSaleMoreItemCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailHouseSaleCellModel : NSObject
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *neighborhoodSoldHouseData;
@end

@interface FHNeighborhoodDetailHouseSaleMoreItemModel : FHDetailBaseModel

@end

NS_ASSUME_NONNULL_END
