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

@implementation FHHouseCardUtils

//支持的Cell样式, key: viewModelClassName value: cellClassName
+ (NSDictionary *)supportCellStyleMap {
    return @{
        NSStringFromClass(FHHouseNeighborhoodCardViewModel.class): NSStringFromClass(FHHouseNeighborhoodCell.class)
    };
}

+ (id)getEntityFromModel:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch (itemModel.cardType) {
            case FHSearchCardTypeNeighborhood: {
                if (itemModel.cellStyle == 10) {
                    return [[FHHouseNeighborhoodCardViewModel alloc] initWithModel:itemModel];
                }
                break;
            }
            default:
                break;
        }
    }
    
    return nil;
}


@end
