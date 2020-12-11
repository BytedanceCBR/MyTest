//
//  FHNeighborhoodDetailRecommendSM.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendSM.h"
#import "FHHouseCardUtils.h"

@implementation FHNeighborhoodDetailRecommendSM

- (void)updateWithDataModel:(FHSearchHouseDataModel *)data {
    self.recommendCellModel = [[FHNeighborhoodDetailRecommendCellModel alloc] init];
    self.recommendCellModel.data = data;
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    for (FHSearchHouseDataItemsModel *item in data.items) {
        item.advantageDescription = nil;
        id obj = [FHHouseCardUtils getEntityFromModel:item];
        if (obj) {
            [arrayM addObject:obj];
        }
    }
    self.items = arrayM.copy;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
