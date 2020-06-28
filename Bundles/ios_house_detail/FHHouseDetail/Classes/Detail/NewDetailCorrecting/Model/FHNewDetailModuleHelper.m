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
        if ([model isKindOfClass:[FHDetailListSectionTitleModel class]]) {
            [moduleArr removeObject:model];
        }
    }
    NSMutableArray *coreInfos = [[NSMutableArray alloc]init];
    NSMutableArray *sales = [[NSMutableArray alloc]init];
    NSMutableArray *floorPlans = [[NSMutableArray alloc]init];
    NSMutableArray *access = [[NSMutableArray alloc]init];
    NSMutableArray *agentlist = [[NSMutableArray alloc]init];
    NSMutableArray *agentevaluationlist = [[NSMutableArray alloc]init];
    NSMutableArray *locations = [[NSMutableArray alloc]init];
    NSMutableArray *disclaimers = [[NSMutableArray alloc]init];
    NSMutableArray *related = [[NSMutableArray alloc]init];
    NSMutableArray *socialInfo = [[NSMutableArray alloc]init];
    NSMutableArray *timelines = [[NSMutableArray alloc]init];

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
            case FHHouseModelTypeNewAccess:
                            [access addObject:obj];
                            break;
            case FHHouseModelTypeNewAgentList:
                [agentlist addObject:obj];
                break;
            case FHHouseModelTypeAgentEvaluationList:
                [agentevaluationlist addObject:obj];
                break;
            case FHHouseModelTypeNewLocation:
                [locations addObject:obj];
                break;
            case FHHouseModelTypeDisclaimer:
                [disclaimers addObject:obj];
                break;
            case FHHouseModelTypeNewRelated:
                [related addObject:obj];
                break;
            case FHHouseModelTypeNewSocialInfo:
                [socialInfo addObject:obj];
                break;
                
            case FHHouseModelTypeNewTimeline:
                [timelines addObject:obj];
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
    if (access.count > 0) {
        [moduleItems addObject:@{@"access":access}];
    }
    if (agentlist.count > 0) {
        [moduleItems addObject:@{@"agentlist":agentlist}];
    }
    if (agentevaluationlist.count > 0) {
        [moduleItems addObject:@{@"agentevaluationlist":agentevaluationlist}];
    }
    if (locations.count > 0) {
        [moduleItems addObject:@{@"locations":locations}];
    }
    if (related.count > 0) {
        [moduleItems addObject:@{@"related":related}];
    }
    if (disclaimers.count > 0) {
        [moduleItems addObject:@{@"disclaimers":disclaimers}];
    }
    if (socialInfo.count > 0) {
        [moduleItems addObject:@{@"socialInfo":socialInfo}];
    }
    if (timelines.count > 0) {
        [moduleItems addObject:@{@"timelines":timelines}];
    }
    [moduleItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *currentItemArr = obj[[obj allKeys][0]];
//        单个cell模块
        if([[obj allKeys] containsObject:@"sales"] || [[obj allKeys] containsObject:@"agentlist"]|| [[obj allKeys] containsObject:@"agentevaluationlist"]|| [[obj allKeys] containsObject:@"floorPlans"] || [[obj allKeys] containsObject:@"socialInfo"] || [[obj allKeys] containsObject:@"access"]) {
            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
                model.shadowImageType = FHHouseShdowImageTypeRound;
//                model.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
            }];
        }
//        if([[obj allKeys] containsObject:@"socialInfo"]) {
//            [currentItemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                FHDetailBaseModel *model = (FHDetailBaseModel *)obj;
//                model.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
//                 model.shadowImageType = FHHouseShdowImageTypeRound;
//            }];
//        }
//        多个cell模块
        if ([[obj allKeys] containsObject:@"locations"] || [[obj allKeys] containsObject:@"related"] || [[obj allKeys] containsObject:@"timelines"]) {
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
        if ([[obj allKeys] containsObject:@"related"] || [[obj allKeys] containsObject:@"disclaimers"]) {
            //如果包含大标题的模块存在，则当前模块第一个元素和上一个模块最后一个元素的阴影不裁剪,同时在当前模块插入标题
            if (idx > 0) {
                FHDetailBaseModel *currentModel = currentItemArr[0];
                currentModel.shdowImageScopeType = FHHouseShdowImageScopeTypeTopAll;
                NSDictionary *previousItem = moduleItems[idx-1];
                NSArray *previousArr = previousItem[[previousItem allKeys][0]];
                FHDetailBaseModel *previousModel = previousArr[previousArr.count -1];
                previousModel.shdowImageScopeType = FHHouseShdowImageScopeTypeBottomAll;
                [FHNewDetailModuleHelper moduleInsertSectionTitle:moduleArr beforeModel:currentModel];
            }
        }
    }];
    return moduleArr;
}

+ (void)moduleInsertSectionTitle:(NSMutableArray *)returnArr beforeModel:(FHDetailBaseModel *) model{
    __block NSInteger insterIndex = 0 ;
    FHDetailListSectionTitleModel *titleMolde = [[FHDetailListSectionTitleModel alloc]init];
    if (model.houseModelType == FHHouseModelTypeNewRelated) {
        titleMolde.title = @"周边新盘";
    }
    [returnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:model]) {
            insterIndex = idx;
        }
    }];
    [returnArr insertObject:titleMolde atIndex:insterIndex];
}

@end
