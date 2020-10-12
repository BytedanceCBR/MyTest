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

@end


@interface FHNeighborhoodDetailHouseSaleCellModel : NSObject
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *neighborhoodSoldHouseData;
@end

NS_ASSUME_NONNULL_END
