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

-(void)addHouseShowLog;

@end

@interface FHFeedHouseItemCellView : ExploreCellViewBase

@property (nonatomic, strong) ExploreOrderedData *orderedData;

-(void)addHouseShowLog;

@end

NS_ASSUME_NONNULL_END
