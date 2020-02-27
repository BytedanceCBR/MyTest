//
//  FHOldDetailModuleHelper.m
//  FHHouseDetail
//
//  Created by liuyu on 2019/12/5.
//

#import "FHNeighborhoodDetailModuleHelper.h"
#import "FHDetailBaseModel.h"
#import "FHHouseShadowImageType.h"
#import "FHDetailListSectionTitleCell.h"

@implementation FHNeighborhoodDetailModuleHelper

+ (NSMutableArray *)moduleClassificationMethod:(NSMutableArray *)moduleArr{
    NSArray *filterArr = [moduleArr copy];
    for (FHDetailBaseModel *model in filterArr) {
        model.shdowImageScopeType = FHHouseShdowImageScopeTypeDefault;
        if ([model isKindOfClass:[FHDetailListSectionTitleModel class]]) {
            [moduleArr removeObject:model];
        }
    }
    
    NSMutableArray *coreInfos = [[NSMutableArray alloc]init];
    NSMutableArray *agentlist = [[NSMutableArray alloc]init];
    NSMutableArray *locationPeripherys = [[NSMutableArray alloc]init];
    NSMutableArray *qas = [[NSMutableArray alloc]init];
    NSMutableArray *plotsSlods = [[NSMutableArray alloc]init];
    NSMutableArray *peripherys = [[NSMutableArray alloc]init];
    [moduleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
        switch (model.houseModelType) {
            case FHPlotHouseModelTypeCoreInfo:
                [coreInfos addObject:obj];
                break;
            case FHPlotHouseModelTypeAgentlist:
                [agentlist addObject:obj];
                break;
            case FHPlotHouseModelTypeLocationPeriphery:
                [locationPeripherys addObject:obj];
                break;
            case FHPlotHouseModelTypeNeighborhoodQA:
                [qas addObject:obj];
                break;
            case FHPlotHouseModelTypeSold:
                [plotsSlods addObject:obj];
                break;
            case FHPlotHouseModelTypePeriphery:
                [peripherys addObject:obj];
                break;
            default:
                break;
        }
    }];
    NSMutableArray *moduleItems = [[NSMutableArray alloc]init];
    if (coreInfos.count > 0) {
        [moduleItems addObject:@{@"coreInfos":coreInfos}];
    }
    if (qas.count > 0) {
        [moduleItems addObject:@{@"qas":qas}];
    }
    if (agentlist.count > 0) {
        [moduleItems addObject:@{@"agentlist":agentlist}];
    }
    if (locationPeripherys.count > 0) {
        [moduleItems addObject:@{@"locationPeripherys":locationPeripherys}];
    }
    if (plotsSlods.count > 0) {
        [moduleItems addObject:@{@"plotsSlods":plotsSlods}];
    }
    if (peripherys.count > 0) {
        [moduleItems addObject:@{@"peripherys":peripherys}];
    }
    [moduleItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *currentItemArr = obj[[obj allKeys][0]];
//        单个cell模块
        if([[obj allKeys] containsObject:@"qas"] || [[obj allKeys] containsObject:@"agentlist"]|| [[obj allKeys] containsObject:@"peripherys"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                model.shadowImageType = FHHouseShdowImageTypeRound;;
            }];
        }
        if([[obj allKeys] containsObject:@"qas"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                model.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
                 model.shadowImageType = FHHouseShdowImageTypeRound;
            }];
        }
//        多个cell模块
        if ([[obj allKeys] containsObject:@"locationPeripherys"] || [[obj allKeys] containsObject:@"plots"]|| [[obj allKeys] containsObject:@"housingEvaluation"]|| [[obj allKeys] containsObject:@"plotsSlods"]) {
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
        //加载周边时
//            if ([[obj allKeys] containsObject:@"locationPeripherys"] || [[obj allKeys] containsObject:@"housingEvaluation"] || [[obj allKeys] containsObject:@"disclaimers"]) {
//                //如果包含大标题的模块存在，则当前模块第一个元素和上一个模块最后一个元素的阴影不裁剪,同时在当前模块插入标题
//                if (idx > 0) {
//                    FHDetailBaseModel *currentModel = currentItemArr[0];
//                    currentModel.shdowImageScopeType = FHHouseShdowImageScopeTypeTopAll;
//                    NSDictionary *previousItem = moduleItems[idx-1];
//                    NSArray *previousArr = previousItem[[previousItem allKeys][0]];
//                    FHDetailBaseModel *previousModel = previousArr[previousArr.count -1];
//                    previousModel.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
//                    [FHNeighborhoodDetailModuleHelper moduleInsertSectionTitle:moduleArr beforeModel:currentModel];
//                }
//            }
    }];
    return moduleArr;
}
//+ (void)moduleInsertSectionTitle:(NSMutableArray *)returnArr beforeModel:(FHDetailBaseModel *) model{
//    __block NSInteger insterIndex = 0 ;
//    FHDetailListSectionTitleModel *titleMolde = [[FHDetailListSectionTitleModel alloc]init];
//    if (model.houseModelType == FHHouseModelTypeLocationPeriphery) {
//        titleMolde.title = @"位置及周边配套";
//    }
//    if (model.houseModelType == FHHouseModelTypeHousingEvaluation) {
//        titleMolde.title = @"房源评价动态";
//    }
//    [returnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isEqual:model]) {
//            insterIndex = idx;
//        }
//    }];
//    [returnArr insertObject:titleMolde atIndex:insterIndex];
//}

@end
