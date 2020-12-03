//
//  FHSuggestionSubscribCell+HouseCard.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHSuggestionSubscribCell.h"
#import "FHHouseCardTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionSubscribCell(HouseCard)<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

NS_ASSUME_NONNULL_END
