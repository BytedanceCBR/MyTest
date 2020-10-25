//
//  FHNeighborhoodDetailRecommendSM.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailRecommendCell.h"
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailRecommendSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, strong) FHNeighborhoodDetailRecommendCellModel *recommendCellModel;

- (void)updateWithDataModel:(FHSearchHouseDataModel *)data;

@end

NS_ASSUME_NONNULL_END
