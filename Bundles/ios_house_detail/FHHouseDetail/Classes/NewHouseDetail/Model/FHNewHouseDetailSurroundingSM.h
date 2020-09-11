//
//  FHNewHouseDetailSurroundingSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailSurroundingCellModel;
@class FHNewHouseDetailMapCellModel;

@interface FHNewHouseDetailSurroundingSM : FHNewHouseDetailSectionModel

@property (nonatomic, strong) FHNewHouseDetailSurroundingCellModel *surroundingCellModel;

@property (nonatomic, strong) FHNewHouseDetailMapCellModel *mapCellModel;

@end

NS_ASSUME_NONNULL_END
