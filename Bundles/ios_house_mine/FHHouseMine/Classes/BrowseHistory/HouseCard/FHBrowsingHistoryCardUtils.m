//
//  FHBrowsingHistoryCardUtils.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHBrowsingHistoryCardUtils.h"
#import "FHSearchHouseModel.h"
#import "FHBrowsingHistoryNeighborhoodCell.h"
#import "FHBrowsingHistoryNeighborhoodCardViewModel.h"
#import "FHBrowsingHistorySecondCell.h"
#import "FHHouseSecondCardViewModel.h"

@implementation FHBrowsingHistoryCardUtils

+ (NSDictionary *)supportCellStyleMap {
    return @{
        NSStringFromClass(FHBrowsingHistoryNeighborhoodCardViewModel.class): NSStringFromClass(FHBrowsingHistoryNeighborhoodCell.class),
        NSStringFromClass(FHHouseSecondCardViewModel.class): NSStringFromClass(FHBrowsingHistorySecondCell.class),
    };
}

+ (id)getEntityFromModel:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch (itemModel.cardType) {
            case FHSearchCardTypeNeighborhood:
                return [[FHBrowsingHistoryNeighborhoodCardViewModel alloc] initWithModel:itemModel];
            case FHSearchCardTypeSecondHouse:
                return [[FHHouseSecondCardViewModel alloc] initWithModel:itemModel];
            default:
                break;
        }
    }
    
    return nil;
}


@end
