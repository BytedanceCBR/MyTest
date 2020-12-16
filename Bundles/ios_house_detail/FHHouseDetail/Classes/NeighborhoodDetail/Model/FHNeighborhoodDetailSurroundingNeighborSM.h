//
//  FHNeighborhoodDetailSurroundingNeighborSM.h
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/11.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSurroundingNeighborSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, copy) NSString *moreTitle;

@property (nonatomic, strong) FHDetailRelatedNeighborhoodResponseDataModel *model;

- (void)updateWithDataModel:(FHDetailRelatedNeighborhoodResponseDataModel *)data;

@end

NS_ASSUME_NONNULL_END
