//
//  FHHouseReserveAdviserViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseReserveAdviserViewModelDelegate <FHHouseNewComponentViewModelDelegate>

- (NSMutableDictionary *)belongSubscribeCache;

- (UIViewController *)belongsVC;

- (UITableView *)belongTableView;

@end

@interface FHHouseReserveAdviserViewModel : FHHouseNewComponentViewModel

@end

NS_ASSUME_NONNULL_END
