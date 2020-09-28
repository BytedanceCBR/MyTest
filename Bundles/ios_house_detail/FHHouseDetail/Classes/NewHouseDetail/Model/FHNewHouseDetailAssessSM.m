//
//  FHNewHouseDetailAssessSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAssessSM.h"
#import "FHNewHouseDetailAssessCollectionCell.h"

@implementation FHNewHouseDetailAssessSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    [super updateDetailModel:model];
    
    FHNewHouseDetailAssessCellModel *cellModel = [[FHNewHouseDetailAssessCellModel alloc] init];
    cellModel.strategy = model.data.strategy;
    self.assessCellModel = cellModel;
}

- (void)updateDetailTracer:(NSDictionary *)tracerDict {
    self.assessCellModel.tracerDic = tracerDict;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}


@end
