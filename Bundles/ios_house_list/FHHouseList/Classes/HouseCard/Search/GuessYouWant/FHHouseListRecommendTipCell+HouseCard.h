//
//  FHHouseListRecommendTipCell+HouseCard.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseListRecommendTipCell.h"
#import "FHHouseCardTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRecommendTipCell(HouseCard)<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

NS_ASSUME_NONNULL_END
