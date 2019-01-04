//
//  FHFilterModelParser.m
//  FHHouseBase
//
//  Created by leo on 2018/12/28.
//

#import "FHFilterModelParser.h"
#import "FHEnvContext.h"

@implementation FHFilterModelParser

+(NSArray<FHFilterNodeModel*>*)getConfigByHouseType:(FHHouseType)houseType {

    FHConfigDataModel* model = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHSearchFilterConfigItem*>* config = nil;
    switch (houseType) {
        case FHHouseTypeNewHouse:
            config = model.courtFilter;
            break;
        case FHHouseTypeRentHouse:
            config = model.rentFilter;
            break;
        case FHHouseTypeNeighborhood:
            config = model.neighborhoodFilter;
            break;
        default:// FHHouseTypeSecondHandHouse
            config = model.filter;
            break;
    }
    NSArray<FHFilterNodeModel*>* filters = [self convertConfigItemsToModel:config];
    return filters;
}

+(NSArray<FHFilterNodeModel*>*)getSortConfigByHouseType:(FHHouseType)houseType {
    FHConfigDataModel* model = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHSearchFilterConfigItem*>* config = nil;
    switch (houseType) {
        case FHHouseTypeNewHouse:
            config = model.courtFilterOrder;
            break;
        case FHHouseTypeRentHouse:
            config = model.rentFilterOrder;
            break;
        case FHHouseTypeNeighborhood:
            config = model.neighborhoodFilterOrder;
            break;
        default:// FHHouseTypeSecondHandHouse
            config = model.houseFilterOrder;
            break;
    }
    NSArray<FHFilterNodeModel*>* filters = [self convertConfigItemsToModel:config];
    return filters;
}

+(NSArray<FHFilterNodeModel*>*)convertConfigItemsToModel:(NSArray<FHSearchFilterConfigItem*>*)items {
    NSMutableArray<FHFilterNodeModel*>* result = [[NSMutableArray alloc] initWithCapacity:[items count]];
    [items enumerateObjectsUsingBlock:^(FHSearchFilterConfigItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFilterNodeModel* model = [self convertConfigItemToModel:obj];
        [result addObject:model];
    }];
    return result;
}

+(FHFilterNodeModel*)convertConfigItemToModel:(FHSearchFilterConfigItem*)item {
    FHFilterNodeModel* model = [[FHFilterNodeModel alloc] init];
    model.label = item.text;
    model.rowId = item.tabId;
    model.rate = [item.rate integerValue];
    model.isSupportMulti = item.supportMulti;
    if ([item.options count] > 0) {
        model.children = [self convertConfigOptionsToModel:item.options
                                              supportMutli:nil
                                                withParent:model];
    } else {
        model.children = nil;
    }
    return model;
}


+(NSArray<FHFilterNodeModel*>*)convertConfigOptionsToModel:(NSArray<FHSearchFilterConfigOption*>*)options
                                              supportMutli:(NSNumber*)supportNutli
                                                withParent:(FHFilterNodeModel*)model {
    NSMutableArray<FHFilterNodeModel*>* result = [[NSMutableArray alloc] init];
    [options enumerateObjectsUsingBlock:^(FHSearchFilterConfigOption * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFilterNodeModel* mm = [self convertConfigOptionToModel:obj
                                                    supportMutli:supportNutli ? supportNutli : obj.supportMulti
                                                      withParent:model];
        [result addObject:mm];
    }];
    return result;
}

+(FHFilterNodeModel*)convertConfigOptionToModel:(FHSearchFilterConfigOption*)option
                                   supportMutli:(NSNumber*)supportNutli
                                     withParent:(FHFilterNodeModel*)model {
    FHFilterNodeModel* result = [[FHFilterNodeModel alloc] init];
    result.label = option.text;
    result.rankType = option.rankType;
    result.isEmpty = [option.isEmpty integerValue];
    result.isNoLimit = [option.isNoLimit integerValue];
    result.value = option.value;
    result.key = option.type;
    result.parent = model;
    result.rate = model.rate;
    result.isSupportMulti = supportNutli ? [supportNutli boolValue] : [option.supportMulti boolValue];
    result.children = [self convertConfigOptionsToModel:option.options supportMutli:supportNutli withParent:result];
    return result;
}

@end
