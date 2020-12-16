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

@property (nonatomic, assign) BOOL shouldShowSaleHouse; //bottomMargin 如果有在售房源为 5，否则为 10

@property(nonatomic,strong) FHNeighborhoodDetailFloorpanCellModel *floorpanCellModel;

- (void)updateWithDataModel:(FHDetailNeighborhoodSaleHouseInfoListModel *)model;

@end

NS_ASSUME_NONNULL_END
