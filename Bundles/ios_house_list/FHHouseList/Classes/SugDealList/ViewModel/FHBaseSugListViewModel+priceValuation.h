//
//  FHBaseSugListViewModel+priceValuation.h
//  FHHouseList
//
//  Created by 张静 on 2019/5/6.
//

#import "FHBaseSugListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBaseSugListViewModel (priceValuation)

- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
