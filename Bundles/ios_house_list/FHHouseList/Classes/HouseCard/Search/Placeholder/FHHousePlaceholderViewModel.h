//
//  FHHousePlaceholderViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardCellViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHousePlaceholderStyle1ViewModel : FHHouseNewComponentViewModel<FHHouseCardCellViewModelProtocol>

@end

@interface FHHousePlaceholderStyle2ViewModel : FHHouseNewComponentViewModel<FHHouseCardCellViewModelProtocol>

- (CGFloat)topOffset;

@end

@interface FHHousePlaceholderStyle3ViewModel : FHHouseNewComponentViewModel<FHHouseCardCellViewModelProtocol>


@end

NS_ASSUME_NONNULL_END
