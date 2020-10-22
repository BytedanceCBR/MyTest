//
//  FHNeighborhoodDetailAgentSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailAgentSM.h"



@implementation FHNeighborhoodDetailAgentSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    self.recommendedRealtorsTitle = model.data.recommendedRealtorsTitle;
    self.recommendedRealtors = model.data.recommendedRealtors;
    self.associateInfo = model.data.recommendRealtorsAssociateInfo;
    self.isFold = YES;
    self.moreModel = [[FHNeighborhoodDetailReleatorMoreCellModel alloc] init];
}

- (nonnull id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object {
//    FHNeighborhoodDetailAgentSM *agentSectionModel = (FHNeighborhoodDetailAgentSM *)object;
    return self == object;
}


@end
