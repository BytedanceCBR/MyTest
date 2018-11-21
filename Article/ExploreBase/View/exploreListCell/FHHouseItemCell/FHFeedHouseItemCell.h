//
//  FHFeedHouseItemCell.h
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "ExploreCellBase.h"
#import "ExploreCellViewBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedHouseItemCell : ExploreCellBase


@end

@interface FHFeedHouseItemCellView : ExploreCellViewBase

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end

NS_ASSUME_NONNULL_END
