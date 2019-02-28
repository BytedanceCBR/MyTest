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

// 两个数据-只需赋值一个即可
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, strong , nullable) FHRentDetailResponseDataNeighborhoodInfoModel *rent_neighborhoodInfo ;

@end

NS_ASSUME_NONNULL_END
