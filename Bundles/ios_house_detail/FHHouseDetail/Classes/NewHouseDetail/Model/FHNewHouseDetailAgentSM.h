//
//  FHNewHouseDetailAgentSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"
#import "FHDetailBaseModel.h"
#import <IGListDiffKit/IGListDiffable.h>
@class FHHouseDetailPhoneCallViewModel;
@class FHNewHouseDetailReleatorMoreCellModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailAgentSM : FHNewHouseDetailSectionModel

@property (nonatomic, copy, nullable) NSString *recommendedRealtorsTitle;    // 推荐经纪人标题文案
@property (nonatomic, copy, nullable) NSString *recommendedRealtorsSubTitle; // 推荐经纪人副标题文案
@property (nonatomic, strong, nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

//@property (nonatomic, assign) BOOL isFold; // 折叠

//@property (nonatomic, strong, nullable) FHNewHouseDetailReleatorMoreCellModel *moreModel;

@end

NS_ASSUME_NONNULL_END
