//
//  FHNeighborhoodDetailAgentSM.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailReleatorCollectionCell.h"
#import "FHNeighborhoodDetailReleatorMoreCell.h"
#import <IGListDiffKit/IGListDiffable.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailAgentSM : FHNeighborhoodDetailSectionModel

@property (nonatomic, copy, nullable) NSString *recommendedRealtorsTitle;    // 推荐经纪人标题文案
@property (nonatomic, strong, nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@property (nonatomic, assign) BOOL isFold; // 折叠
@property (nonatomic, strong, nullable) FHNeighborhoodDetailReleatorMoreCellModel *moreModel;

@end

NS_ASSUME_NONNULL_END
