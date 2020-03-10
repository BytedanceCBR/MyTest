//
//  FHNewDetailModuleHelper.m
//  FHHouseDetail
//
//  Created by liuyu on 2019/12/5.
//

#import "FHNewDetailModuleHelper.h"
#import "FHDetailBaseModel.h"
#import "FHHouseShadowImageType.h"
#import "FHDetailListSectionTitleCell.h"

@implementation FHNewDetailModuleHelper

+ (NSMutableArray *)moduleClassificationMethod:(NSMutableArray *)moduleArr{
    NSArray *filterArr = [moduleArr copy];
    for (FHDetailBaseModel *model in filterArr) {
        model.shdowImageScopeType = FHHouseShdowImageScopeTypeDefault;
//        if ([model isKindOfClass:[FHDetailListSectionTitleModel class]]) {
//            [moduleArr removeObject:model];
//        }
    }
    NSMutableArray *coreInfos = [[NSMutableArray alloc]init];
    NSMutableArray *sales = [[NSMutableArray alloc]init];
    NSMutableArray *floorPlans = [[NSMutableArray alloc]init];
    NSMutableArray *agentlist = [[NSMutableArray alloc]init];
    NSMutableArray *locations = [[NSMutableArray alloc]init];
    NSMutableArray *disclaimers = [[NSMutableArray alloc]init];

    [moduleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
        switch (model.houseModelType) {
            case FHHouseModelTypeNewCoreInfo:
                [coreInfos addObject:obj];
                break;
            case FHHouseModelTypeNewSales:
                [sales addObject:obj];
                break;
            case FHHouseModelTypeNewFloorPlan:
                [floorPlans addObject:obj];
                break;
            case FHHouseModelTypeNewAgentList:
                [agentlist addObject:obj];
                break;
            case FHHouseModelTypeNewLocation:
                [locations addObject:obj];
                break;
            case FHHouseModelTypeDisclaimer:
                [disclaimers addObject:obj];
                break;
            default:
                break;
        }
    }];
    NSMutableArray *moduleItems = [[NSMutableArray alloc]init];
    if (coreInfos.count > 0) {
        [moduleItems addObject:@{@"coreInfos":coreInfos}];
    }
    if (sales.count > 0) {
        [moduleItems addObject:@{@"sales":sales}];
    }
    if (floorPlans.count > 0) {
        [moduleItems addObject:@{@"floorPlans":floorPlans}];
    }
    if (agentlist.count > 0) {
        [moduleItems addObject:@{@"agentlist":agentlist}];
    }
    if (locations.count > 0) {
        [moduleItems addObject:@{@"locations":locations}];
    }
    if (disclaimers.count > 0) {
        [moduleItems addObject:@{@"disclaimers":disclaimers}];
    }
    [moduleItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *currentItemArr = obj[[obj allKeys][0]];
//        单个cell模块
        if([[obj allKeys] containsObject:@"sales"] || [[obj allKeys] containsObject:@"agentlist"]|| [[obj allKeys] containsObject:@"floorPlans"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                model.shadowImageType = FHHouseShdowImageTypeRound;;
            }];
        }
//        if([[obj allKeys] containsObject:@"locations"]) {
//            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
//                model.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
//                 model.shadowImageType = FHHouseShdowImageTypeRound;
//            }];
//        }
//        多个cell模块
        if ([[obj allKeys] containsObject:@"locations"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                if (idx == currentItemArr.count-1 && currentItemArr.count != 1) {
                    model.shadowImageType = FHHouseShdowImageTypeLBR;
                }else if(idx == 0 && currentItemArr.count == 1)  {
                    model.shadowImageType = FHHouseShdowImageTypeRound;
                }else if (idx == 0 && currentItemArr.count != 1) {
                    model.shadowImageType = FHHouseShdowImageTypeLTR;
                }else {
                    model.shadowImageType = FHHouseShdowImageTypeLR;
                }
            }];
        }
        if ([[obj allKeys] containsObject:@"coreInfos"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                if (idx == currentItemArr.count-1 && currentItemArr.count != 1) {
                    model.shadowImageType = FHHouseShdowImageTypeLBR;
                }else {
                    model.shadowImageType = FHHouseShdowImageTypeLR;
                }
            }];
        }
    }];
    return moduleArr;
}

@end
