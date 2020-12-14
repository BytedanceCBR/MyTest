//
//  FHNeighborhoodDetailCoreInfoSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailCoreInfoSM.h"
#import <ByteDanceKit/ByteDanceKit.h>


@implementation FHNeighborhoodDetailCoreInfoSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    
    NSMutableArray *items = [NSMutableArray array];
    FHNeighborhoodDetailHeaderTitleModel *houseTitleModel = [[FHNeighborhoodDetailHeaderTitleModel alloc] init];
    houseTitleModel.titleStr = model.data.name;
    houseTitleModel.address = model.data.neighborhoodInfo.address;
    houseTitleModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
    houseTitleModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
    houseTitleModel.mapCentertitle = model.data.neighborhoodInfo.name;
    houseTitleModel.baiduPanoramaUrl = model.data.neighborhoodInfo.baiduPanoramaUrl;
    houseTitleModel.tradeAreaName = model.data.neighborhoodInfo.tradeAreaName;
    houseTitleModel.areaName = model.data.neighborhoodInfo.areaName;
    houseTitleModel.districtName = model.data.neighborhoodInfo.districtName;
    self.titleCellModel = houseTitleModel;
    [items addObject:self.titleCellModel];
    
    if (model.data.coreInfo.count == 3) {
        FHNeighborhoodDetailSubMessageModel *subMessageModel = [[FHNeighborhoodDetailSubMessageModel alloc] init];
        subMessageModel.perSquareMetre = [((FHDetailNeighborhoodDataCoreInfoModel *)model.data.coreInfo[0]).val stringByAppendingFormat:@" %@",((FHDetailNeighborhoodDataCoreInfoModel *)model.data.coreInfo[0]).unit];
        subMessageModel.monthUp = ((FHDetailNeighborhoodDataCoreInfoModel *)model.data.coreInfo[1]).value ?: @"0";
        subMessageModel.subTitleText = ((FHDetailNeighborhoodDataCoreInfoModel *)model.data.coreInfo[2]).value ?: @"上个月参考均价";
        
        subMessageModel.onSale = model.data.statsMinfo.onSale.val ?:@"暂无数据" ;
        subMessageModel.sold = model.data.statsMinfo.sold.val ?: @"暂无数据";
        subMessageModel.soldUrl = model.data.statsMinfo.sold.openUrl;
        self.subMessageModel = subMessageModel;
        [items addObject:self.subMessageModel];
    }
    
//    if ((model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0 )|| model.data.neighborhoodInfo.baiduPanoramaUrl.length > 0) {
//        FHNeighborhoodDetailQuickEntryModel *quickEntryModel = [[FHNeighborhoodDetailQuickEntryModel alloc] init];
//        quickEntryModel.baiduPanoramaUrl = model.data.neighborhoodInfo.baiduPanoramaUrl;
//        quickEntryModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
//        quickEntryModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
//        quickEntryModel.mapCentertitle = model.data.neighborhoodInfo.name;
//        [quickEntryModel clearUpQuickEntryNames];
//        self.quickEntryModel = quickEntryModel;
//        [items addObject:self.quickEntryModel];
//    }
    

//    NSMutableArray *mArr = [NSMutableArray array];
//    [model.data.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (obj.value.length > 0 && ![obj.value isEqualToString:@"-"]) {
//                [mArr addObject:obj];
//            }
//    }];
//    
//    if (mArr.count > 0) {
//        FHNeighborhoodDetailPropertyInfoModel *propertyInfoModel = [[FHNeighborhoodDetailPropertyInfoModel alloc] init];
//        propertyInfoModel.baseInfo = mArr.copy;
//        propertyInfoModel.baseInfoFoldCount = model.data.baseInfoFoldCount;
//        self.propertyInfoModel = propertyInfoModel;
//        [items addObject:self.propertyInfoModel];
//    }
    
    

    self.items = items.copy;
}
- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    
    return self == object;
}

@end
