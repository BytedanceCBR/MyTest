//
//  FHNeighborhoodDetailSurroundingNeighborSM.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/11.
//

#import "FHNeighborhoodDetailSurroundingNeighborSM.h"

@implementation FHNeighborhoodDetailSurroundingNeighborSM

- (void)updateWithDataModel:(FHDetailRelatedNeighborhoodResponseDataModel *)data {
    self.titleName = [NSString stringWithFormat:@"周边小区(%@)",data.total];
    self.model = data;
    self.moreTitle = @"查看全部";
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
