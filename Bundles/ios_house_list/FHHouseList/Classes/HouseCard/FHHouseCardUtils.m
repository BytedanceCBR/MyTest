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
#import "FHHouseSearchSecondHouseViewModel.h"
#import "FHHouseSearchSecondHouseCell.h"
#import "FHHousePlaceholderCell.h"
#import "FHHousePlaceholderViewModel.h"

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
                if (itemModel.cellStyles == 10) {
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

+ (NSDictionary *)houseList_supportCellStyleMap {
    return @{
        NSStringFromClass(FHHouseSearchSecondHouseViewModel.class): NSStringFromClass(FHHouseSearchSecondHouseCell.class),
        NSStringFromClass(FHHousePlaceholderStyle1ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle1Cell.class),
        NSStringFromClass(FHHousePlaceholderStyle2ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle2Cell.class),
        NSStringFromClass(FHHousePlaceholderStyle3ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle3Cell.class),
    };
}

+ (id)houseList_getEntityFromModel:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch (itemModel.cardType) {
            case FHSearchCardTypeSecondHouse: {
                return [[FHHouseSearchSecondHouseViewModel alloc] initWithModel:itemModel];
                break;
            }
            default:
                break;
        }
    }
    
    return nil;
}

+ (NSArray *)getPlaceholderModelsWithStyle:(FHHousePlaceholderStyle)style count:(NSInteger)count {
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSInteger index = 0; index < count; index++) {
        id viewModel = nil;
        switch (style) {
            case FHHousePlaceholderStyle1:
                viewModel = [[FHHousePlaceholderStyle1ViewModel alloc] init];
                break;
            case FHHousePlaceholderStyle2:
                viewModel = [[FHHousePlaceholderStyle2ViewModel alloc] init];
                break;
            case FHHousePlaceholderStyle3:
                viewModel = [[FHHousePlaceholderStyle3ViewModel alloc] init];
                break;
            default:
                break;
        }
        
        if (viewModel) {
            [dataList addObject:viewModel];
        }
    }
    
    return dataList;
}

@end
