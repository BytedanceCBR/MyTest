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
}

@end
