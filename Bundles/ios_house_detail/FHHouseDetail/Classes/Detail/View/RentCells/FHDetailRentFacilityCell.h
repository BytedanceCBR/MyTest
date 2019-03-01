//
//  FHDetailRentFacilityCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailRentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailRentFacilityCell : FHDetailBaseCell

@end

// FHDetailRentFacilityModel
@interface FHDetailRentFacilityModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHRentDetailResponseDataFacilitiesModel> *facilities;

@end

NS_ASSUME_NONNULL_END
