//
//  FHDetailNeighborhoodHouseCorrectingModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/2/24.
//

#import "FHDetailBaseModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHRentSameNeighborhoodResponse.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodHouseSaleModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *neighborhoodSoldHouseData;
@end

@interface FHDetailNeighborhoodHouseRentModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *sameNeighborhoodRentHouseData;
@end

NS_ASSUME_NONNULL_END
