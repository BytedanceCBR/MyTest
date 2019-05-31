//
//  FHMineDefine.h
//  Pods
//
//  Created by 谢思铭 on 2019/5/23.
//

#ifndef FHMineDefine_h
#define FHMineDefine_h

typedef NS_ENUM(NSInteger, FHMineModuleType)
{
    FHMineModuleTypeHouseFocus = 0,
    FHMineModuleTypeService,
    FHMineModuleTypeTool,
};

typedef NS_ENUM(NSInteger, FHMineItemType)
{
    FHMineItemTypeHouseNew = 1,
    FHMineItemTypeHouseSecond,
    FHMineItemTypeHouseRent,
    FHMineItemTypeHouseNeighborhood,
    FHMineItemTypeFavorite,
    FHMineItemTypeSugSubscribe,
    FHMineItemTypeFeedback = 8,
    FHMineItemTypePriceValuation,
    FHMineItemTypeHouseLoanCalculation,
    FHMineItemTypeNeighborhoodDeal,
};

#endif /* FHMineDefine_h */
