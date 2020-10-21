//
//  FHNewHouseDetailAgentSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAgentSM.h"
#import "FHNewHouseDetailReleatorMoreCell.h"
#import "FHNewHouseDetailReleatorCollectionCell.h"
#import "FHHouseDetailPhoneCallViewModel.h"

@implementation FHNewHouseDetailAgentSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    
    self.recommendedRealtorsTitle = model.data.recommendedRealtorsTitle;
    self.recommendedRealtorsSubTitle = model.data.recommendedRealtorsSubTitle;
    self.recommendedRealtors = model.data.recommendedRealtors;
    self.associateInfo = model.data.recommendRealtorsAssociateInfo;

    self.isFold = YES;
    
    self.moreModel = [[FHNewHouseDetailReleatorMoreCellModel alloc] init];
    /******* 这里的 逻辑   ********/
//    self.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNewHouse houseId:model.da];
//    NSMutableDictionary *paramsDict = @{}.mutableCopy;
//    if (self.detailTracerDic) {
//        [paramsDict addEntriesFromDictionary:self.detailTracerDic];
//    }
//    paramsDict[@"page_type"] = [self pageTypeString];
//    agentListModel.phoneCallViewModel.tracerDict = paramsDict;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
