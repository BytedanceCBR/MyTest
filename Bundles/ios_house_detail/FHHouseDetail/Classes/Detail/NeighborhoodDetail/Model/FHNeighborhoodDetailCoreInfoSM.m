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

    if (model.data.baseInfo.count > 0) {
        FHNeighborhoodDetailPropertyInfoModel *propertyInfoModel = [[FHNeighborhoodDetailPropertyInfoModel alloc] init];
        propertyInfoModel.baseInfo = model.data.baseInfo;
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
