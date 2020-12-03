//
//  FHHouseCardUtils.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseCardUtils.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHEnvContext.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "FHHouseNeighborhoodCell.h"
#import "FHSearchHouseModel.h"
#import "FHHousePlaceholderCell.h"
#import "FHHousePlaceholderViewModel.h"
#import "FHHouseSearchNewHouseViewModel.h"
#import "FHHouseSearchNewHouseCell.h"
#import "FHHouseSearchSecondHouseViewModel.h"
#import "FHHouseSearchSecondHouseCell.h"
#import "FHHouseSearchRentHouseViewModel.h"
#import "FHHouseListRentCell.h"
#import "FHHouseSubscribeViewModel.h"
#import "FHSuggestionSubscribCell.h"
#import "FHHouseNeighborAgencyViewModel.h"
#import "FHNeighbourhoodAgencyCardCell.h"
#import "FHHouseListRecommendTipCell.h"
#import "FHHouseGuessYouWantViewModel.h"
#import "FHRecommendSecondhandHouseTitleCell.h"
#import "FHHouseReserveAdviserViewModel.h"
#import "FHHousReserveAdviserCell.h"
#import "FHHouseFindHouseHelperViewModel.h"
#import "FHFindHouseHelperCell.h"
#import "FHHouseLynxViewModel.h"
#import "FHDynamicLynxCell.h"
#import "FHHouseRedirectTipViewModel.h"
#import "FHHouseListRedirectTipCell.h"

@implementation FHHouseCardUtils

//支持的Cell样式, key: viewModelClassName value: cellClassName
+ (NSDictionary *)supportCellStyleMap {
    if ([FHEnvContext isHouseListComponentEnable]) {
        return [self houseList_supportCellStyleMap];
    }
    
    return @{
        NSStringFromClass(FHHouseNeighborhoodCardViewModel.class): NSStringFromClass(FHHouseNeighborhoodCell.class)
    };
}

+ (id)getEntityFromModel:(id)model {
    if ([FHEnvContext isHouseListComponentEnable]) {
        return [self houseList_getEntityFromModel:model];
    }
    
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
        NSStringFromClass(FHHousePlaceholderStyle1ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle1Cell.class),
        NSStringFromClass(FHHousePlaceholderStyle2ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle2Cell.class),
        NSStringFromClass(FHHousePlaceholderStyle3ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle3Cell.class),
        NSStringFromClass(FHHouseSearchSecondHouseViewModel.class): NSStringFromClass(FHHouseSearchSecondHouseCell.class),
        NSStringFromClass(FHHouseSearchNewHouseViewModel.class): NSStringFromClass(FHHouseSearchNewHouseCell.class),
        NSStringFromClass(FHHouseNeighborhoodCardViewModel.class): NSStringFromClass(FHHouseNeighborhoodCell.class),
        NSStringFromClass(FHHouseSearchRentHouseViewModel.class): NSStringFromClass(FHHouseListRentCell.class),
        NSStringFromClass(FHHouseSubscribeViewModel.class): NSStringFromClass(FHSuggestionSubscribCell.class),
        NSStringFromClass(FHHouseNeighborAgencyViewModel.class): NSStringFromClass(FHNeighbourhoodAgencyCardCell.class),
        NSStringFromClass(FHHouseGuessYouWantTipViewModel.class): NSStringFromClass(FHHouseListRecommendTipCell.class),
        NSStringFromClass(FHHouseGuessYouWantContentViewModel.class): NSStringFromClass(FHRecommendSecondhandHouseTitleCell.class),
        NSStringFromClass(FHHouseReserveAdviserViewModel.class): NSStringFromClass(FHHousReserveAdviserCell.class),
        NSStringFromClass(FHHouseFindHouseHelperViewModel.class): NSStringFromClass(FHFindHouseHelperCell.class),
        NSStringFromClass(FHHouseLynxViewModel.class): NSStringFromClass(FHDynamicLynxCell.class),
        NSStringFromClass(FHHouseRedirectTipViewModel.class): NSStringFromClass(FHHouseListRedirectTipCell.class),
    };
}

+ (id)houseList_getEntityFromModel:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch (itemModel.cardType) {
            case FHSearchCardTypeNewHouse: {
                return [[FHHouseSearchNewHouseViewModel alloc] initWithModel:itemModel];
                break;
            }
            case FHSearchCardTypeSecondHouse: {
                return [[FHHouseSearchSecondHouseViewModel alloc] initWithModel:itemModel];
                break;
            }
            case FHSearchCardTypeNeighborhood: {
                return [[FHHouseNeighborhoodCardViewModel alloc] initWithModel:itemModel];
                break;
            }
            case FHSearchCardTypeRentHouse: {
                return [[FHHouseSearchRentHouseViewModel alloc] initWithModel:itemModel];
                break;
            }
            default:
                break;
        }
    } else if ([model isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        return [[FHHouseSubscribeViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
        return [[FHHouseNeighborAgencyViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHSearchGuessYouWantTipsModel class]]) {
        return [[FHHouseGuessYouWantTipViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHSearchGuessYouWantContentModel class]]) {
        return [[FHHouseGuessYouWantContentViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        return [[FHHouseRedirectTipViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHSearchFindHouseHelperModel class]]) {
        return [[FHHouseFindHouseHelperViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHDynamicLynxCellModel class]]) {
        return [[FHHouseLynxViewModel alloc] initWithModel:model];
    } else if ([model isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        return [[FHHouseReserveAdviserViewModel alloc] initWithModel:model];
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
