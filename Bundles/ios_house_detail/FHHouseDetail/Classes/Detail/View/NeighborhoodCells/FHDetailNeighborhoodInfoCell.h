//
//  FHDetailNeighborhoodInfoCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRentModel.h"

NS_ASSUME_NONNULL_BEGIN

// 小区信息（二手房、租房）
@interface FHDetailNeighborhoodInfoCell : FHDetailBaseCell

@end

@interface FHDetailNeighborhoodInfoModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo ;

@end

NS_ASSUME_NONNULL_END
