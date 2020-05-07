//
//  FHRecommendCoutCell.h
//  FHHouseList
//
//  Created by xubinbin on 2020/5/6.
//

#import "FHDetailBaseCell.h"
#import "FHHouseListBaseItemModel.h"


@interface FHRecommendCoutCell : FHDetailBaseCell

- (void)refreshWithData:(bool)isFirst andLast:(BOOL)isLast;

@end

@interface FHRecommendCoutItem : JSONModel

@property(nonatomic, strong) FHHouseListBaseItemModel *item;

@end
