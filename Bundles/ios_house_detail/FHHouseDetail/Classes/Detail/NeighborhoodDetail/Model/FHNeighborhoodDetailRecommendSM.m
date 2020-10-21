//
//  FHNeighborhoodDetailRecommendSM.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendSM.h"

@implementation FHNeighborhoodDetailRecommendSM

- (void)updateWithDataModel:(FHSearchHouseDataModel *)data {
    self.recommendCellModel = [[FHNeighborhoodDetailRecommendCellModel alloc] init];
    self.recommendCellModel.data = data;
    self.items = data.items;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
