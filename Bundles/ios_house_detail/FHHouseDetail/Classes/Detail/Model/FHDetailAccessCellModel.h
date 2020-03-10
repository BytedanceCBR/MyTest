//
//  FHDetailAccessCellModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailAccessCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataStrategyModel *strategy;

@end

NS_ASSUME_NONNULL_END
