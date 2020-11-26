//
//  FHBrowsingHistoryNeighborhoodCardViewModel.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseNeighborhoodCardViewModel.h"
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBrowsingHistoryNeighborhoodCardViewModel : FHHouseNeighborhoodCardViewModel

@property (nonatomic, assign, readonly) BOOL isOffShelf;

@property (nonatomic, strong) FHSearchHouseItemModel *model;

@end

NS_ASSUME_NONNULL_END
