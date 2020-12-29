//
//  FHListBaseCell+HouseCard.h
//  ABRInterface
//
//  Created by bytedance on 2020/12/14.
//

#import "FHListBaseCell.h"
#import "FHHouseCardTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHListBaseCell(HouseCard)<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

NS_ASSUME_NONNULL_END
