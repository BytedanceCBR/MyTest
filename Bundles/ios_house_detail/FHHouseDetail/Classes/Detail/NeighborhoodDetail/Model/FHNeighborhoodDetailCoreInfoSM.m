//
//  FHNeighborhoodDetailCoreInfoSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailCoreInfoSM.h"



@implementation FHNeighborhoodDetailCoreInfoSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    
    NSMutableArray *items = [NSMutableArray array];
    FHNeighborhoodDetailHeaderTitleModel *houseTitleModel = [[FHNeighborhoodDetailHeaderTitleModel alloc] init];
    if (model.data.name.length || model.data.neighborhoodInfo.address.length) {
        houseTitleModel.titleStr = model.data.name;
        houseTitleModel.address = model.data.neighborhoodInfo.address;
        self.titleCellModel = houseTitleModel;
        [items addObject:self.titleCellModel];
    }
    
    if (model.data.neighborhoodInfo.id.length > 0) {
        FHNeighborhoodDetailSubMessageModel *subMessageModel = [[FHNeighborhoodDetailSubMessageModel alloc] init];
        subMessageModel.neighborhoodInfo = model.data.neighborhoodInfo;
        self.subMessageModel = subMessageModel;
        [items addObject:self.subMessageModel];
    }
    
    if ((model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0 )|| model.data.neighborhoodInfo.baiduPanoramaUrl.length > 0) {
        FHNeighborhoodDetailQuickEntryModel *quickEntryModel = [[FHNeighborhoodDetailQuickEntryModel alloc] init];
        quickEntryModel.baiduPanoramaUrl = model.data.neighborhoodInfo.baiduPanoramaUrl;
        quickEntryModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        quickEntryModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
        quickEntryModel.mapCentertitle = model.data.neighborhoodInfo.name;
        [quickEntryModel clearUpQuickEntryNames];
        self.quickEntryModel = quickEntryModel;
        [items addObject:self.quickEntryModel];
    }
    

    NSMutableArray *mArr = [NSMutableArray array];
    [model.data.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.value.length > 0 && ![obj.value isEqualToString:@"-"]) {
                [mArr addObject:obj];
            }
    }];
    
    if (mArr.count > 0) {
        FHNeighborhoodDetailPropertyInfoModel *propertyInfoModel = [[FHNeighborhoodDetailPropertyInfoModel alloc] init];
        propertyInfoModel.baseInfo = mArr.copy;
        propertyInfoModel.baseInfoFoldCount = model.data.baseInfoFoldCount;
        self.propertyInfoModel = propertyInfoModel;
        [items addObject:self.propertyInfoModel];
    }
    
    

    self.items = items.copy;
}
- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

- (void)setIsFold:(BOOL)isFold {
    if (self.propertyInfoModel && [self.propertyInfoModel isKindOfClass:[FHNeighborhoodDetailPropertyInfoModel class]]) {
        self.propertyInfoModel.isFold = isFold;
    }
}

- (BOOL)isFold {
    if (self.propertyInfoModel && [self.propertyInfoModel isKindOfClass:[FHNeighborhoodDetailPropertyInfoModel class]]) {
        return self.propertyInfoModel.isFold;
    }
    return NO;
}

@end
