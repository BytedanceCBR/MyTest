//
//  FHNeighborhoodDetailHouseSaleSM.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHouseSaleSM : FHNeighborhoodDetailSectionModel


@property (nonatomic, copy) NSString *moreTitle;

@property (nonatomic, strong) FHDetailSameNeighborhoodHouseResponseDataModel *model;

- (void)updateWithDataModel:(FHDetailSameNeighborhoodHouseResponseDataModel *)model;
@end

NS_ASSUME_NONNULL_END
