//
//  FHNewHouseDetailRecommendSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"
#import "FHNewHouseDetailRelatedCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailRecommendSM : FHNewHouseDetailSectionModel

- (void)updateRelatedModel:(FHListResultHouseModel *)model;

@property (nonatomic, strong, nullable) FHNewHouseDetailTRelatedCollectionCellModel *relatedCellModel;
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
