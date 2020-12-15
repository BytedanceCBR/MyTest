//
//  FHHouseCardUtils.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseCardUtils.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHEnvContext.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHHouseCardCellViewModelProtocol.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "FHHouseNeighborhoodCell.h"
#import "FHSearchHouseModel.h"
#import "FHHousePlaceholderCell.h"
#import "FHHousePlaceholderViewModel.h"
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
#import "FHHouseSecondCell.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHHouseNewCell.h"
#import "FHHouseNewCardViewModel.h"
#import "FHHouseNoResultViewModel.h"
#import "FHHouseNoResultCell.h"

@implementation FHHouseCardUtils

//支持的Cell样式, key: viewModelClassName value: cellClassName
+ (NSDictionary *)supportCellStyleMap {
    if ([FHEnvContext isHouseListComponentEnable]) {
        return @{
            NSStringFromClass(FHHousePlaceholderStyle1ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle1Cell.class),
            NSStringFromClass(FHHousePlaceholderStyle2ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle2Cell.class),
            NSStringFromClass(FHHousePlaceholderStyle3ViewModel.class): NSStringFromClass(FHHousePlaceholderStyle3Cell.class),
            NSStringFromClass(FHHouseSecondCardViewModel.class): NSStringFromClass(FHHouseSecondCell.class),
            NSStringFromClass(FHHouseNewCardViewModel.class): NSStringFromClass(FHHouseNewCell.class),
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
            NSStringFromClass(FHHouseNoResultViewModel.class): NSStringFromClass(FHHouseNoResultCell.class),
        };
    }
    
    return @{
        NSStringFromClass(FHHouseNeighborhoodCardViewModel.class): NSStringFromClass(FHHouseNeighborhoodCell.class),
        NSStringFromClass(FHHouseSecondCardViewModel.class): NSStringFromClass(FHHouseSecondCell.class),
        NSStringFromClass(FHHouseNewCardViewModel.class): NSStringFromClass(FHHouseNewCell.class),
    };
}

+ (id)getEntityFromModel:(id)model {
    if ([FHEnvContext isHouseListComponentEnable]) {
        if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
            switch ([itemModel.houseType integerValue]) { //有些接口数据没有返回cardType, 这里用houseType保险点
                case FHSearchCardTypeNewHouse: {
                    return [[FHHouseNewCardViewModel alloc] initWithModel:itemModel];
                    break;
                }
                case FHSearchCardTypeSecondHouse: {
                    return [[FHHouseSecondCardViewModel alloc] initWithModel:itemModel];
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
    
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)model;
        switch ([itemModel.houseType integerValue]) {//有些接口数据没有返回cardType, 这里用houseType保险点
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
    }

    return nil;
}

+ (id)getNoResultViewModelWithExistModel:(id)existModel containerHeight:(CGFloat)containerHeight {
    NSArray *canShowNoResultList = @[
        @"FHHouseGuessYouWantTipViewModel",
        @"FHHouseSubscribeViewModel"
    ];
    
    if (existModel && [existModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        BOOL canShowNoResult = NO;
        NSString *viewModelClassName = NSStringFromClass(((NSObject *)existModel).class);
        for (NSString *className in canShowNoResultList) {
            if ([viewModelClassName isEqualToString:className]) {
                canShowNoResult = YES;
                break;
            }
        }
        
        if (!canShowNoResult) return nil;
        NSString *cellClassName = [[self supportCellStyleMap] btd_stringValueForKey:viewModelClassName];
        if (cellClassName) {
            Class cellClass = NSClassFromString(cellClassName);
            if (cellClass && [cellClass conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)] && [cellClass respondsToSelector:@selector(viewHeightWithViewModel:)]) {
                CGFloat height = [cellClass viewHeightWithViewModel:(id<FHHouseCardCellViewModelProtocol> )existModel];
                if (containerHeight > height) {
                    FHHouseNoResultViewModel *model = [[FHHouseNoResultViewModel alloc] init];
                    model.viewHeight = MAX(containerHeight - height, 300);
                    return model;
                }
            }
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
