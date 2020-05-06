//
//  FHRecommendCoutCell.h
//  FHHouseList
//
//  Created by xubinbin on 2020/5/6.
//

#import "FHDetailBaseCell.h"
#import "FHHouseListBaseItemModel.h"


@interface FHRecommendCoutCell : FHDetailBaseCell

@end

@interface FHRecommendCoutItem : JSONModel

@property(nonatomic, strong) FHHouseListBaseItemModel *item;

@end
