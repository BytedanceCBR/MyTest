//
//  FHNewHouseDetailRecommendSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailRecommendSM.h"

@implementation FHNewHouseDetailRecommendSM

- (instancetype)initWithRelatedModel:(FHListResultHouseModel *)model {
    if (self = [super init]) {
        FHNewHouseDetailTRelatedCollectionCellModel *relatedCellModel = [[FHNewHouseDetailTRelatedCollectionCellModel alloc] init];
        relatedCellModel.relatedModel = model.data;
        self.relatedCellModel = relatedCellModel;
    }
    return self;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
