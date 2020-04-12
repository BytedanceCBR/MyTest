//
//  FHFloorPanDetailModuleHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHFloorPanDetailModuleHelper.h"
#import "FHDetailBaseModel.h"
#import "FHHouseShadowImageType.h"
#import "FHDetailListSectionTitleCell.h"

@implementation FHFloorPanDetailModuleHelper
+ (NSMutableArray *)moduleClassificationMethod:(NSMutableArray *)moduleArr{
    NSArray *filterArr = [moduleArr copy];
    for (FHDetailBaseModel *model in filterArr) {
        model.shdowImageScopeType = FHHouseShdowImageScopeTypeDefault;
        if ([model isKindOfClass:[FHDetailListSectionTitleModel class]]) {
            [moduleArr removeObject:model];
        }
    }
    NSMutableArray *coreInfos = [[NSMutableArray alloc]init];
    NSMutableArray *floorPlans = [[NSMutableArray alloc]init];
    NSMutableArray *disclaimers = [[NSMutableArray alloc]init];
    
    
    [moduleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
        switch (model.houseModelType) {
            case FHFloorPanHouseModelTypeCoreInfo:
                [coreInfos addObject:obj];
                break;
            case FHFloorPlanHouseModelTypeFloorPlan:
                [floorPlans addObject:obj];
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
    if (floorPlans.count > 0) {
        [moduleItems addObject:@{@"floorPlans":floorPlans}];
    }
    if (disclaimers.count > 0) {
        [moduleItems addObject:@{@"disclaimers":disclaimers}];
    }
    [moduleItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *currentItemArr = obj[[obj allKeys][0]];
        if ([[obj allKeys] containsObject:@"floorPlans"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                model.shadowImageType = FHHouseShdowImageTypeRound;
            }];
        }
        if ([[obj allKeys] containsObject:@"coreInfos"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                if (idx == currentItemArr.count-1) {
                    model.shadowImageType = FHHouseShdowImageTypeLBR;
                }else {
                    model.shadowImageType = FHHouseShdowImageTypeLR;
                }
            }];
        }
        if ([[obj allKeys] containsObject:@"disclaimers"]) {
            //如果包含大标题的模块存在，则当前模块第一个元素和上一个模块最后一个元素的阴影不裁剪,同时在当前模块插入标题
            if (idx > 0) {
                FHDetailBaseModel *currentModel = currentItemArr[0];
                currentModel.shdowImageScopeType = FHHouseShdowImageScopeTypeTopAll;
                NSDictionary *previousItem = moduleItems[idx-1];
                NSArray *previousArr = previousItem[[previousItem allKeys][0]];
                FHDetailBaseModel *previousModel = previousArr[previousArr.count -1];
                previousModel.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
                [FHFloorPanDetailModuleHelper moduleInsertSectionTitle:moduleArr beforeModel:currentModel];
            }
        }
    }];
    
    
    return moduleArr;
}

+ (void)moduleInsertSectionTitle:(NSMutableArray *)returnArr beforeModel:(FHDetailBaseModel *) model{
    __block NSInteger insterIndex = 0 ;
    FHDetailListSectionTitleModel *titleMolde = [[FHDetailListSectionTitleModel alloc]init];
    
    [returnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:model]) {
            insterIndex = idx;
        }
    }];
    [returnArr insertObject:titleMolde atIndex:insterIndex];
}

@end
