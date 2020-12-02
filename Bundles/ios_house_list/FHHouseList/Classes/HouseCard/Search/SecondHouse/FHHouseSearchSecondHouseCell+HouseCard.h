//
//  FHHouseSearchSecondHouseCell+HouseCard.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHHouseSearchSecondHouseCell.h"
#import "FHHouseCardTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSearchSecondHouseCell(HouseCard)<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

NS_ASSUME_NONNULL_END
