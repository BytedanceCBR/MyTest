//
//  FHNeighborhoodDetailStrategySM.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailStrategySM.h"
#import "FHFeedUGCCellModel.h"

@implementation FHNeighborhoodDetailStrategySM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    NSMutableArray *itemArray = [NSMutableArray array];
    FHDetailNeighborhoodDataStrategyModel *strategy = model.data.strategy;
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]init];
    if (strategy.article) {
        [dataDic addEntriesFromDictionary:@{@"article":strategy.article}];
    }
    if (strategy.score) {
        [dataDic  addEntriesFromDictionary:@{@"score":strategy.score}];
    }
    
    if (strategy.compare) {
        [dataDic addEntriesFromDictionary:@{@"compare":strategy.compare}];
    }
    [itemArray addObject:dataDic];
    self.items = [itemArray copy];
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
