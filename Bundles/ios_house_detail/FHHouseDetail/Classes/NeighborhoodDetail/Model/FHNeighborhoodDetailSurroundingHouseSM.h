//
//  FHNeighborhoodDetailSurroundingHouse.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/12/10.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSurroundingHouseSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, copy) NSString *moreTitle;

@property (nonatomic, copy) NSString *total;

@property (nonatomic, strong) FHDetailRelatedNeighborhoodResponseDataModel *model;

- (void)updateWithDataModel:(id)data;

@end

NS_ASSUME_NONNULL_END
