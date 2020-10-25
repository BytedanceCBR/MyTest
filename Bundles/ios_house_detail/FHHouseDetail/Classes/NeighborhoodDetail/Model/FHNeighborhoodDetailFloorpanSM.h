//
//  FHNeighborhoodDetailFloorpanSM.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/14.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailFloorpanCollectionCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailFloorpanSM : FHNeighborhoodDetailSectionModel

@property(nonatomic,strong) FHNeighborhoodDetailFloorpanCellModel *floorpanCellModel;
- (void)updateWithDataModel:(FHDetailNeighborhoodSaleHouseInfoListModel *)model;
@end

NS_ASSUME_NONNULL_END
