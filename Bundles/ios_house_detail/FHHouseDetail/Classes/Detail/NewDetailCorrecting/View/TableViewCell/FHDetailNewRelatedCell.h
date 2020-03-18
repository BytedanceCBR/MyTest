//
//  FHDetailNewRelatedCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/16.
//

#import "FHDetailBaseCell.h"
#import "FHHouseBase/FHHouseListBaseItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@class FHDetailRelatedCourtDataModel;

// 周边新盘
@interface FHDetailNewRelatedCell : FHDetailBaseCell <FHDetailScrollViewDidScrollProtocol>

@end

@interface FHDetailNewRelatedCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHHouseListDataModel *relatedHouseData;

@end

NS_ASSUME_NONNULL_END
