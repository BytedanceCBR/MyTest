//
//  FHNeighborhoodDetailHouseSaleSM.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailHouseSaleCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHouseSaleSM : FHNeighborhoodDetailSectionModel
@property(nonatomic,strong) FHNeighborhoodDetailHouseSaleCellModel *houseSaleCellModel;
- (void)updateWithDataModel:(FHDetailSameNeighborhoodHouseResponseDataModel *)model;
@end

NS_ASSUME_NONNULL_END
