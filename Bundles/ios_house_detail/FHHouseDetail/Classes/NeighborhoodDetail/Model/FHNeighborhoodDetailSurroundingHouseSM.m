//
//  FHNeighborhoodDetailSurroundingHouse.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/12/10.
//

#import "FHNeighborhoodDetailSurroundingHouseSM.h"
#import "FHHouseCardUtils.h"

@implementation FHNeighborhoodDetailSurroundingHouseSM

- (void)updateWithDataModel:(FHSearchHouseDataModel *)data {
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    for (id item in data.items) {
        id obj = [FHHouseCardUtils getEntityFromModel:item];
        if (obj) {
            [arrayM addObject:obj];
        }
    }
    self.items = arrayM.copy;
    self.moreTitle = [NSString stringWithFormat:@"查看在售%@套房源", data.total];
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
