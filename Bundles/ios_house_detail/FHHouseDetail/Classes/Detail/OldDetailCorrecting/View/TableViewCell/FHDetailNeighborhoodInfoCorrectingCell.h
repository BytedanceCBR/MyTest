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

@class FHHouseDetailContactViewModel;
// 小区信息（二手房、租房）
@interface FHDetailNeighborhoodInfoCorrectingCell : FHDetailBaseCell<FHDetailScrollViewDidScrollProtocol>

@end

@interface FHDetailNeighborhoodInfoCorrectingModel : FHDetailBaseModel

// 两个数据-只需赋值一个即可
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, strong , nullable) FHRentDetailResponseDataNeighborhoodInfoModel *rent_neighborhoodInfo ;
@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;


@end

NS_ASSUME_NONNULL_END
