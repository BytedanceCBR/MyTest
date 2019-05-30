//
//  FHBaseSugListViewModel+dealList.h
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#import "FHBaseSugListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBaseSugListViewModel (dealList)

- (void)requestNeighborDealSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query searchType:(NSString *)searchType;

@end

NS_ASSUME_NONNULL_END
