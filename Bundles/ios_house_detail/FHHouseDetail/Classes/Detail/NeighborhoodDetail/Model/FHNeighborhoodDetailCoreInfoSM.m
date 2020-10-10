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
    houseTitleModel.titleStr = model.data.name;
    houseTitleModel.address = model.data.neighborhoodInfo.address;
    self.titleCellModel = houseTitleModel;
    [items addObject:self.titleCellModel];
    
    FHNeighborhoodDetailSubMessageModel *subMessageModel = [[FHNeighborhoodDetailSubMessageModel alloc] init];
    subMessageModel.neighborhoodInfo = model.data.neighborhoodInfo;
    self.subMessageModel = subMessageModel;
    [items addObject:self.subMessageModel];
    
    
    self.items = items.copy;
}
- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}


@end
