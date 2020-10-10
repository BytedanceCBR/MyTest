//
//  FHNeighborhoodDetailCoreInfoSM.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailHeaderTitleCollectionCell.h"
#import "FHNeighborhoodDetailSubMessageCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailCoreInfoSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, strong) FHNeighborhoodDetailHeaderTitleModel *titleCellModel;
@property (nonatomic, strong) FHNeighborhoodDetailSubMessageModel *subMessageModel;

@end

NS_ASSUME_NONNULL_END
