//
//  FHBrowsingHistoryCardUtils.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHBrowsingHistoryCardUtils.h"
#import "FHSearchHouseModel.h"
#import "FHBrowsingHistoryNeighborhoodCell.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "FHBrowsingHistorySecondCell.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHHouseNewCardViewModel.h"
#import "FHBrowsingHistoryNewCell.h"

@implementation FHBrowsingHistoryCardUtils

+ (NSDictionary *)supportCellStyleMap {
    return @{
        NSStringFromClass(FHHouseNeighborhoodCardViewModel.class): NSStringFromClass(FHBrowsingHistoryNeighborhoodCell.class),
        NSStringFromClass(FHHouseSecondCardViewModel.class): NSStringFromClass(FHBrowsingHistorySecondCell.class),
        NSStringFromClass(FHHouseNewCardViewModel.class): NSStringFromClass(FHBrowsingHistoryNewCell.class),
    };
}

+ (id)getEntityFromModel:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch (itemModel.cardType) {
            case FHSearchCardTypeNeighborhood:
                return [[FHHouseNeighborhoodCardViewModel alloc] initWithModel:itemModel];
            case FHSearchCardTypeSecondHouse:
                return [[FHHouseSecondCardViewModel alloc] initWithModel:itemModel];
            case FHSearchCardTypeNewHouse:
                return [[FHHouseNewCardViewModel alloc] initWithModel:itemModel];
            default:
                break;
        }
    }
    
    return nil;
}


@end
