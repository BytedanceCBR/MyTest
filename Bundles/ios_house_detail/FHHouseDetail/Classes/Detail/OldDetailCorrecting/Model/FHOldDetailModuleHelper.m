//
//  FHOldDetailModuleHelper.m
//  FHHouseDetail
//
//  Created by liuyu on 2019/12/5.
//

#import "FHOldDetailModuleHelper.h"
#import "FHDetailBaseModel.h"
#import "FHHouseShadowImageType.h"
#import "FHDetailListSectionTitleCell.h"

@implementation FHOldDetailModuleHelper

+ (NSMutableArray *)moduleClassificationMethod:(NSMutableArray *)moduleArr{
    NSArray *filterArr = [moduleArr copy];
    for (FHDetailBaseModel *model in filterArr) {
        model.shdowImageScopeType = FHHouseShdowImageScopeTypeDefault;
        if ([model isKindOfClass:[FHDetailListSectionTitleModel class]]) {
            [moduleArr removeObject:model];
        }
    }
    
    NSMutableArray *coreInfos = [[NSMutableArray alloc]init];
    NSMutableArray *subscribes = [[NSMutableArray alloc]init];
    NSMutableArray *outlineInfo = [[NSMutableArray alloc]init];
    NSMutableArray *billBoard = [[NSMutableArray alloc]init];
    NSMutableArray *housingEvaluation = [[NSMutableArray alloc]init];
    NSMutableArray *agentlist = [[NSMutableArray alloc]init];
    NSMutableArray *locationPeripherys = [[NSMutableArray alloc]init];
    NSMutableArray *tips = [[NSMutableArray alloc]init];
    NSMutableArray *plots = [[NSMutableArray alloc]init];
    NSMutableArray *peripherys = [[NSMutableArray alloc]init];
    NSMutableArray *disclaimers = [[NSMutableArray alloc]init];
    [moduleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
        switch (model.houseModelType) {
            case FHHouseModelTypeCoreInfo:
                [coreInfos addObject:obj];
                break;
            case FHHouseModelTypeSubscribe:
                [subscribes addObject:obj];
                break;
            case FHHouseModelTypeOutlineInfo:
                [outlineInfo addObject:obj];
                break;
            case FHHouseModelTypeBillBoard:
                [billBoard addObject:obj];
                break;
            case FHHouseModelTypeHousingEvaluation:
                [housingEvaluation addObject:obj];
                break;
            case FHHouseModelTypeAgentlist:
                [agentlist addObject:obj];
                break;
            case FHHouseModelTypeLocationPeriphery:
                [locationPeripherys addObject:obj];
                break;
            case FHHouseModelTypeTips:
                [tips addObject:obj];
                break;
            case FHHouseModelTypePlot:
                [plots addObject:obj];
                break;
            case FHHouseModelTypePeriphery:
                [peripherys addObject:obj];
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
    if (subscribes.count > 0) {
        [moduleItems addObject:@{@"subscribes":subscribes}];
    }
    if (outlineInfo.count > 0) {
        [moduleItems addObject:@{@"outlineInfo":outlineInfo}];
    }
    if (billBoard.count > 0) {
        [moduleItems addObject:@{@"billBoard":billBoard}];
    }
    if (agentlist.count > 0) {
        [moduleItems addObject:@{@"agentlist":agentlist}];
    }
    if (housingEvaluation.count > 0) {
        [moduleItems addObject:@{@"housingEvaluation":housingEvaluation}];
    }
    if (locationPeripherys.count > 0) {
        [moduleItems addObject:@{@"locationPeripherys":locationPeripherys}];
    }
    if (tips.count > 0) {
        [moduleItems addObject:@{@"tips":tips}];
    }
    if (plots.count > 0) {
        [moduleItems addObject:@{@"plots":plots}];
    }
    if (peripherys.count > 0) {
        [moduleItems addObject:@{@"peripherys":peripherys}];
    }
    if (disclaimers.count > 0) {
        [moduleItems addObject:@{@"disclaimers":disclaimers}];
    }
    [moduleItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *currentItemArr = obj[[obj allKeys][0]];
//        单个cell模块
        if([[obj allKeys] containsObject:@"subscribes"] || [[obj allKeys] containsObject:@"outlineInfo"]
           || [[obj allKeys] containsObject:@"billBoard"] || [[obj allKeys] containsObject:@"agentlist"]
           || [[obj allKeys] containsObject:@"tips"] || [[obj allKeys] containsObject:@"peripherys"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                model.shadowImageType = FHHouseShdowImageTypeRound;;
            }];
        }
//        多个cell模块
        if ([[obj allKeys] containsObject:@"locationPeripherys"] || [[obj allKeys] containsObject:@"plots"]|| [[obj allKeys] containsObject:@"housingEvaluation"]) {
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
        if ([[obj allKeys] containsObject:@"locationPeripherys"] || [[obj allKeys] containsObject:@"housingEvaluation"] || [[obj allKeys] containsObject:@"disclaimers"]) {
            //如果包含大标题的模块存在，则当前模块第一个元素和上一个模块最后一个元素的阴影不裁剪,同时在当前模块插入标题
            if (idx > 0) {
                FHDetailBaseModel *currentModel = currentItemArr[0];
                currentModel.shdowImageScopeType = FHHouseShdowImageScopeTypeTopAll;
                NSDictionary *previousItem = moduleItems[idx-1];
                NSArray *previousArr = previousItem[[previousItem allKeys][0]];
                FHDetailBaseModel *previousModel = previousArr[previousArr.count -1];
                previousModel.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
                [FHOldDetailModuleHelper moduleInsertSectionTitle:moduleArr beforeModel:currentModel];
            }
        }
    }];
    return moduleArr;
}
+ (void)moduleInsertSectionTitle:(NSMutableArray *)returnArr beforeModel:(FHDetailBaseModel *) model{
    __block NSInteger insterIndex = 0 ;
    FHDetailListSectionTitleModel *titleMolde = [[FHDetailListSectionTitleModel alloc]init];
    if (model.houseModelType == FHHouseModelTypeLocationPeriphery) {
        titleMolde.title = @"位置及周边配套";
    }
    if (model.houseModelType == FHHouseModelTypeHousingEvaluation) {
        titleMolde.title = @"房源评价动态";
    }
    [returnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:model]) {
            insterIndex = idx;
        }
    }];
    [returnArr insertObject:titleMolde atIndex:insterIndex];
}

@end
