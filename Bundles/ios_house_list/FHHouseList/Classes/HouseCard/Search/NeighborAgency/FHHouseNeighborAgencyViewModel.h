//
//  FHHouseNeighborAgencyViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNeighborAgencyViewModelDelegate <FHHouseNewComponentViewModelDelegate>

- (UIViewController *)belongsVC;

@end

@interface FHHouseNeighborAgencyViewModel : FHHouseNewComponentViewModel

@end

NS_ASSUME_NONNULL_END
