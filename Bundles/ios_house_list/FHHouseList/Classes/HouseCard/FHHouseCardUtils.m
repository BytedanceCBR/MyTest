//
//  FHHouseCardUtils.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseCardUtils.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "FHHouseNeighborhoodCell.h"
#import "FHSearchHouseModel.h"
#import "FHHouseSecondCell.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHHouseNewCell.h"
#import "FHHouseNewCardViewModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

@implementation FHHouseCardUtils

//支持的Cell样式, key: viewModelClassName value: cellClassName
+ (NSDictionary *)supportCellStyleMap {
    return @{
        NSStringFromClass(FHHouseNeighborhoodCardViewModel.class): NSStringFromClass(FHHouseNeighborhoodCell.class),
        NSStringFromClass(FHHouseSecondCardViewModel.class): NSStringFromClass(FHHouseSecondCell.class),
        NSStringFromClass(FHHouseNewCardViewModel.class): NSStringFromClass(FHHouseNewCell.class),
    };
}

+ (id)getEntityFromModel:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch (itemModel.cardType) {
            case FHSearchCardTypeNeighborhood: {
                if (itemModel.cellStyles == 10) {
                    return [[FHHouseNeighborhoodCardViewModel alloc] initWithModel:itemModel];
                }
                break;
            }
            case FHSearchCardTypeSecondHouse:
                return [[FHHouseSecondCardViewModel alloc] initWithModel:itemModel];
            case FHSearchCardTypeNewHouse:
                return [[FHHouseNewCardViewModel alloc] initWithModel:itemModel];
            default:
                break;
        }
    } else if ([model isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseListBaseItemModel *itemModel = (FHHouseListBaseItemModel *)model;
        return [[FHHouseSecondCardViewModel alloc] initWithModel:itemModel];
//        switch (itemModel.cardType) {
//            case FHSearchCardTypeSecondHouse:
//                return [[FHHouseSecondCardViewModel alloc] initWithModel:itemModel];
//            default:
//                break;
//        }
    } else if ([model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        return [[FHHouseSecondCardViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHDetailRelatedNeighborhoodResponseDataItemsModel class]]) {
        return [[FHHouseSecondCardViewModel alloc] initWithModel:model];
    }
    
    return nil;
}


@end
