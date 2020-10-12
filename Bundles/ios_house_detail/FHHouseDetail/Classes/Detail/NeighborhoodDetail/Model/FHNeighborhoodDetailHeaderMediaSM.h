//
//  FHNeighborhoodDetailHeaderMediaSM.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailHeaderMediaCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHeaderMediaSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, strong) FHNeighborhoodDetailHeaderMediaModel *headerCellModel;

- (void)updatewithContactViewModel:(FHHouseDetailContactViewModel *)contactViewModel;

@end

NS_ASSUME_NONNULL_END
